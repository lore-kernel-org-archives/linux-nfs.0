From: Arnaud Giersch <arnaud.giersch@free.fr>
Subject: nfssvc: writting fds to kernel failed: errno 0 (Success)
Date: Mon, 12 Feb 2007 00:10:02 +0100
Message-ID: <87fy9c5m0l.fsf@groumpf.homeip.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HGNpd-0004Uw-Dr
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 15:10:06 -0800
Received: from smtp3-g19.free.fr ([212.27.42.29])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HGNpe-0007v1-3A
	for nfs@lists.sourceforge.net; Sun, 11 Feb 2007 15:10:07 -0800
Received: from groumpf.localnet (lns-bzn-50f-62-147-179-239.adsl.proxad.net
	[62.147.179.239])
	by smtp3-g19.free.fr (Postfix) with ESMTP id AB0A849F77
	for <nfs@lists.sourceforge.net>; Mon, 12 Feb 2007 00:10:03 +0100 (CET)
Received: from jekyll.localnet ([192.168.1.1])
	by groumpf.localnet with esmtp (Exim 4.63)
	(envelope-from <arnaud.giersch@free.fr>) id 1HGNpb-0002E5-6P
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 00:10:03 +0100
Received: from arnaud by jekyll.localnet with local (Exim 4.63)
	(envelope-from <arnaud.giersch@free.fr>) id 1HGNpa-0000AA-Ss
	for nfs@lists.sourceforge.net; Mon, 12 Feb 2007 00:10:02 +0100
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi,

Since two months, I can see the following strange messages logged each
time that rpc.nfsd is started:

Feb 11 21:46:23 bilbo nfsd[18672]: nfssvc: writting fds to kernel failed: errno 0 (Success)
Feb 11 21:46:23 bilbo nfsd[18672]: nfssvc: writting fds to kernel failed: errno 0 (Success)

It seems however harmless, the NFS server works fine.  

AFAICS, these messages appeared with some kernel between 2.6.18 and
2.6.19.  I don't know which one exactly.  With earlier kernels, the
file /proc/fs/nfsd/portlist does not exist, and the function
nfssvc_setfds() from support/nfs/nfssvc.c (in nfs-utils) exits early
and silently.

This issue has recently reported in the Debian bug tracking system.  See
http://bugs.debian.org/408669

Regards,

        Arnaud Giersch

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
