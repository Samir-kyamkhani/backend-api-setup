#!/bin/bash

# Function to prompt user for input with a default value
ask() {
    local prompt=$1
    local default=$2
    while true; do
        read -p "$prompt (default: $default): " input
        input=${input:-$default}  # Set default if input is empty
        echo "$input"
        return
    done
}

# Function to prompt user for yes/no input
ask_yes_no() {
    local prompt=$1
    while true; do
        read -p "$prompt (y/n): " yn
        case $yn in
            [Yy]* ) return 0;;  # Yes
            [Nn]* ) return 1;;  # No
            * ) echo "Please answer yes or no.";;
        esac
    done
}

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Node.js is not installed. Installing Node.js..."
    
    if ! command -v curl &> /dev/null; then
        echo "Curl is not installed. Please install curl and re-run the script."
        exit 1
    fi

    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js is already installed."
fi

# Initialize npm project
echo "Initializing npm project..."
npm init -y

# Get package details from the user
echo "Please provide the following details for your package.json (press Enter to use default values):"
name=$(ask "Package name" "backend")
version=$(ask "Package version" "1.0.0")
author=$(ask "Author name" "Your Name")
description=$(ask "Package description" "A backend API project")

# Create package.json with user input
cat <<EOL > package.json
{
  "name": "$name",
  "version": "$version",
  "main": "index.js",
  "type": "module",
  "scripts": {
    "dev": "nodemon -r dotenv/config --experimental-json-modules src/index.js"
  },
  "author": "$author",
  "license": "ISC",
  "description": "$description",
  "devDependencies": {
    "nodemon": "^3.1.9",
    "prettier": "^3.4.2"
  },
  "dependencies": {
    "bcrypt": "^5.1.1",
    "cloudinary": "^2.5.1",
    "cookie-parser": "^1.4.7",
    "cors": "^2.8.5",
    "dotenv": "^16.4.7",
    "express": "^4.21.2",
    "jsonwebtoken": "^9.0.2",
    "mongoose": "^8.9.5",
    "multer": "^1.4.5-lts.1"
  }
}
EOL

echo "package.json file created successfully."

# Install dependencies if user agrees
if ask_yes_no "Do you want to install dependencies?"; then
    npm install
else
    echo "Skipping dependency installation."
fi

# Create .env file if it does not exist
if [ ! -f .env ]; then
    echo "Creating .env file..."
    cat <<EOL > .env
PORT=2000
MONGODB_URI=
CLIENT_URL=
CLOUD_NAME=
CLOUDINARY_API_KEY=
CLOUDINARY_SECRET_KEY=
EOL
    echo ".env file created. Please update it with correct values."
else
    echo ".env file already exists. Skipping..."
fi

# Create necessary folders if they don't exist
mkdir -p src/{controllers,db,middlewares,models,routes,utils} public/temp

# Create necessary files if they don't exist
touch src/{index.js,app.js,constants.js} src/db/db.js src/utils/{asyncHandler.js,ApiError.js,ApiResponse.js,cloudinary.js} src/middlewares/multer.js

# Populate index.js with content
cat <<EOL > src/index.js
import db_connection from "./db/db";
import app from "./app";
import dotenv from "dotenv";

dotenv.config({
  path: "./.env",
});

const PORT = process.env.PORT || 5000;

