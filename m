Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f170.google.com ([209.85.160.170]:35098 "EHLO
	mail-yk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751495AbbHEVN4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:56 -0400
Received: by ykcq64 with SMTP id q64so41668232ykc.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:55 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 17/18] nfsd: close cached files prior to a REMOVE or RENAME that would replace target
Date: Wed,  5 Aug 2015 17:13:35 -0400
Message-Id: <1438809216-4846-18-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's not uncommon for some workloads to do a bunch of I/O to a file and
delete it just afterward. If knfsd has a cached open file however, then
the file may still be open when the dentry is unlinked. If the
underlying filesystem is nfs, then that could trigger it to do a
sillyrename.

On a REMOVE or RENAME scan the nfsd_file cache for open files that
correspond to the inode, and proactively unhash and put their
references. This should prevent any delete-on-last-close activity from
occurring, solely due to knfsd's open file cache.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfsd/filecache.c | 27 +++++++++++++++++++++++++++
 fs/nfsd/filecache.h |  1 +
 fs/nfsd/trace.h     | 17 +++++++++++++++++
 fs/nfsd/vfs.c       | 23 +++++++++++++++++++++--
 4 files changed, 66 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 44dee985864b..a114f3a69117 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -272,6 +272,33 @@ nfsd_file_find_locked(struct knfsd_fh *fh, unsigned int may_flags,
 	return NULL;
 }
 
+/**
+ * nfsd_file_force_close - attempt to forcibly close a nfsd_file
+ * @fh: filehandle of the file to attempt to remove
+ *
+ * Walk the whole hash bucket, looking for any files that correspond to "fh".
+ * If any do, then unhash them and put the hashtable reference to them.
+ */
+void
+nfsd_file_close_fh(struct knfsd_fh *fh)
+{
+	struct nfsd_file	*nf;
+	struct hlist_node	*tmp;
+	unsigned int		hashval = file_hashval(fh);
+	LIST_HEAD(dispose);
+
+	spin_lock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	hlist_for_each_entry_safe(nf, tmp, &nfsd_file_hashtbl[hashval].nfb_head, nf_node) {
+		if (fh_match(&nf->nf_handle, fh)) {
+			nfsd_file_unhash(nf);
+			nfsd_file_put_locked(nf, &dispose);
+		}
+	}
+	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
+	trace_nfsd_file_close_fh(hashval, fh, !list_empty(&dispose));
+	nfsd_file_dispose_list(&dispose);
+}
+
 __be32
 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **pnf)
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index b8a59d615729..40c47cac2c33 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -44,6 +44,7 @@ int nfsd_file_cache_init(void);
 void nfsd_file_cache_purge(void);
 void nfsd_file_cache_shutdown(void);
 void nfsd_file_put(struct nfsd_file *nf);
+void nfsd_file_close_fh(struct knfsd_fh *fh);
 __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **nfp);
 #endif /* _FS_NFSD_FILECACHE_H */
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index ff26d91f8106..c45d318e3a0b 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -147,6 +147,23 @@ TRACE_EVENT(nfsd_file_acquire,
 			show_nf_may(__entry->nf_may), __entry->nf_time,
 			__entry->nf_file, be32_to_cpu(__entry->status))
 );
+
+TRACE_EVENT(nfsd_file_close_fh,
+	TP_PROTO(unsigned int hash, struct knfsd_fh *handle, int found),
+	TP_ARGS(hash, handle, found),
+	TP_STRUCT__entry(
+		__field(unsigned int, hash)
+		__field_struct(struct knfsd_fh, handle)
+		__field(int, found)
+	),
+	TP_fast_assign(
+		__entry->hash = hash;
+		__entry->handle = *handle;
+		__entry->found = found;
+	),
+	TP_printk("hash=0x%x handle=%s found=%d", __entry->hash,
+			show_nf_fh(__entry->handle), __entry->found)
+);
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 8308d786c1e2..c70c6fbec4d7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1581,6 +1581,21 @@ out_nfserr:
 	goto out_unlock;
 }
 
+static __be32
+nfsd_close_cached_files(struct dentry *dentry, struct svc_fh *fhp)
+{
+	__be32		err = nfs_ok;
+	struct knfsd_fh	kfh = { 0 };
+
+	if (d_really_is_positive(dentry) && S_ISREG(d_inode(dentry)->i_mode)) {
+		err = fh_compose_shallow(&kfh, fhp->fh_maxsize,
+					 fhp->fh_export, dentry, fhp);
+		if (err == nfs_ok)
+			nfsd_file_close_fh(&kfh);
+	}
+	return err;
+}
+
 /*
  * Rename a file
  * N.B. After this call _both_ ffhp and tfhp need an fh_put
@@ -1650,6 +1665,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
+	nfsd_close_cached_files(ndentry, tfhp);
 	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
 	if (!host_err) {
 		host_err = commit_metadata(tfhp);
@@ -1719,10 +1735,13 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	if (!type)
 		type = d_inode(rdentry)->i_mode & S_IFMT;
 
-	if (type != S_IFDIR)
+	if (type != S_IFDIR) {
+		nfsd_close_cached_files(rdentry, fhp);
 		host_err = vfs_unlink(dirp, rdentry, NULL);
-	else
+	} else {
 		host_err = vfs_rmdir(dirp, rdentry);
+	}
+
 	if (!host_err)
 		host_err = commit_metadata(fhp);
 	dput(rdentry);
-- 
2.4.3

