library(readr)
library(dplyr)
library(exifr)

setwd("~/Desktop/work/")

#マスターとなるExifList.csvを読み込み
master <- read_csv("ExifFrame.csv", locale=locale(encoding="CP932"))

#ひとつのファイルのExif情報を一時的に確保するために使用する
temp <- master

#フォルダ内のファイル名をパスとともに取得
lf <- list.files(path="~/Desktop/work/pictures", full.names=T)

#読み込んだファイル数でループ処理
for(i in 1:length(lf)){

  #exif取得
  exif <- read_exif(lf[i])

  #GPSLatitude
  if ( !is.null(exif$GPSLatitude) ){
    temp$GPSLatitude <- exif$GPSLatitude
  } else {
    temp$GPSLatitude <- NA
  }

  #GPSLongitude
  if ( !is.null(exif$GPSLongitude) ){
    temp$GPSLongitude <- exif$GPSLongitude
  } else {
    temp$GPSLongitude <- NA
  }

  #GPSDateTime
  if ( !is.null(exif$GPSDateTime) ){
    temp$GPSDateTime <- exif$GPSDateTime
  } else {
    temp$GPSDateTime <- "不明"
  }

  temp$File <- gsub("/Users/ryuseitabata/Desktop/work/pictures/","", lf[i])

  #masterにバインド
  master <- rbind(master, temp)
}

#まず、結果をcsvファイルに書き出し　こちらは庁内端末Windowsでも見れるようにCP932でエンコーディング
write.csv(master, "exif取得状況.csv", fileEncoding="CP932", row.names=FALSE, quote=FALSE)

#Azure用にNA削除するため、コピーする
master2 <- master

#NA行を削除
master2 <- na.omit(master2)

#以下、20180911に機能追加：ファイルIDとテキスト本文を#list.logから読み取り、inner_joinする
#メール本文に微妙なカンマが混じるので、read_csvでは読み込むと失敗するため、あえてread.csvを使用かつヘッダーはなし指定で読み込むべし
listlog <- read.csv("#list.log", header=FALSE, fileEncoding="Shift_JIS")

#メール本文に含まれるカンマを削除
listlog$V5 <- gsub(",", "", listlog$V5)

#メール本文に含まれる改行コード(\n)を削除
listlog$V5 <- gsub("\n", "", listlog$V5)

#メール本文に含まれる(_)を削除
listlog$V5 <- gsub("_", "", listlog$V5)

#outlookIDとファイル名を結合してinner_joinのキーとするIDを作成
listlog <- listlog %>% mutate(ID=paste(listlog$V1, listlog$V6, sep="_"))

#master2とlistlogを結合
master2 <- inner_join(master2, listlog, by=c("File"="ID"))

#Azure用にcsvファイルに書き出し　こちらはutf-8
write.csv(master2, "exif_master.csv", fileEncoding="UTF-8", row.names=FALSE, quote=FALSE)
