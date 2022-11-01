select * from NashvilleHousing

-- 1 -- -----------------------     standardize date format for saledate

-- converting saledate to date format
select SaleDate , convert (date,saledate) from NashvilleHousing

-- updating coverted column into database
update NashvilleHousing set SaleDate = convert (date,SaleDate)

-- its not getting updated so creating new column with date datatype and then trying
alter table NashvilleHousing add SaleDateConv date

update NashvilleHousing set SaleDateConv = convert (date,SaleDate)

-- 2 -------------------Property Address data 

select PropertyAddress from NashvilleHousing
where PropertyAddress is null

-- want to fill the null values of property address 

select PropertyAddress,ParcelID from NashvilleHousing
order by ParcelID

select * from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

/* we observe that for parcel id property address is same like parcel id is getting repeated but address is 
same so what we want to do is we need to copy that property address for that particular parcel id and fill in 
where property address is null */

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
JOIN NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
Where a.PropertyAddress is null


-- 3 ------------------------------------breaking out address column into individual column as address,city,state

/* i observe that coma is a seprator for address and city , 
so with the help oh substring and charindex we would split
and then we will use parsename for different column */

---------------------------------------------------property address --------------------------
Select PropertyAddress From NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address
From NashvilleHousing

-- updating 

ALTER TABLE NashvilleHousing
Add PropertyAddAddress Nvarchar(255)

Update NashvilleHousing
SET PropertyAddAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertyAddCity Nvarchar(255)

Update NashvilleHousing
SET PropertyAddCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))

---------------------------------------------------owner address --------------------------

Select OwnerAddress From NashvilleHousing

-- using parsename

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

--updating 

ALTER TABLE NashvilleHousing
Add OwnerAddAddress Nvarchar(255)

Update NashvilleHousing
SET OwnerAddAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerAddCity Nvarchar(255)

Update NashvilleHousing
SET OwnerAddCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerAddState Nvarchar(255)

Update NashvilleHousing
SET OwnerAddState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

-- 4 -----------------------------changing y and n in soldasvacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant

Select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

-- 5 -------------------------------------remove duplicates----------------- 

WITH RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- 6 delete unused columns -------------------------------------------------

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

select * from NashvilleHousing