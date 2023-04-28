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
                 notch=TRUE, show.legend=FALSE) +
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
    ggtitle(sc_type) + 
    ylab(memory_measure) +
    xlab("") +
    labs(subtitle = "\n") +
    scale_x_continuous(expand= c(0,.1),
                       breaks = (x_break),
                       labels = x_label) + 
    this_theme +
    theme(legend.position="none",
          legend.title=element_blank(),
          axis.text.x = element_text(angle = 45, hjust = 1,
                                     color = c(temp_cf_man)))
  return(plot)
}
