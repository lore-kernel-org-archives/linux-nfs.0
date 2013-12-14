Return-Path: linux-nfs-owner@vger.kernel.org
Received: from teakhout.nixpanic.net ([83.161.152.167]:51341 "EHLO
	ndevos-laptop.usersys.redhat.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753751Ab3LNTan (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 14 Dec 2013 14:30:43 -0500
From: Niels de Vos <ndevos@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Niels de Vos <ndevos@redhat.com>,
        Santosh Pradhan <spradhan@redhat.com>
Subject: [PATCH] NFS: dprintk() should not print negative fileids
Date: Sat, 14 Dec 2013 20:20:51 +0100
Message-Id: <1387048851-17824-1-git-send-email-ndevos@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A fileid in NFS is a uint64. There are some occurrences where dprintk()
outputs a signed fileid. This leads to confusion and more difficult to
read debugging (negative fileids matching positive inode numbers).

Signed-off-by: Niels de Vos <ndevos@redhat.com>
CC: Santosh Pradhan <spradhan@redhat.com>
---
 fs/nfs/direct.c         |    4 ++--
 fs/nfs/inode.c          |   22 +++++++++++-----------
 fs/nfs/nfs3acl.c        |    2 +-
 fs/nfs/nfs4filelayout.c |    8 ++++----
 fs/nfs/read.c           |   12 ++++++------
 fs/nfs/write.c          |    8 ++++----
 6 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index d71d66c..049b340 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -237,9 +237,9 @@ static void nfs_direct_complete(struct nfs_direct_req *dreq)
 
 static void nfs_direct_readpage_release(struct nfs_page *req)
 {
-	dprintk("NFS: direct read done (%s/%lld %d@%lld)\n",
+	dprintk("NFS: direct read done (%s/%llu %d@%lld)\n",
 		req->wb_context->dentry->d_inode->i_sb->s_id,
-		(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
+		(unsigned long long)NFS_FILEID(req->wb_context->dentry->d_inode),
 		req->wb_bytes,
 		(long long)req_offset(req));
 	nfs_release_request(req);
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 00ad1c2..de9f796 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -458,9 +458,9 @@ nfs_fhget(struct super_block *sb, struct nfs_fh *fh, struct nfs_fattr *fattr, st
 		unlock_new_inode(inode);
 	} else
 		nfs_refresh_inode(inode, fattr);
-	dprintk("NFS: nfs_fhget(%s/%Ld fh_crc=0x%08x ct=%d)\n",
+	dprintk("NFS: nfs_fhget(%s/%Lu fh_crc=0x%08x ct=%d)\n",
 		inode->i_sb->s_id,
-		(long long)NFS_FILEID(inode),
+		(unsigned long long)NFS_FILEID(inode),
 		nfs_display_fhandle_hash(fh),
 		atomic_read(&inode->i_count));
 
@@ -870,8 +870,8 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 	struct nfs_fattr *fattr = NULL;
 	struct nfs_inode *nfsi = NFS_I(inode);
 
-	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Ld)\n",
-		inode->i_sb->s_id, (long long)NFS_FILEID(inode));
+	dfprintk(PAGECACHE, "NFS: revalidating (%s/%Lu)\n",
+		inode->i_sb->s_id, (unsigned long long)NFS_FILEID(inode));
 
 	trace_nfs_revalidate_inode_enter(inode);
 
@@ -895,9 +895,9 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 
 	status = NFS_PROTO(inode)->getattr(server, NFS_FH(inode), fattr, label);
 	if (status != 0) {
-		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) getattr failed, error=%d\n",
+		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Lu) getattr failed, error=%d\n",
 			 inode->i_sb->s_id,
-			 (long long)NFS_FILEID(inode), status);
+			 (unsigned long long)NFS_FILEID(inode), status);
 		if (status == -ESTALE) {
 			nfs_zap_caches(inode);
 			if (!S_ISDIR(inode->i_mode))
@@ -908,9 +908,9 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 
 	status = nfs_refresh_inode(inode, fattr);
 	if (status) {
-		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Ld) refresh failed, error=%d\n",
+		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%s/%Lu) refresh failed, error=%d\n",
 			 inode->i_sb->s_id,
-			 (long long)NFS_FILEID(inode), status);
+			 (unsigned long long)NFS_FILEID(inode), status);
 		goto err_out;
 	}
 
@@ -919,9 +919,9 @@ __nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 
 	nfs_setsecurity(inode, fattr, label);
 
-	dfprintk(PAGECACHE, "NFS: (%s/%Ld) revalidation complete\n",
+	dfprintk(PAGECACHE, "NFS: (%s/%Lu) revalidation complete\n",
 		inode->i_sb->s_id,
-		(long long)NFS_FILEID(inode));
+		(unsigned long long)NFS_FILEID(inode));
 
 err_out:
 	nfs4_label_free(label);
@@ -1434,7 +1434,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
 	unsigned long now = jiffies;
 	unsigned long save_cache_validity;
 
