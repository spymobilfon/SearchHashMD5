[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = @'

<Window
		xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
		xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
		xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
		xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
		Title="Поиск файлов по хеш-функции MD5" Height="350" Width="500" WindowStartupLocation="CenterScreen" Background="White">
	<Grid>
		<Label Content="Папка или файл для поиска:" HorizontalAlignment="Left" Margin="20,20,0,0" VerticalAlignment="Top"/>
		<TextBlock Name="Files" HorizontalAlignment="Left" Margin="20,169,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="400" Height="91"/>
		<TextBox Name="Path" HorizontalAlignment="Left" Height="23" Margin="20,51,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="400"/>
		<Label Content="Значение хеш-функции MD5 для поиска:" HorizontalAlignment="Left" Margin="20,79,0,0" VerticalAlignment="Top"/>
		<TextBox Name="Hash" HorizontalAlignment="Left" Height="23" Margin="20,110,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="400"/>
		<Label Content="Результат поиска:" HorizontalAlignment="Left" Margin="20,138,0,0" VerticalAlignment="Top"/>
		<Button Name="Search" Content="Поиск" HorizontalAlignment="Left" Margin="20,265,0,0" VerticalAlignment="Top" Width="100"/>
		<Button Name="Exit" Content="Выход" HorizontalAlignment="Left" Margin="150,265,0,0" VerticalAlignment="Top" Width="100"/>
	</Grid>
</Window>

'@

$Reader = (New-Object System.Xml.XmlNodeReader $XAML)
Try {$Form = [Windows.Markup.XamlReader]::Load( $Reader )}
Catch {Write-Host "Unable to load Windows.Markup.XamlReader. Some possible causes for this problem include: .NET Framework is missing PowerShell must be launched with PowerShell -sta, invalid XAML code was encountered."; exit}

$XAML.SelectNodes("//*[@Name]") | %{Set-Variable -Name ($_.Name) -Value $Form.FindName($_.Name)}

$Search.Add_Click({

	if (!$Path.Text -or !$Hash.Text) {

		[System.Windows.MessageBox]::Show('Путь или хеш не заданы.','Error','OK','Error')

	} else {

		$hashFiles = Get-ChildItem -Path $Path.Text -Recurse | ForEach-Object {Get-FileHash -Path $_.FullName -Algorithm MD5} | Where-Object {$_.Hash -eq $Hash.Text}
		$Files.Text = $hashFiles.Path

	}

})

$Exit.Add_Click({$Form.Close()})

$Form.ShowDialog() | Out-Null