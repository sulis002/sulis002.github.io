# How I Created My E-Portfolio on GitHub Pages

## Introduction
This guide explains the steps I followed to create my e-portfolio using GitHub Pages and Jekyll’s Minimal theme. It includes setup, customization, and how I organized my files.

## Step 1 - Create a GitHub repository
1. Logged in to my GitHub account [sulis002]
2. Created **new repository** named 'sulis002.github.io'
3. Chose the **Public** option and initialized with a 'README.md'
4. Clone my repository to cloud drive

## Step 2 - Enable GitHub pages
1. Went to **Settings → Pages**.
2. Selected the **main branch** and / '(root)' folder.
3. Saved settings — GitHub automatically generated my website URL:  
   'https://sulis002.github.io'

## Step 3 - Install / configure the theme (YAML)
1. In my repository root, open _config.yml
2. Added the theme and basic site metadata, example as follow:
   <img width="288" height="83" alt="image" src="https://github.com/user-attachments/assets/62079647-9955-4027-ae1b-fb1ce58ed5b5" />
3. Save and commit

## Step 4 - Rewrite index.md with my information 
1. Open index.md in the repository root
2. Typed my resume-style content using markdown element as instructued for Header1–Header3, italic, bold, ordered list, unordered list, link, and inline code
3. Preview of my index.md with my details:
   <img width="1055" height="590" alt="image" src="https://github.com/user-attachments/assets/8c8b246e-da55-4ad8-b779-0b5a28311f9e" />
4. Save and commit

## Step 5 - Added picture in my repository root
1. In the repository root create assets/img folder
2. Rename to assets/img/.gitkeep -> adding .gitkeep so that git will keep the folder in the repository
3. Added my PNG picture IMG_7383.PNG
4. Save and commit

## Step 6 - Replaced logo stock with my headshot
1. Opened _config.yml
2. Edited existing code to below:
   <img width="1059" height="190" alt="image" src="https://github.com/user-attachments/assets/cacc87a1-1ed7-4624-a7c5-d68ade5568ad" />
3. Save and commit

## Step 7 - Verified pages build & deployment
1. Clicked "Actions" tab
2. Confirmed latest workflow for pages and deployment to make sure that it doesn't have any errors

## Final look of my e-portfolio 

<img width="1077" height="660" alt="image" src="https://github.com/user-attachments/assets/73737600-765b-41b3-858b-f1ee50ce5115" />

