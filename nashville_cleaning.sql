/*

Data cleaning using SQL

*/

SELECT *
FROM nashville_housing.dbo.nashville_housing_data


--------------------------------------------------------------------------------------------------------------------------

--Standardize Date Format

ALTER TABLE nashville_housing_data
ADD SaleDateConverted DATE;


UPDATE nashville_housing_data
SET SaleDateConverted = CONVERT(date, SaleDate)


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM nashville_housing.dbo.nashville_housing_data

-------------------------------------------------------------------------------------------------------------------------------

--Populate Property Address data

/* Some of the values in the PropertyAdress column are null however, each property adress has it's own  uniqueparcel ID. 
The following code is going to connect the null rows to rows that have a value in PropertyAdress. */

SELECT *
FROM nashville_housing.dbo.nashville_housing_data
WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, 
	   a.PropertyAddress, 
	   b.ParcelID, 
	   b.PropertyAddress, 
	   ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing.dbo.nashville_housing_data a
JOIN nashville_housing.dbo.nashville_housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM nashville_housing.dbo.nashville_housing_data a
JOIN nashville_housing.dbo.nashville_housing_data b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL 


----------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


SELECT PropertyAddress
FROM nashville_housing.dbo.nashville_housing_data


SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) AS Address,
	   SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) AS Address
FROM nashville_housing.dbo.nashville_housing_data


ALTER TABLE nashville_housing_data
ADD PropertySplitAddress NVARCHAR(255);

UPDATE nashville_housing_data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE nashville_housing_data
ADD PropertySplitCity NVARCHAR(255);

UPDATE nashville_housing_data
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))




Select *
From PortfolioProject.dbo.NashvilleHousing





SELECT OwnerAddress
FROM nashville_housing.dbo.nashville_housing_data


SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
	   PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
FROM nashville_housing.dbo.nashville_housing_data



ALTER TABLE nashville_housing_data
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashville_housing_data
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE nashville_housing_data
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashville_housing_data
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE nashville_housing_data
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashville_housing_data
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


SELECT *
FROM nashville_housing.dbo.nashville_housing_data

-------------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM nashville_housing.dbo.nashville_housing_data
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM nashville_housing.dbo.nashville_housing_data


UPDATE nashville_housing_data
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM nashville_housing.dbo.nashville_housing_data
--ORDER BY ParcelID

DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT *
FROM nashville_housing.dbo.nashville_housing_data


ALTER TABLE nashville_housing_data
DROP COLUMN OwnerAddress,  
			PropertyAddress, 
			SaleDate







