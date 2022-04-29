make_ndg_to_plot <- function(df_to_clean,sub_title) {
  # set up
  summarySE <- function(data=NULL, measurevar, groupvars=NULL, na.rm=TRUE,
                        conf.interval=.95, .drop=TRUE) 
  {  require(plyr) 
    length2 <- function (x, na.rm=TRUE) 
    {if (na.rm) sum(!is.na(x))
      else length(x)}
    datac <- ddply(data, groupvars, .drop=.drop, .fun = function(xx, col) 
    {c(N = length2(xx[[col]], na.rm=na.rm), mean = mean   (xx[[col]], na.rm=na.rm),
       sd = sd (xx[[col]], na.rm=na.rm))},
    measurevar)
    datac <- rename(datac, c("mean" = measurevar))
    datac$se <- datac$sd / sqrt(datac$N)  # Calculate standard error of the mean
    ciMult <- qt(conf.interval/2 + .5, datac$N-1)
    datac$ci <- datac$se * ciMult
    return(datac) }
  
  pres_theme <- theme(    
    panel.background    = element_blank() ,            #   control the major gridlines 
    panel.grid.major.y  = element_line() ,             #   suppress the vertical grid lines
    panel.grid.major.x  = element_blank() ,            #   suppress the minor grid lines
    panel.grid.minor    = element_blank() ,            #   add axes
    axis.text           = element_text( size=20, family="Times", colour='black'),   #   tick labels' size, font & color. 
    axis.line.x         = element_line( size=.8),   #   adjust the axis ticks
    axis.line.y         = element_line( size=.8),
    axis.ticks          = element_line( size=.8, colour='black'),   #   axis colors and thickness 
    axis.title.y        = element_text( angle=90, vjust= 1.5, hjust=.47,    
                                        size=20, family="Times"),  
    axis.title.x        = element_text( vjust=-.5, hjust = .505,                    
                                        size=20, family="Times "),                   
    plot.title = element_text (size=20, family="Times", colour='black', face = 'bold'),
    legend.text = element_text(size=20, family="Times"),
    legend.title = element_text(size=20, family="Times", face = 'bold')
  )
  
  df_to_clean$participant=factor(df_to_clean$participant)
  is.factor(df_to_clean$participant)
  
  library(dplyr)
  
  nd7_emto = df_to_clean %>% 
    filter(study_instruction_condition %in% c("view", "decrease"))
  
  detach("package:dplyr")
  
  ObBg <- nd7_emto$scene_component
  outcome = nd7_emto$corrected_recognition
  valence = nd7_emto$valence
  part_id = as.factor(nd7_emto$participant)
  # Create emotional memory trade-off figure
  df3 <- data.frame(ObBg, valence, outcome,part_id)
  df3<-na.omit(df3)
  dfc <- summarySE(df3, measurevar = "outcome", groupvars = c("valence","ObBg")) #insert variables
  dfc$x_coord = c(1,1.8,3,3.8)
  dfc
  # 1= negative background, 2 = negative objects, 3 = neutral backgrounds, 4 = neutral backgrounds
  library(dplyr)
  
  df3 = df3%>%
    mutate(x_coord = ifelse(ObBg == "objects" & valence == "negative", 1.8, 
                            ifelse(ObBg == "background" & valence == "negative", 1,
                                   ifelse(ObBg == "objects" & valence == "neutral", 3.8,
                                          ifelse(ObBg == "background" & valence == "neutral", 3,5)))))
  detach("package:dplyr", unload=TRUE)
  Change_plot = ggplot (na.omit(dfc), aes (x_coord, outcome, fill =  ObBg))
  p1 =Change_plot +
    stat_summary(fun.y = "mean", geom = "bar", aes(width = .75), colour = "black", position = "dodge", alpha = .6)+
    scale_fill_manual(values = c( "background" = "grey", "objects" = "slategray"),
                      labels = c( "background", "object")
    ) +
    scale_x_discrete(labels=c("negative","neutral") 
    )+
    geom_errorbar(aes(ymin = outcome - se,  
                      ymax = outcome + se), 
                  size=.3, width=.1,color = "black", position=position_dodge(.75))+
    geom_point(data = df3,aes(x = x_coord, y = outcome, color = ObBg),
               position = position_jitter(width = .1, height = 0), 
               size = 4, shape = 20, alpha = .6)+
    scale_color_manual(values = c( "background" = "grey", "objects" = "slategray"),
                       labels = c( "background", "object")
    )  +
    xlab ("") +
    labs(subtitle = sub_title)+
    scale_y_continuous("Corrected recognition\n", breaks=c(0,.1,.2,.3,.4,.5,.6,.7,.8), expand = c(0, 0))+
    coord_cartesian(y=c(0,.9)) +
    scale_x_continuous(breaks = (c(1.4,3.4)),
                       labels = c("negative","neutral")) + 
    ggtitle ("Emotional memory trade-off\n")+
    theme(plot.title = element_text(hjust = 0.5))+
    pres_theme+
    theme(legend.title=element_blank()) + 
    theme(legend.position="bottom")
  p1
  return(p1)
}