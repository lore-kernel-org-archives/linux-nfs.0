From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/21] SUNRPC: minor optimization of "xid" field in
	rpc_xprt
Date: Thu, 16 Nov 2006 15:03:45 -0500
Message-ID: <20061116200344.32549.32770.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko0q-0006pU-0B
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:08 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko0q-0004dZ-1I
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:39:09 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
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
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
