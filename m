From: <robvog@hetnet.nl>
Subject: VFS: Cannot open root device, nfsroot
Date: Wed, 12 Jun 2002 11:49:53 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <30da01c211f6$80b1acf0$d16897c2@hetnet.nl>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [194.151.104.209] (helo=hetnet.nl)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17I4mV-00074q-00
	for <nfs@lists.sourceforge.net>; Wed, 12 Jun 2002 02:51:11 -0700
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hi everyone,

I got the error:

NET4: Unix domain sockets 1.0/smp for linux NET4.0
ds: no socket drivers loaded
request_module[block-major-8]: root fs not mounted
VFS: Cannot open root device ""or 08:03
Please append a correct "root"boot option

The strange thing is that it tries to mount from harddisk. This I got =
somewhere else:
 "the kernel looks like it is trying to boot off of 08:03, which is =
correct, /dev/sda3."
sda3 is indeed the root partition of the scsi harddisk.

It seems the kernel tries to mount /dev/sda3 as root instead of mounting =
the directory offered by nfsserver.

Getting kernel goes ok, so there seems to be some misunderstanding =
between pxelinux config file and nfsserver.
These are my config files:

/tftpboot/pxelinux.cfg/default I got:
LABEL  linux
KERNEL  bzImage
APPEND root=3D/dev/nfs ip=3Ddhcp nfsroot=3D192.168.1.1:/netboot/base

/etc/exports:
/netboot/base       192.168.1.0/255.255.255.0(rw,no_root_squash)

/etc/hosts.allow:
ALL:ALL

/etc/hosts.deny:
 is empty

rpcinfo -p : says portmapper, mountd and nfs are active.

My log that logs all says nothing after DHCPPACK for ip assignment by =
dhcpd and "tftp: client does not accept options" which is normal I =
understand.

I have also tried to use other kernels and root filesystems (in =
/netboot/base, client was supposed to nfs) but without succes.
The kernels I made all gave the error:

NET4: Unix domain sockets 1.0/smp for linux NET4.0
ds: no socket drivers loaded
request_module[block-major-8]: root fs not mounted
VFS: Cannot open root device ""or 08:03
Please append a correct "root"boot option

And a kernel I ripped of a bootflop gave not the error:
ds: no socket drivers loaded
but has propably not the necessary modules for nfsroot compiled.

I am at a loss, I have no idee why it's not working.
If anyone has a sugestion I would very much apreciate it.


_______________________________________________________________

Sponsored by:
ThinkGeek at http://www.ThinkGeek.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
