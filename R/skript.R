df <- read.csv("../data/narodnosti.csv", header=F, stringsAsFactors=F)

dm <- data.frame(df[2:nrow(df),1])
colnames(dm) <- c("narod")

for(i in 1:(ncol(df)/2)) {

  df.temp <- df[2:nrow(df), (2*i-1):(2*i)]
  colnames(df.temp) <- c("narod", "pocet")
  dm <- merge(dm, df.temp, all=T, by="narod")
  colnames(dm)[ncol(dm)] <- i
  dm <- dm[dm$narod != "",]
  
}

rm(df.temp); rm(i)

colnames(dm)[2:ncol(dm)] <- df[1, seq(from = 1, to = ncol(df), by = 2)]

write.csv(dm, file="../data/narodnosti.csv", row.names=F)
