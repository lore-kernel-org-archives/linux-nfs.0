From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 10/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 02:20:43 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.30299.681489.154226@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z4an-0001Ep-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 17:20:50 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

This is a nontrivial change to the NFS client.

In this patch, we finish modifying the async READ path so that it is
version-agnostic.  We define a new nfs_rpc_op ->setup_read(), and move
the v2- and v3-specific code in nfs_read_rpcsetup() there.  We also
have to change nfs_readpage() result so that the 'count' of bytes
read is a parameter.  The extra parameter means that it can no longer
be ->tk_exit().  Instead, it is called from a version-specific ->tk_exit()
routine which is set in ->read_setup().

The upshot of all this is that the version-specific part of the
async READ path has been encapsulated in a new nfs_rpc_op
->read_setup(), and NFSv4 can share the logic for asynchronous
READ's with NFSv2 and v3.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E09/fs/nfs/nfs3proc.c linux-2.5.41-nfsv4-E10/fs/nfs/nfs3proc.c
--- linux-2.5.41-nfsv4-E09/fs/nfs/nfs3proc.c	2002-10-08 19:41:47.000000000 -0400
+++ linux-2.5.41-nfsv4-E10/fs/nfs/nfs3proc.c	2002-10-08 19:44:22.000000000 -0400
@@ -14,6 +14,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs3.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 #include <linux/smp_lock.h>
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -646,6 +647,51 @@
 
 extern u32 *nfs3_decode_dirent(u32 *, struct nfs_entry *, int);
 
+static void
+nfs3_read_done(struct rpc_task *task)
+{
+	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
+
+	if (nfs_async_handle_jukebox(task))
+		return;
+	nfs_readpage_result(task, data->u.v3.res.count, data->u.v3.res.eof);
+}
+
+static void
+nfs3_proc_read_setup(struct nfs_read_data *data, unsigned int count)
+{
+	struct rpc_task		*task = &data->task;
+	struct inode		*inode = data->inode;
+	struct nfs_page		*req;
+	int			flags;
+	struct rpc_message	msg;
+	
+	req = nfs_list_entry(data->pages.next);
+	data->u.v3.args.fh     = NFS_FH(inode);
+	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.pgbase = req->wb_offset;
+	data->u.v3.args.pages  = data->pagevec;
+	data->u.v3.args.count  = count;
+	data->u.v3.res.fattr   = &data->fattr;
+	data->u.v3.res.count   = count;
+	data->u.v3.res.eof     = 0;
+	
+	/* N.B. Do we need to test? Never called for swapfile inode */
+	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
+
+	/* Finalize the task. */
+	rpc_init_task(task, NFS_CLIENT(inode), nfs3_read_done, flags);
+	task->tk_calldata = data;
+	/* Release requests */
+	task->tk_release = nfs_readdata_release;
+
+	msg.rpc_proc = NFS3PROC_READ;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
+	msg.rpc_cred = data->cred;
+	rpc_call_setup(&data->task, &msg, 0);
+}
+
 struct nfs_rpc_ops	nfs_v3_clientops = {
 	.version	= 3,			/* protocol version */
 	.getroot	= nfs3_proc_get_root,
@@ -669,4 +715,5 @@
 	.mknod		= nfs3_proc_mknod,
 	.statfs		= nfs3_proc_statfs,
 	.decode_dirent	= nfs3_decode_dirent,
+	.read_setup	= nfs3_proc_read_setup,
 };
diff -u --recursive --new-file linux-2.5.41-nfsv4-E09/fs/nfs/proc.c linux-2.5.41-nfsv4-E10/fs/nfs/proc.c
--- linux-2.5.41-nfsv4-E09/fs/nfs/proc.c	2002-10-08 19:41:47.000000000 -0400
+++ linux-2.5.41-nfsv4-E10/fs/nfs/proc.c	2002-10-08 19:44:22.000000000 -0400
@@ -41,6 +41,7 @@
 #include <linux/nfs.h>
 #include <linux/nfs2.h>
 #include <linux/nfs_fs.h>
+#include <linux/nfs_page.h>
 #include <linux/smp_lock.h>
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
@@ -469,6 +470,48 @@
 
 extern u32 * nfs_decode_dirent(u32 *, struct nfs_entry *, int);
 
