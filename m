From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/14] SUNRPC: Enable support for rpcbind versions 3
	and 4 via CONFIG options
Date: Thu, 18 Jan 2007 18:30:45 -0500
Message-ID: <20070118233045.23310.43704.stgit@localhost.localdomain>
References: <20070118232356.23310.6705.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7gie-0002pS-Ns
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:56 -0800
Received: from agminet01.oracle.com ([141.146.126.228])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7gig-0004U5-8i
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:30:58 -0800
To: trond.myklybust@fys.uio.no
In-Reply-To: <20070118232356.23310.6705.stgit@localhost.localdomain>
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

 fs/Kconfig        |   24 ++++++++++++++++++++++++
 net/sunrpc/clnt.c |    8 +++++---
 2 files changed, 29 insertions(+), 3 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 8cd2417..b49d1b5 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1764,6 +1764,30 @@ config NFS_COMMON
 config SUNRPC
 	tristate
 
+config RPCBIND_VERSION3
+	bool "Support for rpcbind version 3"
+	depends on SUNRPC && EXPERIMENTAL
+	default n
+	help
+	  The in-kernel Linux RPC client already supports rpcbind version 2.
+	  This option adds support to the Linux in-kernel RPC client for
+	  rpcbind version 3.
+
+	  Not all servers support rpcbind version 3, and the client support is
+	  still experimental.  If unsure, say N.
+
+config RPCBIND_VERSION4
+	bool "Support for rpcbind version 4"
+	depends on SUNRPC && EXPERIMENTAL && RPCBIND_VERSION3
+	default n
+	help
+	  The in-kernel Linux RPC client already supports rpcbind version 2.
+	  This option adds support to the Linux in-kernel RPC client for
+	  rpcbind version 4.
+
+	  Not all servers support rpcbind version 4, and the client support is
+	  still experimental.  If unsure, say N.
+
 config SUNRPC_GSS
 	tristate
 
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 244cce4..493b950 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -894,9 +894,11 @@ call_bind_status(struct rpc_task *task)
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
