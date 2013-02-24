Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f174.google.com ([74.125.82.174]:61059 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511Ab3BXNfx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Feb 2013 08:35:53 -0500
Received: by mail-we0-f174.google.com with SMTP id r6so1719031wey.33
        for <linux-nfs@vger.kernel.org>; Sun, 24 Feb 2013 05:35:51 -0800 (PST)
From: Benny Halevy <bhalevy@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>,
        "Since 3.6" <stable@kernel.org>
Subject: [PATCH] pnfs: fix resend_to_mds for directio
Date: Sun, 24 Feb 2013 15:35:47 +0200
Message-Id: <1361712947-1778-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pass the directio request on pageio_init to clean up the API.

Percolate pg_dreq from original nfs_pageio_descriptor to the
pnfs_{read,write}_done_resend_to_mds and use it on respective
call to nfs_pageio_init_{read,write} on the newly created
nfs_pageio_descriptor.

Reproduced by:

Server: linux-pnfs pnfs-all-3.7 42aba94

Client: linux-nfs/bugfixes 666b3d8

Command:
# mount -o minorversion=1 server:/ /mnt
# dd bs=128k count=8 if=/dev/zero of=/mnt/dd.out oflag=direct

BUG: unable to handle kernel NULL pointer dereference at 0000000000000028
IP: [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [nfs]
PGD 34786067 PUD 34794067 PMD 0 
Oops: 0002 [#1] SMP 
Modules linked in: nfs_layout_nfsv41_files nfsv4 nfs nfsd lockd nfs_acl auth_rpcgss exportfs sunrpc btrfs zlib_deflate libcrc32c ipv6 autofs4
CPU 1 
Pid: 259, comm: kworker/1:2 Not tainted 3.8.0-rc6 #2 Bochs Bochs
RIP: 0010:[<ffffffffa021a3a8>]  [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [nfs]
RSP: 0018:ffff880038f8fa68  EFLAGS: 00010206
RAX: ffffffffa021a6a9 RBX: ffff880038f8fb48 RCX: 00000000000a0000
RDX: ffffffffa021e616 RSI: ffff8800385e9a40 RDI: 0000000000000028
RBP: ffff880038f8fa68 R08: ffffffff81ad6720 R09: ffff8800385e9510
R10: ffffffffa0228450 R11: ffff880038e87418 R12: ffff8800385e9a40
R13: ffff8800385e9a70 R14: ffff880038f8fb38 R15: ffffffffa0148878
FS:  0000000000000000(0000) GS:ffff88003e400000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000028 CR3: 0000000034789000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process kworker/1:2 (pid: 259, threadinfo ffff880038f8e000, task ffff880038302480)
Stack:
 ffff880038f8fa78 ffffffffa021a6bf ffff880038f8fa88 ffffffffa021bb82
 ffff880038f8fae8 ffffffffa021f454 ffff880038f8fae8 ffffffff8109689d
 ffff880038f8fab8 ffffffff00000006 0000000000000000 ffff880038f8fb48
Call Trace:
 [<ffffffffa021a6bf>] nfs_direct_pgio_init+0x16/0x18 [nfs]
 [<ffffffffa021bb82>] nfs_pgheader_init+0x6a/0x6c [nfs]
 [<ffffffffa021f454>] nfs_generic_pg_writepages+0x51/0xf8 [nfs]
 [<ffffffff8109689d>] ? mark_held_locks+0x71/0x99
 [<ffffffffa0148878>] ? rpc_release_resources_task+0x37/0x37 [sunrpc]
 [<ffffffffa021bc25>] nfs_pageio_doio+0x1a/0x43 [nfs]
 [<ffffffffa021be7c>] nfs_pageio_complete+0x16/0x2c [nfs]
 [<ffffffffa02608be>] pnfs_write_done_resend_to_mds+0x95/0xc5 [nfsv4]
 [<ffffffffa0148878>] ? rpc_release_resources_task+0x37/0x37 [sunrpc]
 [<ffffffffa028e27f>] filelayout_reset_write+0x8c/0x99 [nfs_layout_nfsv41_files]
 [<ffffffffa028e5f9>] filelayout_write_done_cb+0x4d/0xc1 [nfs_layout_nfsv41_files]
 [<ffffffffa024587a>] nfs4_write_done+0x36/0x49 [nfsv4]
 [<ffffffffa021f996>] nfs_writeback_done+0x53/0x1cc [nfs]
 [<ffffffffa021fb1d>] nfs_writeback_done_common+0xe/0x10 [nfs]
 [<ffffffffa028e03d>] filelayout_write_call_done+0x28/0x2a [nfs_layout_nfsv41_files]
 [<ffffffffa01488a1>] rpc_exit_task+0x29/0x87 [sunrpc]
 [<ffffffffa014a0c9>] __rpc_execute+0x11d/0x3cc [sunrpc]
 [<ffffffff810969dc>] ? trace_hardirqs_on_caller+0x117/0x173
 [<ffffffffa014a39f>] rpc_async_schedule+0x27/0x32 [sunrpc]
 [<ffffffffa014a378>] ? __rpc_execute+0x3cc/0x3cc [sunrpc]
 [<ffffffff8105f8c1>] process_one_work+0x226/0x422
 [<ffffffff8105f7f4>] ? process_one_work+0x159/0x422
 [<ffffffff81094757>] ? lock_acquired+0x210/0x249
 [<ffffffffa014a378>] ? __rpc_execute+0x3cc/0x3cc [sunrpc]
 [<ffffffff810600d8>] worker_thread+0x126/0x1c4
 [<ffffffff8105ffb2>] ? manage_workers+0x240/0x240
 [<ffffffff81064ef8>] kthread+0xb1/0xb9
 [<ffffffff81064e47>] ? __kthread_parkme+0x65/0x65
 [<ffffffff815206ec>] ret_from_fork+0x7c/0xb0
 [<ffffffff81064e47>] ? __kthread_parkme+0x65/0x65
Code: 00 83 38 02 74 12 48 81 4b 50 00 00 01 00 c7 83 60 07 00 00 01 00 00 00 48 89 df e8 55 fe ff ff 5b 41 5c 5d c3 66 90 55 48 89 e5 <f0> ff 07 5d c3 55 48 89 e5 f0 ff 0f 0f 94 c0 84 c0 0f 95 c0 0f 
RIP  [<ffffffffa021a3a8>] atomic_inc+0x4/0x9 [nfs]
 RSP <ffff880038f8fa68>
CR2: 0000000000000028

Cc: Since 3.6 <stable@kernel.org>
Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfs/direct.c          |  9 +++------
 fs/nfs/internal.h        |  6 ++++--
 fs/nfs/nfs4filelayout.c  |  6 ++++--
 fs/nfs/pagelist.c        |  5 +++--
 fs/nfs/pnfs.c            | 30 ++++++++++++++++++------------
 fs/nfs/pnfs.h            | 12 ++++++++----
 fs/nfs/read.c            |  9 +++++----
 fs/nfs/write.c           | 10 ++++++----
 include/linux/nfs_page.h |  3 ++-
 include/linux/nfs_xdr.h  |  6 ++++--
 10 files changed, 57 insertions(+), 39 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 0bd7a55..fc0ce02 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -409,9 +409,8 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 	unsigned long seg;
 
 	NFS_PROTO(dreq->inode)->read_pageio_init(&desc, dreq->inode,
-			     &nfs_direct_read_completion_ops);
+			     &nfs_direct_read_completion_ops, dreq);
 	get_dreq(dreq);
-	desc.pg_dreq = dreq;
 
 	for (seg = 0; seg < nr_segs; seg++) {
 		const struct iovec *vec = &iov[seg];
@@ -499,8 +498,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 	get_dreq(dreq);
 
 	NFS_PROTO(dreq->inode)->write_pageio_init(&desc, dreq->inode, FLUSH_STABLE,
-			      &nfs_direct_write_completion_ops);
-	desc.pg_dreq = dreq;
+			      &nfs_direct_write_completion_ops, dreq);
 
 	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
 		if (!nfs_pageio_add_request(&desc, req)) {
@@ -811,8 +809,7 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 	unsigned long seg;
 
 	NFS_PROTO(inode)->write_pageio_init(&desc, inode, FLUSH_COND_STABLE,
-			      &nfs_direct_write_completion_ops);
-	desc.pg_dreq = dreq;
+			      &nfs_direct_write_completion_ops, dreq);
 	get_dreq(dreq);
 	atomic_inc(&inode->i_dio_count);
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 541c9eb..c42fd4d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -356,7 +356,8 @@ extern struct dentry *nfs4_get_root(struct super_block *, struct nfs_fh *,
 extern void nfs_readhdr_free(struct nfs_pgio_header *hdr);
 extern void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode,
-			const struct nfs_pgio_completion_ops *compl_ops);
+			const struct nfs_pgio_completion_ops *compl_ops,
+			struct nfs_direct_req *dreq);
 extern int nfs_initiate_read(struct rpc_clnt *clnt,
 			     struct nfs_read_data *data,
 			     const struct rpc_call_ops *call_ops, int flags);
@@ -380,7 +381,8 @@ extern int nfs_generic_pagein(struct nfs_pageio_descriptor *desc,
 /* write.c */
 extern void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			struct inode *inode, int ioflags,
-			const struct nfs_pgio_completion_ops *compl_ops);
+			const struct nfs_pgio_completion_ops *compl_ops,
+			struct nfs_direct_req *dreq);
 extern struct nfs_write_header *nfs_writehdr_alloc(void);
 extern void nfs_writehdr_free(struct nfs_pgio_header *hdr);
 extern int nfs_generic_flush(struct nfs_pageio_descriptor *desc,
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 194c484..49eeb04 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -99,7 +99,8 @@ static void filelayout_reset_write(struct nfs_write_data *data)
 
 		task->tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
 							&hdr->pages,
-							hdr->completion_ops);
+							hdr->completion_ops,
+							hdr->dreq);
 	}
 }
 
