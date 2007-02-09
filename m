From: Christoph Hellwig <hch@infradead.org>
Subject: [PATCH] sunrpc: remove dead variable 'rpciod_running'
Date: Fri, 9 Feb 2007 20:06:49 +0000
Message-ID: <20070209200649.GA9686@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HFc1U-0001LH-Jd
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 12:07:09 -0800
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HFc1V-00045g-8y
	for nfs@lists.sourceforge.net; Fri, 09 Feb 2007 12:07:10 -0800
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

rpciod_running is not used at all, but due to the way DECLARE_MUTEX_LOCKED
works we don't get a warning for it.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/net/sunrpc/sched.c
===================================================================
--- linux-2.6.orig/net/sunrpc/sched.c	2007-02-06 15:55:43.000000000 +0100
+++ linux-2.6/net/sunrpc/sched.c	2007-02-06 15:55:45.000000000 +0100
@@ -973,8 +973,6 @@
 	spin_unlock(&rpc_sched_lock);
 }
 
-static DECLARE_MUTEX_LOCKED(rpciod_running);
-
 static void rpciod_killall(void)
 {
 	unsigned long flags;

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier.
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
