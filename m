From: Usha Ketineni <uketinen@us.ibm.com>
Subject: NFS dentry caching mechanism
Date: Thu, 26 Jan 2006 14:40:27 -0800
Message-ID: <OFE1F20AE4.839B09EC-ON87257102.007A50EE-88257102.007C7D01@us.ibm.com>
Reply-To: uketinen@us.ibm.com
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 007C7CFB88257102_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F2FmS-0006G2-K4
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 14:39:52 -0800
Received: from e32.co.us.ibm.com ([32.97.110.150])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F2FmS-0003QL-AJ
	for nfs@lists.sourceforge.net; Thu, 26 Jan 2006 14:39:52 -0800
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k0QMdjDD001497
	for <nfs@lists.sourceforge.net>; Thu, 26 Jan 2006 17:39:45 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id k0QMbveQ257714
	for <nfs@lists.sourceforge.net>; Thu, 26 Jan 2006 15:37:57 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k0QMdj7d020226
	for <nfs@lists.sourceforge.net>; Thu, 26 Jan 2006 15:39:45 -0700
Received: from d03nm116.boulder.ibm.com (d03nm116.boulder.ibm.com [9.17.195.142])
	by d03av04.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id k0QMdj4i020223
	for <nfs@lists.sourceforge.net>; Thu, 26 Jan 2006 15:39:45 -0700
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
--=_alternative 007C7CFB88257102_=
Content-Type: text/plain; charset="US-ASCII"

We are investigating an issue with the NFS client code in 2.4.21 kernel:

To reproduce the issue:

(using machine A and machine B, and a file system mounted off an NFS 
server 
called /home)

1) On Machine A: 

ls home/source 
ls: /home/source: No such file or directory 

2) On machine B: 
touch /home/source 

3) back on machine A: 
rm /home/source 
rm: cannot lstat `source': No such file or directory 

But source *does* exist. 

This shows the problem.

===

There are workarounds:

1) Mount the file system with acdirmin=0 and acdirmax=0. But this then 
affects 
all system calls, not just unlink(). And it hurts NFS performance.

2) Mount the file system with the noac option, but the same negative 
effect as 
in #1 applies.

What happens is this: 

0) Let F be a filename on the NFS file system. Initially this file
does not exist.

1) The application on the machine A does a stat() on F. The NFS
client in the kernel sends a LOOKUP request to the NFS server, which
obviously returns failure. The stat() fails with ENOENT. OK so far.

2) Immediately afterwards (a few seconds max), the application on
machine B creates the file F. No problems so far.

3) When B is done with F, a few seconds later the application on
machine A does an unlink() on F. Because of the negative dentry
caching in the Linux kernel, it doesn't even bother to send an NFS
REMOVE request to the NFS server, as (it thinks) it knows for sure the
file doesn't exist. It lets the unlink() fail with ENOENT. But the
file definitely exists.

Is there any other solution for this (including moving to a newer kernel)?


Thanks
Usha
--=_alternative 007C7CFB88257102_=
Content-Type: text/html; charset="US-ASCII"


<br>
<form action=https://bugzilla.linux.ibm.com/process_bug.cgi method=post>
<br>
<br><font size=2 face="Arial">We are investigating an issue with the NFS
client code in 2.4.21 kernel:<br>
</font>
<br><font size=2 face="Arial">To reproduce the issue:</font>
<br><font size=2 face="Arial"><br>
(using machine A and machine B, and a file system mounted off an NFS server
<br>
called /home)<br>
<br>
1) On Machine A: <br>
<br>
ls home/source <br>
ls: /home/source: No such file or directory <br>
<br>
2) On machine B: <br>
touch /home/source <br>
<br>
3) back on machine A: <br>
rm /home/source <br>
rm: cannot lstat `source': No such file or directory <br>
<br>
But source *does* exist. <br>
<br>
This shows the problem.<br>
<br>
===<br>
<br>
There are workarounds:<br>
<br>
1) Mount the file system with acdirmin=0 and acdirmax=0. But this then
affects <br>
all system calls, not just unlink(). And it hurts NFS performance.<br>
<br>
2) Mount the file system with the noac option, but the same negative effect
as <br>
in #1 applies.<br>
</font>
<br><font size=2 face="Arial">What happens is this: <br>
<br>
0) Let F be a filename on the NFS file system. Initially this file<br>
does not exist.<br>
<br>
1) The application on the machine A does a stat() on F. The NFS<br>
client in the kernel sends a LOOKUP request to the NFS server, which<br>
obviously returns failure. The stat() fails with ENOENT. OK so far.<br>
<br>
2) Immediately afterwards (a few seconds max), the application on<br>
machine B creates the file F. No problems so far.<br>
<br>
3) When B is done with F, a few seconds later the application on<br>
machine A does an unlink() on F. Because of the negative dentry<br>
caching in the Linux kernel, it doesn't even bother to send an NFS<br>
REMOVE request to the NFS server, as (it thinks) it knows for sure the<br>
file doesn't exist. It lets the unlink() fail with ENOENT. But the<br>
file definitely exists.</font>
<br>
<br><font size=2 face="Arial">Is there any other solution for this (including
moving to a newer kernel)?</font>
<br><font size=2 face="Arial"><br>
</font>
<br><font size=2 face="sans-serif">Thanks</font>
<br><font size=2 face="sans-serif">Usha</font></form>
--=_alternative 007C7CFB88257102_=--


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
