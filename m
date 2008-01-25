From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 096/112] NLM/NFS: Use cached nlm_host when calling
	nlmclnt_proc()
Date: Fri, 25 Jan 2008 11:37:58 -0500
Message-ID: <20080125163758.31887.20428.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14368 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755135AbYAYRAO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:14 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09UA010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:10 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

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
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntproc.c        |   33 ++++++++++-----------------------
 fs/nfs/nfs3proc.c          |    4 +++-
 fs/nfs/proc.c              |    4 +++-
 include/linux/lockd/bind.h |    3 ++-
 4 files changed, 18 insertions(+), 26 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index a10343b..b1a4dba 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -145,34 +145,21 @@ static void nlmclnt_release_lockargs(struct nlm_rqst *req)
 	BUG_ON(req->a_args.lock.fl.fl_ops != NULL);
 }
 
-/*
- * This is the main entry point for the NLM client.
+/**
+ * nlmclnt_proc - Perform a single client-side lock request
+ * @host: address of a valid nlm_host context representing the NLM server
+ * @cmd: fcntl-style file lock operation to perform
+ * @fl: address of arguments for the lock operation
+ *
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
-
-	rpc_peeraddr(client, (struct sockaddr *) &addr, sizeof(addr));
-	host = nlmclnt_lookup_host(&addr, client->cl_xprt->prot, vers,
-				   nfssrv->nfs_client->cl_hostname,
-				   strlen(nfssrv->nfs_client->cl_hostname));
-	if (host == NULL)
-		return -ENOLCK;
+	int			status;
 
+	nlm_get_host(host);
 	call = nlm_alloc_call(host);
 	if (call == NULL)
 		return -ENOMEM;
@@ -219,7 +206,7 @@ nlmclnt_proc(struct inode *inode, int cmd, struct file_lock *fl)
 	dprintk("lockd: clnt proc returns %d\n", status);
 	return status;
 }
-EXPORT_SYMBOL(nlmclnt_proc);
+EXPORT_SYMBOL_GPL(nlmclnt_proc);
 
 /*
  * Allocate an NLM RPC call struct
diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
index e68580e..b353c1a 100644
--- a/fs/nfs/nfs3proc.c
+++ b/fs/nfs/nfs3proc.c
@@ -767,7 +767,9 @@ static void nfs3_proc_commit_setup(struct nfs_write_data *data, struct rpc_messa
 static int
 nfs3_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	return nlmclnt_proc(filp->f_path.dentry->d_inode, cmd, fl);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
 const struct nfs_rpc_ops nfs_v3_clientops = {
diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index c9f46a2..5ccf7fa 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -593,7 +593,9 @@ nfs_proc_commit_setup(struct nfs_write_data *data, struct rpc_message *msg)
 static int
 nfs_proc_lock(struct file *filp, int cmd, struct file_lock *fl)
 {
-	return nlmclnt_proc(filp->f_path.dentry->d_inode, cmd, fl);
+	struct inode *inode = filp->f_path.dentry->d_inode;
+
+	return nlmclnt_proc(NFS_SERVER(inode)->nlm_host, cmd, fl);
 }
 
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index ad5402f..7336807 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -42,7 +42,8 @@ extern struct nlm_host *nlmclnt_init(const char *server_name,
 					u32 nfs_version);
 extern void	nlmclnt_done(struct nlm_host *host);
 
-extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
+extern int	nlmclnt_proc(struct nlm_host *host, int cmd,
+					struct file_lock *fl);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
 
