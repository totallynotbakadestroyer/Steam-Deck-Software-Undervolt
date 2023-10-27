echo "Ensuring undervolt is off..."
bash $toPath"off.sh"
echo "Disable coall path listener..."
systemctl disable --now set-ryzenadj-tweaks.path
echo "Disbling set-ryzenadj-tweaks service..."
systemctl disable set-ryzenadj-tweaks.service
echo "Enable path listener..."
systemctl enable --now set-ryzenadj-curve.path
echo "Enabling set-ryzenadj-curve service..."
systemctl enable set-ryzenadj-curve.service
