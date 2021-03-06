 ## if you have a older version of php as well as 5.6 or higher ## 
 ## Make sure you Set Your PHPVesion for this virtual server to PHP 5.6 or higher ##

# script_Laravel_5_4_desc()
sub script_Laravel_5_4_desc
{
return "Laravel (php 5.6)";
}

sub script_Laravel_5_4_uses
{
return ( "php" );
}

sub script_Laravel_5_4_longdesc
{
return "Installs Composer and Laravel (5.4) For Virtual Server";
}

# script_Laravel_5_4_versions()
sub script_Laravel_5_4_versions
{
return ( "5.4" );
}

sub script_Laravel_5_4_category
{
return "Framework";
}

sub script_Laravel_5_4_php_vers
{
local ($d, $ver) = @_;
if ($ver >= 3.2) {
	return ( 5 );
	}
else {
	return ( 4, 5 );
	}
}

sub script_Laravel_5_4_php_modules
{
return ("mysql", "gd", "mbstring");
}

sub script_Laravel_5_4_php_optional_modules
{
return ("curl");
}

sub script_Laravel_5_4_dbs
{
return ("mysql");
}

# script_Laravel_5_4_depends(&domain, version)
sub script_Laravel_5_4_depends
{
local ($d, $ver) = @_;
local @rv;

# Check for MySQL 4+
&require_mysql();
if (&mysql::get_mysql_version() < 4) {
	push(@rv, "Laravel requires MySQL version 4 or higher");
	}

# Check for PHP 5.6+
local $phpv = &get_php_version(5, $d);
if (!$phpv) {
	push(@rv, "Could not work out exact PHP version");
	}
#~ elsif ($phpv < 5.6) {##for php versions 5.6 and up
elsif ($phpv < 5.2) { ## if you have a older version of php as well as 5.6 or higher ## get_php_version doesnt always return the higher if you have multiple installed
	push(@rv, "Laravel requires PHP version 5.6 or later");
	}

return @rv;
}

# script_Laravel_5_4_params(&domain, version, &upgrade-info)
# Returns HTML for table rows for options for installing Laravel
sub script_Laravel_5_4_params
{
local ($d, $ver, $upgrade) = @_;
local $rv;
local $hdir = &public_html_dir($d, 1);
if ($upgrade) {
	# Options are fixed when upgrading
	local ($dbtype, $dbname) = split(/_/, $upgrade->{'opts'}->{'db'}, 2);
	$rv .= &ui_table_row("Database for Laravel tables", $dbname);
	local $dir = $upgrade->{'opts'}->{'dir'};
	$dir =~ s/^$d->{'home'}\///;
	$rv .= &ui_table_row("Install directory", $dir);
	}
else {
	# Show editable install options
	local @dbs = &domain_databases($d, [ "mysql" ]);
	$rv .= &ui_table_row("Database for Laravel tables",
		     &ui_database_select("db", undef, \@dbs, $d, "Laravel"));
	}
return $rv;
}

