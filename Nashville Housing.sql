-- Data Cleaning Project

-- Removing time from date
select SaleDateConverted, CONVERT(Date, SaleDate)
from dbo.NashvilleHousing

alter table dbo.NashvilleHousing
add SaleDateConverted Date

update dbo.NashvilleHousing
set SaleDateConverted = CONVERT(Date, SaleDate)

-- Some of the PropertyAddresses are null; however, we can identify the correct PropertyAddress using the ParcelID. 

-- Identifying null PropertyAddresses
select *
from dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- Identifying the correct PropertyAddresses by self joining the table 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- Adding in the correct PropertyAddresses to populate nulls
update a
set a.PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]

-- Breaking up the address into separate columns

select PropertyAddress
from dbo.NashvilleHousing

select
parsename(replace(PropertyAddress, ',', '.'), 2) as address,
parsename(replace(PropertyAddress, ',', '.'), 1) as city
from dbo.NashvilleHousing

-- Creating and populating columns with the address and city 

alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = parsename(replace(PropertyAddress, ',', '.'), 2)

alter table NashvilleHousing
Add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitCity = parsename(replace(PropertyAddress, ',', '.'), 1)

-- Checking to see if queries worked

select * from dbo.NashvilleHousing

-- Now, separating out the OwnerAddress (using parsename this time)

select 
	parsename(replace(OwnerAddress, ',', '.'), 3),
	parsename(replace(OwnerAddress, ',', '.'), 2),
	parsename(replace(OwnerAddress, ',', '.'), 1)
from dbo.NashvilleHousing

alter table NashvilleHousing
Add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)

alter table NashvilleHousing
Add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)

alter table NashvilleHousing
Add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)

-- Checking once again to see if queries worked

select * from dbo.NashvilleHousing

-- Cleaning up the SoldAsVacant column to standardize Y/N to Yes/No

select distinct(SoldAsVacant), count(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = 
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N' then 'No'
		 else SoldAsVacant
		 end
from dbo.NashvilleHousing

-- Removing duplicate data
;WITH RowNumCTE AS (
select *, 
	ROW_NUMBER() over (
	PARTITION BY ParcelID, 
				 PropertyAddress, 
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
from dbo.NashvilleHousing
)

select * 
from RowNumCTE
where row_num > 1
order by PropertyAddress

-- Deleting unused columns

alter table dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict, SaleDate

alter table dbo.NashvilleHousing
DROP COLUMN SaleDate

select * from dbo.NashvilleHousing