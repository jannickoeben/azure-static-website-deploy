FROM ruby:2.4.0	
ENV RUBYGEMS_VERSION=2.7.0



# Set default locale for the environment	
ENV LC_ALL C.UTF-8	
ENV LANG en_US.UTF-8	
ENV LANGUAGE en_US.UTF-8	


ADD entrypoint.sh /entrypoint.sh
RUN chmod +x entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
