#   VISUALIZATION PROJECT ON " GOOD_READ_BOOKS "
#                       UNDER THE GUIDENCE OF : PROF. SUDEEP MALLICK


#Visualizing different factors for having a good review of books
#
#________________________________________________________________________###
#..



library(ggplot2)
library(dplyr)

#Read data from file
books<-read.csv("booksP.csv")
books<-na.omit(books)

#datatype conversion
books$language_code<-as.factor(books$language_code)
books$average_rating<-as.numeric(books$average_rating)
books$num_pages<-as.integer(books$num_pages)
books$ratings_count<-as.integer(books$ratings_count)
books$text_reviews_count<-as.integer(books$text_reviews_count)

#Adding derived column
books<-cbind(books,review_index=books$text_reviews_count/books$ratings_count)

books<-na.omit(books)

#(1) average rating vs. number of books of that rating
ggplot(books, aes(average_rating)) + geom_freqpoly(binwidth=0.01,color = "blue")+
   labs( x = "Average Rating", y = "Number of books",title ="Distribution of average rating in the dataset",caption = "Fig. 1" )

#(2) Number of reviews
#(a) ratings_count distribution
ratingcount.df<-data.frame(table(books$ratings_count))
names(ratingcount.df)<-c("ratings_count","cum_freq")
ratingcount.df$cum_freq<-rev(cumsum(rev(ratingcount.df$cum_freq)))
ggplot(ratingcount.df, aes(x=ratings_count, y=cum_freq)) +  geom_col()+
  labs(x="Numer of Ratings",y="Cummulative Frequency",title="Cummulative frequency(greater than type) plot for Ratings count",caption="Fig. 2.a")+
  scale_x_discrete(breaks = levels(ratingcount.df$ratings_count)[c(T,rep(F,999))])

#(b) text reviews distribution
treviewcount.df<-data.frame(table(books$text_reviews_count))
names(treviewcount.df)<-c("text_reviews_count","cum_freq")
treviewcount.df$cum_freq<-rev(cumsum(rev(treviewcount.df$cum_freq)))
ggplot(treviewcount.df, aes(x=text_reviews_count, y=cum_freq)) +  geom_col()+
  labs(x="Numer of Text Reviews",y="Cummulative Frequency",title="Cummulative frequency(greater than type) plot for Number of Text Reviews",caption = "Fig. 2.b")+
  scale_x_discrete(breaks = levels(ratingcount.df$ratings_count)[c(T,rep(F,205))])
  


#(c) total reviews distribution
reviews.df<-data.frame(table(books$ratings_count+books$text_reviews_count))
names(reviews.df)<-c("reviews_count","cum_freq")
reviews.df$cum_freq<-rev(cumsum(rev(reviews.df$cum_freq)))
ggplot(reviews.df, aes(x=reviews_count, y=cum_freq)) +  geom_col()+
  labs(x="Total Numer of Reviews",y="Cummulative Frequency",title="Cummulative frequency(greater than type) Total Number of Reviews",caption = "Fig. 2.c")+
  scale_x_discrete(breaks = levels(ratingcount.df$ratings_count)[c(T,rep(F,299))])


#(d) review index distribution
ggplot(books,aes(review_index))+
  geom_freqpoly(binwidth=0.007,colour="red")+
  labs(x="Review Index",y="Frequency",title="Frequency polygon for Review Index",caption = "Fig. 2.d")

#(3) Number of books for different languages
lang<-data.frame(table(books$language_code))
lang<-lang[order(lang$Freq,decreasing=T),]
levels(lang$Var1)<-c(levels(lang$Var1),"others")
lang<-rbind(lang %>% top_n(7,lang$Freq),c("others",sum(lang$Freq[8:31],na.rm=T)))
ggplot(lang, aes(x="", y=as.integer(Freq), fill=Var1))+
  geom_bar(width = 1, stat = "identity")+
  coord_polar("y", start=0)+
  labs(x="Languages",y="Number of books",title="Pie Chart for number of books of different languages",caption = "Fig. 3")

#(4) Number of books of different pages
ggplot(books,aes(num_pages))+
  geom_histogram(binwidth = 5)+
  labs(x="Number of pages",y="Number of Books",title="Histogram of books of different page numbers",caption = "Fig. 4")+
  coord_cartesian(xlim = c(0,2000),ylim = c(0,350))


