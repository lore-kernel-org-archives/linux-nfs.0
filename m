From: kanagesh <kanagesh@ncoretech.com>
Subject: Timeout error with NFS over USB
Date: Fri, 17 Jan 2003 10:10:45 +0530
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3E27894D.1080F3D@ncoretech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [164.164.42.6] (helo=gateway.ncoretech.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZOTp-0003cH-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 20:51:49 -0800
Received: from mail.ncoretech.com (mail.ncoretech.com [192.168.1.3])
	by gateway.ncoretech.com (8.12.5/8.12.5) with ESMTP id h0H4nJgo003854
	for <nfs@lists.sourceforge.net>; Fri, 17 Jan 2003 10:19:20 +0530
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.ncoretech.com (Postfix) with ESMTP id 7799D1408F
	for <nfs@lists.sourceforge.net>; Fri, 17 Jan 2003 10:28:43 +0530 (IST)
Received: from mail.ncoretech.com ([127.0.0.1]) by localhost (mail.ncoretech.com [127.0.0.1]) (amavisd-new) with ESMTP id 10611-03 for <nfs@lists.sourceforge.net>; Fri, 17 Jan 2003 10:28:43 -0000 (IST)
Received: from ncoretech.com (ws130.ncoretech.com [192.168.1.130])
	by mail.ncoretech.com (Postfix) with ESMTP id 1A6A51407E
	for <nfs@lists.sourceforge.net>; Fri, 17 Jan 2003 10:28:43 +0530 (IST)
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



Hi,

I am working on an embedded board running on a StrongARM SA1110
processor.
It has got Linux (kernel 2.4.18 - rmk4) running on it.  I am trying to
mount a
partition from the native linux machine (running on RedHat 7.3) through
NFS
over USB.

I have set up the native linux system as the NFS Server (I have made the

appropriate entries in the /etc/exports and /etc/hosts.allow and
/etc/hosts.deny
files).  I then mount the folder that has been exported by the NFS
Server.

Everything seems to work fine upto here.  I have got a couple of issues:

1.  When I telnet into the target board, I am able to log in without any
issues
      and work on the mounted partition.  But, every now and then, I get
the
      following message on the target board:

        NETDEV WATCHDOG: usbf: transmit timed out


On the target board, the binary utilities (like ls, cp, mv, mount) are
all part of
busybox (version 0.60.5).

On the native Linux system (NFS Server)
***********************************

/etc/exports reads:

/skiff 1.1.1.1(rw)
/home/winnie 1.1.1.1(rw)

(here 1.1.1.1 is the ip address of the target board and 1.1.1.2 is the
ip address of the native host)

the output of rpcinfo -p

   program vers proto   port
    100000    2   tcp    111    portmapper
    100000    2   udp   111    portmapper
    100024    1   udp   1024  status
    100024    1   tcp   1024  status
    391002    2   tcp   1025  sgi_fam
    100005    1   udp   1030  mountd
    100005    1   tcp   1136  mountd
    100005    2   udp   1030  mountd
    100005    2   tcp   1136  mountd
    100005    3   udp   1030  mountd
    100005    3   tcp   1136  mountd
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100021    1   udp   1031  nlockmgr
    100021    3   udp   1031  nlockmgr
    100021    4   udp   1031  nlockmgr
    100001    3   udp    704   rstatd
    100001    2   udp    704   rstatd
    100001    1   udp    704   rstatd
    100011    1   udp    707   rquotad
    100011    2   udp    707   rquotad
    100011    1   tcp    710   rquotad
    100011    2   tcp    710   rquotad

/sbin/ifconfig reads:

eth0      Link encap:Ethernet  HWaddr 00:50:BA:88:0D:FA
          inet addr:192.168.1.130  Bcast:192.168.1.255
Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:36032 errors:0 dropped:0 overruns:0 frame:0
          TX packets:26519 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:13790636 (13.1 Mb)  TX bytes:3211478 (3.0 Mb)
          Interrupt:11

lo        Link encap:Local Loopback
          inet addr:127.0.0.1  Mask:255.0.0.0
          UP LOOPBACK RUNNING  MTU:16436  Metric:1
          RX packets:281 errors:0 dropped:0 overruns:0 frame:0
          TX packets:281 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:0
          RX bytes:20132 (19.6 Kb)  TX bytes:20132 (19.6 Kb)

usb0      Link encap:Ethernet  HWaddr 40:4C:55:2A:61:4F
          inet addr:1.1.1.2  Bcast:1.255.255.255  Mask:255.255.255.0
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:245 errors:0 dropped:0 overruns:0 frame:0
          TX packets:235 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:100
          RX bytes:31500 (30.7 Kb)  TX bytes:40586 (39.6 Kb)

ls -l /home/ reads:

drwx------   45 winnie winnie     4096 Jan 16 15:29 winnie
drwxr-xr-x    2 ppp      101          4096 Dec 27 13:17 ppp

On the target board,  (nfs is the mount point)
**************************************

before the NFS Mount:

drwxr-xr-x    1 root     root            0 Nov 30 01:20 nfs

after the NFS Mount:

drwx------   45 winnie winnie     4096 Jan 16  2003 nfs

I am not running the portmap daemon on the target board.  I have only
set up the NFS Server,
turned on NFS capability in the Linux Kernel for the target board and I
mount the partition
exported by the NFS Server, using the mount command from busybox.

Has anyone faced this timeout errors before?  If it has been, is there a
fix?

Thanks in advance,
Kanagesh







-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