@@ -119,7 +120,8 @@ static void filelayout_reset_read(struct nfs_read_data *data)
 
 		task->tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
 							&hdr->pages,
-							hdr->completion_ops);
+							hdr->completion_ops,
+							hdr->dreq);
 	}
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index e56e846..11d0b70 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -255,7 +255,8 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 		     const struct nfs_pageio_ops *pg_ops,
 		     const struct nfs_pgio_completion_ops *compl_ops,
 		     size_t bsize,
-		     int io_flags)
+		     int io_flags,
+		     struct nfs_direct_req *dreq)
 {
 	INIT_LIST_HEAD(&desc->pg_list);
 	desc->pg_bytes_written = 0;
@@ -270,7 +271,7 @@ void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 	desc->pg_ioflags = io_flags;
 	desc->pg_error = 0;
 	desc->pg_lseg = NULL;
-	desc->pg_dreq = NULL;
+	desc->pg_dreq = dreq;
 	desc->pg_layout_private = NULL;
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init);
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 6be70f6..e1ccc62 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1369,29 +1369,31 @@ struct pnfs_layout_segment *
 
 void
 pnfs_pageio_init_read(struct nfs_pageio_descriptor *pgio, struct inode *inode,
-		      const struct nfs_pgio_completion_ops *compl_ops)
+		      const struct nfs_pgio_completion_ops *compl_ops,
+		      struct nfs_direct_req *dreq)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		nfs_pageio_init_read(pgio, inode, compl_ops);
+		nfs_pageio_init_read(pgio, inode, compl_ops, dreq);
 	else
