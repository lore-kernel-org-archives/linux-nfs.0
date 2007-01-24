From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/15] NFS: disconnect before retrying NFSv4 requests
	over TCP
Date: Wed, 24 Jan 2007 14:19:57 -0500
Message-ID: <20070124191957.31133.48291.stgit@localhost.localdomain>
References: <20070124191704.31133.12713.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H9ngP-000198-19
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:21 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H9ngN-0004OE-Bx
	for nfs@lists.sourceforge.net; Wed, 24 Jan 2007 11:21:22 -0800
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

RFC3530 section 3.1.1 states an NFSv4 client MUST NOT send a request
twice on the same connection unless it is the NULL procedure.  Section
3.1.1 suggests that the client should disconnect and reconnect if it
wants to retry a request.

Implement this by adding an rpc_clnt flag that an ULP can use to
specify that the underlying transport should be disconnected on a
major timeout.  The NFSv4 client asserts this new flag, and requests
no retries after a minor retransmit timeout.

Note that disconnecting on a retransmit is in general not safe to do
if the RPC client does not reuse the TCP port number when reconnecting.

See http://bugzilla.linux-nfs.org/show_bug.cgi?id=6

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c             |    9 ++++++---
 include/linux/sunrpc/clnt.h |    2 ++
 net/sunrpc/clnt.c           |    2 ++
 net/sunrpc/xprt.c           |   10 ++++++++++
 4 files changed, 20 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 23ab145..a514599 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -394,7 +394,8 @@ static void nfs_init_timeout_values(stru
 static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 						unsigned int timeo,
 						unsigned int retrans,
-						rpc_authflavor_t flavor)
+						rpc_authflavor_t flavor,
+						int flags)
 {
 	struct rpc_timeout	timeparms;
 	struct rpc_clnt		*clnt = NULL;
@@ -407,6 +408,7 @@ static int nfs_create_rpc_client(struct 
 		.program	= &nfs_program,
 		.version	= clp->rpc_ops->version,
 		.authflavor	= flavor,
+		.flags		= flags,
 	};
 
 	if (!IS_ERR(clp->cl_rpcclient))
@@ -548,7 +550,7 @@ #endif
 	 * - RFC 2623, sec 2.3.2
 	 */
 	error = nfs_create_rpc_client(clp, proto, data->timeo, data->retrans,
-			RPC_AUTH_UNIX);
+					RPC_AUTH_UNIX, 0);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -868,7 +870,8 @@ static int nfs4_init_client(struct nfs_c
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
-	error = nfs_create_rpc_client(clp, proto, timeo, retrans, authflavour);
+	error = nfs_create_rpc_client(clp, proto, timeo, retrans, authflavour,
+					RPC_CLNT_CREATE_DISCRTRY);
 	if (error < 0)
 		goto error;
 	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index a1be89d..c7a78ee 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -40,6 +40,7 @@ struct rpc_clnt {
 
 	unsigned int		cl_softrtry : 1,/* soft timeouts */
 				cl_intr     : 1,/* interruptible */
+				cl_discrtry : 1,/* disconnect before retry */
 				cl_autobind : 1,/* use getport() */
 				cl_oneshot  : 1,/* dispose after use */
 				cl_dead     : 1;/* abandoned */
@@ -111,6 +112,7 @@ #define RPC_CLNT_CREATE_AUTOBIND	(1UL <<
 #define RPC_CLNT_CREATE_ONESHOT		(1UL << 3)
 #define RPC_CLNT_CREATE_NONPRIVPORT	(1UL << 4)
 #define RPC_CLNT_CREATE_NOPING		(1UL << 5)
+#define RPC_CLNT_CREATE_DISCRTRY	(1UL << 6)
 
 struct rpc_clnt *rpc_create(struct rpc_create_args *args);
 struct rpc_clnt	*rpc_bind_new_program(struct rpc_clnt *,
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 244cce4..a5ce924 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -249,6 +249,8 @@ struct rpc_clnt *rpc_create(struct rpc_c
 		clnt->cl_autobind = 1;
 	if (args->flags & RPC_CLNT_CREATE_ONESHOT)
 		clnt->cl_oneshot = 1;
+	if (args->flags & RPC_CLNT_CREATE_DISCRTRY)
+		clnt->cl_discrtry = 1;
 
 	return clnt;
 }
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index 9f787ac..815addd 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -735,6 +735,16 @@ void xprt_transmit(struct rpc_task *task
 			xprt_reset_majortimeo(req);
 			/* Turn off autodisconnect */
 			del_singleshot_timer_sync(&xprt->timer);
+		} else {
+			/* If all request bytes have been sent,
+			 * then we must be retransmitting this one */
+			if (!req->rq_bytes_sent) {
+				if (task->tk_client->cl_discrtry) {
+					xprt_disconnect(xprt);
+					task->tk_status = -ENOTCONN;
+					return;
+				}
+			}
 		}
 	} else if (!req->rq_bytes_sent)
 		return;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
