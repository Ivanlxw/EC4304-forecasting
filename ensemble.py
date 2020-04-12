from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.preprocessing import MultiLabelBinarizer
from sklearn.metrics import mean_squared_error

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

def iterative_pred(model, OOB_data, steps:int =1):
    preds = []
    for i in range(1, steps+1):
        temp_data = OOB_data.iloc[i].reshape(1,-1)
        if i > 1:
            temp_data['Adj Close_SNP500'] =preds[-1]
        print(temp_data)
        print(model.predict(temp_data))

if __name__ == '__main__':
    full_df, idx_psuedo_OOB, idx_OOB = data_prep.split_data("./data/output.csv")
    df = full_df[:idx_psuedo_OOB]

    df = build_and_model_VAR(df, full_industries).dropna()

    psuedo_OOB = full_df.iloc[idx_psuedo_OOB-1:idx_OOB+1]
    psuedo_OOB = build_and_model_VAR(psuedo_OOB,[]).dropna()

    df['target'] = df['Adj Close_SNP500'].apply(encode_labels)
    lags= 5

    X_lagged = data_prep.get_lagged_df(df, col2lag=df.columns, n=lags)

    full_lagged = data_prep.get_lagged_df(full_df, col2lag=full_df.columns, n=lags)
    lagged_OOB = full_lagged.iloc[idx_psuedo_OOB-lags:idx_OOB-lags]
    
    regress = True
    if regress:
        y = df['Adj Close_SNP500'][lags:]
        print(y.shape)
        ## TODO: choosing best params
        reg = RandomForestRegressor()
        reg.fit(X_lagged,y)
        iterative_pred(reg, lagged_OOB, steps=2)

    else:
        ## put target as a label.
        mlb = MultiLabelBinarizer()
        y = df['target']
        print(df['target'].head())



