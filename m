From: "Kendrick M. Smith" <kmsmith@umich.edu>
Subject: patch 16/38: CLIENT: add ->setup_{write,commit}() for async write,
 part 1
Date: Tue, 13 Aug 2002 19:02:46 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.SOL.4.44.0208131902210.25942-100000@rastan.gpcc.itd.umich.edu>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from donkeykong.gpcc.itd.umich.edu ([141.211.2.163])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17ekga-0002TG-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 16:02:48 -0700
To: linux-kernel@vger.kernel.org, <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


This is a nontrivial change to the NFS client.

This patch does for the async WRITE and COMMIT paths what patch 14
did for the async READ path, by changing 'struct nfs_write_data'
so that the v2- and v3-specific parts are moved into a private area,
with room for a v4-specific part in parallel.  None of the logic is
changed.

--- old/fs/nfs/write.c	Sat Aug 10 23:12:28 2002
+++ new/fs/nfs/write.c	Sat Aug 10 23:12:22 2002
@@ -72,12 +72,19 @@ struct nfs_write_data {
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
@@ -106,7 +113,6 @@ static __inline__ struct nfs_write_data
 	if (p) {
 		memset(p, 0, sizeof(*p));
 		INIT_LIST_HEAD(&p->pages);
-		p->args.pages = p->pagevec;
 	}
 	return p;
 }
@@ -864,10 +870,10 @@ nfs_write_rpcsetup(struct list_head *hea
 	/* Set up the RPC argument and reply structs
 	 * NB: take care not to mess about with data->commit et al. */

-	pages = data->args.pages;
+	pages = data->pagevec;
 	count = 0;
 	while (!list_empty(head)) {
-		struct nfs_page *req = nfs_list_entry(head->next);
+		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
 		nfs_list_add_request(req, &data->pages);
 		*pages++ = req->wb_page;
@@ -876,13 +882,14 @@ nfs_write_rpcsetup(struct list_head *hea
 	req = nfs_list_entry(data->pages.next);
 	data->inode = req->wb_inode;
 	data->cred = req->wb_cred;
-	data->args.fh     = NFS_FH(req->wb_inode);
-	data->args.offset = page_offset(req->wb_page) + req->wb_offset;
-	data->args.pgbase = req->wb_offset;
-	data->args.count  = count;
-	data->res.fattr   = &data->fattr;
-	data->res.count   = count;
-	data->res.verf    = &data->verf;
+	data->u.v3.args.fh     = NFS_FH(req->wb_inode);
+	data->u.v3.args.offset = page_offset(req->wb_page) + req->wb_offset;
+	data->u.v3.args.pgbase = req->wb_offset;
+	data->u.v3.args.pages  = pages;
+	data->u.v3.args.count  = count;
+	data->u.v3.res.fattr   = &data->fattr;
+	data->u.v3.res.count   = count;
+	data->u.v3.res.verf    = &data->verf;
 }


@@ -920,14 +927,14 @@ nfs_flush_one(struct list_head *head, st
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
@@ -940,16 +947,16 @@ nfs_flush_one(struct list_head *head, st
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
@@ -1003,8 +1010,8 @@ static void
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
@@ -1128,11 +1135,11 @@ nfs_commit_rpcsetup(struct list_head *he

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
@@ -1169,8 +1176,8 @@ nfs_commit_list(struct list_head *head,
 	task->tk_release = nfs_writedata_release;

 	msg.rpc_proc = NFS3PROC_COMMIT;
-	msg.rpc_argp = &data->args;
-	msg.rpc_resp = &data->res;
+	msg.rpc_argp = &data->u.v3.args;
+	msg.rpc_resp = &data->u.v3.res;
 	msg.rpc_cred = data->cred;

 	dprintk("NFS: %4d initiated commit call\n", task->tk_pid);
@@ -1198,7 +1205,7 @@ static void
 nfs_commit_done(struct rpc_task *task)
 {
 	struct nfs_write_data	*data = (struct nfs_write_data *)task->tk_calldata;
-	struct nfs_writeres	*resp = &data->res;
+	struct nfs_writeres	*resp = &data->u.v3.res;
 	struct nfs_page		*req;
 	struct inode		*inode = data->inode;




-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
