FROM openshift/base-centos7

#EXPOSE 8081

ENV TOMCAT_VERSION=8.5.45 \
    MAVEN_VERSION=3.5.4 \
    STI_SCRIPTS_PATH=/usr/libexec/s2i/
ENV pip_packages="ansible"
LABEL io.k8s.description="Platform for building and running JEE applications on Tomcat" \
      io.k8s.display-name="Tomcat Builder" \
      io.openshift.tags="builder,tomcat" \
      io.openshift.s2i.destination="/opt/s2i/destination"
 
# pip install --upgrade pip
#RUN yum -y install openshift-ansible
RUN yum install java-1.8.0-openjdk  java-1.8.0-openjdk-devel -y
COPY apache-maven-3.5.4-bin.tar.gz /
COPY oc /usr/local/bin/
RUN  ls -l /usr/local/bin/
# Install Maven, Tomcat 8.5.24
RUN INSTALL_PKGS="tar java-1.8.0-openjdk java-1.8.0-openjdk-devel" && \
    yum install -y --enablerepo=centosplus $INSTALL_PKGS && \
    rpm -V $INSTALL_PKGS && \
    yum clean all -y && \
    tar -xvf /apache-maven-3.5.4-bin.tar.gz    -C /usr/local && \
    ln -sf /usr/local/apache-maven-$MAVEN_VERSION/bin/mvn /usr/local/bin/mvn && \
    mkdir -p $HOME/.m2 && \
    rm -rf /spring/boot/* && \
    mkdir -p /opt/s2i/destination && \
    mkdir /tmp/src && \
    mkdir -p /opt/maven/repository/ && \
    chmod 777 /opt/maven/repository && \
    chmod 777 /usr/local/bin/oc && \
    mkdir  /springboot/ && \
    mkdir /logs	&& \
	chmod 777 /opt/
#RUN yum install -y git

# Add s2i customizations
ADD ./settings.xml $HOME/.m2/
# Copy the S2I scripts from the specific language image to $STI_SCRIPTS_PATH
#COPY ./s2i/bin/ $STI_SCRIPTS_PATH
COPY ./s2i/bin/ /usr/libexec/s2i

RUN chmod -R a+rw /logs && \
    chmod -R a+rw /springboot && \
    chmod -R a+rw $HOME && \
    chmod -R +x $STI_SCRIPTS_PATH && \
    chmod -R g+rw /opt/s2i/destination && \
	chmod -R 777 /opt/ 
	
USER 1001

CMD $STI_SCRIPTS_PATH/usage
