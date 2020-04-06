"""
Should take in csv from a file source 
and return pd.DataFrame, with its lagged values
"""

import pandas as pd

## returns a csv with lagged values
def get_lagged(filepath:str, index_col="Date", col2lag="Adj Close" , n=1) -> pd.DataFrame:
    temp_df = pd.read_csv(filepath, index_col=index_col)
    # lag the values
    for lag in range(n):
        temp_c_name = f"{col2lag}_{lag+1}"
        temp_df[temp_c_name] = temp_df[col2lag].shift(lag+1)
    
    ## remove NA values
    temp_df.dropna()
    return temp_df

## gets the % return of a columns
def get_perc_return(df, column_name, n=1) -> pd.DataFrame:
	'''
	Column has to be the name of a column in the csv file
	REturns data and result columns
	'''
	temp_df = df
	target = temp_df[column_name]
	returns = (target - target.shift(n))/target.shift(n)
	temp_df['%_returns'] = returns
	temp_df = temp_df.dropna()
	return temp_df[['Date','%_returns']]

if __name__ == '__main__':
    get_lagged("./data/PPH_pharm_etf.csv", n=2)
    results = get_perc_return("./data/SnP_500.csv", column_name="Open").head()
    print(type(results))
    print(results)