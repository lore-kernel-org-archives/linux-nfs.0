From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 07/25] SUNRPC: create API for getting remote peer
	address
Date: Wed, 09 Aug 2006 10:59:06 -0400
Message-ID: <20060809145906.3914.27977.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApWe-0008Lb-2Z
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:16 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApWb-0003Xk-GS
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 07:59:13 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

Provide an API for retrieving the remote peer address without allowing
direct access to the rpc_xprt struct.

Test-plan:
Compile kernel with CONFIG_NFS enabled.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 include/linux/sunrpc/clnt.h |    1 +
 net/sunrpc/clnt.c           |   21 +++++++++++++++++++++
 2 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 2e68ac0..65196b0 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -123,6 +123,7 @@ void		rpc_setbufsize(struct rpc_clnt *, 
 size_t		rpc_max_payload(struct rpc_clnt *);
 void		rpc_force_rebind(struct rpc_clnt *);
 int		rpc_ping(struct rpc_clnt *clnt, int flags);
+size_t		rpc_peeraddr(struct rpc_clnt *, struct sockaddr *, size_t);
 
 /*
  * Helper function for NFSroot support
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index bff350e..da377eb 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -536,6 +536,27 @@ rpc_call_setup(struct rpc_task *task, st
 		task->tk_action = rpc_exit_task;
 }
 
+/**
+ * rpc_peeraddr - extract remote peer address from clnt's xprt
+ * @clnt: RPC client structure
+ * @buf: target buffer
+ * @size: length of target buffer
+ *
+ * Returns the number of bytes that are actually in the stored address.
+ */
+size_t rpc_peeraddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t bufsize)
+{
+	size_t bytes;
+	struct rpc_xprt *xprt = clnt->cl_xprt;
+
+	bytes = sizeof(xprt->addr);
+	if (bytes > bufsize)
+		bytes = bufsize;
+	memcpy(buf, &clnt->cl_xprt->addr, bytes);
+	return sizeof(xprt->addr);
+}
+EXPORT_SYMBOL(rpc_peeraddr);
+
 void
 rpc_setbufsize(struct rpc_clnt *clnt, unsigned int sndsize, unsigned int rcvsize)
 {

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
