import data_prep
import pandas as pd
import matplotlib.pyplot as plt

full_industries = ["Pharm", "Semicon", "Industrial", "Energy", "Financial", "Tech", "Utilities", "Consumer"]

def build_and_model_VAR(main_df:pd.DataFrame, var2add:list ):
    temp_df = pd.DataFrame()
    for var in var2add:
        for col in main_df.columns:
            if "Adj Close_"+var in col:
                temp_df[f"Adj Close_{var}"] = data_prep.get_perc_return_df(main_df[col])
            elif "Volume_" + var in col:
                temp_df[f"Volume_{var}"] = main_df[col]

    temp_df['Adj Close_SNP500'] = data_prep.get_perc_return_df(main_df['Adj Close_SNP500'])
    temp_df['Volume_SNP500'] = main_df['Volume_SNP500']

    return temp_df

def forecast_ARMA_ADL(full_df, model,start_idx, end_idx,):
    steps = end_idx - start_idx
    p = model.k_ar 
    q = model.k_ma
    # build psuedo_OOB
    lagged_fulldf = build_and_model_VAR(full_df, full_industries)
    lagged_fulldf = lagged_fulldf.drop("Adj Close_SNP500", axis=1)
    lagged_fulldf = data_prep.get_lagged_df(full_df,col2lag=list(full_df.columns), n=p)
    ## ignore const and ar components to get exog data.
    psuedo_OOB = lagged_fulldf[list(model.params.keys()[1:-(p+q)])].iloc[start_idx-p+1:end_idx-p+1] 

    psuedo_OOB = psuedo_OOB.iloc[:steps].reset_index(drop=True)
    res2 = list(model.forecast(steps=steps, exog=psuedo_OOB))
    nice_result = {
        "forecast": res2[0].tolist(),
        "sd": res2[1].tolist(),
        "conf interval": res2[2].tolist(),
    }
    return nice_result

def predicted_views(full_y_val, y_pred):
    """
    Arguments:
    full_y_val - Close_SNP500 prices sliced at desired date range.

    """

    plt.figure(figsize=(12,7))
    ## plotting
    plt.plot(y_pred)
    plt.plot(full_y_val)

    plt.tight_layout()
    plt.show()

if __name__ == "__main__":
    temp = pd.read_csv("./data/output.csv")
    final = build_and_model_VAR(temp, var2add=["Pharm", "Utilities"])
    print(final.columns)
    print(final.head())