-	dfprintk(VFS, "NFS: %s(%s/%ld fh_crc=0x%08x ct=%d info=0x%x)\n",
+	dfprintk(VFS, "NFS: %s(%s/%lu fh_crc=0x%08x ct=%d info=0x%x)\n",
 			__func__, inode->i_sb->s_id, inode->i_ino,
 			nfs_display_fhandle_hash(NFS_FH(inode)),
 			atomic_read(&inode->i_count), fattr->valid);
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 4a1aafb..5a17fea 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -130,7 +130,7 @@ static void __nfs3_forget_cached_acls(struct nfs_inode *nfsi)
 
 void nfs3_forget_cached_acls(struct inode *inode)
 {
-	dprintk("NFS: nfs3_forget_cached_acls(%s/%ld)\n", inode->i_sb->s_id,
+	dprintk("NFS: nfs3_forget_cached_acls(%s/%lu)\n", inode->i_sb->s_id,
 		inode->i_ino);
 	spin_lock(&inode->i_lock);
 	__nfs3_forget_cached_acls(NFS_I(inode));
diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index b86464b..0a93e79 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -91,10 +91,10 @@ static void filelayout_reset_write(struct nfs_write_data *data)
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
-			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
+			"(req %s/%llu, %u bytes @ offset %llu)\n", __func__,
 			data->task.tk_pid,
 			hdr->inode->i_sb->s_id,
-			(long long)NFS_FILEID(hdr->inode),
+			(unsigned long long)NFS_FILEID(hdr->inode),
 			data->args.count,
 			(unsigned long long)data->args.offset);
 
@@ -112,10 +112,10 @@ static void filelayout_reset_read(struct nfs_read_data *data)
 
 	if (!test_and_set_bit(NFS_IOHDR_REDO, &hdr->flags)) {
 		dprintk("%s Reset task %5u for i/o through MDS "
-			"(req %s/%lld, %u bytes @ offset %llu)\n", __func__,
+			"(req %s/%llu, %u bytes @ offset %llu)\n", __func__,
 			data->task.tk_pid,
 			hdr->inode->i_sb->s_id,
-			(long long)NFS_FILEID(hdr->inode),
+			(unsigned long long)NFS_FILEID(hdr->inode),
 			data->args.count,
 			(unsigned long long)data->args.offset);
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 31db5c3..411aedd 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -163,9 +163,9 @@ static void nfs_readpage_release(struct nfs_page *req)
 
 	unlock_page(req->wb_page);
 
-	dprintk("NFS: read done (%s/%Ld %d@%Ld)\n",
+	dprintk("NFS: read done (%s/%Lu %d@%Ld)\n",
 			req->wb_context->dentry->d_inode->i_sb->s_id,
-			(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
+			(unsigned long long)NFS_FILEID(req->wb_context->dentry->d_inode),
 			req->wb_bytes,
 			(long long)req_offset(req));
 	nfs_release_request(req);
@@ -228,11 +228,11 @@ int nfs_initiate_read(struct rpc_clnt *clnt,
 	/* Set up the initial task struct. */
 	NFS_PROTO(inode)->read_setup(data, &msg);
 
-	dprintk("NFS: %5u initiated read call (req %s/%lld, %u bytes @ "
+	dprintk("NFS: %5u initiated read call (req %s/%llu, %u bytes @ "
 			"offset %llu)\n",
 			data->task.tk_pid,
 			inode->i_sb->s_id,
-			(long long)NFS_FILEID(inode),
+			(unsigned long long)NFS_FILEID(inode),
 			data->args.count,
 			(unsigned long long)data->args.offset);
 
@@ -630,9 +630,9 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 	unsigned long npages;
 	int ret = -ESTALE;
 
-	dprintk("NFS: nfs_readpages (%s/%Ld %d)\n",
+	dprintk("NFS: nfs_readpages (%s/%Lu %d)\n",
 			inode->i_sb->s_id,
-			(long long)NFS_FILEID(inode),
+			(unsigned long long)NFS_FILEID(inode),
 			nr_pages);
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGES);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index c1d5482..77a00c6 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1013,10 +1013,10 @@ int nfs_initiate_write(struct rpc_clnt *clnt,
 	NFS_PROTO(inode)->write_setup(data, &msg);
 
 	dprintk("NFS: %5u initiated write call "
-		"(req %s/%lld, %u bytes @ offset %llu)\n",
+		"(req %s/%llu, %u bytes @ offset %llu)\n",
 		data->task.tk_pid,
 		inode->i_sb->s_id,
-		(long long)NFS_FILEID(inode),
+		(unsigned long long)NFS_FILEID(inode),
 		data->args.count,
 		(unsigned long long)data->args.offset);
 
@@ -1606,9 +1606,9 @@ static void nfs_commit_release_pages(struct nfs_commit_data *data)
 		nfs_list_remove_request(req);
 		nfs_clear_page_commit(req->wb_page);
 
-		dprintk("NFS:       commit (%s/%lld %d@%lld)",
+		dprintk("NFS:       commit (%s/%llu %d@%lld)",
 			req->wb_context->dentry->d_sb->s_id,
-			(long long)NFS_FILEID(req->wb_context->dentry->d_inode),
+			(unsigned long long)NFS_FILEID(req->wb_context->dentry->d_inode),
 			req->wb_bytes,
 			(long long)req_offset(req));
 		if (status < 0) {
-- 
1.7.1

