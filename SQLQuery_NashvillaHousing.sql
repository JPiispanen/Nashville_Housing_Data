/*

Cleaning Data in SQL Queries

*/

SELECT *
	FROM NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- #1 Change SaleDate column format from datetime to date)
-- Updating column straight doesn't work so need to create a new column (SaleDate2).
SELECT SaleDate, CONVERT(date, SaleDate)
	FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD SaleDate2 DATE;

UPDATE NashvilleHousing
	SET SaleDate2 = CONVERT(date, SaleDate)

SELECT SaleDate, SaleDate2
	FROM NashvilleHousing

 --------------------------------------------------------------------------------------------------------------------------

-- 2# Property Address column contains NULL values which needs to be populated. Inspecting data tells that ParcellID is connected to PropertyAddress.
-- If there is two different instances with same ParcellID but other one doesn't have PropertyAddress
-- We can use join clause to update Property Address from other instance to other if ParcellID's are equal but UniqueID is different.

SELECT *
	FROM NashvilleHousing
	--WHERE PropertyAddress is null
	ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashvilleHousing a
	JOIN NashvilleHousing b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress IS NULL

-- With ISNULL populate a.ProbertyAddress if it's null with b.PropertyAddress
UPDATE a
	SET	PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
	FROM NashvilleHousing a
		JOIN NashvilleHousing b
			ON a.ParcelID = b.ParcelID
			AND a.[UniqueID ] <> b.[UniqueID ]
		WHERE a.PropertyAddress IS NULL


--------------------------------------------------------------------------------------------------------------------------

-- 3# PropertyAddress column has value which contains address and city. Breaking column inti individual columns (Address, City and State).
-- Delimiter is comma

-- Dividing columns with SUBSTRING() and CHARINDEX() function:
SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
	ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
	FROM NashvilleHousing

-- Easier way to split value to different columns with PARSENAME() function
-- Breaking out OwnerAddress into individual columns (OwnerSlplitAddress, OwnerSplitCity, OwnerSplitState) using PARSENAME().
SELECT OwnerAddress
	FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	ADD OwnerSlplitAddress Nvarchar(255)
ALTER TABLE NashvilleHousing
	ADD OwnerSplitCity Nvarchar(255)
ALTER TABLE NashvilleHousing
	ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
	SET OwnerSlplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)
UPDATE NashvilleHousing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)
UPDATE NashvilleHousing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)

SELECT *
	FROM NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- #4 SoldAsVacant column has values Yes, Y, No, and N.
-- Update table where 'Y' merges with 'Yes' and 'N' merges with 'No'

-- First check if there is distinct values
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
	FROM NashvilleHousing
	GROUP BY SoldAsVacant

SELECT SoldAsVacant
	,CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END
	FROM NashvilleHousing

UPDATE NashvilleHousing
	SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
	END

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- #5 Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
		ORDER BY UniqueID
	) row_num		
FROM 
	NashvilleHousing
)

-- First: Delete 104 duplicates from CTE
--DELETE
--	FROM RowNumCTE
--	WHERE row_num > 1

-- Second: Check that duplicates are deleted
SELECT *
	FROM RowNumCTE
	WHERE row_num > 1
	ORDER BY PropertyAddress



---------------------------------------------------------------------------------------------------------

-- #6 Delete Unused Columns

SELECT * 
	FROM NashvilleHousing

ALTER TABLE NashvilleHousing
	DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE NashvilleHousing
	DROP COLUMN SaleDate