From: Nitin Chandrachoodan <nitin@tenet.res.in>
Subject: remount error: 'unknown nfs mount option: v3'
Date: Mon, 28 Jul 2003 12:06:40 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030728063639.GD2204@tenet.res.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from 165.tenet.28.144.202.in-addr.arpa
	([202.144.28.165] helo=nimbus.tenet.res.in ident=[/Q+72vEqn9Z1lvF8PcuyZCoyXrgvPEDE])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19h1cO-00054K-00
	for <nfs@lists.sourceforge.net>; Sun, 27 Jul 2003 23:36:25 -0700
Received: from edge.isrl.tenet.res.in ([144.16.244.158])
	by nimbus.tenet.res.in (8.11.6/8.11.6) with ESMTP id h6S6PQe06515
	for <nfs@lists.sourceforge.net>; Mon, 28 Jul 2003 11:55:26 +0530
To: nfs@lists.sourceforge.net
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


Hello,

We have a diskless client setup in our lab, with / and /usr
mounted from a server. The server is running a standard RedHat
8.0 distrib, and the clients have a standard (except for
recompiled kernel) RedHat 9.0. nfs-utils, mount etc. are the
standard versions out of the box.

The /etc/exports on the server contains

/tftpboot           192.168.15.0/24(rw,sync,no_root_squash)
/home1/remoteusr    192.168.15.0/24(rw,sync,no_root_squash)

The root fs is mounted by the kernel option to pxelinux given by 
  DEFAULT linux
  LABEL   linux
          KERNEL bzImage.wks
          APPEND panic=5 nfsroot=192.168.15.1:/tftpboot
          IPAPPEND 1

The /usr is mounted in rc.sysinit using 
action $"Mounting /usr partition" mount 192.168.15.1:/home1/remoteusr /usr -t nfs -o ro,nolock

So far so good, it boots up, and runs normally. 

The problem arises when I try to remount the / and /usr as
read-write (to install software on the client). When I try 
  mount -n -o remount,rw /
  mount -n -o remount,rw /usr

the second mount fails with "unknown nfs mount option: v3".

I noticed that typing 'mount' after bootup shows
  /dev/root on / type nfs (ro,v2,rsize=4096,wsize=4096,hard,udp,nolock,addr=192.168.15.1)
  192.168.15.1:/home1/remoteusr on /usr type nfs (ro,v3,rsize=4096,wsize=4096,hard,udp,nolock,addr=192.168.15.1)

The /etc/fstab does not contain any of the entries, and
/etc/mtab is linked to /proc/mounts.

It seems that the 'v3' showing up in the mount listing is
causing the problem. I dont know why it is there, and why the /
got mounted as v2, I did not specify those options anywhere.

How are default options passed to the NFS systems? Are they
compiled into the kernel? When I try mounting these same
filesystems from another RH9 machine that is not diskless, it
works fine, and mount shows 
  nfs:/home1/remoteusr on /mnt/hdd type nfs (rw,addr=192.168.15.1)

Any suggestions would be greatly appreciated.

Thanks in advance,

Nitin


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
