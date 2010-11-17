Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:42862 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935208Ab0KQSAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Nov 2010 13:00:49 -0500
Received: by gyh4 with SMTP id 4so1277899gyh.19
        for <linux-nfs@vger.kernel.org>; Wed, 17 Nov 2010 10:00:49 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/12] NFS: Simplify ->decode_dirent() calling sequence
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 17 Nov 2010 13:00:45 -0500
Message-ID: <20101117180045.29429.84268.stgit@matisse.1015granger.net>
In-Reply-To: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
References: <20101117175317.29429.90956.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up.

The pointer returned by ->decode_dirent() is no longer used as a
pointer.  The only call site (xdr_decode() in fs/nfs/dir.c) simply
extracts the errno value encoded in the pointer.  Replace the
returned pointer with a standard integer errno return value.

Also, pass the "server" argument as part of the nfs_entry instead of
as a separate parameter.  It's faster to derive "server" in
nfs_readdir_xdr_to_array() since we already have the directory's inode
handy.  "server" ought to be invariant for a set of entries in the
same directory, right?

The legacy versions of decode_dirent() don't use "server" anyway, so
it's wasted work for them to derive and pass "server" for each entry.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: J. Bruce Fields <bfields@redhat.com>
---

 fs/nfs/dir.c            |   15 ++++++++-------
 fs/nfs/internal.h       |    9 ++++++---
 fs/nfs/nfs2xdr.c        |   18 +++++++++---------
 fs/nfs/nfs3xdr.c        |   28 ++++++++++++++--------------
 fs/nfs/nfs4_fs.h        |    1 -
 fs/nfs/nfs4xdr.c        |   29 ++++++++++++++++++++++-------
 include/linux/nfs_xdr.h |    3 ++-
 7 files changed, 61 insertions(+), 42 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 07ac384..025a999 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -172,7 +172,7 @@ struct nfs_cache_array {
 
 #define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
 
-typedef __be32 * (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
+typedef int (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, int);
 typedef struct {
 	struct file	*file;
 	struct page	*page;
@@ -365,14 +365,14 @@ error:
 	return error;
 }
 
-/* Fill in an entry based on the xdr code stored in desc->page */
-static
-int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, struct xdr_stream *stream)
+static int xdr_decode(nfs_readdir_descriptor_t *desc,
+		      struct nfs_entry *entry, struct xdr_stream *xdr)
 {
-	__be32 *p = desc->decode(stream, entry, NFS_SERVER(desc->file->f_path.dentry->d_inode), desc->plus);
-	if (IS_ERR(p))
-		return PTR_ERR(p);
+	int error;
 
+	error = desc->decode(xdr, entry, desc->plus);
+	if (error)
+		return error;
 	entry->fattr->time_start = desc->timestamp;
 	entry->fattr->gencount = desc->gencount;
 	return 0;
@@ -545,6 +545,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	entry.eof = 0;
 	entry.fh = nfs_alloc_fhandle();
 	entry.fattr = nfs_alloc_fattr();
+	entry.server = NFS_SERVER(inode);
 	if (entry.fh == NULL || entry.fattr == NULL)
 		goto out;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 68313da..b8e3892 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -187,15 +187,18 @@ extern void nfs_destroy_directcache(void);
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(enum nfs_stat);
 extern struct rpc_procinfo nfs_procedures[];
-extern __be32 *nfs2_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
+extern int nfs2_decode_dirent(struct xdr_stream *,
+				struct nfs_entry *, int);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
-extern __be32 *nfs3_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
+extern int nfs3_decode_dirent(struct xdr_stream *,
+				struct nfs_entry *, int);
 
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
-extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
+extern int nfs4_decode_dirent(struct xdr_stream *,
+				struct nfs_entry *, int);
 #endif
 #ifdef CONFIG_NFS_V4_1
 extern const u32 nfs41_maxread_overhead;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 417531b..9ff0504 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -936,10 +936,10 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
  *                      the local page cache.
  * @xdr: XDR stream where entry resides
  * @entry: buffer to fill in with entry data
- * @server: nfs_server data for this directory
  * @plus: boolean indicating whether this should be a readdirplus entry
  *
- * Returns the position of the next item in the buffer, or an ERR_PTR.
+ * Returns zero if successful, otherwise a negative errno value is
+ * returned.
  *
  * This function is not invoked during READDIR reply decoding, but
  * rather whenever an application invokes the getdents(2) system call
@@ -954,8 +954,8 @@ static int nfs2_xdr_dec_writeres(struct rpc_rqst *req, __be32 *p,
  *		entry		*nextentry;
  *	};
  */
-__be32 *nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-			   struct nfs_server *server, int plus)
+int nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
+		       int plus)
 {
 	__be32 *p;
 	int error;
@@ -968,9 +968,9 @@ __be32 *nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		if (unlikely(p == NULL))
 			goto out_overflow;
 		if (*p++ == xdr_zero)
-			return ERR_PTR(-EAGAIN);
+			return -EAGAIN;
 		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
+		return -EBADCOOKIE;
 	}
 
 	p = xdr_inline_decode(xdr, 4);
@@ -980,7 +980,7 @@ __be32 *nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 
 	error = decode_filename_inline(xdr, &entry->name, &entry->len);
 	if (unlikely(error))
