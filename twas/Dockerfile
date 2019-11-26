# docker build -t twastest .
# docker run --rm -p 9080:9080 -p 9043:9043 -it twastest
FROM ibmcom/websphere-traditional
ENV ENABLE_BASIC_LOGGING=true
RUN printf 'websphere' > /tmp/PASSWORD
RUN mkdir -p /work/app && wget -q -O /work/app/swat.ear https://raw.githubusercontent.com/kgibm/problemdetermination/master/swat.ear
RUN printf '\n\
ResourceType=Application\n\
ImplementingResourceType=Application\n\
CreateDeleteCommandProperties=true\n\
ResourceId=Deployment\n\
Name=swat\n\
TargetServer=!{serverName}\n\
TargetNode=!{nodeName}\n\
EarFileLocation=/work/app/swat.ear\n\
' > /work/config/was-config.props
RUN /work/configure.sh
