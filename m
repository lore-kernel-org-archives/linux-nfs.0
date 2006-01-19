From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Lock recursion in rpc_pipefs+auth_gss...
Date: Thu, 19 Jan 2006 08:17:12 -0500
Message-ID: <1137676632.7857.14.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-bB3irmY3xbsS/6iLWM0+"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
To: Vincent Roqueta <vincent.roqueta@ext.bull.net>,
	Vince Busam <vbusam@google.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>


--=-bB3irmY3xbsS/6iLWM0+
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

I believe I've finally figured out what is causing the Oopses that Vince
and Vincent were seeing. It all boils down to a mutex being held after
the inode is released due to a deadlock situation.

The issue is that when doing a downcall in order to stuff an RPCSEC_GSS
credential into the credcache, gss_pipe_downcall ends up calling
rpcauth_lookup_credcache(). This again may result in the creation of a
new credential if rpcauth_lookup_credcache() doesn't find any existing
entries in the credcache.
The problem is that as that new credential is being created,
gss_create_cred() will immediately do an upcall in order to initialise
the context. Since the rpc_pipefs downcall code is already holding the
inode->i_mutex (a.k.a. inode->i_sem in 2.6.15 and older), we deadlock
when the upcall tries to grab the same mutex.

The appended patch works around the problem by allowing the downcall to
tell gss_create_cred() that it will initialise the new cred, thus
avoiding the deadlock.

Cheers,
  Trond


--=-bB3irmY3xbsS/6iLWM0+
Content-Disposition: inline; filename=linux-2.6.16-03-gss_lock_recursion.dif
Content-Type: text/plain; name=linux-2.6.16-03-gss_lock_recursion.dif;
	charset=UTF-8
Content-Transfer-Encoding: 7bit

Author: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: Fix a lock recursion in the auth_gss downcall

 When we look up a new cred in the auth_gss downcall so that we can stuff
 the credcache, we do not want that lookup to queue up an upcall in order
 to initialise it. To do an upcall here not only redundant, but since we
 are already holding the inode->i_mutex, it will trigger a lock recursion.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 include/linux/sunrpc/auth.h    |    4 ++++
 net/sunrpc/auth.c              |   17 ++++++++++-------
 net/sunrpc/auth_gss/auth_gss.c |   14 ++++++++------
 net/sunrpc/auth_unix.c         |    6 +++---
 4 files changed, 25 insertions(+), 16 deletions(-)

diff --git a/include/linux/sunrpc/auth.h b/include/linux/sunrpc/auth.h
index b68c11a..ee7ff29 100644
--- a/include/linux/sunrpc/auth.h
+++ b/include/linux/sunrpc/auth.h
@@ -87,6 +87,10 @@ struct rpc_auth {
 						 * uid/gid, fs[ug]id, gids)
 						 */
 
+/* Flags for rpcauth_lookupcred() */
+#define RPCAUTH_LOOKUP_DONTBLOCK	0x01
+#define RPCAUTH_LOOKUP_ROOTCREDS	0x02	/* This really ought to go! */
+
 /*
  * Client authentication ops
  */
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 9ac1b8c..1ca89c3 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -184,7 +184,7 @@ rpcauth_gc_credcache(struct rpc_auth *au
  */
 struct rpc_cred *
 rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
-		int taskflags)
+		int flags)
 {
 	struct rpc_cred_cache *cache = auth->au_credcache;
 	HLIST_HEAD(free);
@@ -193,7 +193,7 @@ rpcauth_lookup_credcache(struct rpc_auth
 			*cred = NULL;
 	int		nr = 0;
 
-	if (!(taskflags & RPC_TASK_ROOTCREDS))
+	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS))
 		nr = acred->uid & RPC_CREDCACHE_MASK;
 retry:
 	spin_lock(&rpc_credcache_lock);
