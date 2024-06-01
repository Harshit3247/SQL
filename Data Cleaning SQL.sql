select * from Nash;

--Standardize Date Format

Select SaleDate,Convert(Date,SaleDate) as YYYYMMDD  from Nash;

alter table Nash
add SaleDateConverted Date;

update Nash 
set SaleDateConverted=convert(Date,SaleDate)

select SaleDate,SaleDateConverted from Nash;

--Populate Property Address

select * from Nash
--where PropertyAddress is null
order by ParcelID;

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.propertyaddress,b.propertyaddress) from Nash a 
join Nash b 
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null;

update a
set propertyaddress = isnull(a.propertyaddress,b.propertyaddress)
from Nash a 
join Nash b 
	on a.ParcelID=b.ParcelID
	and a.[UniqueID]<>b.[UniqueID]
where a.PropertyAddress is null;

--address into columns

select propertyaddress from Nash;

select substring(propertyaddress,1,charindex(',',propertyaddress)-1) as Address,
substring(propertyaddress,charindex(',',propertyaddress)+1,charindex(',',propertyaddress)-1) as Address
from nash;

alter table Nash
add PropertySplitAddress nvarchar(255);

update Nash 
set PropertySplitAddress=substring(propertyaddress,1,charindex(',',propertyaddress)-1)

alter table Nash
add PropertySplitCity nvarchar(255);

update Nash 
set PropertySplitCity=substring(propertyaddress,charindex(',',propertyaddress)+1,charindex(',',propertyaddress)-1)

select PropertyAddress,PropertySplitAddress,PropertySplitCity from Nash;

select OwnerAddress from Nash;

select parsename(replace(OwnerAddress,',','.'),3), 
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from Nash;

alter table Nash
add OwnerSplitAddress nvarchar(255);

update Nash 
set OwnerSplitAddress=parsename(replace(OwnerAddress,',','.'),3)

alter table Nash
add OwnerSplitCity nvarchar(255);

update Nash 
set OwnerSplitCity=parsename(replace(OwnerAddress,',','.'),2)

alter table Nash
add OwnerSplitState nvarchar(255);

update Nash 
set OwnerSplitState=parsename(replace(OwnerAddress,',','.'),1)

select OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState from Nash;


-- Change Y and N to Yes and No in "Sold as Vacant" field
select distinct(SoldAsVacant), count(SoldAsVacant)
from Nash
group by SoldAsVacant
order by 2;

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from Nash;

update Nash
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end

select distinct(SoldAsVacant), count(SoldAsVacant)
from Nash
group by SoldAsVacant
order by 2

--Remove Duplicates
with rownumcte as(
	select *, row_number() over 
		(partition by ParcelID,PropertyAddress,SalePrice,SaleDate,LegalReference 
		order by UniqueID
		)as row_num 
	from Nash)
delete from rownumcte where row_num>1;

-- Delete Unused Columns
select *
from Nash

alter table Nash
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate