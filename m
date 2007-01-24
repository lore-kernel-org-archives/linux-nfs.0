From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 12/15] SUNRPC: RPC client should retry with different
	versions of rpcbind
Date: Wed, 24 Jan 2007 14:20:17 -0500
Message-ID: <20070124192016.31133.38106.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9nhB-0001GG-Si
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:10 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9nh5-0004V7-HI
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:22:11 -0800
In-Reply-To: <20070124191704.31133.12713.stgit@localhost.localdomain>
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/clnt.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index a5ce924..606b397 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -896,9 +896,11 @@ call_bind_status(struct rpc_task *task)
 				task->tk_pid);
 		break;
 	case -EPROTONOSUPPORT:
-		dprintk("RPC: %5u remote rpcbind version 2 unavailable\n",
-				task->tk_pid);
-		break;
+		dprintk("RPC: %5u remote rpcbind version unavailable, retrying\n",
+ 				task->tk_pid);
+		task->tk_status = 0;
+		task->tk_action = call_bind;
+		return;
 	default:
 		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
 				task->tk_pid, -task->tk_status);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
