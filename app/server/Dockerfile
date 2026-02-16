FROM node:18-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm install

# Copy application files
COPY . .

# Expose port (5000 is used in the app, but typically inside docker we listen on 5000 too)
EXPOSE 5000

# Start command
CMD ["npm", "start"]
