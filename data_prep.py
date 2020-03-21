"""
Should take in csv from a file source 
and return pd.DataFrame, with its lagged values
"""

import pandas as pd

def get_lagged(filepath:str, index_col="Date", col2lag="Adj Close" , n=1) -> pd.DataFrame:
    temp_df = pd.read_csv(filepath, index_col=index_col)
    # lag the values
    for lag in range(n):
        temp_c_name = f"{col2lag}_{lag+1}"
        temp_df[temp_c_name] = temp_df[col2lag].shift(lag+1)
    
    ## remove NA values
    temp_df.dropna()
    return temp_df

if __name__ == '__main__':
    get_lagged("./data/PPH_pharm_etf.csv", n=2)