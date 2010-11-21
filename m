Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:49411 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755045Ab0KUTVq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 21 Nov 2010 14:21:46 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 8/8] NFS: Ensure we return the dirent->d_type when it is known
Date: Sun, 21 Nov 2010 14:21:22 -0500
Message-Id: <1290367282-5445-8-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1290367282-5445-7-git-send-email-Trond.Myklebust@netapp.com>
References: <1290367282-5445-1-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-2-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-3-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-4-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-5-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-6-git-send-email-Trond.Myklebust@netapp.com>
 <1290367282-5445-7-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Store the dirent->d_type in the struct nfs_cache_array_entry so that we
can use it in getdents() calls.

This fixes a regression with the new readdir code.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c            |    7 ++++---
 fs/nfs/internal.h       |    9 +++++++++
 fs/nfs/nfs2xdr.c        |    2 ++
 fs/nfs/nfs3xdr.c        |    2 ++
 fs/nfs/nfs4xdr.c        |    4 ++++
 include/linux/nfs_xdr.h |    1 +
 6 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index ced7291..8ea4a41 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -162,6 +162,7 @@ struct nfs_cache_array_entry {
 	u64 cookie;
 	u64 ino;
 	struct qstr string;
+	unsigned char d_type;
 };
 
 struct nfs_cache_array {
@@ -265,6 +266,7 @@ int nfs_readdir_add_to_array(struct nfs_entry *entry, struct page *page)
 
 	cache_entry->cookie = entry->prev_cookie;
 	cache_entry->ino = entry->ino;
+	cache_entry->d_type = entry->d_type;
 	ret = nfs_readdir_make_qstr(&cache_entry->string, entry->name, entry->len);
 	if (ret)
 		goto out;
@@ -701,7 +703,6 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 	int i = 0;
 	int res = 0;
 	struct nfs_cache_array *array = NULL;
-	unsigned int d_type = DT_UNKNOWN;
 
 	array = nfs_readdir_get_array(desc->page);
 	if (IS_ERR(array)) {
@@ -711,11 +712,11 @@ int nfs_do_filldir(nfs_readdir_descriptor_t *desc, void *dirent,
 
 	for (i = desc->cache_entry_index; i < array->size; i++) {
 		struct nfs_cache_array_entry *ent;
-		d_type = DT_UNKNOWN;
 
 		ent = &array->array[i];
 		if (filldir(dirent, ent->string.name, ent->string.len,
-		    file->f_pos, nfs_compat_user_ino64(ent->ino), d_type) < 0) {
+		    file->f_pos, nfs_compat_user_ino64(ent->ino),
+		    ent->d_type) < 0) {
 			desc->eof = 1;
 			break;
 		}
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index db08ff3..e6356b7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -362,6 +362,15 @@ unsigned int nfs_page_length(struct page *page)
 }
 
 /*
+ * Convert a umode to a dirent->d_type
+ */
+static inline
+unsigned char nfs_umode_to_dtype(umode_t mode)
+{
+	return (mode >> 12) & 15;
+}
+
+/*
  * Determine the number of pages in an array of length 'len' and
  * with a base offset of 'base'
  */
diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
index ab59377..5914a19 100644
--- a/fs/nfs/nfs2xdr.c
+++ b/fs/nfs/nfs2xdr.c
@@ -485,6 +485,8 @@ nfs_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_se
 	entry->prev_cookie	  = entry->cookie;
 	entry->cookie	  = ntohl(*p++);
 
+	entry->d_type = DT_UNKNOWN;
+
 	p = xdr_inline_peek(xdr, 8);
 	if (p != NULL)
 		entry->eof = !p[0] && p[1];
diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
index e79e4f5..f6cc60f 100644
--- a/fs/nfs/nfs3xdr.c
+++ b/fs/nfs/nfs3xdr.c
@@ -622,11 +622,13 @@ nfs3_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry, struct nfs_s
 	entry->prev_cookie = entry->cookie;
 	p = xdr_decode_hyper(p, &entry->cookie);
 
+	entry->d_type = DT_UNKNOWN;
 	if (plus) {
 		entry->fattr->valid = 0;
 		p = xdr_decode_post_op_attr_stream(xdr, entry->fattr);
 		if (IS_ERR(p))
 			goto out_overflow_exit;
+		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
 		/* In fact, a post_op_fh3: */
 		p = xdr_inline_decode(xdr, 4);
 		if (unlikely(!p))
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index a3b39cb..9f1826b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -6208,6 +6208,10 @@ __be32 *nfs4_decode_dirent(struct xdr_stream *xdr, struct nfs_entry *entry,
 	if (entry->fattr->valid & NFS_ATTR_FATTR_FILEID)
 		entry->ino = entry->fattr->fileid;
 
+	entry->d_type = DT_UNKNOWN;
+	if (entry->fattr->valid & NFS_ATTR_FATTR_TYPE)
+		entry->d_type = nfs_umode_to_dtype(entry->fattr->mode);
+
 	if (verify_attr_len(xdr, p, len) < 0)
 		goto out_overflow;
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index ba6cc8f..80f0719 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -483,6 +483,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	unsigned char		d_type;
 };
 
 /*
-- 
1.7.3.2

