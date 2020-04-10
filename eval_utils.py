import data_prep
import pandas as pd

full_industries = ["Pharm", "Semicon", "Industrial", "Energy", "Financial", "Tech", "Utilities", "Consumer"]

def build_and_model_VAR(main_df:pd.DataFrame, var2add:list ):
    temp_df = pd.DataFrame()
    for var in var2add:
        for col in main_df.columns:
            if "Open_"+var in col or "Volume_" + var in col:
                try:
                    temp_df.columns
                except:
                    temp_df = main_df[col]
                else:
                    temp_df = pd.concat([temp_df, main_df[col]], axis=1)
                    
    temp_df['Open_SNP500'] = main_df['Open_SNP500']
    temp_df['Volume_SNP500'] = main_df['Volume_SNP500']
    
    temp_df.index = main_df.index
        
    return temp_df

def forecast_ARMA_ADL(full_df, model, steps):
    # build psuedo_OOB
    lagged_fulldf = build_and_model_VAR(full_df, full_industries)
    lagged_fulldf = lagged_fulldf.drop("Open_SNP500", axis=1)
    lagged_fulldf = data_prep.get_lagged_df(full_df,col2lag=list(full_df.columns), n=4)
    ## ignore const and ar components to get exog data.
    psuedo_OOB = lagged_fulldf[list(model.params.keys()[1:-model.k_ar])] 

    psuedo_OOB = psuedo_OOB.iloc[:steps].reset_index(drop=True)
    res2 = list(res_full2.forecast(steps=steps, exog=psuedo_OOB))
    nice_result = {
        "forecast": res2[0].tolist(),
        "sd": res2[1].tolist(),
        "conf interval": res2[2].tolist(),
    }

def predicted_views(model, ):
    return