-		return ERR_PTR(error);
+		return error;
 
 	/*
 	 * The type (size and byte order) of nfscookie isn't defined in
@@ -997,11 +997,11 @@ __be32 *nfs2_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	entry->eof = 0;
 	if (p != NULL)
 		entry->eof = (p[0] == xdr_zero) && (p[1] != xdr_zero);
-	return p;
+	return 0;
 
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
+	return -EIO;
 }
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index b286980..8388d87 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -1970,10 +1970,10 @@ out_status:
  *			the local page cache
  * @xdr: XDR stream where entry resides
  * @entry: buffer to fill in with entry data
- * @server: nfs_server data for this directory
  * @plus: boolean indicating whether this should be a readdirplus entry
  *
- * Returns the position of the next item in the buffer, or an ERR_PTR.
+ * Returns zero if successful, otherwise a negative errno value is
+ * returned.
  *
  * This function is not invoked during READDIR reply decoding, but
  * rather whenever an application invokes the getdents(2) system call
@@ -2000,8 +2000,8 @@ out_status:
  *		entryplus3	*nextentry;
  *	};
  */
-__be32 *nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-			   struct nfs_server *server, int plus)
+int nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
+		       int plus)
 {
 	struct nfs_entry old = *entry;
 	__be32 *p;
@@ -2015,29 +2015,29 @@ __be32 *nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		if (unlikely(p == NULL))
 			goto out_overflow;
 		if (*p == xdr_zero)
-			return ERR_PTR(-EAGAIN);
+			return -EAGAIN;
 		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
+		return -EBADCOOKIE;
 	}
 
 	error = decode_fileid3(xdr, &entry->ino);
 	if (unlikely(error))
-		return ERR_PTR(error);
+		return error;
 
 	error = decode_inline_filename3(xdr, &entry->name, &entry->len);
 	if (unlikely(error))
-		return ERR_PTR(error);
+		return error;
 
 	entry->prev_cookie = entry->cookie;
 	error = decode_cookie3(xdr, &entry->cookie);
 	if (unlikely(error))
-		return ERR_PTR(error);
+		return error;
 
 	if (plus) {
 		entry->fattr->valid = 0;
 		error = decode_post_op_attr(xdr, entry->fattr);
 		if (unlikely(error))
-			return ERR_PTR(error);
+			return error;
 
 		/* In fact, a post_op_fh3: */
 		p = xdr_inline_decode(xdr, 4);
@@ -2048,7 +2048,7 @@ __be32 *nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 			if (unlikely(error)) {
 				if (error == -E2BIG)
 					goto out_truncated;
-				return ERR_PTR(error);
+				return error;
 			}
 		} else
 			zero_nfs_fh3(entry->fh);
@@ -2059,15 +2059,15 @@ __be32 *nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	entry->eof = 0;
 	if (p != NULL)
 		entry->eof = (p[0] == xdr_zero) && (p[1] != xdr_zero);
-	return p;
+	return 0;
 
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
+	return -EIO;
 out_truncated:
 	dprintk("NFS: directory entry contains invalid file handle\n");
 	*entry = old;
-	return ERR_PTR(-EAGAIN);
+	return -EAGAIN;
 }
 
 /*
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 9fa4963..7a6eecf 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -331,7 +331,6 @@ extern void nfs_free_seqid(struct nfs_seqid *seqid);
 extern const nfs4_stateid zero_stateid;
 
 /* nfs4xdr.c */
-extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int);
 extern struct rpc_procinfo nfs4_procedures[];
 
 struct nfs4_mount_data;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index af30a5f..f77b08d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6159,8 +6159,22 @@ out:
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-__be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
-			   struct nfs_server *server, int plus)
+/**
+ * nfs4_decode_dirent - Decode a single NFSv4 directory entry stored in
+ *                      the local page cache.
+ * @xdr: XDR stream where entry resides
+ * @entry: buffer to fill in with entry data
+ * @plus: boolean indicating whether this should be a readdirplus entry
+ *
+ * Returns zero if successful, otherwise a negative errno value is
+ * returned.
+ *
+ * This function is not invoked during READDIR reply decoding, but
+ * rather whenever an application invokes the getdents(2) system call
+ * on a directory already in our cache.
+ */
+int nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
+		       int plus)
 {
 	uint32_t bitmap[2] = {0};
 	uint32_t len;
@@ -6172,9 +6186,9 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 		if (unlikely(!p))
 			goto out_overflow;
 		if (!ntohl(*p++))
-			return ERR_PTR(-EAGAIN);
+			return -EAGAIN;
 		entry->eof = 1;
-		return ERR_PTR(-EBADCOOKIE);
+		return -EBADCOOKIE;
 	}
 
 	p = xdr_inline_decode(xdr, 12);
@@ -6203,7 +6217,8 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (decode_attr_length(xdr, &len, &p) < 0)
 		goto out_overflow;
 
-	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh, server, 1) < 0)
+	if (decode_getfattr_attrs(xdr, bitmap, entry->fattr, entry->fh,
+					entry->server, 1) < 0)
 		goto out_overflow;
 	if (entry->fattr->valid & NFS_ATTR_FATTR_FILEID)
 		entry->ino = entry->fattr->fileid;
@@ -6217,11 +6232,11 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	else
 		entry->eof = 0;
 
-	return p;
+	return 0;
 
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-	return ERR_PTR(-EIO);
+	return -EIO;
 }
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ba6cc8f..236e07c 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -483,6 +483,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs_server *	server;
 };
 
 /*
@@ -1088,7 +1089,7 @@ struct nfs_rpc_ops {
 	int	(*pathconf) (struct nfs_server *, struct nfs_fh *,
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
-	__be32 *(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, struct nfs_server *, int plus);
+	int	(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);