@@ -202,7 +202,7 @@ retry:
 	hlist_for_each_safe(pos, next, &cache->hashtable[nr]) {
 		struct rpc_cred *entry;
 	       	entry = hlist_entry(pos, struct rpc_cred, cr_hash);
-		if (entry->cr_ops->crmatch(acred, entry, taskflags)) {
+		if (entry->cr_ops->crmatch(acred, entry, flags)) {
 			hlist_del(&entry->cr_hash);
 			cred = entry;
 			break;
@@ -224,7 +224,7 @@ retry:
 	rpcauth_destroy_credlist(&free);
 
 	if (!cred) {
-		new = auth->au_ops->crcreate(auth, acred, taskflags);
+		new = auth->au_ops->crcreate(auth, acred, flags);
 		if (!IS_ERR(new)) {
 #ifdef RPC_DEBUG
 			new->cr_magic = RPCAUTH_CRED_MAGIC;
@@ -238,7 +238,7 @@ retry:
 }
 
 struct rpc_cred *
-rpcauth_lookupcred(struct rpc_auth *auth, int taskflags)
+rpcauth_lookupcred(struct rpc_auth *auth, int flags)
 {
 	struct auth_cred acred = {
 		.uid = current->fsuid,
@@ -250,7 +250,7 @@ rpcauth_lookupcred(struct rpc_auth *auth
 	dprintk("RPC:     looking up %s cred\n",
 		auth->au_ops->au_name);
 	get_group_info(acred.group_info);
-	ret = auth->au_ops->lookup_cred(auth, &acred, taskflags);
+	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
 	put_group_info(acred.group_info);
 	return ret;
 }
@@ -265,11 +265,14 @@ rpcauth_bindcred(struct rpc_task *task)
 		.group_info = current->group_info,
 	};
 	struct rpc_cred *ret;
+	int flags = 0;
 
 	dprintk("RPC: %4d looking up %s cred\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name);
 	get_group_info(acred.group_info);
-	ret = auth->au_ops->lookup_cred(auth, &acred, task->tk_flags);
+	if (task->tk_flags & RPC_TASK_ROOTCREDS)
+		flags |= RPCAUTH_LOOKUP_ROOTCREDS;
+	ret = auth->au_ops->lookup_cred(auth, &acred, flags);
 	if (!IS_ERR(ret))
 		task->tk_msg.rpc_cred = ret;
 	else
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 8d78228..3f42a4d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -580,7 +580,7 @@ gss_pipe_downcall(struct file *filp, con
 	} else {
 		struct auth_cred acred = { .uid = uid };
 		spin_unlock(&gss_auth->lock);
-		cred = rpcauth_lookup_credcache(clnt->cl_auth, &acred, 0);
+		cred = rpcauth_lookup_credcache(clnt->cl_auth, &acred, RPCAUTH_LOOKUP_DONTBLOCK);
 		if (IS_ERR(cred)) {
 			err = PTR_ERR(cred);
 			goto err_put_ctx;
@@ -758,13 +758,13 @@ gss_destroy_cred(struct rpc_cred *rc)
  * Lookup RPCSEC_GSS cred for the current process
  */
 static struct rpc_cred *
-gss_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int taskflags)
+gss_lookup_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 {
-	return rpcauth_lookup_credcache(auth, acred, taskflags);
+	return rpcauth_lookup_credcache(auth, acred, flags);
 }
 
 static struct rpc_cred *
-gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int taskflags)
+gss_create_cred(struct rpc_auth *auth, struct auth_cred *acred, int flags)
 {
 	struct gss_auth *gss_auth = container_of(auth, struct gss_auth, rpc_auth);
 	struct gss_cred	*cred = NULL;
@@ -786,12 +786,14 @@ gss_create_cred(struct rpc_auth *auth, s
 	cred->gc_flags = 0;
 	cred->gc_base.cr_ops = &gss_credops;
 	cred->gc_service = gss_auth->service;
+	if (flags & RPCAUTH_LOOKUP_DONTBLOCK)
+		goto out;
 	do {
 		err = gss_create_upcall(gss_auth, cred);
 	} while (err == -EAGAIN);
 	if (err < 0)
 		goto out_err;
-
+out:
 	return &cred->gc_base;
 
 out_err:
@@ -801,7 +803,7 @@ out_err:
 }
 
 static int
-gss_match(struct auth_cred *acred, struct rpc_cred *rc, int taskflags)
+gss_match(struct auth_cred *acred, struct rpc_cred *rc, int flags)
 {
 	struct gss_cred *gss_cred = container_of(rc, struct gss_cred, gc_base);
 
diff --git a/net/sunrpc/auth_unix.c b/net/sunrpc/auth_unix.c
index 1b3ed4f..df14b6b 100644
--- a/net/sunrpc/auth_unix.c
+++ b/net/sunrpc/auth_unix.c
@@ -75,7 +75,7 @@ unx_create_cred(struct rpc_auth *auth, s
 
 	atomic_set(&cred->uc_count, 1);
 	cred->uc_flags = RPCAUTH_CRED_UPTODATE;
-	if (flags & RPC_TASK_ROOTCREDS) {
+	if (flags & RPCAUTH_LOOKUP_ROOTCREDS) {
 		cred->uc_uid = 0;
 		cred->uc_gid = 0;
 		cred->uc_gids[0] = NOGROUP;
@@ -108,12 +108,12 @@ unx_destroy_cred(struct rpc_cred *cred)
  * request root creds (e.g. for NFS swapping).
  */
 static int
-unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int taskflags)
+unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int flags)
 {
 	struct unx_cred	*cred = (struct unx_cred *) rcred;
 	int		i;
 
-	if (!(taskflags & RPC_TASK_ROOTCREDS)) {
+	if (!(flags & RPCAUTH_LOOKUP_ROOTCREDS)) {
 		int groups;
 
 		if (cred->uc_uid != acred->uid

--=-bB3irmY3xbsS/6iLWM0+
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--=-bB3irmY3xbsS/6iLWM0+--
