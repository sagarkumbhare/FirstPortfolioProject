/*Cleaning Data in SQL Queries*/
select * from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------

--Standadize Date Format

select saledate, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter Table NashvilleHousing
ADD SaleDateConverted DATE;

Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

select SaleDateConverted, CONVERT(Date,SaleDate)
from PortfolioProject.dbo.NashvilleHousing
------------------------------------------

----Populate Property Address Data

select *
from PortfolioProject.dbo.NashvilleHousing
---where PropertyAddress is NULL
order by ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is NULL


------Breaking out address into Individual Columns (Address,City,State)

select propertyaddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is NULL
--order by ParcelID

select 
SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1) as Address
,SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing

Alter Table NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(Propertyaddress,1,CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(Propertyaddress,CHARINDEX(',',PropertyAddress) +1,LEN(PropertyAddress))





select * from PortfolioProject.dbo.NashvilleHousing

select OwnerAddress from PortfolioProject.dbo.NashvilleHousing

Select 
Parsename(Replace(OwnerAddress,',','.'),3)
,Parsename(Replace(OwnerAddress,',','.'),2)
,Parsename(Replace(OwnerAddress,',','.'),1)
from PortfolioProject.dbo.NashvilleHousing



Alter Table NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = Parsename(Replace(OwnerAddress,',','.'),3)

Alter Table NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = Parsename(Replace(OwnerAddress,',','.'),2)


Alter Table NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = Parsename(Replace(OwnerAddress,',','.'),1)


select * from PortfolioProject.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------

--Replacing Y with YES and N with NO


select distinct SoldAsVacant,count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select distinct SoldAsVacant
,Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
 END
from PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
 END
 --------------------------------------------------------------------

 --Remove Duplicates 
 WITH RowNumCTE AS(
 Select *, 
 ROW_NUMBER() OVER(
 PARTITION BY parcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
			    UniqueID
				)row_num
 from PortfolioProject.dbo.NashvilleHousing
 )
Delete from RowNumCTE
 where row_num > 1
 --order by PropertyAddress


  WITH RowNumCTE AS(
 Select *, 
 ROW_NUMBER() OVER(
 PARTITION BY parcelID,
              PropertyAddress,
			  SalePrice,
			  SaleDate,
			  LegalReference
			  ORDER BY
			    UniqueID
				)row_num
 from PortfolioProject.dbo.NashvilleHousing
 )
Select * from RowNumCTE
 where row_num > 1
 --order by PropertyAddress


 --------------------------------------
 ----Delete Unused Columns

  Select * from PortfolioProject.dbo.NashvilleHousing

  Alter TABLE PortfolioProject.dbo.NashvilleHousing
  DROP Column OwnerAddress,TaxDistrict,PropertyAddress,SaleDate