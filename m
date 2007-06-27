From: "zheng xin" <zhx821223@hotmail.com>
Subject: NFS problem when mounting dynamic file system
Date: Wed, 27 Jun 2007 21:14:17 +0000
Message-ID: <BAY129-F303A409AA4A2368690527CAD0A0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I3eqF-0003r8-SJ
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 14:14:24 -0700
Received: from bay0-omc1-s26.bay0.hotmail.com ([65.54.246.98])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I3eqH-000719-Vw
	for nfs@lists.sourceforge.net; Wed, 27 Jun 2007 14:14:27 -0700
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

Hi NFS experts:

When I am using NFS, I get the following problem:

I have two PCs, both in subnet 192.168.255.0(28), PC A: 192.168.255.3 PC 
B:192.168.255.1

In PC A, automount is running to automatically mount a SD card.
/etc/auto.master:
#
# $Id: auto.master,v 1.4 2005/01/04 14:36:54 raven Exp $
#
# Sample auto.master file
# This is an automounter map and it has the following format
# key [ -mount-options-separated-by-comma ] location
# For details of the format look at autofs(5).
#/misc  /etc/auto.misc --timeout=60
#/smb   /etc/auto.smb
/mnt    /etc/auto.misc --timeout=1 --ghost

/etc/auto.misc:
#
# $Id: auto.misc,v 1.2 2003/09/29 08:22:35 raven Exp $
#
# This is an automounter map and it has the following format
# key [ -mount-options-separated-by-comma ] location
# Details may be found in the autofs(5) manpage
#cd             -fstype=iso9660,ro,nosuid,nodev :/dev/cdrom

# the following entries are samples to pique your imagination
#linux          -ro,soft,intr           ftp.example.org:/pub/linux
#boot           -fstype=ext2            :/dev/hda1
#floppy         -fstype=auto            :/dev/fd0
#floppy         -fstype=ext2            :/dev/fd0
#e2floppy       -fstype=ext2            :/dev/fd0
#jaz            -fstype=ext2            :/dev/sdc1
#removable      -fstype=ext2            :/dev/hdd
card            -fstype=vfat            :/dev/mmcblk0

It will mount the SD card into /mnt/card when it is present. This works all 
right.

Now, I would like to access the SD card from PC B. So I do the following:

In PC A:
I edited /etc/exports:
/mnt/card 192.168.255.0/28(rw,sync,no_root_squash,no_subtree_check)

Now start NFS, I can see the following:
>exportfs -v
/mnt/card       
192.168.255.0/28(rw,wdelay,no_root_squash,no_subtree_check,anonuid=65534,anongid=65534)

Then in PC B:
>mount -t nfs 192.168.255.3:/mnt/card /mnt/
mount: 192.168.255.3:/mnt/card failed, reason given by server: Permission 
denied
mount: nfsmount failed: Bad file descriptor
mount: Mounting 192.168.255.3:/mnt/card on /mnt/ failed: Bad file descriptor

BTW: My NFS version: nfs-utils-1.0.10 with no addtional patches.

Does anybody know what I did wrong or any fixes to NFS can get rid of my 
problem.

Thanks a lot.
Shane

_________________________________________________________________
Express yourself instantly with MSN Messenger! Download today it's FREE! 
http://messenger.msn.click-url.com/go/onm00200471ave/direct/01/


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
