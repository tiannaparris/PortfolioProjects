-- Cleaning Data in SQL Queries
-----------------------------------------------------------------------

SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing


-----------------------------------------------------------------------
-- Standardise Date Format


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD UpdatedSaleDate Date;

Update SQLPortfolio.dbo.NashvilleHousing
SET UpdatedSaleDate = CONVERT(Date,SaleDate)

SELECT UpdatedSaleDate, SaleDate
FROM SQLPortfolio.dbo.NashvilleHousing


-----------------------------------------------------------------------
-- Populate Property Address Data


SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.NashvilleHousing a
JOIN SQLPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM SQLPortfolio.dbo.NashvilleHousing a
JOIN SQLPortfolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

SELECT PropertyAddress
FROM SQLPortfolio.dbo.NashvilleHousing
WHERE PropertyAddress is NULL


-------------------------------------------------------------------------
-- Breaking out Full Address into individual Columns (Address, City, State)

--Property Address

SELECT PropertyAddress
FROM SQLPortfolio.dbo.NashvilleHousing


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD PropertyAddressStreet NVARCHAR(255);

UPDATE SQLPortfolio.dbo.NashvilleHousing
SET PropertyAddressStreet = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD PropertyAddressCity NVARCHAR(255);

UPDATE SQLPortfolio.dbo.NashvilleHousing
SET PropertyAddressCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

SELECT PropertyAddressStreet, PropertyAddressCity
FROM SQLPortfolio.dbo.NashvilleHousing


-- Owner Address

SELECT OwnerAddress
FROM SQLPortfolio.dbo.NashvilleHousing


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD OwnerAddressStreet NVARCHAR(255);

UPDATE SQLPortfolio.dbo.NashvilleHousing
SET OwnerAddressStreet = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD OwnerAddressCity NVARCHAR(255);

UPDATE SQLPortfolio.dbo.NashvilleHousing
SET OwnerAddressCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)


ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
ADD OwnerAddressState NVARCHAR(255);

UPDATE SQLPortfolio.dbo.NashvilleHousing
SET OwnerAddressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)


------------------------------------------------------------------------------
-- Change "Y" to "Yes" and "N" to "No" in the "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM SQLPortfolio.dbo.NashvilleHousing


UPDATE SQLPortfolio.dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


	
-------------------------------------------------------------------------------
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

FROM SQLPortfolio.dbo.NashvilleHousing
)
--SELECT *
DELETE
FROM RowNUMCTE
WHERE row_num > 1
--ORDER BY PropertyAddress



----------------------------------------------------------------
-- Delete Unused Columns


SELECT *
FROM SQLPortfolio.dbo.NashvilleHousing

ALTER TABLE SQLPortfolio.dbo.NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, TaxDistrict, PropertyAddress

