From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFS: Use cached nlm_host when calling nlmclnt_proc()
Date: Tue, 08 Jan 2008 10:32:22 -0500
Message-ID: <20080108153221.20097.13404.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:23062 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753767AbYAHPcc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 10:32:32 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that each NFS mount point caches its own nlm_host structure, it can be
passed to nlmclnt_proc() for each lock request.  By pinning an nlm_host for
each mount point, we trade the overhead of looking up or creating a fresh
nlm_host struct during every NLM procedure call for a little extra memory.

We also restrict the nlmclnt_proc symbol to limit the use of this call to
in-tree modules.

Note that nlm_lookup_host() (just removed from the client's per-request
NLM processing) could also trigger an nlm_host garbage collection.  Now
client-side nlm_host garbage collection occurs only during NFS mount
processing.  Since the NFS client now holds a reference on these nlm_host
structures, they wouldn't have been affected by garbage collection
anyway.

Given that nlm_lookup_host() reorders the global nlm_host chain after
every successful lookup, and that a garbage collection could be triggered
during the call, we've removed a significant amount of per-NLM-request
CPU processing overhead.

Sidebar: there are only a few remaining references to the internals of
NFS inodes in the client-side NLM code.  The only references I found are
related to extracting or comparing the inode's file handle via NFS_FH().
One is in nlmclnt_grant(); the other is in nlmclnt_setlockargs().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntproc.c        |   22 ++++------------------
 fs/nfs/nfs3proc.c          |    5 ++++-
 fs/nfs/proc.c              |    5 ++++-
 include/linux/lockd/bind.h |    3 ++-
 4 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index a10343b..40d498b 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -148,30 +148,16 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
 /*
  * This is the main entry point for the NLM client.
  */
-int
-nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
+int nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl)
 {
-	struct rpc_clnt		*client = NFS_CLIENT(inode);
-	struct sockaddr_in	addr;
-	struct nfs_server	*nfssrv = NFS_SERVER(inode);
-	struct nlm_host		*host;
 	struct nlm_rqst		*call;
 	sigset_t		oldset;
 	unsigned long		flags;
-	int			status, vers;
-
-	vers = (NFS_PROTO(inode)->version == 3) ? 4 : 1;
-	if (NFS_PROTO(inode)->version > 3) {
-		printk(KERN_NOTICE "NFSv4 file locking not implemented!\n");
-		return -ENOLCK;
-	}
+	int			status;
 
-	rpc_peeraddr(client, (struct sockaddr *) &addr, sizeof(addr));
-	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers,
-				   nfssrv->nfs_client->cl_hostname,
-				   strlen(nfssrv->nfs_client->cl_hostname));
 	if (host == NULL)
 		return -ENOLCK;
+	nlm_get_host(host);
 
 	call = nlm_alloc_call(host);
 	if (call == NULL)
@@ -219,7 +205,7 @@ nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 	dprintk("lockd: clnt proc returns %d\n", status);
 	return status;
 }
-EXPORT_SYMBOL(nlmclnt_proc);
+EXPORT_SYMBOL_GPL(nlmclnt_proc);
 
 /*
  * Allocate an NLM RPC call struct
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index 4cdc236..f07b8d7 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -796,7 +796,10 @@ static void nfs3_proc_commit_setup(struct nfs_write_data *data, int how)
 static int
 nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	return nlmclnt_proc(filp->f_path.dentry->d_inode, cmd, fl);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
+
+	return nlmclnt_proc(host, cmd, fl);
 }
 
 const struct nfs_rpc_ops nfs_v3_clientops = {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 4f80d88..50cac6a 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -609,7 +609,10 @@ nfs_proc_commit_setup(struct nfs_write_data *data, int how)
 static int
 nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	return nlmclnt_proc(filp->f_path.dentry->d_inode, cmd, fl);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+	struct nlm_host *host = NFS_SERVER(inode)->nlm_host;
+
+	return nlmclnt_proc(host, cmd, fl);
 }
 
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 372c8df..59d51f1 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -42,7 +42,8 @@ extern struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
 					unsigned short protocol);
 extern void	nlmclnt_done(struct nlm_host *host);
 
-extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
+extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
+					struct file_lock *fl);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 

