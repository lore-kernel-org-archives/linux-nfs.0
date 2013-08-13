Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:46208 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758013Ab3HMSgE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 14:36:04 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH 06/10] NFSv4: Add tracepoints for debugging inode manipulations
Date: Tue, 13 Aug 2013 14:35:48 -0400
Message-ID: <1376418952-12481-6-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376418952-12481-5-git-send-email-Trond.Myklebust@netapp.com>
References: <1376418952-12481-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-3-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-4-git-send-email-Trond.Myklebust@netapp.com>
 <1376418952-12481-5-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up basic tracepoints for debugging NFSv4 setattr, access,
readlink, readdir, get_acl set_acl get_security_label,
and set_security_label.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  | 36 ++++++++++++++++++++++--------------
 fs/nfs/nfs4trace.h | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 68 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3f639c8..be75a11 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2315,6 +2315,7 @@ static int nfs4_do_setattr(struct inode *inode, struct rpc_cred *cred,
 	int err;
 	do {
 		err = _nfs4_do_setattr(inode, cred, fattr, sattr, state, ilabel, olabel);
+		trace_nfs4_setattr(inode, err);
 		switch (err) {
 		case -NFS4ERR_OPENMODE:
 			if (!(sattr->ia_valid & ATTR_SIZE)) {
@@ -3143,8 +3144,9 @@ static int nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(inode),
-				_nfs4_proc_access(inode, entry),
+		err = _nfs4_proc_access(inode, entry);
+		trace_nfs4_access(inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3197,8 +3199,9 @@ static int nfs4_proc_readlink(struct inode *inode, struct page *page,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(inode),
-				_nfs4_proc_readlink(inode, page, pgbase, pglen),
+		err = _nfs4_proc_readlink(inode, page, pgbase, pglen);
+		trace_nfs4_readlink(inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3631,9 +3634,10 @@ static int nfs4_proc_readdir(struct dentry *dentry, struct rpc_cred *cred,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(dentry->d_inode),
-				_nfs4_proc_readdir(dentry, cred, cookie,
-					pages, count, plus),
+		err = _nfs4_proc_readdir(dentry, cred, cookie,
+				pages, count, plus);
+		trace_nfs4_readdir(dentry->d_inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(dentry->d_inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -4333,6 +4337,7 @@ static ssize_t nfs4_get_acl_uncached(struct inode *inode, void *buf, size_t bufl
 	ssize_t ret;
 	do {
 		ret = __nfs4_get_acl_uncached(inode, buf, buflen);
+		trace_nfs4_get_acl(inode, ret);
 		if (ret >= 0)
 			break;
 		ret = nfs4_handle_exception(NFS_SERVER(inode), ret, &exception);
@@ -4412,8 +4417,9 @@ static int nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t buflen
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(inode),
-				__nfs4_proc_set_acl(inode, buf, buflen),
+		err = __nfs4_proc_set_acl(inode, buf, buflen);
+		trace_nfs4_set_acl(inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -4466,8 +4472,9 @@ static int nfs4_get_security_label(struct inode *inode, void *buf,
 		return -EOPNOTSUPP;
 
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(inode),
-				_nfs4_get_security_label(inode, buf, buflen),
+		err = _nfs4_get_security_label(inode, buf, buflen);
+		trace_nfs4_get_security_label(inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -4519,9 +4526,10 @@ static int nfs4_do_set_security_label(struct inode *inode,
 	int err;
 
 	do {
-		err = nfs4_handle_exception(NFS_SERVER(inode),
-				_nfs4_do_set_security_label(inode, ilabel,
-				fattr, olabel),
+		err = _nfs4_do_set_security_label(inode, ilabel,
+				fattr, olabel);
+		trace_nfs4_set_security_label(inode, err);
+		err = nfs4_handle_exception(NFS_SERVER(inode), err,
 				&exception);
 	} while (exception.retry);
 	return err;
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 3e68a75..f32cd614 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -431,6 +431,52 @@ DEFINE_NFS4_LOOKUP_EVENT(nfs4_remove_async);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_get_fs_locations);
 DEFINE_NFS4_LOOKUP_EVENT(nfs4_secinfo);
 
+DECLARE_EVENT_CLASS(nfs4_inode_event,
+		TP_PROTO(const struct inode *inode,
+			int error),
+
+		TP_ARGS(inode, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->dev = inode->i_sb->s_dev;
+			__entry->fileid = NFS_FILEID(inode);
+			__entry->fhandle = nfs_fhandle_hash(NFS_FH(inode));
+			__entry->error = error;
+		),
+
+		TP_printk("error=%d (%s) fileid=%02x:%02x:%lld, fhandle=%0x08x",
+			__entry->error,
+			show_nfsv4_errors(__entry->error),
+			MAJOR(__entry->dev), MINOR(__entry->dev),
+			(unsigned long long)__entry->fileid,
+			__entry->fhandle
+		)
+);
+
+#define DEFINE_NFS4_INODE_EVENT(name)		\
+DEFINE_EVENT(nfs4_inode_event, name,			\
+		TP_PROTO(const struct inode *inode,	\
+			int error),			\
+		TP_ARGS(inode, error))
+
+DEFINE_NFS4_INODE_EVENT(nfs4_setattr);
+DEFINE_NFS4_INODE_EVENT(nfs4_access);
+DEFINE_NFS4_INODE_EVENT(nfs4_readlink);
+DEFINE_NFS4_INODE_EVENT(nfs4_readdir);
+DEFINE_NFS4_INODE_EVENT(nfs4_get_acl);
+DEFINE_NFS4_INODE_EVENT(nfs4_set_acl);
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+DEFINE_NFS4_INODE_EVENT(nfs4_get_security_label);
+DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
+#endif /* CONFIG_NFS_V4_SECURITY_LABEL */
+
 #endif /* _TRACE_NFS4_H */
 
 #undef TRACE_INCLUDE_PATH
-- 
1.8.3.1

