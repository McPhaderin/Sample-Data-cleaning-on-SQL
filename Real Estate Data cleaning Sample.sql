select*
from PortfolioProject..HousingData

--Standardaize the Date Format

select SaleDate, Convert(date,Saledate)
from PortfolioProject..HousingData

Alter Table PortfolioProject..HousingData
add saleDateFormatted Date;

Update PortfolioProject..HousingData
set SaleDateFormatted = convert(date,saleDate)



--Populate Property Adddress where it's Nulll
select *
from PortfolioProject..HousingData
where PropertyAddress is null


select a.PropertyAddress,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from PortfolioProject..HousingData a
join PortfolioProject..HousingData b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]


--Breaking the Property Address Column into Address, City, State

select PropertyAddress
from PortfolioProject..HousingData

select 
SUBSTRING(PropertyAddress,1, CHARINDEX(',',propertyAddress)-1) as PropertyAddress2 
from PortfolioProject..HousingData

Alter table PortfolioProject..HousingData
Add PropertyAddress2 nvarchar(255);

Update PortfolioProject..HousingData
set PropertyAddress2 = SUBSTRING(PropertyAddress,1, CHARINDEX(',',propertyAddress)-1) 
from PortfolioProject..HousingData


select 
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyAddress)) as PropertyCity
from PortfolioProject..HousingData

Alter Table PortfolioProject..HousingData
Add PropertyCity nvarchar(255);

update PortfolioProject..HousingData
set PropertyCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(propertyAddress))
from PortfolioProject..HousingData


--Breaking the Owner Address Column into Address, City, State

select OwnerAddress
from PortfolioProject..HousingData


select PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerAddress1
from PortfolioProject..HousingData

Alter Table PortfolioProject..HousingData
Add OwnerAddress1 nvarchar(255);

Update  PortfolioProject..HousingData
Set OwnerAddress1 = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
                     from PortfolioProject..HousingData


Select PARSENAME( REPLACE(OwnerAddress,',','.'),2)
from PortfolioProject..HousingData

Alter Table PortfolioProject..HousingData
Add OwnerCity nvarchar(255);

Update PortfolioProject..HousingData
Set OwnerCity = PARSENAME( REPLACE(OwnerAddress,',','.'),2)
				from PortfolioProject..HousingData


select PARSENAME( REPLACE( OwnerAddress,',','.'),1)
from PortfolioProject..HousingData

Alter Table PortfolioProject..HousingData
Add OwnerState nvarchar(255);

Update PortfolioProject..HousingData
Set OwnerState = PARSENAME( REPLACE( OwnerAddress,',','.'),1)
				from PortfolioProject..HousingData


--Change the Y and N to Yes and No in "SoldAsVacant" Column

select SoldAsVacant
from PortfolioProject..HousingData

select Distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject..HousingData
Group by SoldAsVacant 
order by count(SoldAsVacant)

Select SoldAsVacant,
	Case 
	When SoldasVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	else  SoldAsVacant
	END
from PortfolioProject..HousingData

Update PortfolioProject..HousingData
Set SoldAsVacant = 	Case 
	When SoldasVacant = 'Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	else  SoldAsVacant
	END
from PortfolioProject..HousingData

--Remove Duplicates Row
WITH ROWNUM_CTE AS(
select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) RowNum
from PortfolioProject..HousingData
)
delete 
from ROWNUM_CTE
where RowNum > 1