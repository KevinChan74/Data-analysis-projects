-- Standardize Date Format

SELECT SaleDateConverted, CAST(SaleDateConverted as Date)
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CAST(SaleDate as Date)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CAST(NashvilleHousing as Date)

-- Populate Property Address data

SELECT *
FROM PortfolioProject.dbo.NashvilleHousing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> B.UniqueID
WHERE a.PropertyAddress Is Null

UPDATE a
SET PropertyAddress  = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.UniqueID <> b.UniqueID

-- Breaking out address into individual columns (address, city, state)

SELECT PropertyAddress
FROM PortfolioProject.dbo.NashvilleHousing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSRTING(PropertyAddress, CHARINDEX(',', PropertyAddress), LEN(PropertyAddress)) as Address
FROM PortfolioProject.dbo.NashvilleHousing

SELECT OwnerAddress
FROM PortfolioProject.dbo.NashivilleHousing

SELECT PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject.dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN 'Y' THEN 'Yes'
         WHEN 'N' THEN 'No'
         ELSE SoldAsVacant 
         END
FROM PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN 'Y' THEN 'Yes'
       WHEN 'N' THEN 'No'
       ELSE SoldAsVacant
       END

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
       ROW_NUMBER() OVER (
       PARTITION BY ParcelID,
			PropertyAddress,
			SalePrice,
			SaleDate,
			LegalReference
			Order By
			UniqueID
			) AS row_num

FROM Portfolio.dbo.NashvilleHousing

DELETE 
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

SELECT *
FROM Portfolioproject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
