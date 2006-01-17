From: Jonas Lihnell <roze@roze.mine.nu>
Subject: (no subject)
Date: Tue, 17 Jan 2006 22:37:33 +0100
Message-ID: <20060117223733.oy3wy9yvc4so8c4s@roze.mine.nu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	format="flowed"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EyyTL-000832-W0
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:34:35 -0800
Received: from mxfep01.bredband.com ([195.54.107.70])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EyyTL-0007Xe-Ed
	for nfs@lists.sourceforge.net; Tue, 17 Jan 2006 13:34:36 -0800
Received: from roze.mine.nu ([213.112.221.123] [213.112.221.123])
          by mxfep01.bredband.com with ESMTP
          id <20060117213425.CWEY17450.mxfep01.bredband.com@roze.mine.nu>
          for <nfs@lists.sourceforge.net>; Tue, 17 Jan 2006 22:34:25 +0100
Received: from localhost (localhost [127.0.0.1])
	by roze.mine.nu (Postfix) with ESMTP id F095612011
	for <nfs@lists.sourceforge.net>; Tue, 17 Jan 2006 22:37:33 +0100 (CET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi there fellow nfs'ers (or whatever I'm supposed to call you :)

I got some issues with my root-on-nfs installation and after an hour of 
googling, reading forums and mailinglist (none in particular, just 
whatever google turned up) and trying a bunch of stuff I thought it was 
time to resort to this mailing list.

I am capable of booting and mounting the rootfs, as well as any other 
nfs shares but it goes slow and from time to time becomes unresponsive 
for some moments. When measuring speed of downloading files to nfs 
share I get decent speed and every few minutes it halts for some 
seconds, sometime just a few, sometimes many.

According to what I've come to know I should set a few options to get 
rid of this situation, namely tcp, rsync, wsync and nfsvers3. 
Unfortunately the booting kernel refuses to use the options I specify 
with append as stated in nfsroot.txt in the documentation folder from 
my kernel.

I can mount the share with the specified options when booted from a 
live-cd (ubuntu 5.10) so as far as I can see it's just a stubborn 
kernel which don't listen to what I say. :D

Some information about my setup and config files:
pxelinux.cfg/default:
"DEFAULT /bzImage
APPEND ip=dhcp root=/dev/nfs 
nfsroot=192.168.0.64:/mnt/storage/network-nodes/default,sync,hard,intr,rw,nolock,rsize=8192,wsize=8192,nfsvers=3,tcp"

Some information I am supposed to give when mailing this list:
nfs-utils version: net-fs/nfs-utils-1.0.6-r6
kernel version: sys-kernel/gentoo-sources-2.6.14-r5
operating system: Gentoo Linux

network layout:
Servers "eth1: DGE-530T Gigabit Ethernet Adapter" connected to a dlink 
gigabit switch which in turn is connected to the clients "eth0: VIA 
Rhine II"

Good to know: "eth0: link up, 100Mbps, full-duplex"

/etc/exports snippet:
"# Netboot
/mnt/storage/network-nodes/     192.168.0.0/24(rw,sync,no_root_squash)"

rcpinfo -p localhost run on the server:
"   100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  33543  status
    100024    1   tcp  47866  status
    100011    1   udp   4002  rquotad
    100011    2   udp   4002  rquotad
    100011    1   tcp   4002  rquotad
    100011    2   tcp   4002  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  33544  nlockmgr
    100021    3   udp  33544  nlockmgr
    100021    4   udp  33544  nlockmgr
    100021    1   tcp  47867  nlockmgr
    100021    3   tcp  47867  nlockmgr
    100021    4   tcp  47867  nlockmgr
    100005    1   udp    834  mountd
    100005    1   tcp    837  mountd
    100005    2   udp    834  mountd
    100005    2   tcp    837  mountd
    100005    3   udp    834  mountd
    100005    3   tcp    837  mountd"

rpcinfo -p 192.168.0.64 run on the client:
"    100000    2   tcp    111  portmapper
    100000    2   udp    111  portmapper
    100024    1   udp  33543  status
    100024    1   tcp  47866  status
    100011    1   udp   4002  rquotad
    100011    2   udp   4002  rquotad
    100011    1   tcp   4002  rquotad
    100011    2   tcp   4002  rquotad
    100003    2   udp   2049  nfs
    100003    3   udp   2049  nfs
    100003    2   tcp   2049  nfs
    100003    3   tcp   2049  nfs
    100021    1   udp  33544  nlockmgr
    100021    3   udp  33544  nlockmgr
    100021    4   udp  33544  nlockmgr
    100021    1   tcp  47867  nlockmgr
    100021    3   tcp  47867  nlockmgr
    100021    4   tcp  47867  nlockmgr
    100005    1   udp    834  mountd
    100005    1   tcp    837  mountd
    100005    2   udp    834  mountd
    100005    2   tcp    837  mountd
    100005    3   udp    834  mountd
    100005    3   tcp    837  mountd"



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
