From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: NFS mount count is incremented incorrectly
Date: Thu, 14 Aug 2003 13:27:22 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030814132006.7C2A.KAKMY@mvh.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.194])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19n9i0-0000Ps-00
	for <nfs@lists.sourceforge.net>; Wed, 13 Aug 2003 21:27:33 -0700
To: util-linux@math.uio.no
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hello

We assume that an NFS client tries to mount a filesystem
on an NFS server.
A mount count in /var/lib/nfs/rmtab may be incremented
even when a mount command fails.


example:

System: GNU-Debian/Linux 
Architecture: i386
Package: nfs-kernel-server 1.0-2, mount 2.11n-4

(1)server

~# exportfs -o rw *.test1.co.jp:/share
~# exportfs -v
/share          *.test1.co.jp(rw,async,wdelay,root_squash)
/share1         <world>(rw,async,wdelay,root_squash)
~# cat /var/lib/nfs/rmtab
~#

(2)client

~# mount -t nfs nfs-server:/share /nowhere
mount: mount point /nowhere does not exist
~# 

(3)server

~# cat /var/lib/nfs/rmtab
nfs-client.test1.co.jp:/share:0x00000002
~# cat /proc/fs/nfs/exports
# Version 1.1
# Path Client(Flags) # IPs
/share  nfs-client.test1.co.jp(rw,root_squash,async,wdelay) # xx.xx.xx.xx
~#


Because the mount command does not request MOUNTPROC_UMNT
 to the NFS server, when the mount command gets
an error from mount() system call.

I think that it needs for the try_mount_one() of mount.c
to add code which requests MOUNTPROC_UMNT when 
guess_fstype_and_mount() returns error.
I think we should make the nfsmount() function request
MOUNTPROC_UMNT.


-- 
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>



-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
