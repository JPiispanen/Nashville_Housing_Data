# Nashville_Housing_Data

## Data cleaning with SQL

### Dataset
- Downloaded dataset from [Kaggle Nashville Housing Data] (https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data) by tmthyjames 
- There are 56,000+ rows altogether

### Performed data cleaning procedures
1. Changed date format (datetime --> date) with CONVERT() fuction
2. Populated NULL values with JOIN clause and ISNULL function
3. Divided columns value to individual columns with SUBSTRING() and CHARINDEX() function and also with PARSENAME() function
4. Standardized column values ('Y' --> 'Yes' and 'N' --> 'No') with CASE expression and UPDATE statement
5. Identified and deleted duplicate records by creating CTE and using ROW_NUMBER() function and PARTITION BY clause 
6. Deleted unused columns with DROP COLUMN command