-		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0);
+		nfs_pageio_init(pgio, inode, ld->pg_read_ops, compl_ops, server->rsize, 0, dreq);
 }
 
 void
 pnfs_pageio_init_write(struct nfs_pageio_descriptor *pgio, struct inode *inode,
 		       int ioflags,
-		       const struct nfs_pgio_completion_ops *compl_ops)
+		       const struct nfs_pgio_completion_ops *compl_ops,
+		       struct nfs_direct_req *dreq)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
 	struct pnfs_layoutdriver_type *ld = server->pnfs_curr_ld;
 
 	if (ld == NULL)
-		nfs_pageio_init_write(pgio, inode, ioflags, compl_ops);
+		nfs_pageio_init_write(pgio, inode, ioflags, compl_ops, dreq);
 	else
-		nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops, server->wsize, ioflags);
+		nfs_pageio_init(pgio, inode, ld->pg_write_ops, compl_ops, server->wsize, ioflags, dreq);
 }
 
 bool
@@ -1422,13 +1424,14 @@ struct pnfs_layout_segment *
 
 int pnfs_write_done_resend_to_mds(struct inode *inode,
 				struct list_head *head,
-				const struct nfs_pgio_completion_ops *compl_ops)
+				const struct nfs_pgio_completion_ops *compl_ops,
+				struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor pgio;
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_write(&pgio, inode, FLUSH_STABLE, compl_ops);
+	nfs_pageio_init_write(&pgio, inode, FLUSH_STABLE, compl_ops, dreq);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
@@ -1463,7 +1466,8 @@ static void pnfs_ld_handle_write_error(struct nfs_write_data *data)
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
 		data->task.tk_status = pnfs_write_done_resend_to_mds(hdr->inode,
 							&hdr->pages,
-							hdr->completion_ops);
+							hdr->completion_ops,
+							hdr->dreq);
 }
 
 /*
@@ -1578,13 +1582,14 @@ static void pnfs_writehdr_free(struct nfs_pgio_header *hdr)
 
 int pnfs_read_done_resend_to_mds(struct inode *inode,
 				struct list_head *head,
-				const struct nfs_pgio_completion_ops *compl_ops)
+				const struct nfs_pgio_completion_ops *compl_ops,
+				struct nfs_direct_req *dreq)
 {
 	struct nfs_pageio_descriptor pgio;
 	LIST_HEAD(failed);
 
 	/* Resend all requests through the MDS */
