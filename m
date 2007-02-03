From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: asynchronous locks for cluster exports
Date: Sat,  3 Feb 2007 00:30:55 -0500
Message-ID: <35541.8655825362$1170480672@news.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: linux-fsdevel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HDDUI-0000ur-TA
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:30:59 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HDDUJ-0008Ht-KY
	for nfs@lists.sourceforge.net; Fri, 02 Feb 2007 21:31:00 -0800
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


This is another attempt at a posix locking interface that allows us to
provide NFS clients with cluster-coherent locking without blocking lockd
while the filesystem goes off and talks to other nodes.

This time we're using the existing file ->lock operation instead of
defining a new export operation for the purpose, and factoring out the
code that switches between calling ->lock or the default local
operation, so that lock managers and local callers go through the same
code.

I find the existing interfaces a little odd, and while I think I managed
to combine them correctly, I'd certainly appreciate any review.

The gfs2 implementation in the last patch is (unfortunately) still just
a rough draft that needs some more thought and some testing.

--b.

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