#(5) number of authers having exactly certain number of books barplot

# creates a dataframe with number of authors having n number of books
author<-data.frame(table(table(unlist(strsplit(books$authors,split = "/")))))
names(author)<-c("no_of_books","no_of_authors")
ggplot(author, aes(no_of_books, no_of_authors)) +
  geom_col() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_x_discrete(breaks=levels(author$no_of_books)[c(T,rep(F,4))])+
  labs(x="Number of Books",y="Number of authors",title="Number of Authors having n Number of Books",caption = "Fig. 5")+
  coord_cartesian(xlim = c(0,25))+
  scale_fill_brewer(palette = "Blues")


#(6) Book published in different years
pubdate<-substr(books$publication_date, nchar(books$publication_date)-4+1, nchar(books$publication_date))
pubdate<-as.integer(pubdate)
pubdate<-pubdate[pubdate>=1900]
pubdate<-data.frame(table(pubdate))
ggplot(data=pubdate, aes(x=pubdate, y=Freq)) +
  geom_bar(stat = 'identity') +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  scale_x_discrete(breaks=levels(pubdate)[T,rep(F,9)])+
  scale_fill_brewer(palette = "Blues")+
  labs(x="Publication year",y="Number of Books",title = "Books published in different year",caption = "Fig.6")
  




# (7) Language vs average rating

avg.lang<-aggregate(average_rating~language_code, data=books, FUN = mean)
ggplot(avg.lang, aes(language_code, average_rating)) +
  geom_col(aes(colour=language_code))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(title="Average rating for different languages",caption="Fig. 7",x="language",y="average rating")



#(8) number of pages vs average ratings

ggplot(books,aes(num_pages,average_rating))+
  geom_rug(aes(colour="red"))+geom_density_2d()+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(title = "Rug plot: Average Rating vs. Number of Pages",
       caption = "Fig. 8",x="total no of pages",y="average rating")



#(9) Reviews vs average rating
#(a) rating count vs average rating
ggplot(books,aes(average_rating,ratings_count))+
  geom_jitter(aes(colour=average_rating))+
  labs(caption="Fig. 9.a",y="ratings count",x="average rating")+
  coord_cartesian(ylim = c(0,2500000))


#(b) text reviews vs average rating
ggplot(books,aes(average_rating,text_reviews_count))+
  geom_jitter(aes(colour=average_rating))+
  labs(caption="Fig. 9.b",y="text reviews count",x="average rating")+
  coord_cartesian(ylim = c(0,50000))


#(c) Total reviews vs average rating
ggplot(books,aes(average_rating,ratings_count+text_reviews_count))+
  geom_jitter(aes(colour=average_rating))+
  labs(caption="Fig. 9.c",y="text reviews count + ratings count",x="average rating")+
  coord_cartesian(ylim = c(0,2500000))


#(d) review_index vs average rating
ggplot(books,aes(review_index,average_rating))+
  geom_smooth(aes(colour=review_index))+
  labs(caption="Fig. 9.d",x="review index",y="average rating")

#(10) average ratings for different publishers 
#           [ just to see wheather rating is above 4.5]
avg.pub<-aggregate(average_rating~publisher, data=books[], FUN = mean)
ggplot(avg.pub, aes(publisher,average_rating)) +
  geom_col()+
  scale_x_discrete(breaks=NULL)+
  labs(caption = "Fig.10 ",x="publishers",y="average rating")


#(11) pages per book for different languages
pagesperbook<-aggregate(num_pages~language_code,data=books, FUN=mean)
ggplot(pagesperbook,aes(language_code,num_pages))+
  geom_col(aes(colour=language_code))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(caption="Fig. 11",x="language code",y="no of pages")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))


  


#(12) total reviews for different languages
reviews.lang<-aggregate(ratings_count+text_reviews_count~language_code,data=books, FUN=sum)
names(reviews.lang)<-c("language","reviews")
ggplot(reviews.lang,aes(x=language,y=as.integer(reviews)))+
  geom_bar(stat = "identity")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(y="Number of reviews",caption = "Fig. 12")



