library(readr)
library(dplyr)
library(exifr)

setwd("~/Desktop/work/")

#�}�X�^�[�ƂȂ�ExifList.csv��ǂݍ���
master <- read_csv("ExifFrame.csv", locale=locale(encoding="CP932"))

#�ЂƂ̃t�@�C����Exif�����ꎞ�I�Ɋm�ۂ��邽�߂Ɏg�p����
temp <- master

#�t�H���_���̃t�@�C�������p�X�ƂƂ��Ɏ擾
lf <- list.files(path="~/Desktop/work/pictures", full.names=T)

#�ǂݍ��񂾃t�@�C�����Ń��[�v����
for(i in 1:length(lf)){

  #exif�擾
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
    temp$GPSDateTime <- "�s��"
  }

  temp$File <- gsub("/Users/ryuseitabata/Desktop/work/pictures/","", lf[i])

  #master�Ƀo�C���h
  master <- rbind(master, temp)
}

#�܂��A���ʂ�csv�t�@�C���ɏ����o���@������͒����[��Windows�ł������悤��CP932�ŃG���R�[�f�B���O
write.csv(master, "exif�擾��.csv", fileEncoding="CP932", row.names=FALSE, quote=FALSE)

#Azure�p��NA�폜���邽�߁A�R�s�[����
master2 <- master

#NA�s���폜
master2 <- na.omit(master2)

#�ȉ��A20180911�ɋ@�\�ǉ��F�t�@�C��ID�ƃe�L�X�g�{����#list.log����ǂݎ��Ainner_join����
#���[���{���ɔ����ȃJ���}��������̂ŁAread_csv�ł͓ǂݍ��ނƎ��s���邽�߁A������read.csv���g�p���w�b�_�[�͂Ȃ��w��œǂݍ��ނׂ�
listlog <- read.csv("#list.log", header=FALSE, fileEncoding="Shift_JIS")

#���[���{���Ɋ܂܂��J���}���폜
listlog$V5 <- gsub(",", "", listlog$V5)

#���[���{���Ɋ܂܂����s�R�[�h(\n)���폜
listlog$V5 <- gsub("\n", "", listlog$V5)

#���[���{���Ɋ܂܂��(_)���폜
listlog$V5 <- gsub("_", "", listlog$V5)

#outlookID�ƃt�@�C��������������inner_join�̃L�[�Ƃ���ID���쐬
listlog <- listlog %>% mutate(ID=paste(listlog$V1, listlog$V6, sep="_"))

#master2��listlog������
master2 <- inner_join(master2, listlog, by=c("File"="ID"))

#Azure�p��csv�t�@�C���ɏ����o���@�������utf-8
write.csv(master2, "exif_master.csv", fileEncoding="UTF-8", row.names=FALSE, quote=FALSE)