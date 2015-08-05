Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f182.google.com ([209.85.160.182]:33392 "EHLO
	mail-yk0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305AbbHEVN5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 17:13:57 -0400
Received: by ykoo205 with SMTP id o205so46667409yko.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 14:13:56 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 18/18] nfsd: call flush_delayed_fput from nfsd_file_close_fh
Date: Wed,  5 Aug 2015 17:13:36 -0400
Message-Id: <1438809216-4846-19-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...when there are open files to be closed.

When knfsd does an fput(), it gets queued to a list and a workqueue job
is then scheduled to do the actual __fput work. In the case of knfsd
closing down the file prior to a REMOVE or RENAME, we really want to
ensure that those files are closed prior to returning. When there are
files to be closed, call flush_delayed_fput to ensure this.

There are deadlock possibilities if you call flush_delayed_fput while
holding locks, however. In the case of nfsd_rename, we don't even do the
lookups of the dentries to be renamed until we've locked for rename.

Once we've figured out what the target dentry is for a rename, check to
see whether there are cached open files associated with it. If there
are, then unwind all of the locking, close them all, and then reattempt
the rename.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/file_table.c     |  1 +
 fs/nfsd/filecache.c | 33 ++++++++++++++++++++++++++++++++-
 fs/nfsd/filecache.h |  1 +
 fs/nfsd/trace.h     | 10 +++++++++-
 fs/nfsd/vfs.c       | 52 ++++++++++++++++++++++++++++++++++++++++++++--------
 5 files changed, 87 insertions(+), 10 deletions(-)

diff --git a/fs/file_table.c b/fs/file_table.c
index 7f9d407c7595..33898e72618c 100644
--- a/fs/file_table.c
+++ b/fs/file_table.c
@@ -257,6 +257,7 @@ void flush_delayed_fput(void)
 {
 	delayed_fput(NULL);
 }
+EXPORT_SYMBOL_GPL(flush_delayed_fput);
 
 static DECLARE_DELAYED_WORK(delayed_fput_work, delayed_fput);
 
diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index a114f3a69117..ce8b8e4f7cf3 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -273,6 +273,34 @@ nfsd_file_find_locked(struct knfsd_fh *fh, unsigned int may_flags,
 }
 
 /**
+ * nfsd_file_is_cached - are there any cached open files for this fh?
+ * @fh: filehandle of the file to check
+ *
+ * Scan the hashtable for open files that match this fh. Returns true if there
+ * are any, and false if not.
+ */
+bool
+nfsd_file_is_cached(struct knfsd_fh *fh)
+{
+	bool			ret = false;
+	struct nfsd_file	*nf;
+	unsigned int		hashval = file_hashval(fh);
+
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(nf, &nfsd_file_hashtbl[hashval].nfb_head,
+				 nf_node) {
+		if (fh_match(&nf->nf_handle, fh)) {
+			ret = true;
+			break;
+		}
+	}
+	rcu_read_unlock();
+	trace_nfsd_file_is_cached(hashval, fh, (int)ret);
+	return ret;
+}
+
+
+/**
  * nfsd_file_force_close - attempt to forcibly close a nfsd_file
  * @fh: filehandle of the file to attempt to remove
  *
@@ -296,7 +324,10 @@ nfsd_file_close_fh(struct knfsd_fh *fh)
 	}
 	spin_unlock(&nfsd_file_hashtbl[hashval].nfb_lock);
 	trace_nfsd_file_close_fh(hashval, fh, !list_empty(&dispose));
-	nfsd_file_dispose_list(&dispose);
+	if (!list_empty(&dispose)) {
+		nfsd_file_dispose_list(&dispose);
+		flush_delayed_fput();
+	}
 }
 
 __be32
diff --git a/fs/nfsd/filecache.h b/fs/nfsd/filecache.h
index 40c47cac2c33..2a347e16f095 100644
--- a/fs/nfsd/filecache.h
+++ b/fs/nfsd/filecache.h
@@ -44,6 +44,7 @@ int nfsd_file_cache_init(void);
 void nfsd_file_cache_purge(void);
 void nfsd_file_cache_shutdown(void);
 void nfsd_file_put(struct nfsd_file *nf);
+bool nfsd_file_is_cached(struct knfsd_fh *fh);
 void nfsd_file_close_fh(struct knfsd_fh *fh);
 __be32 nfsd_file_acquire(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		  unsigned int may_flags, struct nfsd_file **nfp);
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index c45d318e3a0b..150ce332fbd7 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -148,7 +148,7 @@ TRACE_EVENT(nfsd_file_acquire,
 			__entry->nf_file, be32_to_cpu(__entry->status))
 );
 
-TRACE_EVENT(nfsd_file_close_fh,
+DECLARE_EVENT_CLASS(nfsd_file_search_class,
 	TP_PROTO(unsigned int hash, struct knfsd_fh *handle, int found),
 	TP_ARGS(hash, handle, found),
 	TP_STRUCT__entry(
@@ -164,6 +164,14 @@ TRACE_EVENT(nfsd_file_close_fh,
 	TP_printk("hash=0x%x handle=%s found=%d", __entry->hash,
 			show_nf_fh(__entry->handle), __entry->found)
 );
+
+#define DEFINE_NFSD_FILE_SEARCH_EVENT(name)				 \
+DEFINE_EVENT(nfsd_file_search_class, name,				 \
+	TP_PROTO(unsigned int hash, struct knfsd_fh *handle, int found), \
+	TP_ARGS(hash, handle, found))
+
+DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_close_fh);
+DEFINE_NFSD_FILE_SEARCH_EVENT(nfsd_file_is_cached);
 #endif /* _NFSD_TRACE_H */
 
 #undef TRACE_INCLUDE_PATH
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index c70c6fbec4d7..464e524e8f6e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1596,6 +1596,22 @@ nfsd_close_cached_files(struct dentry *dentry, struct svc_fh *fhp)
 	return err;
 }
 
