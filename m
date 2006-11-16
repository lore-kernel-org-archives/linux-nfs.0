From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/21] SUNRPC: fix print format for tk_pid
Date: Thu, 16 Nov 2006 15:05:08 -0500
Message-ID: <20061116200508.32549.35507.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko29-0006yV-0Q
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:29 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko25-0000io-Vi
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:30 -0800
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

The tk_pid field is an unsigned short.  The proper print format specifier for
that type is %5u, not %4d.

Also clean up some miscellaneous print formatting nits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth.c      |   22 ++++++------
 net/sunrpc/auth_unix.c |    6 ++-
 net/sunrpc/clnt.c      |   86 ++++++++++++++++++++++++++----------------------
 net/sunrpc/pmap_clnt.c |   14 ++++----
 net/sunrpc/sched.c     |   52 +++++++++++++++--------------
 net/sunrpc/stats.c     |    6 ++-
 net/sunrpc/xprt.c      |   47 ++++++++++++++------------
 net/sunrpc/xprtsock.c  |   85 ++++++++++++++++++++++++-----------------------
 8 files changed, 165 insertions(+), 153 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 993ff1a..3a57b12 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -181,7 +181,7 @@ rpcauth_gc_credcache(struct rpc_auth *au
 	struct rpc_cred	*cred;
 	int		i;
 
-	dprintk("RPC: gc'ing RPC credentials for auth %p\n", auth);
+	dprintk("RPC:       gc'ing RPC credentials for auth %p\n", auth);
 	for (i = 0; i < RPC_CREDCACHE_NR; i++) {
 		hlist_for_each_safe(pos, next, &cache->hashtable[i]) {
 			cred = hlist_entry(pos, struct rpc_cred, cr_hash);
@@ -267,7 +267,7 @@ rpcauth_lookupcred(struct rpc_auth *auth
 	};
 	struct rpc_cred *ret;
 
-	dprintk("RPC:     looking up %s cred\n",
+	dprintk("RPC:       looking up %s cred\n",
 		auth->au_ops->au_name);
 	get_group_info(acred.group_info);
 	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
@@ -287,7 +287,7 @@ rpcauth_bindcred(struct rpc_task *task)
 	struct rpc_cred *ret;
 	int flags = 0;
 
-	dprintk("RPC: %4d looking up %s cred\n",
+	dprintk("RPC: %5u looking up %s cred\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name);
 	get_group_info(acred.group_info);
 	if (task->tk_flags & RPC_TASK_ROOTCREDS)
@@ -304,7 +304,7 @@ rpcauth_bindcred(struct rpc_task *task)
 void
 rpcauth_holdcred(struct rpc_task *task)
 {
-	dprintk("RPC: %4d holding %s cred %p\n",
+	dprintk("RPC: %5u holding %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, task->tk_msg.rpc_cred);
 	if (task->tk_msg.rpc_cred)
 		get_rpccred(task->tk_msg.rpc_cred);
@@ -324,7 +324,7 @@ rpcauth_unbindcred(struct rpc_task *task
 {
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
-	dprintk("RPC: %4d releasing %s cred %p\n",
+	dprintk("RPC: %5u releasing %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, cred);
 
 	put_rpccred(cred);
@@ -336,7 +336,7 @@ rpcauth_marshcred(struct rpc_task *task,
 {
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
-	dprintk("RPC: %4d marshaling %s cred %p\n",
+	dprintk("RPC: %5u marshaling %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, cred);
 
 	return cred->cr_ops->crmarshal(task, p);
@@ -347,7 +347,7 @@ rpcauth_checkverf(struct rpc_task *task,
 {
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 
-	dprintk("RPC: %4d validating %s cred %p\n",
+	dprintk("RPC: %5u validating %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, cred);
 
 	return cred->cr_ops->crvalidate(task, p);
@@ -359,7 +359,7 @@ rpcauth_wrap_req(struct rpc_task *task, 
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
 
-	dprintk("RPC: %4d using %s cred %p to wrap rpc data\n",
+	dprintk("RPC: %5u using %s cred %p to wrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crwrap_req)
 		return cred->cr_ops->crwrap_req(task, encode, rqstp, data, obj);
@@ -373,7 +373,7 @@ rpcauth_unwrap_resp(struct rpc_task *tas
 {
 	struct rpc_cred *cred = task->tk_msg.rpc_cred;
 
-	dprintk("RPC: %4d using %s cred %p to unwrap rpc data\n",
+	dprintk("RPC: %5u using %s cred %p to unwrap rpc data\n",
 			task->tk_pid, cred->cr_ops->cr_name, cred);
 	if (cred->cr_ops->crunwrap_resp)
 		return cred->cr_ops->crunwrap_resp(task, decode, rqstp,
@@ -388,7 +388,7 @@ rpcauth_refreshcred(struct rpc_task *tas
 	struct rpc_cred	*cred = task->tk_msg.rpc_cred;
 	int err;
 
-	dprintk("RPC: %4d refreshing %s cred %p\n",
+	dprintk("RPC: %5u refreshing %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, cred);
 
 	err = cred->cr_ops->crrefresh(task);
@@ -400,7 +400,7 @@ rpcauth_refreshcred(struct rpc_task *tas
 void
 rpcauth_invalcred(struct rpc_task *task)
 {
-	dprintk("RPC: %4d invalidating %s cred %p\n",
+	dprintk("RPC: %5u invalidating %s cred %p\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name, task->tk_msg.rpc_cred);
 	spin_lock(&rpc_credcache_lock);
 	if (task->tk_msg.rpc_cred)
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index f7f990c..c315346 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -39,7 +39,7 @@ static struct rpc_credops	unix_credops;
 static struct rpc_auth *
 unx_create(struct rpc_clnt *clnt, rpc_authflavor_t flavor)
 {
-	dprintk("RPC: creating UNIX authenticator for client %p\n", clnt);
+	dprintk("RPC:       creating UNIX authenticator for client %p\n", clnt);
 	if (atomic_inc_return(&unix_auth.au_count) == 0)
 		unix_cred_cache.nextgc = jiffies + (unix_cred_cache.expire >> 1);
 	return &unix_auth;
@@ -48,7 +48,7 @@ unx_create(struct rpc_clnt *clnt, rpc_au
 static void
 unx_destroy(struct rpc_auth *auth)
 {
-	dprintk("RPC: destroying UNIX authenticator %p\n", auth);
+	dprintk("RPC:       destroying UNIX authenticator %p\n", auth);
 	rpcauth_free_credcache(auth);
 }
 
@@ -67,7 +67,7 @@ unx_create_cred(struct rpc_auth *auth, s
 	struct unx_cred	*cred;
 	int		i;
 
-	dprintk("RPC:      allocating UNIX cred for uid %d gid %d\n",
+	dprintk("RPC:       allocating UNIX cred for uid %d gid %d\n",
 				acred->uid, acred->gid);
 
 	if (!(cred = kmalloc(sizeof(*cred), GFP_KERNEL)))
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 1a07fe9..4e46558 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -287,7 +287,7 @@ out_no_clnt:
 int
 rpc_shutdown_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC: shutting down %s client for %s, tasks=%d\n",
+	dprintk("RPC:       shutting down %s client for %s, tasks=%d\n",
 			clnt->cl_protname, clnt->cl_server,
 			atomic_read(&clnt->cl_users));
 
@@ -322,7 +322,7 @@ rpc_destroy_client(struct rpc_clnt *clnt
 		return 1;
 	BUG_ON(atomic_read(&clnt->cl_users) != 0);
 
-	dprintk("RPC: destroying %s client for %s\n",
+	dprintk("RPC:       destroying %s client for %s\n",
 			clnt->cl_protname, clnt->cl_server);
 	if (clnt->cl_auth) {
 		rpcauth_destroy(clnt->cl_auth);
@@ -354,7 +354,7 @@ out_free:
 void
 rpc_release_client(struct rpc_clnt *clnt)
 {
-	dprintk("RPC:      rpc_release_client(%p, %d)\n",
+	dprintk("RPC:       rpc_release_client(%p, %d)\n",
 				clnt, atomic_read(&clnt->cl_users));
 
 	if (!atomic_dec_and_test(&clnt->cl_users))
@@ -648,7 +648,7 @@ call_start(struct rpc_task *task)
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	dprintk("RPC: %4d call_start %s%d proc %d (%s)\n", task->tk_pid,
+	dprintk("RPC: %5u call_start %s%d proc %d (%s)\n", task->tk_pid,
 		clnt->cl_protname, clnt->cl_vers, task->tk_msg.rpc_proc->p_proc,
 		(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
@@ -664,7 +664,7 @@ call_start(struct rpc_task *task)
 static void
 call_reserve(struct rpc_task *task)
 {
-	dprintk("RPC: %4d call_reserve\n", task->tk_pid);
+	dprintk("RPC: %5u call_reserve\n", task->tk_pid);
 
 	if (!rpcauth_uptodatecred(task)) {
 		task->tk_action = call_refresh;
@@ -684,7 +684,7 @@ call_reserveresult(struct rpc_task *task
 {
 	int status = task->tk_status;
 
-	dprintk("RPC: %4d call_reserveresult (status %d)\n",
+	dprintk("RPC: %5u call_reserveresult (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	/*
@@ -739,7 +739,7 @@ call_allocate(struct rpc_task *task)
 	struct rpc_xprt *xprt = task->tk_xprt;
 	unsigned int	bufsiz;
 
-	dprintk("RPC: %4d call_allocate (status %d)\n", 
+	dprintk("RPC: %5u call_allocate (status %d)\n",
 				task->tk_pid, task->tk_status);
 	task->tk_action = call_bind;
 	if (req->rq_buffer)
@@ -751,7 +751,8 @@ call_allocate(struct rpc_task *task)
 
 	if (xprt->ops->buf_alloc(task, bufsiz << 1) != NULL)
 		return;
-	printk(KERN_INFO "RPC: buffer allocation failed for task %p\n", task); 
+
+	dprintk("RPC: %5u rpc_buffer allocation failed\n", task->tk_pid);
 
 	if (RPC_IS_ASYNC(task) || !signalled()) {
 		xprt_release(task);
@@ -788,7 +789,7 @@ call_encode(struct rpc_task *task)
 	kxdrproc_t	encode;
 	__be32		*p;
 
-	dprintk("RPC: %4d call_encode (status %d)\n", 
+	dprintk("RPC: %5u call_encode (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	/* Default buffer setup */
@@ -833,7 +834,7 @@ call_bind(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 
-	dprintk("RPC: %4d call_bind (status %d)\n",
+	dprintk("RPC: %5u call_bind (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	task->tk_action = call_connect;
@@ -853,7 +854,7 @@ call_bind_status(struct rpc_task *task)
 	int status = -EACCES;
 
 	if (task->tk_status >= 0) {
-		dprintk("RPC: %4d call_bind_status (status %d)\n",
+		dprintk("RPC: %5u call_bind_status (status %d)\n",
 					task->tk_pid, task->tk_status);
 		task->tk_status = 0;
 		task->tk_action = call_connect;
@@ -862,24 +863,24 @@ call_bind_status(struct rpc_task *task)
 
 	switch (task->tk_status) {
 	case -EACCES:
-		dprintk("RPC: %4d remote rpcbind: RPC program/version unavailable\n",
+		dprintk("RPC: %5u remote rpcbind: RPC program/version unavailable\n",
 				task->tk_pid);
 		rpc_delay(task, 3*HZ);
 		goto retry_timeout;
 	case -ETIMEDOUT:
-		dprintk("RPC: %4d rpcbind request timed out\n",
+		dprintk("RPC: %5u rpcbind request timed out\n",
 				task->tk_pid);
 		goto retry_timeout;
 	case -EPFNOSUPPORT:
-		dprintk("RPC: %4d remote rpcbind service unavailable\n",
+		dprintk("RPC: %5u remote rpcbind service unavailable\n",
 				task->tk_pid);
 		break;
 	case -EPROTONOSUPPORT:
-		dprintk("RPC: %4d remote rpcbind version 2 unavailable\n",
+		dprintk("RPC: %5u remote rpcbind version 2 unavailable\n",
 				task->tk_pid);
 		break;
 	default:
-		dprintk("RPC: %4d unrecognized rpcbind error (%d)\n",
+		dprintk("RPC: %5u unrecognized rpcbind error (%d)\n",
 				task->tk_pid, -task->tk_status);
 		status = -EIO;
 	}
@@ -899,7 +900,7 @@ call_connect(struct rpc_task *task)
 {
 	struct rpc_xprt *xprt = task->tk_xprt;
 
-	dprintk("RPC: %4d call_connect xprt %p %s connected\n",
+	dprintk("RPC: %5u call_connect xprt %p %s connected\n",
 			task->tk_pid, xprt,
 			(xprt_connected(xprt) ? "is" : "is not"));
 
@@ -921,7 +922,7 @@ call_connect_status(struct rpc_task *tas
 	struct rpc_clnt *clnt = task->tk_client;
 	int status = task->tk_status;
 
-	dprintk("RPC: %5u call_connect_status (status %d)\n", 
+	dprintk("RPC: %5u call_connect_status (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	task->tk_status = 0;
@@ -954,7 +955,7 @@ call_connect_status(struct rpc_task *tas
 static void
 call_transmit(struct rpc_task *task)
 {
-	dprintk("RPC: %4d call_transmit (status %d)\n", 
+	dprintk("RPC: %5u call_transmit (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	task->tk_action = call_status;
@@ -1016,7 +1017,7 @@ call_status(struct rpc_task *task)
 	if (req->rq_received > 0 && !req->rq_bytes_sent)
 		task->tk_status = req->rq_received;
 
-	dprintk("RPC: %4d call_status (status %d)\n", 
+	dprintk("RPC: %5u call_status (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	status = task->tk_status;
@@ -1068,11 +1069,11 @@ call_timeout(struct rpc_task *task)
 	struct rpc_clnt	*clnt = task->tk_client;
 
 	if (xprt_adjust_timeout(task->tk_rqstp) == 0) {
-		dprintk("RPC: %4d call_timeout (minor)\n", task->tk_pid);
+		dprintk("RPC: %5u call_timeout (minor)\n", task->tk_pid);
 		goto retry;
 	}
 
-	dprintk("RPC: %4d call_timeout (major)\n", task->tk_pid);
+	dprintk("RPC: %5u call_timeout (major)\n", task->tk_pid);
 	task->tk_timeouts++;
 
 	if (RPC_IS_SOFT(task)) {
@@ -1106,7 +1107,7 @@ call_decode(struct rpc_task *task)
 	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
 	__be32		*p;
 
-	dprintk("RPC: %4d call_decode (status %d)\n", 
+	dprintk("RPC: %5u call_decode (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	if (task->tk_flags & RPC_CALL_MAJORSEEN) {
@@ -1151,7 +1152,7 @@ call_decode(struct rpc_task *task)
 	if (decode)
 		task->tk_status = rpcauth_unwrap_resp(task, decode, req, p,
 						      task->tk_msg.rpc_resp);
-	dprintk("RPC: %4d call_decode result %d\n", task->tk_pid,
+	dprintk("RPC: %5u call_decode result %d\n", task->tk_pid,
 					task->tk_status);
 	return;
 out_retry:
@@ -1165,7 +1166,7 @@ out_retry:
 static void
 call_refresh(struct rpc_task *task)
 {
-	dprintk("RPC: %4d call_refresh\n", task->tk_pid);
+	dprintk("RPC: %5u call_refresh\n", task->tk_pid);
 
 	xprt_release(task);	/* Must do to obtain new XID */
 	task->tk_action = call_refreshresult;
@@ -1181,7 +1182,7 @@ static void
 call_refreshresult(struct rpc_task *task)
 {
 	int status = task->tk_status;
-	dprintk("RPC: %4d call_refreshresult (status %d)\n", 
+	dprintk("RPC: %5u call_refreshresult (status %d)\n",
 				task->tk_pid, task->tk_status);
 
 	task->tk_status = 0;
@@ -1260,11 +1261,13 @@ call_verify(struct rpc_task *task)
 			case RPC_AUTH_ERROR:
 				break;
 			case RPC_MISMATCH:
-				dprintk("%s: RPC call version mismatch!\n", __FUNCTION__);
+				dprintk("RPC: %5u %s: RPC call version mismatch!\n",
+						task->tk_pid, __FUNCTION__);
 				error = -EPROTONOSUPPORT;
 				goto out_err;
 			default:
-				dprintk("%s: RPC call rejected, unknown error: %x\n", __FUNCTION__, n);
+				dprintk("RPC: %5u %s: RPC call rejected, unknown error: %x\n",
+						task->tk_pid, __FUNCTION__, n);
 				goto out_eio;
 		}
 		if (--len < 0)
@@ -1277,8 +1280,8 @@ call_verify(struct rpc_task *task)
 			if (!task->tk_cred_retry)
 				break;
 			task->tk_cred_retry--;
-			dprintk("RPC: %4d call_verify: retry stale creds\n",
-							task->tk_pid);
+			dprintk("RPC: %5u %s: retry stale creds\n",
+					task->tk_pid, __FUNCTION__);
 			rpcauth_invalcred(task);
 			task->tk_action = call_refresh;
 			goto out_retry;
@@ -1288,8 +1291,8 @@ call_verify(struct rpc_task *task)
 			if (!task->tk_garb_retry)
 				break;
 			task->tk_garb_retry--;
-			dprintk("RPC: %4d call_verify: retry garbled creds\n",
-							task->tk_pid);
+			dprintk("RPC: %5u %s: retry garbled creds\n",
+					task->tk_pid, __FUNCTION__);
 			task->tk_action = call_bind;
 			goto out_retry;
 		case RPC_AUTH_TOOWEAK:
@@ -1300,8 +1303,8 @@ call_verify(struct rpc_task *task)
 			printk(KERN_WARNING "call_verify: unknown auth error: %x\n", n);
 			error = -EIO;
 		}
-		dprintk("RPC: %4d call_verify: call rejected %d\n",
-						task->tk_pid, n);
+		dprintk("RPC: %5u %s: call rejected %d\n",
+				task->tk_pid, __FUNCTION__, n);
 		goto out_err;
 	}
 	if (!(p = rpcauth_checkverf(task, p))) {
@@ -1315,20 +1318,23 @@ call_verify(struct rpc_task *task)
 	case RPC_SUCCESS:
 		return p;
 	case RPC_PROG_UNAVAIL:
-		dprintk("RPC: call_verify: program %u is unsupported by server %s\n",
+		dprintk("RPC: %5u %s: program %u is unsupported by server %s\n",
+				task->tk_pid, __FUNCTION__,
 				(unsigned int)task->tk_client->cl_prog,
 				task->tk_client->cl_server);
 		error = -EPFNOSUPPORT;
 		goto out_err;
 	case RPC_PROG_MISMATCH:
-		dprintk("RPC: call_verify: program %u, version %u unsupported by server %s\n",
+		dprintk("RPC: %5u %s: program %u, version %u unsupported by server %s\n",
+				task->tk_pid, __FUNCTION__,
 				(unsigned int)task->tk_client->cl_prog,
 				(unsigned int)task->tk_client->cl_vers,
 				task->tk_client->cl_server);
 		error = -EPROTONOSUPPORT;
 		goto out_err;
 	case RPC_PROC_UNAVAIL:
-		dprintk("RPC: call_verify: proc %p unsupported by program %u, version %u on server %s\n",
+		dprintk("RPC: %5u %s: proc %p unsupported by program %u, version %u on server %s\n",
+				task->tk_pid, __FUNCTION__,
 				task->tk_msg.rpc_proc,
 				task->tk_client->cl_prog,
 				task->tk_client->cl_vers,
@@ -1336,7 +1342,8 @@ call_verify(struct rpc_task *task)
 		error = -EOPNOTSUPP;
 		goto out_err;
 	case RPC_GARBAGE_ARGS:
-		dprintk("RPC: %4d %s: server saw garbage\n", task->tk_pid, __FUNCTION__);
+		dprintk("RPC: %5u %s: server saw garbage\n",
+				task->tk_pid, __FUNCTION__);
 		break;			/* retry */
 	default:
 		printk(KERN_WARNING "call_verify: server accept status: %x\n", n);
@@ -1347,7 +1354,8 @@ out_garbage:
 	task->tk_client->cl_stats->rpcgarbage++;
 	if (task->tk_garb_retry) {
 		task->tk_garb_retry--;
-		dprintk("RPC %s: retrying %4d\n", __FUNCTION__, task->tk_pid);
+		dprintk("RPC %5u %s: retrying\n",
+				task->tk_pid, __FUNCTION__);
 		task->tk_action = call_bind;
 out_retry:
 		return ERR_PTR(-EAGAIN);
diff --git a/net/sunrpc/pmap_clnt.c b/net/sunrpc/pmap_clnt.c
index 090a891..5755bac 100644
--- a/net/sunrpc/pmap_clnt.c
+++ b/net/sunrpc/pmap_clnt.c
@@ -94,7 +94,7 @@ void rpc_getport(struct rpc_task *task)
 	struct rpc_task *child;
 	int status;
 
-	dprintk("RPC: %4d rpc_getport(%s, %u, %u, %d)\n",
+	dprintk("RPC: %5u rpc_getport(%s, %u, %u, %d)\n",
 			task->tk_pid, clnt->cl_server,
 			clnt->cl_prog, clnt->cl_vers, xprt->prot);
 
@@ -175,7 +175,7 @@ int rpc_getport_external(struct sockaddr
 	char		hostname[32];
 	int		status;
 
-	dprintk("RPC:      rpc_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
+	dprintk("RPC:       rpc_getport_external(%u.%u.%u.%u, %u, %u, %d)\n",
 			NIPQUAD(sin->sin_addr.s_addr), prog, vers, prot);
 
 	sprintf(hostname, "%u.%u.%u.%u", NIPQUAD(sin->sin_addr.s_addr));
@@ -218,7 +218,7 @@ static void pmap_getport_done(struct rpc
 		status = 0;
 	}
 
-	dprintk("RPC: %4d pmap_getport_done(status %d, port %u)\n",
+	dprintk("RPC: %5u pmap_getport_done(status %d, port %u)\n",
 			child->tk_pid, status, map->pm_port);
 
 	pmap_wake_portmap_waiters(xprt, status);
@@ -255,13 +255,13 @@ int rpc_register(u32 prog, u32 vers, int
 	struct rpc_clnt		*pmap_clnt;
 	int error = 0;
 
-	dprintk("RPC: registering (%u, %u, %d, %u) with portmapper.\n",
+	dprintk("RPC:       registering (%u, %u, %d, %u) with portmapper.\n",
 			prog, vers, prot, port);
 
 	pmap_clnt = pmap_create("localhost", &sin, IPPROTO_UDP, 1);
 	if (IS_ERR(pmap_clnt)) {
 		error = PTR_ERR(pmap_clnt);
-		dprintk("RPC: couldn't create pmap client. Error = %d\n", error);
+		dprintk("RPC:       couldn't create pmap client. Error = %d\n", error);
 		return error;
 	}
 
@@ -272,7 +272,7 @@ int rpc_register(u32 prog, u32 vers, int
 			"RPC: failed to contact portmap (errno %d).\n",
 			error);
 	}
-	dprintk("RPC: registration status %d/%d\n", error, *okay);
+	dprintk("RPC:       registration status %d/%d\n", error, *okay);
 
 	/* Client deleted automatically because cl_oneshot == 1 */
 	return error;
@@ -303,7 +303,7 @@ static struct rpc_clnt *pmap_create(char
  */
 static int xdr_encode_mapping(struct rpc_rqst *req, __be32 *p, struct portmap_args *map)
 {
-	dprintk("RPC: xdr_encode_mapping(%u, %u, %u, %u)\n",
+	dprintk("RPC:       xdr_encode_mapping(%u, %u, %u, %u)\n",
 		map->pm_prog, map->pm_vers, map->pm_prot, map->pm_port);
 	*p++ = htonl(map->pm_prog);
 	*p++ = htonl(map->pm_vers);
diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
index a1ab4ee..1bfa6fb 100644
--- a/net/sunrpc/sched.c
+++ b/net/sunrpc/sched.c
@@ -73,7 +73,7 @@ static DEFINE_SPINLOCK(rpc_sched_lock);
 static inline void
 __rpc_disable_timer(struct rpc_task *task)
 {
-	dprintk("RPC: %4d disabling timer\n", task->tk_pid);
+	dprintk("RPC: %5u disabling timer\n", task->tk_pid);
 	task->tk_timeout_fn = NULL;
 	task->tk_timeout = 0;
 }
@@ -92,7 +92,7 @@ static void rpc_run_timer(struct rpc_tas
 	callback = task->tk_timeout_fn;
 	task->tk_timeout_fn = NULL;
 	if (callback && RPC_IS_QUEUED(task)) {
-		dprintk("RPC: %4d running timer\n", task->tk_pid);
+		dprintk("RPC: %5u running timer\n", task->tk_pid);
 		callback(task);
 	}
 	smp_mb__before_clear_bit();
@@ -109,7 +109,7 @@ __rpc_add_timer(struct rpc_task *task, r
 	if (!task->tk_timeout)
 		return;
 
-	dprintk("RPC: %4d setting alarm for %lu ms\n",
+	dprintk("RPC: %5u setting alarm for %lu ms\n",
 			task->tk_pid, task->tk_timeout * 1000 / HZ);
 
 	if (timer)
@@ -131,7 +131,7 @@ rpc_delete_timer(struct rpc_task *task)
 		return;
 	if (test_and_clear_bit(RPC_TASK_HAS_TIMER, &task->tk_runstate)) {
 		del_singleshot_timer_sync(&task->tk_timer);
-		dprintk("RPC: %4d deleting timer\n", task->tk_pid);
+		dprintk("RPC: %5u deleting timer\n", task->tk_pid);
 	}
 }
 
@@ -178,7 +178,7 @@ static void __rpc_add_wait_queue(struct 
 	queue->qlen++;
 	rpc_set_queued(task);
 
-	dprintk("RPC: %4d added to queue %p \"%s\"\n",
+	dprintk("RPC: %5u added to queue %p \"%s\"\n",
 				task->tk_pid, queue, rpc_qname(queue));
 }
 
@@ -211,7 +211,7 @@ static void __rpc_remove_wait_queue(stru
 	else
 		list_del(&task->u.tk_wait.list);
 	queue->qlen--;
-	dprintk("RPC: %4d removed from queue %p \"%s\"\n",
+	dprintk("RPC: %5u removed from queue %p \"%s\"\n",
 				task->tk_pid, queue, rpc_qname(queue));
 }
 
@@ -325,7 +325,7 @@ static void rpc_make_runnable(struct rpc
 static void __rpc_sleep_on(struct rpc_wait_queue *q, struct rpc_task *task,
 			rpc_action action, rpc_action timer)
 {
-	dprintk("RPC: %4d sleep_on(queue \"%s\" time %ld)\n", task->tk_pid,
+	dprintk("RPC: %5u sleep_on(queue \"%s\" time %lu)\n", task->tk_pid,
 				rpc_qname(q), jiffies);
 
 	if (!RPC_IS_ASYNC(task) && !RPC_IS_ACTIVATED(task)) {
@@ -362,7 +362,7 @@ void rpc_sleep_on(struct rpc_wait_queue 
  */
 static void __rpc_do_wake_up_task(struct rpc_task *task)
 {
-	dprintk("RPC: %4d __rpc_wake_up_task (now %ld)\n", task->tk_pid, jiffies);
+	dprintk("RPC: %5u __rpc_wake_up_task (now %lu)\n", task->tk_pid, jiffies);
 
 #ifdef RPC_DEBUG
 	BUG_ON(task->tk_magic != RPC_TASK_MAGIC_ID);
@@ -378,7 +378,7 @@ #endif
 
 	rpc_make_runnable(task);
 
-	dprintk("RPC:      __rpc_wake_up_task done\n");
+	dprintk("RPC:       __rpc_wake_up_task done\n");
 }
 
 /*
@@ -399,7 +399,7 @@ static void __rpc_wake_up_task(struct rp
 static void
 __rpc_default_timer(struct rpc_task *task)
 {
-	dprintk("RPC: %d timeout (default timer)\n", task->tk_pid);
+	dprintk("RPC: %5u timeout (default timer)\n", task->tk_pid);
 	task->tk_status = -ETIMEDOUT;
 	rpc_wake_up_task(task);
 }
@@ -480,7 +480,7 @@ struct rpc_task * rpc_wake_up_next(struc
 {
 	struct rpc_task	*task = NULL;
 
-	dprintk("RPC:      wake_up_next(%p \"%s\")\n", queue, rpc_qname(queue));
+	dprintk("RPC:       wake_up_next(%p \"%s\")\n", queue, rpc_qname(queue));
 	spin_lock_bh(&queue->lock);
 	if (RPC_IS_PRIORITY(queue))
 		task = __rpc_wake_up_next_priority(queue);
@@ -588,7 +588,7 @@ static int __rpc_execute(struct rpc_task
 {
 	int		status = 0;
 
-	dprintk("RPC: %4d rpc_execute flgs %x\n",
+	dprintk("RPC: %5u rpc_execute flgs %x\n",
 				task->tk_pid, task->tk_flags);
 
 	BUG_ON(RPC_IS_QUEUED(task));
@@ -649,7 +649,7 @@ static int __rpc_execute(struct rpc_task
 		}
 
 		/* sync task: sleep here */
-		dprintk("RPC: %4d sync task going to sleep\n", task->tk_pid);
+		dprintk("RPC: %5u sync task going to sleep\n", task->tk_pid);
 		/* Note: Caller should be using rpc_clnt_sigmask() */
 		status = out_of_line_wait_on_bit(&task->tk_runstate,
 				RPC_TASK_QUEUED, rpc_wait_bit_interruptible,
@@ -661,16 +661,16 @@ static int __rpc_execute(struct rpc_task
 			 * clean up after sleeping on some queue, we don't
 			 * break the loop here, but go around once more.
 			 */
-			dprintk("RPC: %4d got signal\n", task->tk_pid);
+			dprintk("RPC: %5u got signal\n", task->tk_pid);
 			task->tk_flags |= RPC_TASK_KILLED;
 			rpc_exit(task, -ERESTARTSYS);
 			rpc_wake_up_task(task);
 		}
 		rpc_set_running(task);
-		dprintk("RPC: %4d sync task resuming\n", task->tk_pid);
+		dprintk("RPC: %5u sync task resuming\n", task->tk_pid);
 	}
 
-	dprintk("RPC: %4d, return %d, status %d\n", task->tk_pid, status, task->tk_status);
+	dprintk("RPC: %5u return %d, status %d\n", task->tk_pid, status, task->tk_status);
 	/* Wake up anyone who is waiting for task completion */
 	rpc_mark_complete_task(task);
 	/* Release all resources associated with the task */
@@ -800,7 +800,7 @@ #endif
 	/* starting timestamp */
 	task->tk_start = jiffies;
 
-	dprintk("RPC: %4d new task procpid %d\n", task->tk_pid,
+	dprintk("RPC: %5u new task procpid %u\n", task->tk_pid,
 				current->pid);
 }
 
@@ -812,7 +812,7 @@ rpc_alloc_task(void)
 
 static void rpc_free_task(struct rpc_task *task)
 {
-	dprintk("RPC: %4d freeing task\n", task->tk_pid);
+	dprintk("RPC: %5u freeing task\n", task->tk_pid);
 	mempool_free(task, rpc_task_mempool);
 }
 
@@ -831,7 +831,7 @@ struct rpc_task *rpc_new_task(struct rpc
 
 	rpc_init_task(task, clnt, flags, tk_ops, calldata);
 
-	dprintk("RPC: %4d allocated task\n", task->tk_pid);
+	dprintk("RPC: %5u allocated task\n", task->tk_pid);
 	task->tk_flags |= RPC_TASK_DYNAMIC;
 out:
 	return task;
@@ -857,7 +857,7 @@ #ifdef RPC_DEBUG
 #endif
 	if (!atomic_dec_and_test(&task->tk_count))
 		return;
-	dprintk("RPC: %4d release task\n", task->tk_pid);
+	dprintk("RPC: %5u release task\n", task->tk_pid);
 
 	/* Remove from global task list */
 	spin_lock(&rpc_sched_lock);
@@ -921,7 +921,7 @@ void rpc_killall_tasks(struct rpc_clnt *
 	struct rpc_task	*rovr;
 	struct list_head *le;
 
-	dprintk("RPC:      killing all tasks for client %p\n", clnt);
+	dprintk("RPC:       killing all tasks for client %p\n", clnt);
 
 	/*
 	 * Spin lock all_tasks to prevent changes...
@@ -950,7 +950,7 @@ static void rpciod_killall(void)
 		rpc_killall_tasks(NULL);
 		flush_workqueue(rpciod_workqueue);
 		if (!list_empty(&all_tasks)) {
-			dprintk("rpciod_killall: waiting for tasks to exit\n");
+			dprintk("RPC:       rpciod_killall: waiting for tasks to exit\n");
 			yield();
 		}
 	}
@@ -970,7 +970,7 @@ rpciod_up(void)
 	int error = 0;
 
 	mutex_lock(&rpciod_mutex);
-	dprintk("rpciod_up: users %d\n", rpciod_users);
+	dprintk("RPC:       rpciod_up: users %u\n", rpciod_users);
 	rpciod_users++;
 	if (rpciod_workqueue)
 		goto out;
@@ -978,7 +978,7 @@ rpciod_up(void)
 	 * If there's no pid, we should be the first user.
 	 */
 	if (rpciod_users > 1)
-		printk(KERN_WARNING "rpciod_up: no workqueue, %d users??\n", rpciod_users);
+		printk(KERN_WARNING "rpciod_up: no workqueue, %u users??\n", rpciod_users);
 	/*
 	 * Create the rpciod thread and wait for it to start.
 	 */
@@ -1000,7 +1000,7 @@ void
 rpciod_down(void)
 {
 	mutex_lock(&rpciod_mutex);
-	dprintk("rpciod_down sema %d\n", rpciod_users);
+	dprintk("RPC:       rpciod_down sema %u\n", rpciod_users);
 	if (rpciod_users) {
 		if (--rpciod_users)
 			goto out;
@@ -1038,7 +1038,7 @@ void rpc_show_tasks(void)
 		if (RPC_IS_QUEUED(t))
 			rpc_waitq = rpc_qname(t->u.tk_wait.rpc_waitq);
 
-		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
+		printk("%05u %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
 			t->tk_pid,
 			(t->tk_msg.rpc_proc ? t->tk_msg.rpc_proc->p_proc : -1),
 			t->tk_flags, t->tk_status,
diff --git a/net/sunrpc/stats.c b/net/sunrpc/stats.c
index bd98124..d19cd9e 100644
--- a/net/sunrpc/stats.c
+++ b/net/sunrpc/stats.c
@@ -226,7 +226,7 @@ do_register(const char *name, void *data
 	struct proc_dir_entry *ent;
 
 	rpc_proc_init();
-	dprintk("RPC: registering /proc/net/rpc/%s\n", name);
+	dprintk("RPC:       registering /proc/net/rpc/%s\n", name);
 
 	ent = create_proc_entry(name, 0, proc_net_rpc);
 	if (ent) {
@@ -263,7 +263,7 @@ svc_proc_unregister(const char *name)
 void
 rpc_proc_init(void)
 {
-	dprintk("RPC: registering /proc/net/rpc\n");
+	dprintk("RPC:       registering /proc/net/rpc\n");
 	if (!proc_net_rpc) {
 		struct proc_dir_entry *ent;
 		ent = proc_mkdir("rpc", proc_net);
@@ -277,7 +277,7 @@ rpc_proc_init(void)
 void
 rpc_proc_exit(void)
 {
-	dprintk("RPC: unregistering /proc/net/rpc\n");
+	dprintk("RPC:       unregistering /proc/net/rpc\n");
 	if (proc_net_rpc) {
 		proc_net_rpc = NULL;
 		remove_proc_entry("net/rpc", NULL);
diff --git a/net/sunrpc/xprt.c b/net/sunrpc/xprt.c
index f8ca0a9..4846d25 100644
--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -108,7 +108,7 @@ int xprt_reserve_xprt(struct rpc_task *t
 	return 1;
 
 out_sleep:
-	dprintk("RPC: %4d failed to lock transport %p\n",
+	dprintk("RPC: %5u failed to lock transport %p\n",
 			task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
@@ -158,7 +158,7 @@ int xprt_reserve_xprt_cong(struct rpc_ta
 	}
 	xprt_clear_locked(xprt);
 out_sleep:
-	dprintk("RPC: %4d failed to lock transport %p\n", task->tk_pid, xprt);
+	dprintk("RPC: %5u failed to lock transport %p\n", task->tk_pid, xprt);
 	task->tk_timeout = 0;
 	task->tk_status = -EAGAIN;
 	if (req && req->rq_ntrans)
@@ -281,7 +281,7 @@ __xprt_get_cong(struct rpc_xprt *xprt, s
 
 	if (req->rq_cong)
 		return 1;
-	dprintk("RPC: %4d xprt_cwnd_limited cong = %ld cwnd = %ld\n",
+	dprintk("RPC: %5u xprt_cwnd_limited cong = %lu cwnd = %lu\n",
 			task->tk_pid, xprt->cong, xprt->cwnd);
 	if (RPCXPRT_CONGESTED(xprt))
 		return 0;
@@ -340,7 +340,7 @@ void xprt_adjust_cwnd(struct rpc_task *t
 		if (cwnd < RPC_CWNDSCALE)
 			cwnd = RPC_CWNDSCALE;
 	}
-	dprintk("RPC:      cong %ld, cwnd was %ld, now %ld\n",
+	dprintk("RPC:       cong %ld, cwnd was %ld, now %ld\n",
 			xprt->cong, xprt->cwnd, cwnd);
 	xprt->cwnd = cwnd;
 	__xprt_put_cong(xprt, req);
@@ -387,7 +387,7 @@ void xprt_write_space(struct rpc_xprt *x
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (xprt->snd_task) {
-		dprintk("RPC:      write space: waking waiting task on xprt %p\n",
+		dprintk("RPC:       write space: waking waiting task on xprt %p\n",
 				xprt);
 		rpc_wake_up_task(xprt->snd_task);
 	}
@@ -493,7 +493,7 @@ static void xprt_autoclose(void *args)
  */
 void xprt_disconnect(struct rpc_xprt *xprt)
 {
-	dprintk("RPC:      disconnected transport %p\n", xprt);
+	dprintk("RPC:       disconnected transport %p\n", xprt);
 	spin_lock_bh(&xprt->transport_lock);
 	xprt_clear_connected(xprt);
 	xprt_wake_pending_tasks(xprt, -ENOTCONN);
@@ -529,7 +529,7 @@ void xprt_connect(struct rpc_task *task)
 {
 	struct rpc_xprt	*xprt = task->tk_xprt;
 
-	dprintk("RPC: %4d xprt_connect xprt %p %s connected\n", task->tk_pid,
+	dprintk("RPC: %5u xprt_connect xprt %p %s connected\n", task->tk_pid,
 			xprt, (xprt_connected(xprt) ? "is" : "is not"));
 
 	if (!xprt_bound(xprt)) {
@@ -559,7 +559,7 @@ static void xprt_connect_status(struct r
 	if (task->tk_status >= 0) {
 		xprt->stat.connect_count++;
 		xprt->stat.connect_time += (long)jiffies - xprt->stat.connect_start;
-		dprintk("RPC: %4d xprt_connect_status: connection established\n",
+		dprintk("RPC: %5u xprt_connect_status: connection established\n",
 				task->tk_pid);
 		return;
 	}
@@ -567,19 +567,19 @@ static void xprt_connect_status(struct r
 	switch (task->tk_status) {
 	case -ECONNREFUSED:
 	case -ECONNRESET:
-		dprintk("RPC: %4d xprt_connect_status: server %s refused connection\n",
+		dprintk("RPC: %5u xprt_connect_status: server %s refused connection\n",
 				task->tk_pid, task->tk_client->cl_server);
 		break;
 	case -ENOTCONN:
-		dprintk("RPC: %4d xprt_connect_status: connection broken\n",
+		dprintk("RPC: %5u xprt_connect_status: connection broken\n",
 				task->tk_pid);
 		break;
 	case -ETIMEDOUT:
-		dprintk("RPC: %4d xprt_connect_status: connect attempt timed out\n",
+		dprintk("RPC: %5u xprt_connect_status: connect attempt timed out\n",
 				task->tk_pid);
 		break;
 	default:
-		dprintk("RPC: %4d xprt_connect_status: error %d connecting to server %s\n",
+		dprintk("RPC: %5u xprt_connect_status: error %d connecting to server %s\n",
 				task->tk_pid, -task->tk_status, task->tk_client->cl_server);
 		xprt_release_write(xprt, task);
 		task->tk_status = -EIO;
@@ -601,6 +601,9 @@ struct rpc_rqst *xprt_lookup_rqst(struct
 		if (entry->rq_xid == xid)
 			return entry;
 	}
+
+	dprintk("RPC:       xprt_lookup_rqst did not find xid %08x\n",
+			ntohl(xid));
 	xprt->stat.bad_xids++;
 	return NULL;
 }
@@ -653,7 +656,7 @@ static void xprt_timer(struct rpc_task *
 	struct rpc_rqst *req = task->tk_rqstp;
 	struct rpc_xprt *xprt = req->rq_xprt;
 
-	dprintk("RPC: %4d xprt_timer\n", task->tk_pid);
+	dprintk("RPC: %5u xprt_timer\n", task->tk_pid);
 
 	spin_lock(&xprt->transport_lock);
 	if (!req->rq_received) {
@@ -677,7 +680,7 @@ int xprt_prepare_transmit(struct rpc_tas
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	int err = 0;
 
-	dprintk("RPC: %4d xprt_prepare_transmit\n", task->tk_pid);
+	dprintk("RPC: %5u xprt_prepare_transmit\n", task->tk_pid);
 
 	spin_lock_bh(&xprt->transport_lock);
 	if (req->rq_received && !req->rq_bytes_sent) {
@@ -715,7 +718,7 @@ void xprt_transmit(struct rpc_task *task
 	struct rpc_xprt	*xprt = req->rq_xprt;
 	int status;
 
-	dprintk("RPC: %4d xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
+	dprintk("RPC: %5u xprt_transmit(%u)\n", task->tk_pid, req->rq_slen);
 
 	if (!req->rq_received) {
 		if (list_empty(&req->rq_list)) {
@@ -735,7 +738,7 @@ void xprt_transmit(struct rpc_task *task
 
 	status = xprt->ops->send_request(task);
 	if (status == 0) {
-		dprintk("RPC: %4d xmit complete\n", task->tk_pid);
+		dprintk("RPC: %5u xmit complete\n", task->tk_pid);
 		spin_lock_bh(&xprt->transport_lock);
 
 		xprt->ops->set_retrans_timeout(task);
@@ -776,7 +779,7 @@ static inline void do_xprt_reserve(struc
 		xprt_request_init(task, xprt);
 		return;
 	}
-	dprintk("RPC:      waiting for request slot\n");
+	dprintk("RPC:       waiting for request slot\n");
 	task->tk_status = -EAGAIN;
 	task->tk_timeout = 0;
 	rpc_sleep_on(&xprt->backlog, task, NULL, NULL);
@@ -821,7 +824,7 @@ static void xprt_request_init(struct rpc
 	req->rq_xid     = xprt_alloc_xid(xprt);
 	req->rq_release_snd_buf = NULL;
 	xprt_reset_majortimeo(req);
-	dprintk("RPC: %4d reserved req %p xid %08x\n", task->tk_pid,
+	dprintk("RPC: %5u reserved req %p xid %08x\n", task->tk_pid,
 			req, ntohl(req->rq_xid));
 }
 
@@ -855,7 +858,7 @@ void xprt_release(struct rpc_task *task)
 		req->rq_release_snd_buf(req);
 	memset(req, 0, sizeof(*req));	/* mark unused */
 
-	dprintk("RPC: %4d release request %p\n", task->tk_pid, req);
+	dprintk("RPC: %5u release request %p\n", task->tk_pid, req);
 
 	spin_lock(&xprt->reserve_lock);
 	list_add(&req->rq_list, &xprt->free);
@@ -905,7 +908,7 @@ struct rpc_xprt *xprt_create_transport(i
 		return ERR_PTR(-EIO);
 	}
 	if (IS_ERR(xprt)) {
-		dprintk("RPC:      xprt_create_transport: failed, %ld\n",
+		dprintk("RPC:       xprt_create_transport: failed, %ld\n",
 				-PTR_ERR(xprt));
 		return xprt;
 	}
@@ -935,7 +938,7 @@ struct rpc_xprt *xprt_create_transport(i
 
 	xprt_init_xid(xprt);
 
-	dprintk("RPC:      created transport %p with %u slots\n", xprt,
+	dprintk("RPC:       created transport %p with %u slots\n", xprt,
 			xprt->max_reqs);
 
 	return xprt;
@@ -950,7 +953,7 @@ static void xprt_destroy(struct kref *kr
 {
 	struct rpc_xprt *xprt = container_of(kref, struct rpc_xprt, kref);
 
-	dprintk("RPC:      destroying transport %p\n", xprt);
+	dprintk("RPC:       destroying transport %p\n", xprt);
 	xprt->shutdown = 1;
 	del_timer_sync(&xprt->timer);
 
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9e6202a..6d9750e 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -192,7 +192,7 @@ static void xs_pktdump(char *msg, u32 *p
 	u8 *buf = (u8 *) packet;
 	int j;
 
-	dprintk("RPC:      %s\n", msg);
+	dprintk("RPC:       %s\n", msg);
 	for (j = 0; j < count && j < 128; j += 4) {
 		if (!(j & 31)) {
 			if (j)
@@ -435,7 +435,7 @@ static void xs_nospace(struct rpc_task *
 	struct rpc_xprt *xprt = req->rq_xprt;
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
-	dprintk("RPC: %4d xmit incomplete (%u left of %u)\n",
+	dprintk("RPC: %5u xmit incomplete (%u left of %u)\n",
 			task->tk_pid, req->rq_slen - req->rq_bytes_sent,
 			req->rq_slen);
 
@@ -482,7 +482,7 @@ static int xs_udp_send_request(struct rp
 	status = xs_sendpages(transport, (struct sockaddr *) &xprt->addr,
 				xprt->addrlen, xdr, req->rq_bytes_sent);
 
-	dprintk("RPC:      xs_udp_send_request(%u) = %d\n",
+	dprintk("RPC:       xs_udp_send_request(%u) = %d\n",
 			xdr->len - req->rq_bytes_sent, status);
 
 	if (likely(status >= (int) req->rq_slen))
@@ -503,7 +503,7 @@ static int xs_udp_send_request(struct rp
 		xs_nospace(task);
 		break;
 	default:
-		dprintk("RPC:      sendmsg returned unrecognized error %d\n",
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 		break;
 	}
@@ -553,7 +553,7 @@ static int xs_tcp_send_request(struct rp
 		req->rq_xtime = jiffies;
 		status = xs_sendpages(transport, NULL, 0, xdr, req->rq_bytes_sent);
 
-		dprintk("RPC:      xs_tcp_send_request(%u) = %d\n",
+		dprintk("RPC:       xs_tcp_send_request(%u) = %d\n",
 				xdr->len - req->rq_bytes_sent, status);
 
 		if (unlikely(status < 0))
@@ -584,7 +584,7 @@ static int xs_tcp_send_request(struct rp
 		status = -ENOTCONN;
 		break;
 	default:
-		dprintk("RPC:      sendmsg returned unrecognized error %d\n",
+		dprintk("RPC:       sendmsg returned unrecognized error %d\n",
 			-status);
 		xprt_disconnect(xprt);
 		break;
@@ -636,7 +636,7 @@ static void xs_close(struct rpc_xprt *xp
 	if (!sk)
 		goto clear_close_wait;
 
-	dprintk("RPC:      xs_close xprt %p\n", xprt);
+	dprintk("RPC:       xs_close xprt %p\n", xprt);
 
 	write_lock_bh(&sk->sk_callback_lock);
 	transport->inet = NULL;
@@ -666,7 +666,7 @@ static void xs_destroy(struct rpc_xprt *
 {
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 
-	dprintk("RPC:      xs_destroy xprt %p\n", xprt);
+	dprintk("RPC:       xs_destroy xprt %p\n", xprt);
 
 	cancel_delayed_work(&transport->connect_worker);
 	flush_scheduled_work();
@@ -700,7 +700,7 @@ static void xs_udp_data_ready(struct soc
 	__be32 *xp;
 
 	read_lock(&sk->sk_callback_lock);
-	dprintk("RPC:      xs_udp_data_ready...\n");
+	dprintk("RPC:       xs_udp_data_ready...\n");
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 
@@ -712,7 +712,7 @@ static void xs_udp_data_ready(struct soc
 
 	repsize = skb->len - sizeof(struct udphdr);
 	if (repsize < 4) {
-		dprintk("RPC:      impossible RPC reply size %d!\n", repsize);
+		dprintk("RPC:       impossible RPC reply size %d!\n", repsize);
 		goto dropit;
 	}
 
@@ -776,11 +776,11 @@ static inline void xs_tcp_read_fraghdr(s
 
 	/* Sanity check of the record length */
 	if (unlikely(transport->tcp_reclen < 4)) {
-		dprintk("RPC:      invalid TCP record fragment length\n");
+		dprintk("RPC:       invalid TCP record fragment length\n");
 		xprt_disconnect(xprt);
 		return;
 	}
-	dprintk("RPC:      reading TCP record fragment of length %d\n",
+	dprintk("RPC:       reading TCP record fragment of length %d\n",
 			transport->tcp_reclen);
 }
 
@@ -803,7 +803,7 @@ static inline void xs_tcp_read_xid(struc
 	char *p;
 
 	len = sizeof(transport->tcp_xid) - transport->tcp_offset;
-	dprintk("RPC:      reading XID (%Zu bytes)\n", len);
+	dprintk("RPC:       reading XID (%Zu bytes)\n", len);
 	p = ((char *) &transport->tcp_xid) + transport->tcp_offset;
 	used = xdr_skb_read_bits(desc, p, len);
 	transport->tcp_offset += used;
@@ -812,7 +812,7 @@ static inline void xs_tcp_read_xid(struc
 	transport->tcp_flags &= ~TCP_RCV_COPY_XID;
 	transport->tcp_flags |= TCP_RCV_COPY_DATA;
 	transport->tcp_copied = 4;
-	dprintk("RPC:      reading reply for XID %08x\n",
+	dprintk("RPC:       reading reply for XID %08x\n",
 			ntohl(transport->tcp_xid));
 	xs_tcp_check_fraghdr(transport);
 }
@@ -830,7 +830,7 @@ static inline void xs_tcp_read_request(s
 	req = xprt_lookup_rqst(xprt, transport->tcp_xid);
 	if (!req) {
 		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-		dprintk("RPC:      XID %08x request not found!\n",
+		dprintk("RPC:       XID %08x request not found!\n",
 				ntohl(transport->tcp_xid));
 		spin_unlock(&xprt->transport_lock);
 		return;
@@ -867,17 +867,17 @@ static inline void xs_tcp_read_request(s
 		 * be discarded.
 		 */
 		transport->tcp_flags &= ~TCP_RCV_COPY_DATA;
-		dprintk("RPC:      XID %08x truncated request\n",
+		dprintk("RPC:       XID %08x truncated request\n",
 				ntohl(transport->tcp_xid));
-		dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
+		dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
 				xprt, transport->tcp_copied, transport->tcp_offset,
 					transport->tcp_reclen);
 		goto out;
 	}
 
-	dprintk("RPC:      XID %08x read %Zd bytes\n",
+	dprintk("RPC:       XID %08x read %Zd bytes\n",
 			ntohl(transport->tcp_xid), r);
-	dprintk("RPC:      xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
+	dprintk("RPC:       xprt = %p, tcp_copied = %lu, tcp_offset = %u, tcp_reclen = %u\n",
 			xprt, transport->tcp_copied, transport->tcp_offset,
 				transport->tcp_reclen);
 
@@ -905,7 +905,7 @@ static inline void xs_tcp_read_discard(s
 	desc->count -= len;
 	desc->offset += len;
 	transport->tcp_offset += len;
-	dprintk("RPC:      discarded %Zu bytes\n", len);
+	dprintk("RPC:       discarded %Zu bytes\n", len);
 	xs_tcp_check_fraghdr(transport);
 }
 
@@ -919,7 +919,7 @@ static int xs_tcp_data_recv(read_descrip
 		.count	= len,
 	};
 
-	dprintk("RPC:      xs_tcp_data_recv started\n");
+	dprintk("RPC:       xs_tcp_data_recv started\n");
 	do {
 		/* Read in a new fragment marker if necessary */
 		/* Can we ever really expect to get completely empty fragments? */
@@ -940,7 +940,7 @@ static int xs_tcp_data_recv(read_descrip
 		/* Skip over any trailing bytes on short reads */
 		xs_tcp_read_discard(transport, &desc);
 	} while (desc.count);
-	dprintk("RPC:      xs_tcp_data_recv done\n");
+	dprintk("RPC:       xs_tcp_data_recv done\n");
 	return len - desc.count;
 }
 
@@ -955,8 +955,9 @@ static void xs_tcp_data_ready(struct soc
 	struct rpc_xprt *xprt;
 	read_descriptor_t rd_desc;
 
+	dprintk("RPC:       xs_tcp_data_ready...\n");
+
 	read_lock(&sk->sk_callback_lock);
-	dprintk("RPC:      xs_tcp_data_ready...\n");
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
 	if (xprt->shutdown)
@@ -982,8 +983,8 @@ static void xs_tcp_state_change(struct s
 	read_lock(&sk->sk_callback_lock);
 	if (!(xprt = xprt_from_sock(sk)))
 		goto out;
-	dprintk("RPC:      xs_tcp_state_change client %p...\n", xprt);
-	dprintk("RPC:      state %x conn %d dead %d zapped %d\n",
+	dprintk("RPC:       xs_tcp_state_change client %p...\n", xprt);
+	dprintk("RPC:       state %x conn %d dead %d zapped %d\n",
 				sk->sk_state, xprt_connected(xprt),
 				sock_flag(sk, SOCK_DEAD),
 				sock_flag(sk, SOCK_ZAPPED));
@@ -1154,7 +1155,7 @@ static void xs_set_port(struct rpc_xprt 
 {
 	struct sockaddr_in *sap = (struct sockaddr_in *) &xprt->addr;
 
-	dprintk("RPC:      setting port for xprt %p to %u\n", xprt, port);
+	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
 
 	sap->sin_port = htons(port);
 }
@@ -1173,7 +1174,7 @@ static int xs_bindresvport(struct sock_x
 						sizeof(myaddr));
 		if (err == 0) {
 			transport->port = port;
-			dprintk("RPC:      xs_bindresvport bound to port %u\n",
+			dprintk("RPC:       xs_bindresvport bound to port %u\n",
 					port);
 			return 0;
 		}
@@ -1183,7 +1184,7 @@ static int xs_bindresvport(struct sock_x
 			port--;
 	} while (err == -EADDRINUSE && port != transport->port);
 
-	dprintk("RPC:      can't bind to reserved port (%d).\n", -err);
+	dprintk("RPC:       can't bind to reserved port (%d).\n", -err);
 	return err;
 }
 
@@ -1207,7 +1208,7 @@ static void xs_udp_connect_worker(void *
 	xs_close(xprt);
 
 	if ((err = sock_create_kern(PF_INET, SOCK_DGRAM, IPPROTO_UDP, &sock)) < 0) {
-		dprintk("RPC:      can't create UDP transport socket (%d).\n", -err);
+		dprintk("RPC:       can't create UDP transport socket (%d).\n", -err);
 		goto out;
 	}
 
@@ -1216,7 +1217,7 @@ static void xs_udp_connect_worker(void *
 		goto out;
 	}
 
-	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	if (!transport->inet) {
@@ -1262,7 +1263,7 @@ static void xs_tcp_reuse_connection(stru
 	struct sock_xprt *transport = container_of(xprt, struct sock_xprt, xprt);
 	struct sockaddr any;
 
-	dprintk("RPC:      disconnecting xprt %p to reuse port\n", xprt);
+	dprintk("RPC:       disconnecting xprt %p to reuse port\n", xprt);
 
 	/*
 	 * Disconnect the transport socket by doing a connect operation
@@ -1272,7 +1273,7 @@ static void xs_tcp_reuse_connection(stru
 	any.sa_family = AF_UNSPEC;
 	result = kernel_connect(transport->sock, &any, sizeof(any), 0);
 	if (result)
-		dprintk("RPC:      AF_UNSPEC connect return code %d\n",
+		dprintk("RPC:       AF_UNSPEC connect return code %d\n",
 				result);
 }
 
@@ -1295,7 +1296,7 @@ static void xs_tcp_connect_worker(void *
 	if (!sock) {
 		/* start from scratch */
 		if ((err = sock_create_kern(PF_INET, SOCK_STREAM, IPPROTO_TCP, &sock)) < 0) {
-			dprintk("RPC:      can't create TCP transport socket (%d).\n", -err);
+			dprintk("RPC:       can't create TCP transport socket (%d).\n", -err);
 			goto out;
 		}
 
@@ -1307,7 +1308,7 @@ static void xs_tcp_connect_worker(void *
 		/* "close" the socket, preserving the local port */
 		xs_tcp_reuse_connection(xprt);
 
-	dprintk("RPC:      worker connecting xprt %p to address: %s\n",
+	dprintk("RPC:       worker connecting xprt %p to address: %s\n",
 			xprt, xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	if (!transport->inet) {
@@ -1348,7 +1349,7 @@ static void xs_tcp_connect_worker(void *
 	xprt->stat.connect_start = jiffies;
 	status = kernel_connect(sock, (struct sockaddr *) &xprt->addr,
 			xprt->addrlen, O_NONBLOCK);
-	dprintk("RPC: %p  connect status %d connected %d sock state %d\n",
+	dprintk("RPC:       %p connect status %d connected %d sock state %d\n",
 			xprt, -status, xprt_connected(xprt), sock->sk->sk_state);
 	if (status < 0) {
 		switch (status) {
@@ -1393,7 +1394,7 @@ static void xs_connect(struct rpc_task *
 		return;
 
 	if (transport->sock != NULL) {
-		dprintk("RPC:      xs_connect delayed xprt %p for %lu seconds\n",
+		dprintk("RPC:       xs_connect delayed xprt %p for %lu seconds\n",
 				xprt, xprt->reestablish_timeout / HZ);
 		schedule_delayed_work(&transport->connect_worker,
 					xprt->reestablish_timeout);
@@ -1401,7 +1402,7 @@ static void xs_connect(struct rpc_task *
 		if (xprt->reestablish_timeout > XS_TCP_MAX_REEST_TO)
 			xprt->reestablish_timeout = XS_TCP_MAX_REEST_TO;
 	} else {
-		dprintk("RPC:      xs_connect scheduled xprt %p\n", xprt);
+		dprintk("RPC:       xs_connect scheduled xprt %p\n", xprt);
 		schedule_work(&transport->connect_worker);
 
 		/* flush_scheduled_work can sleep... */
@@ -1496,13 +1497,13 @@ static struct rpc_xprt *xs_setup_xprt(st
 	struct sock_xprt *new;
 
 	if (addrlen > sizeof(xprt->addr)) {
-		dprintk("RPC:      xs_setup_xprt: address too large\n");
+		dprintk("RPC:       xs_setup_xprt: address too large\n");
 		return ERR_PTR(-EBADF);
 	}
 
 	new = kzalloc(sizeof(*new), GFP_KERNEL);
 	if (new == NULL) {
-		dprintk("RPC:      xs_setup_xprt: couldn't allocate rpc_xprt\n");
+		dprintk("RPC:       xs_setup_xprt: couldn't allocate rpc_xprt\n");
 		return ERR_PTR(-ENOMEM);
 	}
 	xprt = &new->xprt;
@@ -1511,7 +1512,7 @@ static struct rpc_xprt *xs_setup_xprt(st
 	xprt->slot = kcalloc(xprt->max_reqs, sizeof(struct rpc_rqst), GFP_KERNEL);
 	if (xprt->slot == NULL) {
 		kfree(xprt);
-		dprintk("RPC:      xs_setup_xprt: couldn't allocate slot table\n");
+		dprintk("RPC:       xs_setup_xprt: couldn't allocate slot table\n");
 		return ERR_PTR(-ENOMEM);
 	}
 
@@ -1561,7 +1562,7 @@ struct rpc_xprt *xs_setup_udp(struct soc
 		xprt_set_timeout(&xprt->timeout, 5, 5 * HZ);
 
 	xs_format_peer_addresses(xprt);
-	dprintk("RPC:      set up transport to address %s\n",
+	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	return xprt;
@@ -1605,7 +1606,7 @@ struct rpc_xprt *xs_setup_tcp(struct soc
 		xprt_set_timeout(&xprt->timeout, 2, 60 * HZ);
 
 	xs_format_peer_addresses(xprt);
-	dprintk("RPC:      set up transport to address %s\n",
+	dprintk("RPC:       set up transport to address %s\n",
 			xprt->address_strings[RPC_DISPLAY_ALL]);
 
 	return xprt;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
