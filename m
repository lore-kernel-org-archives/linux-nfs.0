From: Neil Brown <neilb@suse.de>
Subject: Re: stale nfs file handle with exported loopback mounts
Date: Tue, 30 Oct 2007 16:14:51 +1100
Message-ID: <18214.48587.2205.753253@notabene.brown>
References: <2051050286@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS@lists.sourceforge.net
To: devzero@web.de
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: message from devzero@web.de on Saturday October 27
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Saturday October 27, devzero@web.de wrote:
> Hello !
> 
> with 2.6.22 i`m trying to export loopback mounted iso-images.
> 
> this is /etc/exports:
> 
> /export *(ro,crossmnt,subtree_check)

I recommend replacing subtree_check with no_subtree_check, but it
shouldn't make an important difference in this case.


This should work with nfs-utils 1.1.0 or later.  With earlier releases
you need to explicitly export the subordinate filesystems too.

> 
> in /export, i have loopback mounted iso-images
> 
> after mounting on the client side under /mnt (tried one older and one recent system) , i`m getting:
> 
> vmhost:/mnt # ls -la
> /bin/ls: iso1: Input/output error
> /bin/ls: iso2  Input/output error
> /bin/ls: iso3: Input/output error
> total 10128
> drwxrwxrwt   18 root root  270336 Oct 26 08:45 .
> drwxrwxrwt  186 root root   20760 Oct 27 17:45 ..
> drwxr-xr-x    2 root root   16384 Jan  1  1970 iso1
> drwxr-xr-x    2 root root   16384 Jan  1  1970 iso2
> drwxr-xr-x    2 root root   16384 Jan  1  1970 iso3
> 
> vmhost:/mnt/iso1 # ls
> /bin/ls: .: Stale NFS file handle
> vmhost:/mnt/iso1 # ls -la
> /bin/ls: .: Input/output error

It is a little odd that the errors are inconsistent.

Can you find any log messages from mountd in syslog?  What do they
say?
Also what does
   cat /proc/fs/nfsd/exports

on the server show.

Finally, a tcpdump:

  tcpdump -s 0 -w /tmp/tcpdump port 2049

while you run the experiment might help.

> 
> i`m unsure if i should blame suse here (it`s an opensuse 10.3 box which seems to have nfs-utils 1.1.0)
> 
> does somebody have such setup up and running and can tell his distro / kernel and nfs-utils version ?
> maybe i change distro then.

I doubt that it is a distro-specific thing.  As long as you have
nfs-utils-1.1.0 it should work.  I don't have a 10.3 box
set up yet, but it works fine on Debian/unstable for me.

Maybe try adding the "no_root_squash" export option.
What does "ls -l /export" on the server show?

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
