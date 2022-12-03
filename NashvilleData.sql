/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleH



-- Standardize Date Format --



Select SaleDateConverted, CONVERT(date	,SaleDate)
From PortfolioProject.dbo.NashvilleH

update NashvilleH
SET SaleDate = CONVERT(date,saledate)

Alter table NashvilleH
add SaleDateConverted Date;

Update NashvilleH
SET SaleDateConverted = CONVERT(date,saledate)



-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleH
--where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleH a
JOIN PortfolioProject.dbo.NashvilleH b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set propertyaddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleH a
JOIN PortfolioProject.dbo.NashvilleH b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out Address into Individual Columns (Address, City, State) --




Select PropertyAddress
from PortfolioProject.dbo.NashvilleH


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleH

Alter table NashvilleH
add PropertySplit nvarchar(255);

Update NashvilleH
SET PropertySplit = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter table NashvilleH
add PropertySplitCity nvarchar(255);

Update NashvilleH
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) 


Select *
from PortfolioProject.dbo.NashvilleH






Select OwnerAddress
from PortfolioProject.dbo.NashvilleH

select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
from PortfolioProject.dbo.NashvilleH




Alter table NashvilleH
add OwnerSplit nvarchar(255);
 
Update NashvilleH
SET OwnerSplit = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


Alter table NashvilleH
add OwnerSplitCity nvarchar(255);

Update NashvilleH
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)


Alter table NashvilleH
OwnerSplitState nvarchar(255);

Update NashvilleH
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)




-- Change Y and N to Yes and No in "Sold as Vacant" field --



Select distinct(SoldAsVacant), COUNT(soldasvacant)
from PortfolioProject.dbo.NashvilleH
group by SoldAsVacant
order by 2




Select SoldAsVacant
, Case when soldasvacant =  'Y' THEN 'Yes'
	   When SoldAsVacant =  'N' THEN 'No'
	   else SoldAsVacant
	   END
from PortfolioProject.dbo.NashvilleH

Update NashvilleH
SET SoldAsVacant = Case 
	   when soldasvacant =  'Y' THEN 'Yes'
	   When SoldAsVacant =  'N' THEN 'No'
	   else SoldAsVacant
	   END




-- Remove Duplicates --


With RowNumCTE AS(

Select *,
	ROW_NUMBER() Over(
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order By
					UniqueID
					) row_num
From PortfolioProject.dbo.NashvilleH
--order by ParcelID 
)
Select *
From RowNumCTE
Where row_num > 1
order by PropertyAddress




-- Delete Unused Columns


Select *
From PortfolioProject.dbo.NashvilleH

Alter Table PortfolioProject.dbo.NashvilleH
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate -- Name them all at once otherwise rewrite alter table with new drop column

