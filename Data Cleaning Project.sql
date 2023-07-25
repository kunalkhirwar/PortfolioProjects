--Cleaning data using SQL queries

Select *
From [Portfolio Project].dbo.NashvilleHousing;

-- Standardize Date Format

Update [Portfolio Project].dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update [Portfolio Project].dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);



-- Populate the Property Address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress IS NULL



-- Breaking out Address into Individual Columns (Address, City, State)

Select SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress)) as Address
From NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1);

Alter Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) + 1,len(PropertyAddress));



Select PARSENAME(replace(OwnerAddress,',','.'),3),
	   PARSENAME(replace(OwnerAddress,',','.'),2),
	   PARSENAME(replace(OwnerAddress,',','.'),1)
From NashvilleHousing;

Alter Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3);

Alter Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2);

Alter Table NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update [Portfolio Project].dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1);

Select * 
From NashvilleHousing


--Change Y nad N to 'Yes' and 'No' in "Sold as Vacant" field

Select distinct(soldasvacant), COUNT(soldasvacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2;

Select soldasvacant,
	CASE When soldasvacant = 'Y' Then 'Yes'
		 When soldasvacant = 'N' Then 'No'
		 Else soldasvacant
		 END
From NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When soldasvacant = 'Y' Then 'Yes'
		 When soldasvacant = 'N' Then 'No'
		 Else soldasvacant
		 END


-- Remove Duplicates

With RowNumCTE AS
(
Select *,
	ROW_NUMBER() OVER (
	Partition By ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By 
				 UniqueID
				 ) as row_num
From NashvilleHousing
)


Select * 
From RowNumCTE
Where row_num > 1

Delete 
From RowNumCTE
Where row_num > 1



Select *
From NashvilleHousing


-- Remove unused columns

ALTER Table NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER Table NashvilleHousing
DROP COLUMN SaleDate

Select *
From NashvilleHousing