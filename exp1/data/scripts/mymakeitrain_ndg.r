make_it_rain_plot <- function(df_to_clean,sub_title,temp_cf_man, x_break, x_label) {

# ggplot themes.
this_theme <- theme(    
  panel.background    = element_blank() ,            #   control the major gridlines 
  panel.grid.major.y  = element_line() ,             #   suppress the vertical grid lines
  panel.grid.major.x  = element_blank() ,            #   suppress the minor grid lines
  panel.grid.minor    = element_blank() ,            #   add axes
  axis.text           = element_text(size=20, family="Times", colour='black'),   #   tick labels' size, font & color. 
  axis.line.x         = element_line( size=.8),   #   adjust the axis ticks
  axis.line.y         = element_line( size=.8),
  axis.ticks          = element_line( size=.8, colour='black'),   #   axis colors and thickness 
  axis.title.y        = element_text( angle=90, vjust= 1.5, hjust=.47,    
                                      size=20, family="Times"),  
  axis.title.x        = element_text(vjust=-.5, hjust = .505,                    
                                     size=20, family="Times"),                   
  plot.title = element_text (size=20, family="Times", colour='black', face = 'bold'),
  legend.text = element_text(size=20, family="Times"),
  legend.title = element_text(size=20, family="Times", face = 'bold'),
  plot.subtitle = element_text(size=20,  face="bold", color="black")
)

# Raincloud plot function
make_cloud_plot <- function(df1, df2, dv,memory_measure,temp_cf_man, x_break, x_label) {
  plot <- ggplot(data=df1, aes(x = x_location, y = get(dv), fill = study_instruction_condition)) +
    PupillometryR::geom_flat_violin(aes(x = .85, fill = study_instruction_condition),
                     position = position_nudge(x = .1, y = 0), 
                     adjust = .7, trim = TRUE, alpha = .3, 
                     colour = NA, show.legend=FALSE) +
    geom_point(aes(x = x_location, y = get(dv), colour = study_instruction_condition),
               position = position_jitter(width = .05, height = 0), 
               size = 4, shape = 20, alpha = .9) +
    geom_boxplot(aes(x = x_location, y = get(dv), fill = study_instruction_condition),
                 outlier.shape = NA, alpha = .5, width = .1, colour = "black", 
                 notch=FALSE, show.legend=FALSE) +
    geom_line(aes(x = x_location, y = Mean, group = 1), 
              data = df2, linetype = "dashed", size=1) +
    geom_errorbar(aes(x = x_location, group = study_instruction_condition, 
                      y = Mean, ymin = CI_low, ymax = CI_high), 
                  data = df2, width = .05, size=1, colour='black') +
    geom_point(aes(x = x_location, y = Mean, group = study_instruction_condition, fill = study_instruction_condition),
               data = df2, 
               shape = 22, size = 3, stroke = 1, color = "black") +
    scale_colour_manual(values = temp_cf_man)+
    scale_fill_manual(values = temp_cf_man)+
#    scale_colour_manual(values = c("#3C5488FF", "#00A087FF"))+
#    scale_fill_manual(values = c("#3C5488FF" ,"#00A087FF"))+
    #     scale_colour_manual(values = c("#DC0000FF", "#4DBBD5FF", "#00A087FF"))+
    #     scale_fill_manual(values = c("#DC0000FF", "#4DBBD5FF", "#00A087FF"))+   
    ggtitle(sc_type) + 
    ylab(memory_measure) +
    xlab("") +
    labs(subtitle = "\n") +
    scale_x_continuous(expand= c(0,.1),
                       breaks = (x_break),
                       labels = x_label) + 
    #    scale_x_continuous(expand=c(0, .1),
    #                       breaks = (c(.4, .6,.8)),
    #                       labels = c("failure", "success","view")) + 
#    scale_x_continuous(expand=c(0, .1),
#                       breaks = (c(.4, .6)),
#                       labels = c("decrease","view")) + 
    this_theme +
        theme(legend.position="none",
              legend.title=element_blank(),
              axis.text.x = element_text(angle = 45, hjust = 1,
                                         color = c('#DC0000FF','#4DBBD5FF', '#00A087FF')))
    #  color = c('#1B9E77','#D95F02', '#7570B3')))
#    theme(legend.position="none",
#          legend.title=element_blank(),
#          axis.text.x = element_text(angle = 45, hjust = 1,
#                                     color = c('#3C5488FF','#00A087FF')))
  return(plot)
}
# 
# Difference Violin function
make_diff_plot <- function(df1, df2) {
  plot <- ggplot(data=df1, aes(x=as.numeric(comparison), y=difference)) +
    geom_violin(aes(x = as.numeric(comparison), group = comparison, color = "grey"),
                position = position_nudge(x = 0, y = 0), adjust = .7, trim = TRUE,
                alpha = .3, colour = "grey", fill = "grey")+
    geom_errorbar(aes(x = as.numeric(comparison), group = comparison,
                      y = Difference, ymin = CI_low, ymax =CI_high),
                  data = df2, colour = "black", width = .1, size=1) +
    geom_point(aes(x =as.numeric(comparison), y = Difference, group = comparison),
               data = df2,
               shape = 18, size= 3.5, color = "black") +
    geom_hline(aes(yintercept=0), linetype='dotted', size=.8) +
    annotate("text", x = 1, y = .05, label = "p < .001", size = 4) +
    annotate("text", x = 2, y = .05, label = "p = .024", size = 4) +
    annotate("text", x = 3, y = .05, label = "p < .001", size = 4) +   
    scale_x_continuous(breaks = c(1,2,3),
                       labels= c("informed - no cue","informed - uninformed","uninformed - no cue")) +
    ylab("Difference scores\n") +
    xlab("") +
    labs(subtitle = '') +
    this_theme +
    theme(legend.position = "None",
          axis.text.x = element_text(angle = 45, hjust = 1))
  return(plot)
}

library(dplyr)
nd7_stat_neg = df_to_clean %>%filter(valence == "negative", study_instruction_condition != "decrease")%>% 
  droplevels()
#run model
nd7_stat_neg_aov <- aov_ez('participant','corrected_recognition',nd7_stat_neg,
                           within=c('study_instruction_condition',"scene_component"),
                           anova_table = list(es='pes'))
m_nd7_stat_neg_aov = emmeans(nd7_stat_neg_aov, "scene_component", by = c("study_instruction_condition"))
model = summary(m_nd7_stat_neg_aov)
study_instruction_condition = c("failure", "success","view")
sc = c("objects","background")
# Get the  means and CIs
model_means = modelbased::estimate_means(nd7_stat_neg_aov)

cr_df = model_means
cr_df$x_location <- c(.8, .6, .4) # V,S,F
cr_df$x_location <- cr_df$x_location + .1
cr_df_objects = cr_df%>%
  filter(scene_component == "objects")
cr_df_objects

df2_x_axis = nd7_stat_neg %>%
  mutate(x_location = 
           case_when(study_instruction_condition == "success" ~.6,
                     study_instruction_condition == "failure" ~.4,
                     study_instruction_condition == "view" ~.8))
df2_x_axis = df2_x_axis%>%
  filter(scene_component == "objects")

# Make the plots
sc_type = "Objects"
memory_measure = "Corrected recognition" #
#study_instruction_condition

rain_objects <- make_cloud_plot(df2_x_axis, cr_df_objects,'corrected_recognition',memory_measure,temp_cf_man, x_break, x_label)
rain_objects
#backgrounds
cr_df_background = cr_df%>%
  filter(scene_component == "background")
cr_df_background

df2_x_axis_bg = nd7_stat_neg %>%
  mutate(x_location = 
           case_when(study_instruction_condition == "success" ~.6,
                     study_instruction_condition == "failure" ~.4,
                     study_instruction_condition == "view" ~.8))
df2_x_axis_bg = df2_x_axis_bg%>%
  filter(scene_component == "background")
# Make the plots
memory_measure = "Corrected recognition" #
sc_type = "Backgrounds"
#study_instruction_condition
rain_bg <- make_cloud_plot(df2_x_axis_bg, cr_df_background,'corrected_recognition',memory_measure,temp_cf_man, x_break, x_label)
rain_bg

panel_plot = rain_objects + rain_bg

return(panel_plot)
}
