From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 11/19] A basic NFSv4 client for 2.5.x
Date: Sat, 12 Oct 2002 01:46:44 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15783.25316.851665.336566@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1809Ug-0002KX-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 16:46:58 -0700
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

This patch does for the async WRITE and COMMIT paths what patch 14
did for the async READ path, by changing 'struct nfs_write_data'
so that the v2- and v3-specific parts are moved into a private area,
with room for a v4-specific part in parallel.  None of the logic is
changed.

diff -u --recursive --new-file linux-2.5.41/fs/nfs/write.c linux-2.5.41-nfsv4-E11/fs/nfs/write.c
--- linux-2.5.41/fs/nfs/write.c	2002-10-08 18:43:11.000000000 -0400
+++ linux-2.5.41-nfsv4-E11/fs/nfs/write.c	2002-10-11 18:21:20.000000000 -0400
@@ -72,12 +72,19 @@
 	struct rpc_task		task;
 	struct inode		*inode;
 	struct rpc_cred		*cred;
-	struct nfs_writeargs	args;		/* argument struct */
-	struct nfs_writeres	res;		/* result struct */
 	struct nfs_fattr	fattr;
 	struct nfs_writeverf	verf;
 	struct list_head	pages;		/* Coalesced requests we wish to flush */
 	struct page		*pagevec[NFS_WRITE_MAXIOV];
+	union {
+		struct {
+			struct nfs_writeargs args;
+			struct nfs_writeres  res;
+		} v3;
+#ifdef CONFIG_NFS_V4
+		/* NFSv4 data to come here... */
+#endif
+	} u;
 };
 
 /*
@@ -106,7 +113,7 @@
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		p->args.pages = p->pagevec;
+		p->u.v3.args.pages = p->pagevec;
 	}
 	return p;
 }
@@ -869,10 +876,10 @@
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */
 
-	pages = data->args.pages;
+	pages = data->u.v3.args.pages;
 	count = 0;
 	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
+		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		*pages++ = req->wb_page;
@@ -881,13 +888,13 @@
 	req = nfs_list_entry(data->pages.next);
 	data->inode = req->wb_inode;
 	data->cred = req->wb_cred;
-	data->args.fh     = NFS_FH(req->wb_inode);
-	data->args.offset = req_offset(req) + req->wb_offset;
-	data->args.pgbase = req->wb_offset;
-	data->args.count  = count;
-	data->res.fattr   = &data->fattr;
-	data->res.count   = count;
-	data->res.verf    = &data->verf;
+	data->u.v3.args.fh     = NFS_FH(req->wb_inode);
+	data->u.v3.args.offset = req_offset(req) + req->wb_offset;
+	data->u.v3.args.pgbase = req->wb_offset;
+	data->u.v3.args.count  = count;
+	data->u.v3.res.fattr   = &data->fattr;
+	data->u.v3.res.count   = count;
+	data->u.v3.res.verf    = &data->verf;
 }
 
 
@@ -925,14 +932,14 @@
 	/* Set up the argument struct */
 	nfs_write_rpcsetup(head, data);
 	if (nfsvers < 3)
-		data->args.stable = NFS_FILE_SYNC;
+		data->u.v3.args.stable = NFS_FILE_SYNC;
 	else if (stable) {
 		if (!nfsi->ncommit)
-			data->args.stable = NFS_FILE_SYNC;
+			data->u.v3.args.stable = NFS_FILE_SYNC;
 		else
-			data->args.stable = NFS_DATA_SYNC;
+			data->u.v3.args.stable = NFS_DATA_SYNC;
 	} else
-		data->args.stable = NFS_UNSTABLE;
+		data->u.v3.args.stable = NFS_UNSTABLE;
 
 	/* Finalize the task. */
 	rpc_init_task(task, clnt, nfs_writeback_done, flags);
@@ -945,16 +952,16 @@
 #else
 	msg.rpc_proc = NFSPROC_WRITE;
 #endif
-	msg.rpc_argp = &data->args;
-	msg.rpc_resp = &data->res;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
 	msg.rpc_cred = data->cred;
 
 	dprintk("NFS: %4d initiated write call (req %s/%Ld, %u bytes @ offset %Lu)\n",
 		task->tk_pid,
 		inode->i_sb->s_id,
 		(long long)NFS_FILEID(inode),
-		(unsigned int)data->args.count,
-		(unsigned long long)data->args.offset);
+		(unsigned int)data->u.v3.args.count,
+		(unsigned long long)data->u.v3.args.offset);
 
 	rpc_clnt_sigmask(clnt, &oldset);
 	rpc_call_setup(task, &msg, 0);
@@ -1008,8 +1015,8 @@
 nfs_writeback_done(struct rpc_task *task)
 {
 	struct nfs_write_data	*data = (struct nfs_write_data *) task->tk_calldata;
-	struct nfs_writeargs	*argp = &data->args;
-	struct nfs_writeres	*resp = &data->res;
+	struct nfs_writeargs	*argp = &data->u.v3.args;
+	struct nfs_writeres	*resp = &data->u.v3.res;
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	struct page		*page;
@@ -1133,11 +1140,11 @@
 
 	data->inode	  = inode;
 	data->cred	  = first->wb_cred;
-	data->args.fh     = NFS_FH(inode);
-	data->args.offset = start;
-	data->res.count   = data->args.count = (u32)len;
-	data->res.fattr   = &data->fattr;
-	data->res.verf    = &data->verf;
+	data->u.v3.args.fh     = NFS_FH(inode);
+	data->u.v3.args.offset = start;
+	data->u.v3.res.count   = data->u.v3.args.count = (u32)len;
+	data->u.v3.res.fattr   = &data->fattr;
+	data->u.v3.res.verf    = &data->verf;
 }
 
 /*
@@ -1174,8 +1181,8 @@
 	task->tk_release = nfs_writedata_release;
 
 	msg.rpc_proc = NFS3PROC_COMMIT;
-	msg.rpc_argp = &data->args;
-	msg.rpc_resp = &data->res;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
 	msg.rpc_cred = data->cred;
 
 	dprintk("NFS: %4d initiated commit call\n", task->tk_pid);
@@ -1203,7 +1210,7 @@
 nfs_commit_done(struct rpc_task *task)
 {
 	struct nfs_write_data	*data = (struct nfs_write_data *)task->tk_calldata;
-	struct nfs_writeres	*resp = &data->res;
+	struct nfs_writeres	*resp = &data->u.v3.res;
 	struct nfs_page		*req;
 	struct inode		*inode = data->inode;
 


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
