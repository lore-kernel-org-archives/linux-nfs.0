From: Sumeet Gupta <sumeet.gupta@flextronicssoftware.com>
Subject: NFS Problem : --"mount : fs type nfs not supported by kernel"
Date: Mon, 19 Sep 2005 12:16:24 +0530
Message-ID: <OF1E87C410.9CAE1EE6-ON65257081.00249476-65257081.00253562@flextronicssoftware.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 0025356065257081_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EHFUE-0001EI-Eo
	for nfs@lists.sourceforge.net; Sun, 18 Sep 2005 23:50:46 -0700
Received: from spark.hss.co.in ([203.145.155.21])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EHFUC-0005yS-4N
	for nfs@lists.sourceforge.net; Sun, 18 Sep 2005 23:50:46 -0700
Received: from ultra.hss.co.in (ultra [192.168.100.5])
	by spark.hss.co.in (8.12.10/8.12.10) with ESMTP id j8J6j53q007212
	for <nfs@lists.sourceforge.net>; Mon, 19 Sep 2005 12:15:17 +0530 (IST)
Received: from parinda.nokiaddf.hss.hns.com (localhost [127.0.0.1])
	by ultra.hss.co.in (8.10.0/8.10.0) with ESMTP id j8J6o9621752
	for <nfs@lists.sourceforge.net>; Mon, 19 Sep 2005 12:20:10 +0530 (IST)
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

This is a multipart message in MIME format.
--=_alternative 0025356065257081_=
Content-Type: text/plain; charset="us-ascii"

Hi

I have compiled kernel-2.6.9 on kernel 2.4 .
I am able to compile it successfully after alot of troubles but finally 
while booting i am facing following issues.
Kindly help me out if possible.

If I see the /var/log messages the following error appears 

Sep 12 19:27:36 rncpet31 nfs: Starting NFS services:  succeeded
Sep 12 19:27:36 rncpet31 nfs: rpc.rquotad startup succeeded
Sep 12 19:27:36 rncpet31 nfsd[1698]: nfssvc: No such device
Sep 12 19:27:36 rncpet31 nfs: rpc.nfsd startup failed
Sep 12 19:27:36 rncpet31 nfs: rpc.mountd startup succeeded

Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry 
/home1/amsethi
Sep 12 19:28:09 rncpet31 kernel: nfs warning: mount version older than kernel
Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry 
/home1/labuser
Sep 12 19:28:09 rncpet31 kernel: nfs warning: mount version older than kernel
Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry 
/home1/sumgupta
Sep 12 19:28:12 rncpet31 kernel: nfs warning: mount version older than kernel

If I run the following command to check the nfs status it shows the nfs 
demon is stopped demon i.e. rpc.nfsd

[root@rncpet31 root]# service nfs status
rpc.mountd (pid 1711) is running...
nfsd is stopped
rpc.rquotad (pid 1700) is running...


and while booting the kernel on the booting screen the following message 
appears too :

Starting NFS daemon:                                       [FAILED]
mount : fs type nfs not supported by kernel


The /proc/filesystems didn't contained the entry for nfs when we booted 
the kernel for the first time i.e. the module was compiled with the kernel 
but didn't started at the boot time. So we added the following script to 
start the nfs automatically during bootup but this script only starts the 
client end demon, the server side nfs demon still didn't started up

KERNEL=$(uname -r | cut -b 1-4)
if [ $KERNEL = "2.6." ] ; then
/sbin/modprobe nfs
fi


Thanking You.

Regards
Sumeet Gupta
--=_alternative 0025356065257081_=
Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="sans-serif">Hi</font>
<br>
<br><font size=2 face="sans-serif">I have compiled kernel-2.6.9 on kernel 2.4 .</font>
<br><font size=2 face="sans-serif">I am able to compile it successfully after alot of troubles but finally while booting i am facing following issues.</font>
<br><font size=2 face="sans-serif">Kindly help me out if possible.</font>
<br>
<br><font size=2 face="sans-serif">If I see the /var/log messages the following error appears </font>
<br>
<br><font size=2 face="sans-serif">Sep 12 19:27:36 rncpet31 nfs: Starting NFS services: &nbsp;succeeded</font>
<br><font size=2 face="sans-serif">Sep 12 19:27:36 rncpet31 nfs: rpc.rquotad startup succeeded</font>
<br><font size=2 face="sans-serif">Sep 12 19:27:36 rncpet31 nfsd[1698]: nfssvc: No such device</font>
<br><font size=2 face="sans-serif">Sep 12 19:27:36 rncpet31 <b>nfs: rpc.nfsd startup failed</b></font>
<br><font size=2 face="sans-serif">Sep 12 19:27:36 rncpet31 nfs: rpc.mountd startup succeeded</font>
<br>
<br><font size=2 face="sans-serif">Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry /home1/amsethi</font>
<br><font size=2 face="sans-serif">Sep 12 19:28:09 rncpet31 <b>kernel: nfs warning: mount version older than kernel</b></font>
<br><font size=2 face="sans-serif">Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry /home1/labuser</font>
<br><font size=2 face="sans-serif">Sep 12 19:28:09 rncpet31 <b>kernel: nfs warning: mount version older than kernel</b></font>
<br><font size=2 face="sans-serif">Sep 12 19:28:09 rncpet31 automount[1654]: attempting to mount entry /home1/sumgupta</font>
<br><font size=2 face="sans-serif">Sep 12 19:28:12 rncpet31 <b>kernel: nfs warning: mount version older than kernel</b></font>
<br>
<br><font size=2 face="sans-serif">If I run the following command to check the nfs status it shows the nfs demon is stopped demon i.e. <b>rpc.nfsd</b></font>
<br>
<br><font size=2 face="sans-serif"><b>[root@rncpet31 root]#</b> <b>service nfs status</b></font>
<br><font size=2 face="sans-serif">rpc.mountd (pid 1711) is running...</font>
<br><font size=2 face="sans-serif"><b>nfsd is stopped</b></font>
<br><font size=2 face="sans-serif">rpc.rquotad (pid 1700) is running...<br>
</font>
<br>
<br><font size=2 face="sans-serif">and while booting the kernel on the booting screen the following message appears too :</font>
<br>
<br><font size=2 face="sans-serif"><b>Starting NFS daemon: &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; [FAILED]</b></font>
<br><font size=2 face="sans-serif"><b>mount : fs type nfs not supported by kernel</b></font>
<br>
<br>
<br><font size=2 face="sans-serif">The /proc/filesystems didn't contained the entry for nfs when we booted the kernel for the first time i.e. the module was compiled with the kernel but didn't started at the boot time. So we added the following script to start the nfs automatically during bootup but this script only starts the client end demon, the server side nfs demon still didn't started up</font>
<br>
<br><font size=2 face="Courier New">KERNEL=$(uname -r | cut -b 1-4)</font>
<p><font size=2 face="Courier New">if [ $KERNEL = &quot;2.6.&quot; ] ; then</font>
<p><font size=2 face="Courier New">/sbin/modprobe nfs</font>
<p><font size=2 face="Courier New">fi</font>
<p><font size=2 face="sans-serif"><br>
<br>
Thanking You.<br>
<br>
Regards<br>
Sumeet Gupta</font>
--=_alternative 0025356065257081_=--


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