+static bool
+nfsd_has_cached_files(struct dentry *dentry, struct svc_fh *fhp)
+{
+	__be32		err;
+	bool		ret = false;
+	struct knfsd_fh	kfh = { 0 };
+
+	if (d_really_is_positive(dentry) && S_ISREG(d_inode(dentry)->i_mode)) {
+		err = fh_compose_shallow(&kfh, fhp->fh_maxsize,
+					 fhp->fh_export, dentry, fhp);
+		if (err == nfs_ok)
+			ret = nfsd_file_is_cached(&kfh);
+	}
+	return ret;
+}
+
 /*
  * Rename a file
  * N.B. After this call _both_ ffhp and tfhp need an fh_put
@@ -1608,6 +1624,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	struct inode	*fdir, *tdir;
 	__be32		err;
 	int		host_err;
+	bool		has_cached = false;
 
 	err = fh_verify(rqstp, ffhp, S_IFDIR, NFSD_MAY_REMOVE);
 	if (err)
@@ -1626,6 +1643,7 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (!flen || isdotent(fname, flen) || !tlen || isdotent(tname, tlen))
 		goto out;
 
+retry:
 	host_err = fh_want_write(ffhp);
 	if (host_err) {
 		err = nfserrno(host_err);
@@ -1665,12 +1683,16 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	if (ffhp->fh_export->ex_path.dentry != tfhp->fh_export->ex_path.dentry)
 		goto out_dput_new;
 
-	nfsd_close_cached_files(ndentry, tfhp);
-	host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
-	if (!host_err) {
-		host_err = commit_metadata(tfhp);
-		if (!host_err)
-			host_err = commit_metadata(ffhp);
+	if (nfsd_has_cached_files(ndentry, tfhp)) {
+		has_cached = true;
+		goto out_dput_old;
+	} else {
+		host_err = vfs_rename(fdir, odentry, tdir, ndentry, NULL, 0);
+		if (!host_err) {
+			host_err = commit_metadata(tfhp);
+			if (!host_err)
+				host_err = commit_metadata(ffhp);
+		}
 	}
  out_dput_new:
 	dput(ndentry);
@@ -1683,12 +1705,26 @@ nfsd_rename(struct svc_rqst *rqstp, struct svc_fh *ffhp, char *fname, int flen,
 	 * as that would do the wrong thing if the two directories
 	 * were the same, so again we do it by hand.
 	 */
-	fill_post_wcc(ffhp);
-	fill_post_wcc(tfhp);
+	if (!has_cached) {
+		fill_post_wcc(ffhp);
+		fill_post_wcc(tfhp);
+	}
 	unlock_rename(tdentry, fdentry);
 	ffhp->fh_locked = tfhp->fh_locked = 0;
 	fh_drop_write(ffhp);
 
+	/*
+	 * If the target dentry has cached open files, then we need to try to
+	 * close them prior to doing the rename. Flushing delayed fput
+	 * shouldn't be done with locks held however, so we delay it until this
+	 * point and then reattempt the whole shebang.
+	 */
+	if (has_cached) {
+		has_cached = false;
+		nfsd_close_cached_files(ndentry, tfhp);
+		dput(ndentry);
+		goto retry;
+	}
 out:
 	return err;
 }
-- 
2.4.3

