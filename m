From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/10] SUNRPC: minor optimization of "xid" field in
	rpc_xprt
Date: Tue, 17 Oct 2006 14:44:24 -0400
Message-ID: <20061017184424.25704.28776.stgit@schiele.dsl.sfldmi.ameritech.net>
References: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GZtvp-0000K1-Gk
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:53 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GZtvm-00078W-DE
	for nfs@lists.sourceforge.net; Tue, 17 Oct 2006 11:44:54 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061017184142.25704.44260.stgit@schiele.dsl.sfldmi.ameritech.net>
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

Move the xid field in the rpc_xprt structure to be in the same cache line
as the reserve_lock, since these are used at the same time.

Test plan:
None.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/xprt.h |    7 +------
 1 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/include/linux/sunrpc/xprt.h b/include/linux/sunrpc/xprt.h
index 60394fb..0321fb5 100644
--- a/include/linux/sunrpc/xprt.h
+++ b/include/linux/sunrpc/xprt.h
@@ -158,11 +158,6 @@ struct rpc_xprt {
 				resvport   : 1; /* use a reserved port */
 
 	/*
-	 * XID
-	 */
-	__u32			xid;		/* Next XID value to use */
-
-	/*
 	 * State of TCP reply receive stuff
 	 */
 	__be32			tcp_recm,	/* Fragment header */
@@ -193,8 +188,8 @@ struct rpc_xprt {
 	 */
 	spinlock_t		transport_lock;	/* lock transport info */
 	spinlock_t		reserve_lock;	/* lock slot table */
+	u32			xid;		/* Next XID value to use */
 	struct rpc_task *	snd_task;	/* Task blocked in send */
-
 	struct list_head	recv;
 
 	struct {

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
