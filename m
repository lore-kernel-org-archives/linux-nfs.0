From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 9/19] A basic NFSv4 client for 2.5.x
Date: Wed, 9 Oct 2002 02:19:58 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15779.30254.814868.583164@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17z4a5-00018O-00
	for <nfs@lists.sourceforge.net>; Tue, 08 Oct 2002 17:20:05 -0700
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

Synchronous READ operations are currently done via the ->read() nfs_rpc_op.
Therefore, the synchronous READ path can easily be adapted for NFSv4.  On
the other hand, the asynchronous READ path contains several NFSv3-specific
features, which make it difficult to adapt for NFSv4.

In this patch and the next, we modify the async READ path to be
version-agnostic.  This patch just changes the 'struct nfs_read_data'
so that the v2- and v3-specific parts are moved into a private area,
with room for a v4-specific part in parallel.  None of the logic is
changed.

diff -u --recursive --new-file linux-2.5.41-nfsv4-E08/fs/nfs/read.c linux-2.5.41-nfsv4-E09/fs/nfs/read.c
--- linux-2.5.41-nfsv4-E08/fs/nfs/read.c	2002-10-04 11:28:35.000000000 -0400
+++ linux-2.5.41-nfsv4-E09/fs/nfs/read.c	2002-10-08 19:43:56.000000000 -0400
@@ -38,11 +38,18 @@
 	struct rpc_task		task;
 	struct inode		*inode;
 	struct rpc_cred		*cred;
-	struct nfs_readargs	args;	/* XDR argument struct */
-	struct nfs_readres	res;	/* ... and result struct */
 	struct nfs_fattr	fattr;	/* fattr storage */
 	struct list_head	pages;	/* Coalesced read requests */
 	struct page		*pagevec[NFS_READ_MAXIOV];
+	union {
+		struct {
+			struct nfs_readargs args;
+			struct nfs_readres  res;
+		} v3;   /* also v2 */
+#ifdef CONFIG_NFS_V4
+		/* NFSv4 data will come here... */
+#endif
+	} u;
 };
 
 /*
@@ -64,7 +71,7 @@
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		p->args.pages = p->pagevec;
+		p->u.v3.args.pages = p->pagevec;
 	}
 	return p;
 }
@@ -190,11 +197,13 @@
 static void
 nfs_read_rpcsetup(struct list_head *head, struct nfs_read_data *data)
 {
+	struct nfs_readargs	*args = &data->u.v3.args;
+	struct nfs_readres 	*res = &data->u.v3.res;
 	struct nfs_page		*req;
 	struct page		**pages;
 	unsigned int		count;
 
-	pages = data->args.pages;
+	pages = &args->pages[0];
 	count = 0;
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
@@ -206,13 +215,13 @@
 	req = nfs_list_entry(data->pages.next);
 	data->inode	  = req->wb_inode;
 	data->cred	  = req->wb_cred;
-	data->args.fh     = NFS_FH(req->wb_inode);
-	data->args.offset = req_offset(req) + req->wb_offset;
-	data->args.pgbase = req->wb_offset;
-	data->args.count  = count;
-	data->res.fattr   = &data->fattr;
-	data->res.count   = count;
-	data->res.eof     = 0;
+	args->fh	  = NFS_FH(req->wb_inode);
+	args->offset	  = req_offset(req) + req->wb_offset;
+	args->pgbase	  = req->wb_offset;
+	args->count	  = count;
+	res->fattr	  = &data->fattr;
+	res->count	  = count;
+	res->eof	  = 0;
 }
 
 static void
@@ -264,8 +273,8 @@
 #else
 	msg.rpc_proc = NFSPROC_READ;
 #endif
-	msg.rpc_argp = &data->args;
-	msg.rpc_resp = &data->res;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
 	msg.rpc_cred = data->cred;
 
 	/* Start the async call */
@@ -273,8 +282,8 @@
 		task->tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
-		(unsigned int)data->args.count,
-		(unsigned long long)data->args.offset);
+		(unsigned int)data->u.v3.args.count,
+		(unsigned long long)data->u.v3.args.offset);
 
 	rpc_clnt_sigmask(clnt, &oldset);
 	rpc_call_setup(task, &msg, 0);
@@ -404,7 +413,8 @@
 {
 	struct nfs_read_data	*data = (struct nfs_read_data *) task->tk_calldata;
 	struct inode		*inode = data->inode;
-	unsigned int		count = data->res.count;
+	unsigned int		count = data->u.v3.res.count;
+	int			eof = data->u.v3.res.eof;
 
 	dprintk("NFS: %4d nfs_readpage_result, (status %d)\n",
 		task->tk_pid, task->tk_status);
@@ -424,7 +434,7 @@
 				memset(p + count, 0, PAGE_CACHE_SIZE - count);
 				kunmap(page);
 				count = 0;
-				if (data->res.eof)
+				if (eof)
 					SetPageUptodate(page);
 				else
 					SetPageError(page);


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