# script_Laravel_5_4_parse(&domain, version, &in, &upgrade-info)
# Returns either a hash ref of parsed options, or an error string
sub script_Laravel_5_4_parse
{
local ($d, $ver, $in, $upgrade) = @_;
if ($upgrade) {
	# Options are always the same
	return $upgrade->{'opts'};
	}
else {
	local $hdir = &public_html_dir($d, 0);
	local $dir = $hdir;
	local ($newdb) = ($in->{'db'} =~ s/^\*//);
	return { 'db' => $in->{'db'},
		 'newdb' => $newdb,
		 'dir' => $dir,
		 'path' => "/", };
	}
}

# script_Laravel_5_4_check(&domain, version, &opts, &upgrade-info)
# Returns an error message if a required option is missing or invalid
sub script_Laravel_5_4_check
{
local ($d, $ver, $opts, $upgrade) = @_;
$opts->{'db'} || return "Missing database";
if (-r "$d->{'home'}/.composer") {
	return "Laravel appears to be already installed in the selected directory";
	}
	
return undef;
}

# script_Laravel_5_4_files(&domain, version, &opts, &upgrade-info)
# Returns a list of files needed by Laravel, each of which is a hash ref
# containing a name, filename and URL
sub script_Laravel_5_4_files
{
local ($d, $ver, $opts, $upgrade) = @_;
return undef;
}

sub script_Laravel_5_4_commands
{
return ("unzip");
}

# script_Laravel_5_4_install(&domain, version, &opts, &files, &upgrade-info)
# Actually installs Laravel, and returns either 1 and an informational
# message, or 0 and an error
sub script_Laravel_5_4_install
{
local ($d, $version, $opts, $files, $upgrade) = @_;
local ($out, $ex);

	   local $url = &script_path_url($d, $opts);
	   
	   
	   
 
		  
	   
#~ return (0, "yay done");
	   
	   
if ($opts->{'newdb'} && !$upgrade) {
        local $err = &create_script_database($d, $opts->{'db'});
        return (0, "Database creation failed : $err") if ($err);
        }
local ($dbtype, $dbname) = split(/_/, $opts->{'db'}, 2);
local $dbuser = $dbtype eq "mysql" ? &mysql_user($d) : &postgres_user($d);
local $dbpass = $dbtype eq "mysql" ? &mysql_pass($d) : &postgres_pass($d, 1);
local $dbphptype = $dbtype eq "mysql" ? "mysql" : "psql";
local $dbhost = &get_database_host($dbtype);
local $dberr = &check_script_db_connection($dbtype, $dbname, $dbuser, $dbpass);
return (0, "Database connection failed : $dberr") if ($dberr);

# Extract tar file to temp dir and copy to target
local $verdir = "Laravel";

	   
	   
##workaround ## failed when using run_as_domain_user##so we just sudo to that user and run the commads
	$shell_out = <<`SHELL`;
cd $d->{'home'}
EXPECTED_SIGNATURE=`wget -q -O - https://composer.github.io/installer.sig`
sudo -H -u $d->{'user'} whoami
sudo -H -u $d->{'user'} php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
sudo -H -u $d->{'user'} php -r "if (hash_file('SHA384', 'composer-setup.php') === $EXPECTED_SIGNATURE) { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo -H -u $d->{'user'} php composer-setup.php
sudo -H -u $d->{'user'} php -r "unlink('composer-setup.php');"
SHELL



if ($shell_out !~ /successfully installed to/) {
return (0, "Install Composer failed: ".
		   "<pre>".&html_escape($shell_out)."</pre>");
	   }
	   
	   
	     ##install laravel with composer
#~ local $icmd = "$d->{'home'}/composer.phar global require \"laravel/installer\"";##for php versions 5.6 and up
	   ##points to our php 5.6 instread of our php 5.3 ## if you have a older version of php as well as 5.6 or higher ## this says to try and use the php 5.6 
local $icmd = "export PATH=/opt/rh/rh-php56/root/usr/bin:\$PATH && $d->{'home'}/composer.phar global require \"laravel/installer\"";
local $out = &run_as_domain_user($d, $icmd);
 if ($?) {
return (0, "Install Laravel failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }
		   
		   
##navigates to our home dir and creates a new laravel application
#~ local $icmd = "cd $d->{'home'} && $d->{'home'}/.composer/vendor/bin/laravel new application"##for php versions 5.6 and up
	   ##points to our php 5.6 instread of our php 5.3 ## if you have a older version of php as well as 5.6 or higher ## this says to try and use the php 5.6 
# local $icmd = "export PATH=/opt/rh/rh-php56/root/usr/bin:\$PATH && cd $d->{'home'} && $d->{'home'}/.composer/vendor/bin/laravel new application";
local $icmd = "export PATH=/opt/rh/rh-php56/root/usr/bin:\$PATH && cd $d->{'home'} && $d->{'home'}/composer.phar create-project --prefer-dist laravel/laravel application '5.4.*'";
local $out = &run_as_domain_user($d, $icmd);
 # if ($out !~ /Crafting application/) {
 if ($out !~ /set successfully/) {
return (0, "Install Laravel Application failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }		


	   

	   	   
	local $cfileorig = "$d->{'home'}/application/.env.example";
	   local $cfile = "$d->{'home'}/application/.env";
	   # Copy and update the environment config file for laravel
if (!-r $cfile) {
	&run_as_domain_user($d, "cp ".quotemeta($cfileorig)." ".
				      quotemeta($cfile));
	   }
	   	local $lref = &read_file_lines_as_domain_user($d, $cfile);
	local $l;
	foreach $l (@$lref) {
		if ($l =~ /DB_DATABASE/) {
			$l = "DB_DATABASE=$dbname";
			}
		if ($l =~ /DB_USERNAME/) {
			$l = "DB_USERNAME=$dbuser";
			}
		if ($l =~ /DB_HOST/) {
			$l = "DB_HOST=$dbhost";
			}
		if ($l =~ /DB_PASSWORD/) {
			$l = "DB_PASSWORD=".
			     &php_quotemeta($dbpass)."";
			}
		if ($l =~ /APP_URL/) {
			$l = "APP_URL=$url";
			}
		}
	&flush_file_lines_as_domain_user($d, $cfile);
	   
	   
	   
	   
	##update laravel with composer and regenerate vendor files
#~ local $icmd = "cd $d->{'home'}/application && $d->{'home'}/composer.phar update";##for php versions 5.6 and up
	   ##points to our php 5.6 instread of our php 5.3 ## if you have a older version of php as well as 5.6 or higher ## this says to try and use the php 5.6 
#local $icmd = "export PATH=~/.composer/vendor/bin:/opt/rh/rh-php56/root/usr/bin:\$PATH && cd $d->{'home'}/application && $d->{'home'}/composer.phar update";
#local $out = &run_as_domain_user($d, $icmd);
#  if ($?) {
# return (0, "Update Laravel failed: ".
# 		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
# 	   }
		
		  

##navigates to our application dir and creates a new laravel application key
#~ local $icmd = "cd $d->{'home'}/application && php artisan key:generate";##for php versions 5.6 and up
	   ##points to our php 5.6 instread of our php 5.3 ## if you have a older version of php as well as 5.6 or higher ## this says to try and use the php 5.6 
# local $icmd = "export PATH=/opt/rh/rh-php56/root/usr/bin:\$PATH && cd $d->{'home'}/application && php artisan key:generate";
# local $out = &run_as_domain_user($d, $icmd);
#  if ($out !~ /set successfully/) {
# return (0, "Setup Laravel Application Key failed: ".
# 		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
# 	   }

##backup our public html and point to our new document root /application/public
local $icmd = "mv $d->{'home'}/public_html $d->{'home'}/public_html_backup && ln -s $d->{'home'}/application/public $d->{'home'}/public_html";
local $out = &run_as_domain_user($d, $icmd);
if ($?) {
return (0, "Setup New document root failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }
	   
		   
	
#~ return (1, "Laravel installation complete. It can be accessed at <a target=_blank href='$url'>$url</a>.", "test test test", $url);



		

	


# Return a URL for the user
local $userurl = &script_path_url($d, $opts);
local $rp = $opts->{'dir'};
$rp =~ s/^$d->{'home'}\///;
return (1, "Laravel installation complete. It can be accessed at <a target=_blank href='$url'>$url</a>.", "Under $rp using $dbphptype database $dbname", $userurl);
}

# script_Laravel_5_4_uninstall(&domain, version, &opts)
# Un-installs a Laravel installation, by deleting the directory and database.
# Returns 1 on success and a message, or 0 on failure and an error
sub script_Laravel_5_4_uninstall
{
local ($d, $version, $opts) = @_;



##restore public html document root
local $icmd = "rm $d->{'home'}/public_html && mv $d->{'home'}/public_html_backup $d->{'home'}/public_html";
local $out = &run_as_domain_user($d, $icmd);
if ($?) {
return (0, "Restore public_html document root failed: ".
		   "<pre>".$icmd."</pre><pre>".&html_escape($out)."</pre>");
	   }
	   


local $icmd = "rm -rf $d->{'home'}/application";
local $out = &run_as_domain_user($d, $icmd);
if ($?) {
	return (0, "Remove Application failed : ".
		   "<pre>".&html_escape($icmd)."</pre><pre>".&html_escape($out)."</pre>");
	}
	
local $icmd = "rm -rf $d->{'home'}/.composer";
local $out = &run_as_domain_user($d, $icmd);
if ($?) {
	return (0, "Remove Composer failed : ".
		   "<pre>".&html_escape($icmd)."</pre><pre>".&html_escape($out)."</pre>");
	}
	
unlink("$d->{'home'}/composer.phar");




# drop DB
if ($opts->{'newdb'}) {
        &delete_script_database($d, $opts->{'db'});
        }

return (1, "Laravel directory and tables deleted.");
}

# script_Laravel_5_4_realversion(&domain, &opts)
# Returns the real version number of some script install, or undef if unknown
sub script_Laravel_5_4_realversion
{
local ($d, $opts, $sinfo) = @_;
return undef;
}

# script_Laravel_5_4_latest(version)
# Returns a URL and regular expression or callback func to get the version
sub script_Laravel_5_4_latest
{
return undef;
}

sub script_Laravel_5_4_site
{
return 'https://laravel.com/';
}

1;