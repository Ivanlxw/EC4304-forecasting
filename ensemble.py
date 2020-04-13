import warnings
warnings.filterwarnings("ignore")

from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.linear_model import Lasso
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics import mean_squared_error, accuracy_score
from sklearn.model_selection import GridSearchCV

import data_prep
import eval_utils
from eval_utils import build_and_model_VAR

full_industries = ["Pharm", "Semicon", "Industrial", "Energy", "Financial", "Tech", "Utilities", "Consumer"]

def encode_labels(x):
    if x > 2:
        return 2
    elif x < -2:
        return 0
    else:
        return 1

def iterative_pred(model,test_df, iterative:bool =False):
    OOB_data = test_df.copy()
    # print(OOB_data.shape)
    preds = []
    if iterative:  ## iterative
        idx = 0
        while idx < len(OOB_data):
            temp_d = OOB_data.iloc[idx:idx+1]
            if len(preds) >= 1:
                temp_d["Adj Close_SNP500_L1"] = preds[-1]
            preds.append(model.predict(temp_d).tolist()[0])
            idx += 1
        return preds
    else:
        return model.predict(OOB_data)

if __name__ == '__main__':
    full_df, idx_psuedo_OOB, idx_OOB = data_prep.split_data("./data/output.csv")
    df = full_df[:idx_psuedo_OOB]

    df = build_and_model_VAR(df, full_industries).dropna()

    psuedo_OOB = full_df.iloc[idx_psuedo_OOB-1:idx_OOB+1]
    psuedo_OOB = build_and_model_VAR(psuedo_OOB,[]).dropna()

    df['target'] = df['Adj Close_SNP500'].apply(encode_labels)
    lags= 5

    train_df = df.drop("target", axis=1)
    X_lagged = data_prep.get_lagged_df(train_df, col2lag=train_df.columns, n=lags)

    full_df = build_and_model_VAR(full_df, full_industries).dropna()
    full_lagged = data_prep.get_lagged_df(full_df, col2lag=full_df.columns, n=lags)
    lagged_OOB = full_lagged.iloc[idx_psuedo_OOB-lags:idx_OOB-lags]
    
    regress = True
    if regress:
        y = df['Adj Close_SNP500'][lags:]
        # print(y.head())
        # print(X_lagged.head())
        ## TODO: choosing best
        lasso = Lasso(warm_start=True)
        reg = RandomForestRegressor(n_estimators=100, min_impurity_split=2, min_samples_leaf=1)
        # params = {
        #     "n_estimators": [100],
        #     "min_samples_split" : [2, 5, 10],
        #     "min_samples_leaf" : [1, 4, 10],
        # }
        # reg = GridSearchCV(reg, params, verbose=2, n_jobs=4)
        # print(reg.get_params())
        reg.fit(X_lagged,y)
        lasso.fit(X_lagged,y)

        print(iterative_pred(lasso, lagged_OOB))
        print("lasso mse: ", mean_squared_error(iterative_pred(lasso, lagged_OOB, iterative=True), full_df["Adj Close_SNP500"].iloc[idx_psuedo_OOB-lags:idx_OOB-lags]))

        y_pred = iterative_pred(reg, lagged_OOB, iterative=True)
        print(y_pred)
        print("RFR mse: ", mean_squared_error(y_pred, full_df["Adj Close_SNP500"].iloc[idx_psuedo_OOB-lags:idx_OOB-lags]))

    else:
        ## put target as a label.
        mlb = MultiLabelBinarizer()
        y = df['target'][lags:]
        # params = {
        #     "n_estimators": [100, 200, 400],
        #     "min_samples_split": [2, 5, 10],
        # }
        clf = RandomForestClassifier(min_samples_split=2, n_estimators=100)
        # clf = GridSearchCV(clf, params, verbose=2)
        # print(clf.get_params())
        clf.fit(X_lagged, y)
        full_df["target"] = full_df['Adj Close_SNP500'].apply(encode_labels)
        y_true = full_df["target"].iloc[idx_psuedo_OOB-lags:idx_OOB-lags]
        y_preds = iterative_pred(clf, lagged_OOB, iterative=True)
        print(accuracy_score(y_preds, y_true))



