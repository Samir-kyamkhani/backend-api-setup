# Backend API Project

This project provides a backend API built with **Node.js**, **Express**, **MongoDB**, and **Cloudinary**.

## Key Features

- **Node.js & Express**: For building the API and handling HTTP requests.
- **MongoDB**: A NoSQL database to store data.
- **Cloudinary**: For handling file uploads (like images) easily.
- **Multer**: A library for handling file uploads in Express.
- **Error Handling**: Custom error responses to handle issues smoothly.

---

## How to Install and Run the Project

### 1. Clone the Repository

Open your terminal or command prompt, then clone the repository and navigate into the project directory.

```bash
git clone https://github.com/Samir-kyamkhani/backend-api-setup.git
cd backend-api-setup
```

### 2. Run the Setup Script

Next, you'll run the setup script, which will do the following:

- Install **Node.js** (if it’s not already installed).
- Create all the necessary files and folders.
- Install required dependencies (like Express, MongoDB, Cloudinary).
- Create a `.env` file with placeholders for your credentials.

#### On Windows (PowerShell):

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\backend-api-setup.ps1
```

#### On Linux/Mac (Bash):

```bash
chmod +x backend-api-setup.sh
./backend-api-setup.sh
```

### 3. Configure the `.env` File

After the setup script finishes, you’ll see a `.env` file in your project folder. Open it and replace the placeholders with your actual information:

- **PORT**: The port where your server will run (default: 2000).
- **MONGODB_URI**: Your MongoDB connection string.
- **CLIENT_URL**: Your client-side URL (for handling CORS).
- **Cloudinary** credentials: You need your **Cloudinary** Cloud Name, API Key, and Secret Key.

Example `.env` file:

```env
PORT=2000
MONGODB_URI=<Your MongoDB URI>
CLIENT_URL=<Your Client URL>
CLOUD_NAME=<Your Cloudinary Cloud Name>
CLOUDINARY_API_KEY=<Your Cloudinary API Key>
CLOUDINARY_SECRET_KEY=<Your Cloudinary Secret Key>
```

### 4. Install Dependencies

If dependencies weren’t installed automatically, run this to install them:

```bash
npm install
```

### 5. Start the Server

Once everything is set up, start the server by running:

```bash
npm run dev
```

This will start the server on the port you specified in the `.env` file (default: `2000`).

---

## Project Folder Structure

Once the setup is complete, your project will look like this:

```
backend-api-setup/
├── public/temp/           # Temporary folder for file uploads (handled by Multer)
├── src/                   # All your code files
│   ├── controllers/       # Files for handling API logic
│   ├── db/                # MongoDB connection code
│   ├── middlewares/       # Middleware files like Multer
│   ├── models/            # MongoDB models
│   ├── routes/            # API routes
│   ├── utils/             # Utility files (Cloudinary, error handling, etc.)
│   ├── app.js             # Express app setup
│   ├── constants.js       # Constants (e.g., DB name)
│   └── index.js           # Entry point for the server
├── .env                   # Contains sensitive environment variables
├── .gitignore             # Files to ignore in git (e.g., node_modules)
└── package.json           # NPM configuration file
```

---

## License

This project is open-source and licensed under the MIT License. See the LICENSE file for more details.

---

### Troubleshooting

- **Node.js Issues**: If the script fails to install Node.js, make sure **curl** is installed. You can install it manually if needed:

  ```bash
  sudo apt-get install curl  # For Linux/Mac
  ```

- **MongoDB Connection**: If MongoDB isn’t connecting, double-check your **MongoDB URI** and ensure the database is running.

- **Cloudinary**: Make sure you have the correct **Cloudinary credentials** in the `.env` file.

---

That’s it! You should now have a working backend API project.

### Summary:

- **Clarity**: The steps have been broken down into clear, easy-to-follow instructions.
- **Simplicity**: Only necessary information is included to keep it user-friendly.
- **Troubleshooting**: Simple solutions to common issues.

Let me know if this works for you!