-	nfs_pageio_init_read(&pgio, inode, compl_ops);
+	nfs_pageio_init_read(&pgio, inode, compl_ops, dreq);
 	while (!list_empty(head)) {
 		struct nfs_page *req = nfs_list_entry(head->next);
 
@@ -1615,7 +1620,8 @@ static void pnfs_ld_handle_read_error(struct nfs_read_data *data)
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags))
 		data->task.tk_status = pnfs_read_done_resend_to_mds(hdr->inode,
 							&hdr->pages,
-							hdr->completion_ops);
+							hdr->completion_ops,
+							hdr->dreq);
 }
 
 /*
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 97cb358..0a616e9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -179,9 +179,11 @@ extern int nfs4_proc_getdeviceinfo(struct nfs_server *server,
 void pnfs_put_lseg(struct pnfs_layout_segment *lseg);
 
 void pnfs_pageio_init_read(struct nfs_pageio_descriptor *, struct inode *,
-			   const struct nfs_pgio_completion_ops *);
+			   const struct nfs_pgio_completion_ops *,
+			   struct nfs_direct_req *dreq);
 void pnfs_pageio_init_write(struct nfs_pageio_descriptor *, struct inode *,
-			    int, const struct nfs_pgio_completion_ops *);
+			    int, const struct nfs_pgio_completion_ops *,
+			    struct nfs_direct_req *dreq);
 
 void set_pnfs_layoutdriver(struct nfs_server *, const struct nfs_fh *, u32);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -230,9 +232,11 @@ struct pnfs_layout_segment *pnfs_update_layout(struct inode *ino,
 
 void nfs4_deviceid_mark_client_invalid(struct nfs_client *clp);
 int pnfs_read_done_resend_to_mds(struct inode *inode, struct list_head *head,
-			const struct nfs_pgio_completion_ops *compl_ops);
+			const struct nfs_pgio_completion_ops *compl_ops,
+			struct nfs_direct_req *dreq);
 int pnfs_write_done_resend_to_mds(struct inode *inode, struct list_head *head,
-			const struct nfs_pgio_completion_ops *compl_ops);
+			const struct nfs_pgio_completion_ops *compl_ops,
+			struct nfs_direct_req *dreq);
 struct nfs4_threshold *pnfs_mdsthreshold_alloc(void);
 
 /* nfs4_deviceid_flags */
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index a5e5d98..5b6a44d 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -115,10 +115,11 @@ int nfs_return_empty_page(struct page *page)
 
 void nfs_pageio_init_read(struct nfs_pageio_descriptor *pgio,
 			      struct inode *inode,
-			      const struct nfs_pgio_completion_ops *compl_ops)
+			      const struct nfs_pgio_completion_ops *compl_ops,
+			      struct nfs_direct_req *dreq)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_read_ops, compl_ops,
-			NFS_SERVER(inode)->rsize, 0);
+			NFS_SERVER(inode)->rsize, 0, dreq);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_read);
 
