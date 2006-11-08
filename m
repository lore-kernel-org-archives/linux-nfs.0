From: "Marco Schwarz" <marco.schwarz@gmx.net>
Subject: do_vfs_lock Messages
Date: Wed, 08 Nov 2006 15:49:00 +0100
Message-ID: <20061108144900.241780@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ghojk-0006qg-Hq
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 06:49:08 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1Ghojk-0002A3-1I
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 06:49:09 -0800
To: nfs@lists.sourceforge.net
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

I am getting A LOT of messages like

Nov  8 15:34:56 linux kernel: do_vfs_lock: VFS is out of sync with lock manager!
Nov  8 15:35:06 linux last message repeated 156 times

on a discless client system (root on NFS) with Kernel 2.6.18

Is this critical ? If not, can I supress it somehow ? It doesnt happen with the same server and my older clients (running 2.4.something).

Best regards,
Marco Schwarz

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