+static void
+nfs_read_done(struct rpc_task *task)
+{
+	struct nfs_read_data *data = (struct nfs_read_data *) task->tk_calldata;
+	nfs_readpage_result(task, data->u.v3.res.count, data->u.v3.res.eof);
+}
+
+static void
+nfs_proc_read_setup(struct nfs_read_data *data, unsigned int count)
+{
+	struct rpc_task		*task = &data->task;
+	struct inode		*inode = data->inode;
+	struct nfs_page		*req;
+	int			flags;
+	struct rpc_message	msg;
+	
+	req = nfs_list_entry(data->pages.next);
+	data->u.v3.args.fh     = NFS_FH(inode);
+	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.pgbase = req->wb_offset;
+	data->u.v3.args.pages  = data->pagevec;
+	data->u.v3.args.count  = count;
+	data->u.v3.res.fattr   = &data->fattr;
+	data->u.v3.res.count   = count;
+	data->u.v3.res.eof     = 0;
+	
+	/* N.B. Do we need to test? Never called for swapfile inode */
+	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
+
+	/* Finalize the task. */
+	rpc_init_task(task, NFS_CLIENT(inode), nfs_read_done, flags);
+	task->tk_calldata = data;
+	/* Release requests */
+	task->tk_release = nfs_readdata_release;
+
+	msg.rpc_proc = NFSPROC_READ;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
+	msg.rpc_cred = data->cred;
+	rpc_call_setup(&data->task, &msg, 0);
+}
+
 struct nfs_rpc_ops	nfs_v2_clientops = {
 	.version	= 2,		       /* protocol version */
 	.getroot	= nfs_proc_get_root,
@@ -493,4 +536,5 @@
 	.mknod		= nfs_proc_mknod,
 	.statfs		= nfs_proc_statfs,
 	.decode_dirent	= nfs_decode_dirent,
+	.read_setup	= nfs_proc_read_setup,
 };
diff -u --recursive --new-file linux-2.5.41-nfsv4-E09/fs/nfs/read.c linux-2.5.41-nfsv4-E10/fs/nfs/read.c
--- linux-2.5.41-nfsv4-E09/fs/nfs/read.c	2002-10-08 19:43:56.000000000 -0400
+++ linux-2.5.41-nfsv4-E10/fs/nfs/read.c	2002-10-08 19:44:22.000000000 -0400
@@ -34,34 +34,6 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
-struct nfs_read_data {
-	struct rpc_task		task;
-	struct inode		*inode;
-	struct rpc_cred		*cred;
-	struct nfs_fattr	fattr;	/* fattr storage */
-	struct list_head	pages;	/* Coalesced read requests */
-	struct page		*pagevec[NFS_READ_MAXIOV];
-	union {
-		struct {
-			struct nfs_readargs args;
-			struct nfs_readres  res;
-		} v3;   /* also v2 */
-#ifdef CONFIG_NFS_V4
-		/* NFSv4 data will come here... */
-#endif
-	} u;
-};
-
-/*
- * Local function declarations
- */
-static void	nfs_readpage_result(struct rpc_task *task);
-
-/* Hack for future NFS swap support */
-#ifndef IS_SWAPFILE
-# define IS_SWAPFILE(inode)	(0)
-#endif
-
 static kmem_cache_t *nfs_rdata_cachep;
 
 static __inline__ struct nfs_read_data *nfs_readdata_alloc(void)
@@ -71,7 +43,6 @@
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		p->u.v3.args.pages = p->pagevec;
 	}
 	return p;
 }
@@ -81,7 +52,7 @@
 	kmem_cache_free(nfs_rdata_cachep, p);
 }
 
-static void nfs_readdata_release(struct rpc_task *task)
+void nfs_readdata_release(struct rpc_task *task)
 {
         struct nfs_read_data   *data = (struct nfs_read_data *)task->tk_calldata;
         nfs_readdata_free(data);
@@ -197,31 +168,32 @@
 static void
 nfs_read_rpcsetup(struct list_head *head, struct nfs_read_data *data)
 {
-	struct nfs_readargs	*args = &data->u.v3.args;
-	struct nfs_readres 	*res = &data->u.v3.res;
+	struct inode		*inode;
 	struct nfs_page		*req;
 	struct page		**pages;
 	unsigned int		count;
 
-	pages = &args->pages[0];
+	pages = data->pagevec;
 	count = 0;
 	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
+		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		*pages++ = req->wb_page;
 		count += req->wb_bytes;
 	}
 	req = nfs_list_entry(data->pages.next);
-	data->inode	  = req->wb_inode;
+	data->inode	  = inode = req->wb_inode;
 	data->cred	  = req->wb_cred;
-	args->fh	  = NFS_FH(req->wb_inode);
-	args->offset	  = req_offset(req) + req->wb_offset;
-	args->pgbase	  = req->wb_offset;
-	args->count	  = count;
-	res->fattr	  = &data->fattr;
-	res->count	  = count;
-	res->eof	  = 0;
+
+	NFS_PROTO(inode)->read_setup(data, count);
+
+	dprintk("NFS: %4d initiated read call (req %s/%Ld, %u bytes @ offset %Lu.\n",
+			data->task.tk_pid,
+			inode->i_sb->s_id,
+			(long long)NFS_FILEID(inode),
+			count,
+			(unsigned long long)req_offset(req) + req->wb_offset);
 }
 
 static void
