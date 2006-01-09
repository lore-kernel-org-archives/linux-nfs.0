From: "denis.immoos" <denis.immoos@edubs.ch>
Subject: NFSROOT PROBLEM
Date: Mon, 9 Jan 2006 10:35:29 +0100
Message-ID: <000801c61500$0a6a4dc0$150110ac@wgbs.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EvtRB-00060X-EQ
	for nfs@lists.sourceforge.net; Mon, 09 Jan 2006 01:35:37 -0800
Received: from faraday.edubs.ch ([212.117.98.9])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EvtR9-0006Ho-V2
	for nfs@lists.sourceforge.net; Mon, 09 Jan 2006 01:35:37 -0800
Received: from TITAN01 ([10.149.1.254])
	by faraday.edubs.ch (8.13.0/8.12.11) with ESMTP id k099ZX2q015617
	for <nfs@lists.sourceforge.net>; Mon, 9 Jan 2006 10:35:33 +0100 (CET)
To: <nfs@lists.sourceforge.net>
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

Hi there, 

I have problems mounting a nfs-root filesystem over TCP.

My mount options for the kernel are :

root=/dev/nfs
nfsroot=10.10.1.24:/home/denis/gentoo,wsize=4096,rsize=4096,tcp ip=dhcp

In /etc/exports on the server is the following entry :

/home/denis/gentoo       10.10.103.0/255.255.255.0(ro,no_root_squash,sync)

These are the entries in the Servers syslog :

Jan  5 15:20:33 hydra rpc.mountd: refused mount request from 10.10.103.24
for /home/denis/gentoo,wsize=4096,rsize=4096,proto=tcp (/): no export entry


The Server believes the following string is a directory and is unable to
parse [wsize,rsize,tcp]

>> /home/denis/gentoo,wsize=4096,rsize=4096,proto=tcp <<

I believe this might be a bug either in LILO/Grub or the Kernel.

I tried Lilo/Grub and Syslinux as Bootmanagers the error occurs with Lilo
and Grub, when I boot with Syslinux there is no such behavior and the
options get set.

With Grub and Lilo the the Kernel panics.

If there someone who got the same Problem or even a solution, please mail me
back ...

Denis 



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