#(13) number of pages vs  reviews
#(a) pages vs rating count
ggplot(books,aes(num_pages,ratings_count))+
  geom_count(aes(colour=ratings_count))+
  scale_y_continuous( labels = scales::comma)+
  coord_cartesian(ylim = c(0,3000000))+
  labs(caption="Fig. 13.a",x="no of pages",y="ratings count")

#(b) pages vs text reviews count
ggplot(books,aes(num_pages,text_reviews_count))+
  geom_count(aes(colour=text_reviews_count))+
  scale_y_continuous( labels = scales::comma)+
  coord_cartesian(ylim = c(0,60000))+
  labs(caption="Fig. 13.b",x="no of pages",y="text reviews count")


#(c) total reviews vs number of pages
ggplot(books,aes(num_pages,ratings_count+text_reviews_count))+
  geom_count(aes(colour=ratings_count+text_reviews_count))+
  scale_y_continuous( labels = scales::comma)+
  coord_cartesian(ylim = c(0,3000000))+
  labs(caption="Fig. 13.c",x="no of pages",y="ratings count + text reviews count")


#(d) review_index vs number of pages
ggplot(books,aes(num_pages,review_index))+
  geom_count(aes(colour=review_index))+
  scale_y_continuous( labels = scales::comma)+
  labs(caption="Fig. 13.d",x="no of pages",y="review index")





#(14) 3 authors having most number of books
book.author<-data.frame(table(unlist(strsplit(books$authors,split = "/"))))
book.author<-book.author%>% slice_max(Freq,n=3)

  book.author.df<-books[grep(as.character(book.author$Var1[1]),books$authors),]
  book.author.df$num_pages<-cut_width(book.author.df$num_pages,100,boundary=0)
  book.author.df<-aggregate(average_rating~num_pages,data = book.author.df,mean)
  author<-rep(book.author$Var1[1],nrow(book.author.df))
  book.author.df1<-cbind(book.author.df,author)
 
  

   book.author.df<-books[grep(as.character(book.author$Var1[2]),books$authors),]
  book.author.df$num_pages<-cut_width(book.author.df$num_pages,100,boundary=0)
  book.author.df<-aggregate(average_rating~num_pages,data = book.author.df,mean)
  author<-rep(book.author$Var1[2],nrow(book.author.df))
  book.author.df2<-cbind(book.author.df,author)
  
 
  book.author.df<-books[grep(as.character(book.author$Var1[3]),books$authors),]
  book.author.df$num_pages<-cut_width(book.author.df$num_pages,100,boundary=0)
  book.author.df<-aggregate(average_rating~num_pages,data = book.author.df,mean)
  author<-rep(book.author$Var1[3],nrow(book.author.df))
  book.author.df3<-cbind(book.author.df,author)
  
  book.author.df<-rbind(rbind(book.author.df1,book.author.df2),book.author.df3)
  #(a) number of pages vs average ratings
  ggplot(book.author.df,aes(num_pages,average_rating))+
    geom_line(aes(group = author,colour=author))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    labs(title = "Comparison among the authors having most number of books",
         x="no of pages",y="average rating",caption = "Fig. 14.a")

  
  #(b) total reviews vs average rating for top 3 author

 # book.author.review<-books[c(grep(as.character(book.author$Var1[1]),books$authors),grep(as.character(book.author$Var1[2]),books$authors),grep(as.character(book.author$Var1[3]),books$authors)),]
  book.author.review.df1<-books[grep(as.character(book.author$Var1[1]),books$authors),]
  book.author.review.df2<-books[grep(as.character(book.author$Var1[2]),books$authors),]
  book.author.review.df3<-books[grep(as.character(book.author$Var1[3]),books$authors),]
  author1<-rep(book.author$Var1[1],nrow(book.author.review.df1))
  author2<-rep(book.author$Var1[2],nrow(book.author.review.df2))
  author3<-rep(book.author$Var1[3],nrow(book.author.review.df3))
  
  book.1<-cbind(book.author.review.df1,author=author1)
  book.2<-cbind(book.author.review.df2,author=author2)
  book.3<-cbind(book.author.review.df3,author=author3)
  
  book.author.review<-rbind(rbind(book.1,book.2),book.3)
  
  
  ggplot(book.author.review,aes(ratings_count+text_reviews_count,average_rating))+
    geom_line(aes(group = author,colour=author))+ (xlim(0,5000))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    labs(x="Total reviews",y="average rating",caption = "Fig.14.b",title ="Comparison among the authors having most number of books" )