@@ -245,50 +217,20 @@
 static int
 nfs_pagein_one(struct list_head *head, struct inode *inode)
 {
-	struct rpc_task		*task;
 	struct rpc_clnt		*clnt = NFS_CLIENT(inode);
 	struct nfs_read_data	*data;
-	struct rpc_message	msg;
-	int			flags;
 	sigset_t		oldset;
 
 	data = nfs_readdata_alloc();
 	if (!data)
 		goto out_bad;
-	task = &data->task;
-
-	/* N.B. Do we need to test? Never called for swapfile inode */
-	flags = RPC_TASK_ASYNC | (IS_SWAPFILE(inode)? NFS_RPC_SWAPFLAGS : 0);
 
 	nfs_read_rpcsetup(head, data);
 
-	/* Finalize the task. */
-	rpc_init_task(task, clnt, nfs_readpage_result, flags);
-	task->tk_calldata = data;
-	/* Release requests */
-	task->tk_release = nfs_readdata_release;
-
-#ifdef CONFIG_NFS_V3
-	msg.rpc_proc = (NFS_PROTO(inode)->version == 3) ? NFS3PROC_READ : NFSPROC_READ;
-#else
-	msg.rpc_proc = NFSPROC_READ;
-#endif
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
-
 	/* Start the async call */
-	dprintk("NFS: %4d initiated read call (req %s/%Ld, %u bytes @ offset %Lu.\n",
-		task->tk_pid,
-		inode->i_sb->s_id,
-		(long long)NFS_FILEID(inode),
-		(unsigned int)data->u.v3.args.count,
-		(unsigned long long)data->u.v3.args.offset);
-
 	rpc_clnt_sigmask(clnt, &oldset);
-	rpc_call_setup(task, &msg, 0);
 	lock_kernel();
-	rpc_execute(task);
+	rpc_execute(&data->task);
 	unlock_kernel();
 	rpc_clnt_sigunmask(clnt, &oldset);
 	return 0;
@@ -408,20 +350,15 @@
  * This is the callback from RPC telling us whether a reply was
  * received or some error occurred (timeout or socket shutdown).
  */
-static void
-nfs_readpage_result(struct rpc_task *task)
+void
+nfs_readpage_result(struct rpc_task *task, unsigned int count, int eof)
 {
 	struct nfs_read_data	*data = (struct nfs_read_data *) task->tk_calldata;
 	struct inode		*inode = data->inode;
-	unsigned int		count = data->u.v3.res.count;
-	int			eof = data->u.v3.res.eof;
 
 	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
 
-	if (nfs_async_handle_jukebox(task))
-		return;
-
 	nfs_refresh_inode(inode, &data->fattr);
 	while (!list_empty(&data->pages)) {
 		struct nfs_page *req = nfs_list_entry(data->pages.next);
diff -u --recursive --new-file linux-2.5.41-nfsv4-E09/include/linux/nfs_fs.h linux-2.5.41-nfsv4-E10/include/linux/nfs_fs.h
--- linux-2.5.41-nfsv4-E09/include/linux/nfs_fs.h	2002-10-08 19:43:05.000000000 -0400
+++ linux-2.5.41-nfsv4-E10/include/linux/nfs_fs.h	2002-10-08 19:44:22.000000000 -0400
@@ -379,6 +379,11 @@
 	return (error < 0) ? error : 0;
 }
 
+/* Hack for future NFS swap support */
+#ifndef IS_SWAPFILE
+# define IS_SWAPFILE(inode)	(0)
+#endif
+
 /*
  * linux/fs/nfs/read.c
  */
@@ -387,6 +392,8 @@
 extern int  nfs_pagein_list(struct list_head *, int);
 extern int  nfs_scan_lru_read(struct nfs_server *, struct list_head *);
 extern int  nfs_scan_lru_read_timeout(struct nfs_server *, struct list_head *);
+extern void nfs_readpage_result(struct rpc_task *, unsigned int count, int eof);
+extern void nfs_readdata_release(struct rpc_task *);
 
 /*
  * linux/fs/mount_clnt.c
diff -u --recursive --new-file linux-2.5.41-nfsv4-E09/include/linux/nfs_xdr.h linux-2.5.41-nfsv4-E10/include/linux/nfs_xdr.h
--- linux-2.5.41-nfsv4-E09/include/linux/nfs_xdr.h	2002-10-08 19:43:05.000000000 -0400
+++ linux-2.5.41-nfsv4-E10/include/linux/nfs_xdr.h	2002-10-08 19:44:22.000000000 -0400
@@ -308,6 +308,24 @@
 	int			plus;
 };
 
+struct nfs_read_data {
+	struct rpc_task		task;
+	struct inode		*inode;
+	struct rpc_cred		*cred;
+	struct nfs_fattr	fattr;	/* fattr storage */
+	struct list_head	pages;	/* Coalesced read requests */
+	struct page		*pagevec[NFS_READ_MAXIOV];
+	union {
+		struct {
+			struct nfs_readargs args;
+			struct nfs_readres  res;
+		} v3;   /* also v2 */
+#ifdef CONFIG_NFS_V4
+		/* NFSv4 data will come here... */
+#endif
+	} u;
+};
+
 /*
  * RPC procedure vector for NFSv2/NFSv3 demuxing
  */
@@ -355,6 +373,7 @@
 	int	(*statfs)  (struct nfs_server *, struct nfs_fh *,
 			    struct nfs_fsinfo *);
 	u32 *	(*decode_dirent)(u32 *, struct nfs_entry *, int plus);
+	void	(*read_setup)   (struct nfs_read_data *, unsigned int count);
 };
 
 /*


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
