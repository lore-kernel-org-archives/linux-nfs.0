From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/21] SUNRPC: Remove pprintk() from net/sunrpc/xprt.c
Date: Thu, 16 Nov 2006 15:05:04 -0500
Message-ID: <20061116200504.32549.16983.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1z-0006yC-Th
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:20 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko20-00053s-W8
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:21 -0800
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

These appear to be deprecated.  Removing them also gets rid of some sparse
noise.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprt.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 8cc2afa..f8ca0a9 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -459,7 +459,6 @@ int xprt_adjust_timeout(struct rpc_rqst 
 		if (to->to_maxval && req->rq_timeout >= to->to_maxval)
 			req->rq_timeout = to->to_maxval;
 		req->rq_retries++;
-		pprintk("RPC: %lu retrans\n", jiffies);
 	} else {
 		req->rq_timeout = to->to_initval;
 		req->rq_retries = 0;
@@ -468,7 +467,6 @@ int xprt_adjust_timeout(struct rpc_rqst 
 		spin_lock_bh(&xprt->transport_lock);
 		rpc_init_rtt(req->rq_task->tk_client->cl_rtt, to->to_initval);
 		spin_unlock_bh(&xprt->transport_lock);
-		pprintk("RPC: %lu timeout\n", jiffies);
 		status = -ETIMEDOUT;
 	}
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
