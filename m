Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6970 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757159Ab0JVOOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:40 -0400
Message-ID: <4CC19C49.7060405@netapp.com>
Date: Fri, 22 Oct 2010 10:14:33 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/10] NFS: decode_dirent should use an xdr_stream
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Convert nfs*xdr.c to use an xdr stream in decode_dirent.  This will prevent a
kernel oops that has been occuring when reading a vmapped page.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c            |   29 +++++++++++----
 fs/nfs/internal.h       |    6 ++--
 fs/nfs/nfs2xdr.c        |   39 ++++++++++++++++++--
 fs/nfs/nfs3xdr.c        |   93 ++++++++++++++++++++++++++++++++++++++++++++---
 fs/nfs/nfs4_fs.h        |    2 +-
 fs/nfs/nfs4xdr.c        |   71 +++++++++++++++++++++++++++---------
 include/linux/nfs_xdr.h |    2 +-
 7 files changed, 202 insertions(+), 40 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index cd45bf0..72063ff 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -171,7 +171,7 @@ struct nfs_cache_array {
 
 #define MAX_READDIR_ARRAY ((PAGE_SIZE - sizeof(struct nfs_cache_array)) / sizeof(struct nfs_cache_array_entry))
 
-typedef __be32 * (*decode_dirent_t)(__be32 *, struct nfs_entry *, int);
+typedef __be32 * (*decode_dirent_t)(struct xdr_stream *, struct nfs_entry *, int);
 typedef struct {
 	struct file	*file;
 	struct page	*page;
@@ -357,13 +357,11 @@ error:
 
 /* Fill in an entry based on the xdr code stored in desc->page */
 static
-int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, __be32 **ptr)
+int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, struct xdr_stream *stream)
 {
-	__be32	*p = *ptr;
-	p = desc->decode(p, entry, desc->plus);
+	__be32 *p = desc->decode(stream, entry, desc->plus);
 	if (IS_ERR(p))
 		return PTR_ERR(p);
-	*ptr = p;
 
 	entry->fattr->time_start = desc->timestamp;
 	entry->fattr->gencount = desc->gencount;
@@ -438,10 +436,23 @@ out:
 /* Perform conversion from xdr to cache array */
 static
 void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
-				struct page *xdr_page, struct page *page)
+				struct page *xdr_page, struct page *page, unsigned int buflen)
 {
+	struct xdr_stream stream;
+	struct xdr_buf buf;
 	__be32 *ptr = kmap(xdr_page);
-	while (xdr_decode(desc, entry, &ptr) == 0) {
+
+	buf.head->iov_base = xdr_page;
+	buf.head->iov_len = buflen;
+	buf.tail->iov_len = 0;
+	buf.page_base = 0;
+	buf.page_len = 0;
+	buf.buflen = buf.head->iov_len;
+	buf.len = buf.head->iov_len;
+
+	xdr_init_decode(&stream, &buf, ptr);
+
+	while (xdr_decode(desc, entry, &stream) == 0) {
 		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
 		if (desc->plus == 1)
@@ -458,6 +469,7 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 	struct file	*file = desc->file;
 	struct nfs_cache_array *array;
 	int status = 0;
+	unsigned int array_size = 1;
 
 	entry.prev_cookie = 0;
 	entry.cookie = *desc->dir_cookie;
@@ -476,9 +488,10 @@ int nfs_readdir_xdr_to_array(nfs_readdir_descriptor_t *desc, struct page *page,
 		goto out_release_array;
 	do {
 		status = nfs_readdir_xdr_filler(xdr_page, desc, &entry, file, inode);
+
 		if (status < 0)
 			break;
-		nfs_readdir_page_filler(desc, &entry, xdr_page, page);
+		nfs_readdir_page_filler(desc, &entry, xdr_page, page, array_size * PAGE_SIZE);
 	} while (array->eof_index < 0 && array->size < MAX_READDIR_ARRAY);
 
 	put_page(xdr_page);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c961bc9..74b0155 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -181,15 +181,15 @@ extern void nfs_destroy_directcache(void);
 /* nfs2xdr.c */
 extern int nfs_stat_to_errno(int);
 extern struct rpc_procinfo nfs_procedures[];
-extern __be32 * nfs_decode_dirent(__be32 *, struct nfs_entry *, int);
+extern __be32 *nfs_decode_dirent(struct xdr_stream *, struct nfs_entry *, int);
 
 /* nfs3xdr.c */
 extern struct rpc_procinfo nfs3_procedures[];
-extern __be32 *nfs3_decode_dirent(__be32 *, struct nfs_entry *, int);
+extern __be32 *nfs3_decode_dirent(struct xdr_stream *, struct nfs_entry *, int);
 
 /* nfs4xdr.c */
 #ifdef CONFIG_NFS_V4
-extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
+extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *entry, int plus);
 #endif
 #ifdef CONFIG_NFS_V4_1
 extern const u32 nfs41_maxread_overhead;
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index 79c7438..0210c75 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -500,25 +500,56 @@ err_unmap:
 	goto out;
 }
 
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("nfs: %s: prematurely hit end of receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
+}
+
 __be32 *
-nfs_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
 {
-	if (!*p++) {
-		if (!*p)
+	__be32 *p;
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	if (!ntohl(*p++)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (!ntohl(*p++))
 			return ERR_PTR(-EAGAIN);
 		entry->eof = 1;
 		return ERR_PTR(-EBADCOOKIE);
 	}
 
+	p = xdr_inline_decode(xdr, 8);
+	if (unlikely(!p))
+		goto out_overflow;
+
 	entry->ino	  = ntohl(*p++);
 	entry->len	  = ntohl(*p++);
+
+	p = xdr_inline_decode(xdr, entry->len + 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	entry->name	  = (const char *) p;
 	p		 += XDR_QUADLEN(entry->len);
 	entry->prev_cookie	  = entry->cookie;
 	entry->cookie	  = ntohl(*p++);
-	entry->eof	  = !p[0] && p[1];
+
+	p = xdr_inline_peek(xdr, 8);
+	if (p != NULL)
+		entry->eof = !p[0] && p[1];
+	else
+		entry->eof = 0;
 
 	return p;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return ERR_PTR(-EIO);
 }
 
 /*
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index 52b2fda..d562c8d 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -100,6 +100,13 @@ static const umode_t nfs_type2fmt[] = {
 	[NF3FIFO] = S_IFIFO,
 };
 
+static void print_overflow_msg(const char *func, const struct xdr_stream *xdr)
+{
+	dprintk("nfs: %s: prematurely hit end of receive buffer. "
+		"Remaining buffer length is %tu words.\n",
+		func, xdr->end - xdr->p);
+}
+
 /*
  * Common NFS XDR functions as inlines
  */
@@ -119,6 +126,29 @@ xdr_decode_fhandle(__be32 *p, struct nfs_fh *fh)
 	return NULL;
 }
 
+static inline __be32 *
+xdr_decode_fhandle_stream(struct xdr_stream *xdr, struct nfs_fh *fh)
+{
+	__be32 *p;
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	fh->size = ntohl(*p++);
+
+	if (fh->size <= NFS3_FHSIZE) {
+		p = xdr_inline_decode(xdr, fh->size);
+		if (unlikely(!p))
+			goto out_overflow;
+		memcpy(fh->data, p, fh->size);
+		return p + XDR_QUADLEN(fh->size);
+	}
+	return NULL;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return ERR_PTR(-EIO);
+}
+
 /*
  * Encode/decode time.
  */
@@ -241,6 +271,26 @@ xdr_decode_post_op_attr(__be32 *p, struct nfs_fattr *fattr)
 }
 
 static inline __be32 *
+xdr_decode_post_op_attr_stream(struct xdr_stream *xdr, struct nfs_fattr *fattr)
+{
+	__be32 *p;
+
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	if (ntohl(*p++)) {
+		p = xdr_inline_decode(xdr, 84);
+		if (unlikely(!p))
+			goto out_overflow;
+		p = xdr_decode_fattr(p, fattr);
+	}
+	return p;
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return ERR_PTR(-EIO);
+}
+
+static inline __be32 *
 xdr_decode_pre_op_attr(__be32 *p, struct nfs_fattr *fattr)
 {
 	if (*p++)
@@ -616,19 +666,33 @@ err_unmap:
 }
 
 __be32 *
-nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
 {
+	__be32 *p;
 	struct nfs_entry old = *entry;
 
-	if (!*p++) {
-		if (!*p)
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	if (!ntohl(*p++)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (!ntohl(*p++))
 			return ERR_PTR(-EAGAIN);
 		entry->eof = 1;
 		return ERR_PTR(-EBADCOOKIE);
 	}
 
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
 	p = xdr_decode_hyper(p, &entry->ino);
 	entry->len  = ntohl(*p++);
+
+	p = xdr_inline_decode(xdr, entry->len + 8);
+	if (unlikely(!p))
+		goto out_overflow;
 	entry->name = (const char *) p;
 	p += XDR_QUADLEN(entry->len);
 	entry->prev_cookie = entry->cookie;
@@ -636,10 +700,17 @@ nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
 
 	if (plus) {
 		entry->fattr->valid = 0;
-		p = xdr_decode_post_op_attr(p, entry->fattr);
+		p = xdr_decode_post_op_attr_stream(xdr, entry->fattr);
+		if (IS_ERR(p))
+			goto out_overflow_exit;
 		/* In fact, a post_op_fh3: */
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		if (*p++) {
-			p = xdr_decode_fhandle(p, entry->fh);
+			p = xdr_decode_fhandle_stream(xdr, entry->fh);
+			if (IS_ERR(p))
+				goto out_overflow_exit;
 			/* Ugh -- server reply was truncated */
 			if (p == NULL) {
 				dprintk("NFS: FH truncated\n");
@@ -650,8 +721,18 @@ nfs3_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
 			memset((u8*)(entry->fh), 0, sizeof(*entry->fh));
 	}
 
-	entry->eof = !p[0] && p[1];
+	p = xdr_inline_peek(xdr, 8);
+	if (p != NULL)
+		entry->eof = !p[0] && p[1];
+	else
+		entry->eof = 0;
+
 	return p;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+out_overflow_exit:
+	return ERR_PTR(-EIO);
 }
 
 /*
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d24a8e0..c58ea63 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -331,7 +331,7 @@ extern void nfs_free_seqid(struct nfs_seqid *seqid);
 extern const nfs4_stateid zero_stateid;
 
 /* nfs4xdr.c */
-extern __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus);
+extern __be32 *nfs4_decode_dirent(struct xdr_stream *, struct nfs_entry *entry, int plus);
 extern struct rpc_procinfo nfs4_procedures[];
 
 struct nfs4_mount_data;
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6ea5c93..a4919e9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3950,13 +3950,13 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 	__be32 *p;
 	uint32_t namelen, type;
 
-	p = xdr_inline_decode(xdr, 32);
+	p = xdr_inline_decode(xdr, 32); /* read 32 bytes */
 	if (unlikely(!p))
 		goto out_overflow;
-	p = xdr_decode_hyper(p, &offset);
+	p = xdr_decode_hyper(p, &offset); /* read 2 8-byte long words */
 	p = xdr_decode_hyper(p, &length);
-	type = be32_to_cpup(p++);
-	if (fl != NULL) {
+	type = be32_to_cpup(p++); /* 4 byte read */
+	if (fl != NULL) { /* manipulate file lock */
 		fl->fl_start = (loff_t)offset;
 		fl->fl_end = fl->fl_start + (loff_t)length - 1;
 		if (length == ~(uint64_t)0)
@@ -3966,9 +3966,9 @@ static int decode_lock_denied (struct xdr_stream *xdr, struct file_lock *fl)
 			fl->fl_type = F_RDLCK;
 		fl->fl_pid = 0;
 	}
-	p = xdr_decode_hyper(p, &clientid);
-	namelen = be32_to_cpup(p);
-	p = xdr_inline_decode(xdr, namelen);
+	p = xdr_decode_hyper(p, &clientid); /* read 8 bytes */
+	namelen = be32_to_cpup(p); /* read 4 bytes */  /* have read all 32 bytes now */
+	p = xdr_inline_decode(xdr, namelen); /* variable size field */
 	if (likely(p))
 		return -NFS4ERR_DENIED;
 out_overflow:
@@ -5755,21 +5755,33 @@ static int nfs4_xdr_dec_reclaim_complete(struct rpc_rqst *rqstp, uint32_t *p,
 }
 #endif /* CONFIG_NFS_V4_1 */
 
-__be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
+__be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, int plus)
 {
 	uint32_t bitmap[2] = {0};
 	uint32_t len;
-
-	if (!*p++) {
-		if (!*p)
+	__be32 *p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
+	if (!ntohl(*p++)) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
+		if (!ntohl(*p++))
 			return ERR_PTR(-EAGAIN);
 		entry->eof = 1;
 		return ERR_PTR(-EBADCOOKIE);
 	}
 
+	p = xdr_inline_decode(xdr, 12);
+	if (unlikely(!p))
+		goto out_overflow;
 	entry->prev_cookie = entry->cookie;
 	p = xdr_decode_hyper(p, &entry->cookie);
 	entry->len = ntohl(*p++);
+
+	p = xdr_inline_decode(xdr, entry->len + 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	entry->name = (const char *) p;
 	p += XDR_QUADLEN(entry->len);
 
@@ -5782,29 +5794,54 @@ __be32 *nfs4_decode_dirent(__be32 *p, struct nfs_entry *entry, int plus)
 
 	len = ntohl(*p++);		/* bitmap length */
 	if (len-- > 0) {
+		p = xdr_inline_decode(xdr, 4);
+		if (unlikely(!p))
+			goto out_overflow;
 		bitmap[0] = ntohl(*p++);
 		if (len-- > 0) {
+			p = xdr_inline_decode(xdr, 4);
+			if (unlikely(!p))
+				goto out_overflow;
 			bitmap[1] = ntohl(*p++);
 			p += len;
 		}
 	}
+	p = xdr_inline_decode(xdr, 4);
+	if (unlikely(!p))
+		goto out_overflow;
 	len = XDR_QUADLEN(ntohl(*p++));	/* attribute buffer length */
 	if (len > 0) {
 		if (bitmap[0] & FATTR4_WORD0_RDATTR_ERROR) {
 			bitmap[0] &= ~FATTR4_WORD0_RDATTR_ERROR;
 			/* Ignore the return value of rdattr_error for now */
-			p++;
-			len--;
+			p = xdr_inline_decode(xdr, 4);
+			if (unlikely(!p))
+				goto out_overflow;
 		}
-		if (bitmap[0] == 0 && bitmap[1] == FATTR4_WORD1_MOUNTED_ON_FILEID)
+		if (bitmap[0] == 0 && bitmap[1] == FATTR4_WORD1_MOUNTED_ON_FILEID) {
+			p = xdr_inline_decode(xdr, 8);
+			if (unlikely(!p))
+				goto out_overflow;
 			xdr_decode_hyper(p, &entry->ino);
-		else if (bitmap[0] == FATTR4_WORD0_FILEID)
+		} else if (bitmap[0] == FATTR4_WORD0_FILEID) {
+			p = xdr_inline_decode(xdr, 8);
+			if (unlikely(!p))
+				goto out_overflow;
 			xdr_decode_hyper(p, &entry->ino);
-		p += len;
+		}
 	}
 
-	entry->eof = !p[0] && p[1];
+	p = xdr_inline_peek(xdr, 8);
+	if (p != NULL)
+		entry->eof = !p[0] && p[1];
+	else
+		entry->eof = 0;
+
 	return p;
+
+out_overflow:
+	print_overflow_msg(__func__, xdr);
+	return ERR_PTR(-EIO);
 }
 
 /*
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5772b2c..ca0e8fd 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1036,7 +1036,7 @@ struct nfs_rpc_ops {
 	int	(*pathconf) (struct nfs_server *, struct nfs_fh *,
 			     struct nfs_pathconf *);
 	int	(*set_capabilities)(struct nfs_server *, struct nfs_fh *);
-	__be32 *(*decode_dirent)(__be32 *, struct nfs_entry *, int plus);
+	__be32 *(*decode_dirent)(struct xdr_stream *, struct nfs_entry *, int plus);
 	void	(*read_setup)   (struct nfs_read_data *, struct rpc_message *);
 	int	(*read_done)  (struct rpc_task *, struct nfs_read_data *);
 	void	(*write_setup)  (struct nfs_write_data *, struct rpc_message *);
