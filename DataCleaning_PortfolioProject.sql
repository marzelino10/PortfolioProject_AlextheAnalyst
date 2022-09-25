//*

		Cleaning Data in SQL Queries

*//

select *
from Portfolio_Project..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------


-- STANDARDIZE DATE FORMAT

select Saledate, convert(date,saledate)				
from Portfolio_Project..NashvilleHousing

Update Portfolio_Project..NashvilleHousing							
set SaleDate = convert(date,saledate)

-- If it doesn't Update properly, then:

Alter table NashvilleHousing
add SaleDateConverted Date 

Update Portfolio_Project..NashvilleHousing								
set SaleDateConverted = convert(date,saledate)

select SaledateConverted			
from Portfolio_Project..NashvilleHousing



--------------------------------------------------------------------------------------------------------------------------

-- POPULATE PROPERTY ADDRESS DATA

-- Fixing PropertyAddress = Null

select *
from Portfolio_Project..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID

-- Using ParcelID to populate PropertyAddress = Null

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a																	-- have to use the table alias, otherwise it will shows error message
set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
from Portfolio_Project..NashvilleHousing a
join Portfolio_Project..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


--------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)


select PropertyAddress
from Portfolio_Project..NashvilleHousing
-- where PropertyAddress is null
-- order by ParcelID


-- Using Substring
select
	SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1) as Address,
	SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(PropertyAddress)) as State
from Portfolio_Project..NashvilleHousing


-- For Address
Alter table NashvilleHousing
add PropertySplitAddress nvarchar(255);

Update Portfolio_Project..NashvilleHousing								
set PropertySplitAddress = SUBSTRING(propertyaddress, 1, charindex(',', propertyaddress)-1)


-- For City
Alter table NashvilleHousing
add PropertyCity nvarchar(255);

Update Portfolio_Project..NashvilleHousing								
set PropertyCity = SUBSTRING(propertyaddress, charindex(',', propertyaddress)+1, len(PropertyAddress))


select PropertyAddress, PropertySplitAddress, PropertyCity
from Portfolio_Project..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


--------------------------------------------------------------------------------------------------------------------------

-- BREAKING OUT OWNER ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

select OwnerAddress
from Portfolio_Project..NashvilleHousing
-- where PropertyAddress is null
order by ParcelID


-- Using Parse --> this only works for "." delimiter --> so need to change "," to ".")

select 
	PARSENAME (replace(owneraddress, ',', '.'),3) as OwnerSplitAddress,
	PARSENAME (replace(owneraddress, ',', '.'),2) as OwnerCity,
	PARSENAME (replace(owneraddress, ',', '.'),1) as OwnerState
from Portfolio_Project..NashvilleHousing


-- For Address
Alter table Portfolio_Project..NashvilleHousing
add OwnerSplitAddress nvarchar(255);

Update Portfolio_Project..NashvilleHousing								
set OwnerSplitAddress = PARSENAME (replace(owneraddress, ',', '.'),3)


-- For City
Alter table Portfolio_Project..NashvilleHousing
add OwnerCity nvarchar(255);

Update Portfolio_Project..NashvilleHousing								
set OwnerCity = PARSENAME (replace(owneraddress, ',', '.'),2)


-- For State
Alter table Portfolio_Project..NashvilleHousing
add OwnerState nvarchar(255);

Update Portfolio_Project..NashvilleHousing								
set OwnerState = PARSENAME (replace(owneraddress, ',', '.'),1)


select *
from Portfolio_Project..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------

-- CHANGE 'Y' AND 'N' TO 'YES' AND 'NO' IN "Sold as Vacant" field


select distinct(soldasvacant), count(soldasvacant)
from Portfolio_Project..NashvilleHousing
group by SoldAsVacant
order by 2


select soldasvacant,
	case when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	else SoldAsVacant
	end
from Portfolio_Project..NashvilleHousing


update Portfolio_Project..NashvilleHousing
set SoldAsVacant = case when soldasvacant = 'Y' then 'Yes'
						when soldasvacant = 'N' then 'No'
						else SoldAsVacant
						end



-----------------------------------------------------------------------------------------------------------------------------------------------------------

--	REMOVE DUPLICATES


-- Selecting duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by  UniqueID
				 ) row_num

from Portfolio_Project..NashvilleHousing
--order by ParcelID
)

select *
from RowNumCTE
where row_num > 1
order by PropertyAddress


-- Delete duplicates

With RowNumCTE as (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by  UniqueID
				 ) row_num

from Portfolio_Project..NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from Portfolio_Project..NashvilleHousing


alter table Portfolio_Project..NashvilleHousing
drop column owneraddress, propertyaddress, taxdistrict, saledate