/* 

Cleaning Data using sql queries.

*/

SELECT *
FROM PortfolioProject..['Nashville Housing Data for Data$']

---1) Let's standardize date format ( currently in datetime format).

SELECT SaleDate, CONVERT(Date, SaleDate) Date
FROM PortfolioProject..['Nashville Housing Data for Data$']

---updating the new date with the datetime format.

UPDATE ['Nashville Housing Data for Data$']
SET SaleDate = CONVERT(Date, SaleDate)

SELECT SaleDate 
FROM PortfolioProject..['Nashville Housing Data for Data$']

---oops not working?


ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD SaleDateConverted Date;

UPDATE ['Nashville Housing Data for Data$']
SET SaleDateConverted = CONVERT(Date, SaleDate)

SELECT SaleDateConverted
FROM PortfolioProject..['Nashville Housing Data for Data$']

---It worked!!!! 


---2) Populate Property Address data
SELECT *
FROM PortfolioProject..['Nashville Housing Data for Data$']
---WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID ParcelIDA, a.PropertyAddress PropertyAddressA,
b.ParcelID ParcelIDB, b.PropertyAddress PropertyAddressB, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..['Nashville Housing Data for Data$'] a
JOIN PortfolioProject..['Nashville Housing Data for Data$'] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..['Nashville Housing Data for Data$'] a
JOIN PortfolioProject..['Nashville Housing Data for Data$'] b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


---3) Splitting Address into (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject..['Nashville Housing Data for Data$']

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..['Nashville Housing Data for Data$']

---ADDRESS

ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD PropertySplitAddress NVARCHAR(255);

UPDATE [dbo].['Nashville Housing Data for Data$']
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

---CITY

ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD PropertySplitCity NVARCHAR(255);

UPDATE [dbo].['Nashville Housing Data for Data$']
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', Propertyaddress) +1, LEN(PropertyAddress))


---Verifying changes made

SELECT *
FROM PortfolioProject..['Nashville Housing Data for Data$']


---3) Splitting Owner Address this time using Parsename
SELECT OwnerAddress
FROM PortfolioProject..['Nashville Housing Data for Data$']

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..['Nashville Housing Data for Data$']

---Owner Address

ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE [dbo].['Nashville Housing Data for Data$']
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


--- Owner City

ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD OwnerSplitCity NVARCHAR(255);

UPDATE [dbo].['Nashville Housing Data for Data$']
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

---Owner State
ALTER TABLE [dbo].['Nashville Housing Data for Data$']
ADD OwnerSplitState NVARCHAR(255);

UPDATE [dbo].['Nashville Housing Data for Data$']
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---Verifying Changes made

SELECT OwnerSplitCity,OwnerSplitState, OwnerSplitAddress
FROM PortfolioProject..['Nashville Housing Data for Data$']

---Yes!!! It worked!!! Let's continue..

---4) Chaning Y and N response to Yes and No in "Sold as Vacant" column.
SELECT SoldAsVacant
FROM PortfolioProject..['Nashville Housing Data for Data$']
WHERE SoldAsVacant = 'Y' OR SoldAsVacant = 'N'

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..['Nashville Housing Data for Data$']
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant END
FROM PortfolioProject..['Nashville Housing Data for Data$']

UPDATE [dbo].['Nashville Housing Data for Data$']
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant END
FROM PortfolioProject..['Nashville Housing Data for Data$']


---4) Removing Unnecassary Duplicates
WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (PARTITION BY 
							ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference
							ORDER BY UniqueID) row_num
FROM PortfolioProject..['Nashville Housing Data for Data$']
)
---DELETE
SELECT *
FROM RowNumCTE
WHERE row_num > 1

---GREAT almost done.

--- Deleting Unused columns
ALTER TABLE [dbo].['Nashville Housing Data for Data$']
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE [dbo].['Nashville Housing Data for Data$']
DROP COLUMN SaleDate

SELECT *
FROM PortfolioProject..['Nashville Housing Data for Data$']