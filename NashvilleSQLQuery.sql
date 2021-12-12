--Let's take a look at the data first.

Select * from NashvilleHousing;

--As we can see from the table that the date is in datetime format so let's convert it to date format

Select Convert(Date,SaleDate)
from NashvilleHousing;

Alter Table NashvilleHousing 
Add ConvertedSaleDate Date; 

Update NashvilleHousing 
Set ConvertedSaleDate = Convert(Date,SaleDate)

Select ConvertedSaleDate from NashvilleHousing;

Alter Table NashvilleHousing
Drop Column SaleDate;

Select * from NashvilleHousing;

--So now we added a new column with the updated date and deleted the old date column

--Now when we take a look at the ParcelID we find that some entries of it are similar to each other thus the address should
--also be similar so now let's update the table so it shows the same address for similar IDs.

--Let's take a look at the ParcelID and PropertyAddress

Select ParcelID,PropertyAddress from NashvilleHousing;

--Now let's perform a join on ParcelID to the same table as that will allow us to check the enteries when the ParcelIDs are same.
--We use the other join condition because the UniqueID will always be unique.

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress
from NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] != b.[UniqueID ]

--Let us use the ISNULL function to copy the value of b.PropertyAddress to a.PropertyAddress when the value of a's null.

Select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

--Now let's use the Update Statement along with the join.
--Here we need to use an alias after Update as it will show an error otherwise.

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
Join NashvilleHousing b
On a.ParcelID = b.ParcelID
And a.[UniqueID ] != b.[UniqueID ]
Where a.PropertyAddress is null

Select ParcelID,PropertyAddress from NashvilleHousing;

--Now let's divide the address into Address, City and State

Select PropertyAddress from NashvilleHousing;
Select OwnerAddress from NashvilleHousing;

--Type 1 :- Use Substring

Select PropertyAddress,
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) AS City
from NashvilleHousing;

--Type 2 :- Use REVERSE (BETTER SOLUTION!!!)

Select OwnerAddress
from NashvilleHousing;

Select 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from NashvilleHousing;

ALTER TABLE NashvilleHousing
ADD Address Nvarchar(255);

Update NashvilleHousing
Set Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3);

ALTER TABLE NashvilleHousing
ADD City Nvarchar(255);

Update NashvilleHousing
Set City = PARSENAME(REPLACE(OwnerAddress,',','.'),2);

ALTER TABLE NashvilleHousing
ADD State Nvarchar(255);

Update NashvilleHousing
Set State = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

Select * from NashvilleHousing;

--Now let's change the Y and N in SoldAsVacant column to Yes and No 

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2;

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
from NashvilleHousing;

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
     When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End

Select SoldAsVacant from NashvilleHousing;

--Let's remove the duplicate data

WITH Duplicate as(
Select *, 
ROW_NUMBER() Over (Partition By ParcelID, PropertyAddress, SalePrice, ConvertedSaleDate, LegalReference
Order By UniqueID) r_n
From NashvilleHousing)

Select * from Duplicate
Where r_n > 1

Delete
from Duplicate
Where r_n > 1

--Let's delete unused columns

Select * from NashvilleHousing;

ALTER TABLE NashvilleHousing
Drop Column PropertyAddress, OwnerAddress, TaxDistrict;

ALTER TABLE NashvilleHousing
RENAME Column ConvertedSaleDate to SaleDate;
