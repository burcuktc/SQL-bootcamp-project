------------
create database FINAL_PROJECT
USE FINAL_PROJECT

----Yazarlar tablosu olu�turma-----
create table Yazarlar(
YazarID int primary key,
Yazar�sim varchar(75))

select * from Yazarlar


-----Kitaplar tablosu olu�turma-----
create table Kitaplar(
KitapID int primary key,
KitapAd varchar(75),
YazarID int,
Yayinevi varchar(75),
SayfaSayisi int,
YayinTarihi date
foreign key(YazarID) references Yazarlar(YazarID))

select * from Kitaplar 

-----�yeler tablosu olu�turma-----
create table Uyeler(
UyeID int primary key,
Ad varchar(50),
Soyad varchar(50),
DogumTarihi date,
Cinsiyet varchar(1),
Telefon varchar(15))

select * from Uyeler

-----OduncKitaplar tablosu olu�turma-----
create table OduncKitaplar(
OduncID int primary key,
KitapID int,
UyeID int,
AlimTarihi date,
TeslimTarihi date,
foreign key(KitapID) references Kitaplar(KitapID),
foreign key(UyeID) references Uyeler(UyeID),
)
select * from OduncKitaplar


--V�EW1 ODUNC ALAN K�S�LER
create view vw_OduncAlanKisiler as 
select O.OduncID, U.Ad,U.Soyad, U.Telefon, U.DogumTarihi, U.Cinsiyet, K.KitapID, K.KitapAd,  O.AlimTarihi, O.TeslimTarihi
from OduncKitaplar O 
join Kitaplar K on O.KitapID=K.KitapID
join Uyeler U on O.UyeID=U.UyeID  

SELECT * FROM OduncKitaplar
SELECT * FROM vw_OduncAlanKisiler

-----View2 Yay�nevi Say�s�-----
create view vw_YayineviKitapSayisi as
select K.Yayinevi, count(K.KitapID) as ToplamKitapSay�s�  from Kitaplar K group by K.Yayinevi

select * from vw_YayineviKitapSayisi 


-----View3 Bir yazara ait toplam kitap say�s�-----
create view vw_YazarKitapSayisi as
select Y.Yazar�sim, count(K.KitapID) as ToplamKitapSayisi  from Kitaplar K 
 join Yazarlar Y on K.YazarID=Y.YazarID group by Y.Yazar�sim

select * from vw_YazarKitapSayisi

-----View4 T�m Kitap Bilgileri-----
create view vw_T�mKitapBilgileri as 
select K.KitapID, K.KitapAd,   Y.Yazar�sim, K.SayfaSayisi, K.Yayinevi, K.YayinTarihi from Kitaplar K
join Yazarlar Y on K.YazarID=Y.YazarID

select * from vw_T�mKitapBilgileri

-----View5 En �ok kitap alan �ye-----
create view vw_EnCokKitapAlan as
select top 1 U.UyeID, U.Ad, U.Soyad, count(O.KitapID) as AldigiKitapSayisi   from Uyeler U 
left join OduncKitaplar O on o.UyeID=U.UyeID group by U.UyeID ,U.Ad, U.Soyad order by AldigiKitapSayisi desc

select * from vw_EnCokKitapAlan

select * from Uyeler

--Her bir �yenin ald��� kitap say�s�
SELECT U.UyeID, U.Ad, U.Soyad, COUNT(O.KitapID) AS ToplamKitapSayisi
FROM Uyeler U
LEFT JOIN OduncKitaplar O ON U.UyeID = O.UyeID
GROUP BY U.UyeID, U.Ad, U.Soyad
ORDER BY ToplamKitapSayisi DESC;

---Trigger1 Yeni �ye Eklendi�inde---
create trigger tr_YeniEklenenUye on Uyeler
after insert
as
begin
declare @UyeID int, @Ad varchar(50), @Soyad varchar(50), @DogumTarihi date, @Cinsiyet varchar(1), @Telefon varchar(15)
select @UyeID=UyeID, @Ad=Ad, @Soyad=Soyad, @DogumTarihi=DogumTarihi, @Cinsiyet=Cinsiyet, @Telefon=Telefon from inserted
print 'Yeni �ye ba�ar�l� bir �ekilde eklenmi�tir.Ekelenen �ye ad�:' + @Ad + ' ' + @Soyad
end