db_connection()
  .then(() => {
    app.on("error", function (error) {
      console.log(\`SERVER LISTENING ERROR :: \${error}\`);
    });

    app.listen(PORT, function () {
      console.log(\`SERVER RUNNING ON PORT \${PORT}\`);
    });
  })
  .catch(() => {
    console.log(\`SERVER CONNECTION FAILED :: \${error} \`);
    throw error;
  });
EOL
echo "index.js file created."

# Populate app.js
cat <<EOL > src/app.js
import express from "express";
import cors from "cors";
import cookieParser from "cookie-parser";

const app = express();
const data = "16kb";

app.use(
  cors({
    origin: process.env.CLIENT_URL,
    credentials: true,
  }),
);

app.use(express.json({ limit: data }));
app.use(express.urlencoded({ extended: true, limit: true }));
app.use(express.static("public"));
app.use(cookieParser());

export default app;
EOL
echo "app.js file created."

# Populate constants.js
cat <<EOL > src/constants.js
export const DB_NAME = "";
EOL
echo "constants.js file created."

# Populate ApiError.js
cat <<EOL > src/utils/ApiError.js
class ApiError extends Error {
  constructor(
    statusCode,
    message = "Something went wrong!",
    errorStack = "",
    errors = [],
  ) {
    super(message);
    this.statusCode = statusCode;
    this.message = message;
    this.errors = errors;
    this.data = null;
    this.success = false;

    if (errorStack) {
      this.errorStack = errorStack;
    } else {
      Error.captureStackTrace(this, this.constructor);
    }
  }
}

export { ApiError };
EOL
echo "ApiError.js file created."

# Populate ApiResponse.js
cat <<EOL > src/utils/ApiResponse.js
class ApiResponse {
  constructor(statusCode, message = "Success", data) {
    this.statusCode = statusCode;
    this.message = message;
    this.data = data;
    this.success = statusCode < 400;
  }
}

export { ApiResponse };
EOL
echo "ApiResponse.js file created."

# Populate asyncHandler.js
cat <<EOL > src/utils/asyncHandler.js
const asyncHandler = (requestHandler) => (req, res, next) => {
  Promise.resolve(requestHandler(req, res, next)).catch((error) =>
    next(error.message),
  );
};

export { asyncHandler };
EOL
echo "asyncHandler.js file created."

# Populate cloudinary.js
cat <<EOL > src/utils/cloudinary.js
import { v2 as cloudinary } from "cloudinary";
import fs from "fs";

cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_SECRET_KEY,
});

const uploadOnCloudinary = async (localFilePath) => {
  try {
    if (!localFilePath) return "File Not Found!" || null;

    const response = await cloudinary.uploader.upload(localFilePath, {
      resource_type: "auto",
    });

    fs.unlinkSync(localFilePath); // remove the local saved file after successful upload
    return response;
  } catch (error) {
    fs.unlinkSync(localFilePath); // remove the local saved file if upload fails
    return null;
  }
};

const deleteFromCloudinary = async (findePost) => {
  try {
    if (!findePost) return "File Not Found!" || null;

    const oldThumbnail = findePost.thumbnail;
    const splitThumbnail = oldThumbnail.split("/");
    const thumbnailFile = splitThumbnail[splitThumbnail.length - 1];
    const splitDotThumbnail = thumbnailFile.split(".")[0];

    await cloudinary.uploader.destroy(splitDotThumbnail, {
      resource_type: "auto",
    });
  } catch (error) {
    return null;
  }
};

export { uploadOnCloudinary, deleteFromCloudinary };
EOL
echo "cloudinary.js file created."

# Populate multer.js
cat <<EOL > src/middlewares/multer.js
import multer from "multer";
import path from "path";

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "./public/temp");
  },

  filename: (req, file, cb) => {
    const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
    const fileExtension = path.extname(file.originalname);
    const baseName = path.basename(file.originalname, fileExtension);
    cb(null, \`\${baseName}-\${uniqueSuffix}\${fileExtension}\`);
  },
});

export const upload = multer({
  storage,
});
EOL
echo "multer.js file created."

# Populate db.js
cat <<EOL > src/db/db.js
import mongoose from "mongoose";
import { DB_NAME } from "../constants";

const db_connection = async () => {
  try {
    const connectionInstance = await mongoose.connect(
      \`\${process.env.MONGODB_URI}/\${DB_NAME}\`,
    );

    console.log(\`Db connection successfully \${connectionInstance.connection.host}\`);
  } catch (error) {
    console.log(\`Db connection failed :: \${error}\`);
  }
};

export default db_connection;
EOL
echo "db.js file created."

# Create .gitignore file
cat <<EOL > .gitignore
node_modules/
.env
public/temp/
EOL
echo ".gitignore created."

# Create .prettierignore file
cat <<EOL > .prettierignore
/.vscode
/node_modules
./dist
*.env
.env
.env.*
EOL
echo ".prettierignore created."

# Create .prettierrc file
cat <<EOL > .prettierrc
{
  "singleQuote": false,
  "bracketSpacing": true,
  "tabWidth": 2,
  "trailingComa": "es5",
  "semi": true
}
EOL
echo ".prettierrc created."

# Create .gitkeep file in temp directory
touch public/temp/.gitkeep
echo ".gitkeep file created in public/temp"

echo "Setup complete!"
