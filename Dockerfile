FROM nginx:alpine 
# Spelling mistake fixed: potfolio.html -> index.html 
COPY index.html /usr/share/nginx/html/index.html 
EXPOSE 80