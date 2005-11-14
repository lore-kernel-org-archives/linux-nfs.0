From: Jeremy Sanders <jss@ast.cam.ac.uk>
Subject: Diskless boot problems
Date: Mon, 14 Nov 2005 14:55:22 +0000 (GMT)
Message-ID: <Pine.LNX.4.64.0511141441390.11652@xpc20.ast.cam.ac.uk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EbfkL-0001Gy-SH
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 06:55:49 -0800
Received: from ppsw-0.csi.cam.ac.uk ([131.111.8.130])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EbfkJ-0003Cx-Jr
	for nfs@lists.sourceforge.net; Mon, 14 Nov 2005 06:55:50 -0800
Received: from cass41.ast.cam.ac.uk ([131.111.69.186]:48587)
	by ppsw-0.csi.cam.ac.uk (ppsw.cam.ac.uk [131.111.8.130]:25)
	with esmtp id 1Ebfjv-0001y4-0p (Exim 4.54) for nfs@lists.sourceforge.net
	(return-path <jss@ast.cam.ac.uk>); Mon, 14 Nov 2005 14:55:23 +0000
Received: from xserv1.ast.cam.ac.uk (xserv1.ast.cam.ac.uk [131.111.69.235])
	by cass41.ast.cam.ac.uk (8.13.4+Sun/8.13.4) with ESMTP id jAEEtND7023123
	for <nfs@lists.sourceforge.net>; Mon, 14 Nov 2005 14:55:23 GMT
Received: from xpc20.ast.cam.ac.uk (xpc20.ast.cam.ac.uk [131.111.69.39])
	by xserv1.ast.cam.ac.uk (Postfix) with ESMTP id 04941172FD7
	for <nfs@lists.sourceforge.net>; Mon, 14 Nov 2005 14:55:22 +0000 (GMT)
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


We have a set of clients which boot over the network, and mount their root 
file systems over NFS from a server. All systems run linux-2.6.9-22 
(Scientific Linux 4.1, a RHEL clone).

Occasionally the system breaks. For some reason some of the clients 
produce errors in the logs like:

portmap: server localhost not responding, timed out
RPC: failed to contact portmap (errno -5).
portmap: server localhost not responding, timed out
RPC: failed to contact portmap (errno -5).
portmap: server localhost not responding, timed out
RPC: failed to contact portmap (errno -5).
lockd_up: makesock failed, error=-5
portmap: server localhost not responding, timed out
RPC: failed to contact portmap (errno -5).
lockd_up: no pid, 2 users??

This happens every few weeks, and appears random. The clients then get 
into a funny state where some parts of the system appear to continue 
working, but with lockups and hangs.

The systems boot using pxelinux. A busybox initrd sets the IP of the 
client using dhcp, and mounts the root file system. This setup is so that 
the client can use a standard kernel image.

The mount options the client use are:

XXX:~> cat /proc/mounts
aaa.bbb.ccc.ddd:/xss_data1/foo / nfs rw,v3,rsize=32768,wsize=32768,hard,udp,nolock,addr=aaa.bbb.ccc.ddd 0 0
...

I'm not sure how the kernel uses rsize,wsize=32768 with udp, but it says 
so.

Any ideas what could cause this??? We experienced a very similar problem 
with Fedora Core 2, and before that RedHat 7.3.

Thanks

Jeremy

-- 
Jeremy Sanders <jss@ast.cam.ac.uk>   http://www-xray.ast.cam.ac.uk/~jss/
X-Ray Group, Institute of Astronomy, University of Cambridge, UK.
Public Key Server PGP Key ID: E1AAE053


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. Download
it for free - -and be entered to win a 42" plasma tv or your very own
Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