select * from Uyeler

insert into Uyeler(UyeID,Ad,Soyad,DogumTarihi,Cinsiyet,Telefon)
values (5564,'Melisa','�ZG�N','1996-06-14','K','550-1207978')
--
select * from Uyeler

--Trigger2 Uyelerde de�i�iklik yap�ld���nda
create trigger tr_UyeUpdate on Uyeler 
after update
as 
begin
If UPDATE(Telefon)
Begin
declare  @Telefon varchar(15)
select @Telefon=Telefon from inserted
print '�ye telefon bilgisi g�ncellenmi�tir. G�ncellenen no:' + @Telefon
end
end

update Uyeler
set Telefon='559-1421818' where UyeID=5500

--Trigger3 UyeSilme ---
create trigger tr_UyeSilme on Uyeler
after delete
as
begin
declare @UyeID int, @Ad varchar(50), @Soyad varchar(50)
select  @UyeID=UyeID, @Ad=Ad, @Soyad=Soyad from deleted
print '�ye ba�ar�l� bir �ekilde silinmi�tir. Silinen �ye id,ad ve soyad bilgileri:' + '  ' +  cast(@UyeID as varchar(10)) + ' ' +  @Ad + ' '  + @Soyad 
end

select*from Uyeler
delete from Uyeler where UyeID=5564

select * from OduncKitaplar

---Trigger4 alim tarihinden 15 g�n sonras�n� teslim tarihi olarak ekleme---
create trigger tr_OduncKitaplarTeslimTarihi
ON OduncKitaplar
AFTER INSERT
AS
BEGIN
    UPDATE O
    SET O.TeslimTarihi = DATEADD(DAY, 15, I.AlimTarihi)
    FROM OduncKitaplar O
    JOIN inserted I ON O.OduncID = I.OduncID
end

select * from OduncKitaplar

insert into OduncKitaplar(OduncID,KitapID,UyeID,AlimTarihi)
values(303,50,1355,'2023-11-19')

select * from OduncKitaplar





--trigger al�m tarihi gecmi� tarih olamaz
create trigger tr_GecmisTarihliVeriKontrol on OduncKitaplar
after insert
as
begin
IF exists(Select 1 from inserted where AlimTarihi<GETDATE())
begin
RAISERROR('Gecmis tarihli veri girdiniz. Ge�mi� tarihli veri giri�i yap�lamaz',16,1)
rollback transaction
end
end

select * from OduncKitaplar
insert into OduncKitaplar(OduncID,KitapID,UyeID,AlimTarihi)
values(304,75,1260,'2023-05-05')




--trigger6 yeni kitap eklendi:
create trigger tr_YeniKitapEkleme on Kitaplar
after insert 
as
begin
declare @KitapID int, @KitapAd varchar(50)
select @KitapAd=KitapAd from inserted
print 'Yeni kitap eklendi. Kitap ad:' + @KitapAd

end

insert into Kitaplar(KitapID,KitapAd,YazarID,Yayinevi,SayfaSayisi)
VALUES (3460,'Zehra','1423','Koridor',178)
SELECT * FROM Kitaplar
-----------------

---------------------

---INDEX
---1---
select * from vw_T�mKitapBilgileri

create index IX_KitaplarKitapAd ON Kitaplar(KitapAd)
create index IX_YazarlarYazar�sim ON Yazarlar(Yazar�sim)
CREATE index IX_UyelerUyeAd On Uyeler(Ad)


SELECT U.UyeID, U.Ad, U.Soyad, Y.YazarID, Y.Yazar�sim, COUNT(*) AS KitapSayisi
FROM Uyeler U
JOIN OduncKitaplar OK ON U.UyeID = OK.UyeID
JOIN Kitaplar K ON OK.KitapID = K.KitapID
JOIN Yazarlar Y ON K.YazarID = Y.YazarID
GROUP BY U.UyeID, U.Ad, U.Soyad, Y.YazarID, Y.Yazar�sim
ORDER BY U.UyeID, COUNT(*) DESC;