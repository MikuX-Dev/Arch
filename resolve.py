import subprocess

def rebase_or_merge():
    # Ask for the branch to rebase from
    branch_name = input("Enter the branch name to rebase from: ")

    # Ask for the Git URL to fetch
    git_url = input("Enter the Git URL to fetch: ")

    # Fetch the repository
    subprocess.run(["git", "fetch", git_url])

    # Ask whether to rebase or merge
    operation = ""
    while operation.lower() not in ["rebase", "merge"]:
        operation = input("Enter 'rebase' or 'merge' to continue: ")

    # Perform rebase or merge based on the chosen operation
    if operation.lower() == "rebase":
        subprocess.run(["git", "rebase", f"origin/{branch_name}"])
    elif operation.lower() == "merge":
        subprocess.run(["git", "merge", f"origin/{branch_name}"])

    # Automatically resolve merge conflicts
    subprocess.run(["git", "diff", "--name-only", "--diff-filter=U"], capture_output=True)
    conflict_files = subprocess.run(["git", "diff", "--name-only", "--diff-filter=U"], capture_output=True, text=True).stdout.splitlines()

    for file in conflict_files:
        print(f"Resolving conflicts in: {file}")
        subprocess.run(["git", "checkout", "--theirs", file])
        subprocess.run(["git", "add", file])

    # Commit the merge changes
    subprocess.run(["git", "commit", "-m", "Merge branch"])

    print("Merge conflicts resolved successfully!")


# Call the function to run the script
try:
    with open("git_log.txt", "w") as log_file:
        # Redirecting stdout and stderr to the log file
        subprocess.run(["python", "script.py"], stdout=log_file, stderr=log_file)
    print("Script executed successfully! Log file saved as git_log.txt.")
except Exception as e:
    print(f"An error occurred: {str(e)}")