#(c) total reviews vs number of pages
  ggplot(book.author.review,aes(num_pages,ratings_count+text_reviews_count))+
    geom_line(aes(group = author,colour=author))+
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
    labs(y="Total reviews",caption = "Fig.14.c",title ="Comparison among the authors having most number of books" )
  
  
  
#(15) For top 3 publishers
  publishers.top<-data.frame(table(books$publisher))
publishers.top<-publishers.top %>% slice_max(Freq,n=3)    
pub.top<-as.character(publishers.top$Var1)
publishers.top.df1<-books[books$publisher==pub.top[1] | books$publisher==pub.top[2] | books$publisher==pub.top[3] ,]

# (a) number of pages vs average ratings
ggplot(publishers.top.df1,aes(num_pages,average_rating))+
  geom_line(aes(group = publisher,colour=publisher))+(xlim(400,800))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(caption = "Fig.15.a",x="total no of pages of book",y="average rating",title ="Comparison among the publishers having most number of books" )

# (b) total reviews vs average ratings
ggplot(publishers.top.df1,aes(ratings_count+text_reviews_count,average_rating))+
  geom_line(aes(group = publisher,colour=publisher))+(xlim(200,10000))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(x="ratings count + text reviews count",y="average rating",caption = "Fig.15.b",title ="Comparison among the publishers having most number of books" )

#(c) number of pages vs total number of reviews
ggplot(publishers.top.df1,aes(num_pages,ratings_count+text_reviews_count))+
  geom_line(aes(group = publisher,colour=publisher))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(y="Total Reviews",x="total no of book",y="ratings count + text reviews count",caption = "Fig.15.c",title ="Comparison among the publishers having most number of books" )

#(16)
#pub<-data.frame(table(books$publisher))
#pub<-pub[order(pub$Freq,decreasing=T),]
#pub7 <-pub %>% top_n(7,pub$Freq)
#top7publisher  <-as.vector(pub7$Var1)
#lang.pub <-table(books[books$publisher==top7publisher,c(7,12)])
#barplot(lang.pub,1,  beside = T,legend.text= rownames(lang.pub),col =blues9,args.legend  = list(x=ncol(lang.pub)+350,y=50))
#library(RColorBrewer)
#barplot(lang.pub,beside=T,xlim= c(0,ncol(lang.pub)+300),col=brewer.pal(nrow(lang.pub),"Paired"),ylab="no of books",xlab= "name of top 7 pblishers",legend.text= T,args.legend= list(x=ncol(lang.pub)+370))

pub<-data.frame(table(books$publisher))
pub<-pub[order(pub$Freq,decreasing=T),]
pub7 <- pub %>% top_n(7,pub$Freq) 
top7publisher <- as.vector(pub7$Var1); top7publisher  # sera sera

lang.pub <- table(book[book$publisher==top7publisher,c(7,12)])
barplot(lang.pub,1,horiz = FALSE,main = "top 7 publishers and lanuguage used ", beside = T,xlab = "publishers ",angle = 90,legend.text = rownames(lang.pub),col =blues9,args.legend = list(x=ncol(lang.pub)+10))




#(17)
library(plot3D)
rating_count<-books$ratings_count
text_reviews_count<-books$text_reviews_count
average_rating<-books$average_rating
scatter3D(rating_count,text_reviews_count,average_rating,xlab="Rating Count",ylab="Text Reviews Count",zlab="Average Rating",pch = 19,  bty = "g",  type = "h", phi = 0,ticktype = "detailed",cex=0.5)


#(18)

ggplot(books,aes(review_index,average_rating,colour=text_reviews_count))+
  geom_jitter()+
  facet_grid(vars(language_code))+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  labs(caption = "Fig.18",x="review index",y="average rating" )+
  scale_y_continuous(n.breaks = 2)


#(20)
ggplot(books,aes(ratings_count,average_rating,colour=text_reviews_count))+
  geom_point()+
  facet_grid(vars(language_code))+
  theme(axis.text.x = element_text(angle = 0, vjust = 0.5, hjust=1))+
  labs(caption = "Fig.19" ,x="rating count",y="average rating")+
  scale_y_continuous(n.breaks = 2)




#########################################################################################################################
##########################################################################################################################
