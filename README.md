# Intune-Autopliot-Json-Downloader

This PowerShell application provides a graphical user interface (GUI) for downloading AutopilotConfigurationFile.json from Intune via Graph API. It allows you to connect to an Azure tenant, browse for a directory to save Autopilot profile json, and update the necessary PowerShell modules.

![image](https://raw.githubusercontent.com/christian45410/intune-autopliot-json-downloader/main/Screenshot.png)

## Prerequisites

Before running the application, ensure that you have the following prerequisites:

- PowerShell
- Access to an Azure tenant with appropriate Graph API permissions.
- Internet connectivity to install/update PowerShell modules.

## Installation and Usage

1. Clone or download the repository to your local machine.

2. Run the script to launch the GUI application.

3. Use the following buttons and their respective functionalities:

   - **Update**: Click this button to update the required PowerShell modules (NuGet, AzureAD, WindowsAutopilotIntune, Microsoft.Graph.Intune).

   - **Connect**: Click this button to connect to the Azure tenant and retrieve Autopilot profiles. This will populate the list of profiles in the list box in the GUI.

   - **Browse**: Click this button to browse and select a directory where the Autopilot profile JSON file will be saved.

   - **Save**: Click this button to save the selected Autopilot profile as a JSON file in the chosen directory.

## Contributing

Contributions to this project are welcome. If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the GitHub repository.

## License

This project is licensed under the [MIT License](LICENSE).

