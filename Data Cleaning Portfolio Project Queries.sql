/*
Cleaning data in sql queries
*/

 
---------------------------------------------------------------------------

-- Standardize date format

select SaleDate, CONVERT(date, SaleDate) 
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

Alter table NashvilleHousing
Add SaleDateConverted date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(date, SaleDate)


---------------------------------------------------------------------------

--Populate Property Adress Data

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID


select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
On a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
    Join PortfolioProject.dbo.NashvilleHousing b
    On a.ParcelID = b.ParcelID 
    and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


---------------------------------------------------------------------------

--Breaking out Adress into Individual Columns (Adress, City, State)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID 


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as City

from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add PropertySplitAdress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAdress  = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) 

select * 
from PortfolioProject.dbo.NashvilleHousing -- here we can see that both columns were added at the end of the table


select OwnerAddress 
from PortfolioProject.dbo.NashvilleHousing

select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) as Address,
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) as City, 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)  as State
from PortfolioProject.dbo.NashvilleHousing


Alter table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


Alter table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity= PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


Alter table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


select * 
from PortfolioProject.dbo.NashvilleHousing


---------------------------------------------------------------------------

--Change Y and N to Yes and No in 'Sold As Vacant' field

select distinct(SoldAsVacant),count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant 
order by 2


select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN  'Yes'
     WHEN SoldAsVacant = 'N' THEN  'No'
	 ELSE SoldAsVacant
END
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN  'Yes'
                        WHEN SoldAsVacant = 'N' THEN  'No'
	                    ELSE SoldAsVacant
                    END

---------------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE
as
(
select *, 
ROW_NUMBER() OVER(
    PARTITION BY  ParcelID,
		          PropertyAddress,
		          SalePrice,
		          SaleDate,
		          LegalReference
		          ORDER BY UniqueID
		          ) row_num

from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select * 
from RowNumCTE
where row_num >1
order by PropertyAddress


---------------------------------------------------------------------------

--Delete Unused Columns

select * 
from PortfolioProject.dbo.NashvilleHousing


ALTER table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate

