@@ -147,7 +148,7 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 	if (len < PAGE_CACHE_SIZE)
 		zero_user_segment(page, len, PAGE_CACHE_SIZE);
 
-	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
+	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops, NULL);
 	nfs_pageio_add_request(&pgio, new);
 	nfs_pageio_complete(&pgio);
 	NFS_I(inode)->read_io += pgio.pg_bytes_written;
@@ -651,7 +652,7 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	if (ret == 0)
 		goto read_complete; /* all pages were read */
 
-	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops);
+	NFS_PROTO(inode)->read_pageio_init(&pgio, inode, &nfs_async_read_completion_ops, NULL);
 
 	ret = read_cache_pages(mapping, pages, readpage_async_filler, &desc);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c483cc5..068e394 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -355,7 +355,8 @@ static int nfs_writepage_locked(struct page *page, struct writeback_control *wbc
 	NFS_PROTO(page_file_mapping(page)->host)->write_pageio_init(&pgio,
 							  page->mapping->host,
 							  wb_priority(wbc),
-							  &nfs_async_write_completion_ops);
+							  &nfs_async_write_completion_ops,
+							  NULL);
 	err = nfs_do_writepage(page, wbc, &pgio);
 	nfs_pageio_complete(&pgio);
 	if (err < 0)
@@ -398,7 +399,7 @@ int nfs_writepages(struct address_space *mapping, struct writeback_control *wbc)
 
 	nfs_inc_stats(inode, NFSIOS_VFSWRITEPAGES);
 
-	NFS_PROTO(inode)->write_pageio_init(&pgio, inode, wb_priority(wbc), &nfs_async_write_completion_ops);
+	NFS_PROTO(inode)->write_pageio_init(&pgio, inode, wb_priority(wbc), &nfs_async_write_completion_ops, NULL);
 	err = write_cache_pages(mapping, wbc, nfs_writepages_callback, &pgio);
 	nfs_pageio_complete(&pgio);
 
@@ -1232,10 +1233,11 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 
 void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 			       struct inode *inode, int ioflags,
-			       const struct nfs_pgio_completion_ops *compl_ops)
+			       const struct nfs_pgio_completion_ops *compl_ops,
+			       struct nfs_direct_req *dreq)
 {
 	nfs_pageio_init(pgio, inode, &nfs_pageio_write_ops, compl_ops,
-				NFS_SERVER(inode)->wsize, ioflags);
+				NFS_SERVER(inode)->wsize, ioflags, dreq);
 }
 EXPORT_SYMBOL_GPL(nfs_pageio_init_write);
 
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 92ce578..dd2b5c0 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -87,7 +87,8 @@ extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     const struct nfs_pageio_ops *pg_ops,
 			     const struct nfs_pgio_completion_ops *compl_ops,
 			     size_t bsize,
-			     int how);
+			     int how,
+			     struct nfs_direct_req *dreq);
 extern	int nfs_pageio_add_request(struct nfs_pageio_descriptor *,
 				   struct nfs_page *);
 extern	void nfs_pageio_complete(struct nfs_pageio_descriptor *desc);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 29adb12..2cb8b4b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1414,12 +1414,14 @@ struct nfs_rpc_ops {
 	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	void	(*read_pageio_init)(struct nfs_pageio_descriptor *, struct inode *,
-				    const struct nfs_pgio_completion_ops *);
+				    const struct nfs_pgio_completion_ops *,
+				    struct nfs_direct_req *dreq);
 	void	(*read_rpc_prepare)(struct rpc_task *, struct nfs_read_data *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
 	void	(*write_pageio_init)(struct nfs_pageio_descriptor *, struct inode *, int,
-				     const struct nfs_pgio_completion_ops *);
+				     const struct nfs_pgio_completion_ops *,
+				     struct nfs_direct_req *dreq);
 	void	(*write_rpc_prepare)(struct rpc_task *, struct nfs_write_data *);
 	int	(*write_done)  (struct rpc_task *, struct nfs_write_data *);
 	void	(*commit_setup) (struct nfs_commit_data *, struct rpc_message *);
-- 
1.7.11.7

