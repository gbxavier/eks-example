FROM node:lts-alpine3.14

# Create working directory
WORKDIR /usr/src/app

# Install app dependencies, once the node_modules is not checked out
# The wildcard ensures both package.json AND package-lock.json are copied
# Copying only package.json to take advantage of cached Docker layers.
COPY package*.json ./
RUN npm install

# Copy app source
COPY . .

# Tells docker that you expect to listen to this port
EXPOSE 8080

# That's one small step for man, one giant leap (or node_module) for mankind.
# Neil Armstrong
CMD ["node", "index.js"]