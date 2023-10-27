echo "Ensuring undervolt is off..."
bash $toPath"off.sh"
echo "Disable coper path listener..."
systemctl disable --now set-ryzenadj-curve.path
echo "Disabling set-ryzenadj-curve service..."
systemctl disable set-ryzenadj-curve.service
echo "Enable coall path listener..."
systemctl enable --now set-ryzenadj-tweaks.path
echo "Enabling set-ryzenadj-tweaks service..."
systemctl enable set-ryzenadj-tweaks.service
