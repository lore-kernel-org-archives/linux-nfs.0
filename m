Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:30941 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933187Ab3HNXZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 19:25:20 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 10/13] NFSv4: Add tracepoints for debugging getattr
Date: Wed, 14 Aug 2013 19:24:55 -0400
Message-ID: <1376522698-44596-11-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1376522698-44596-10-git-send-email-Trond.Myklebust@netapp.com>
References: <1376522698-44596-1-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-2-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-3-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-4-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-5-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-6-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-7-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-8-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-9-git-send-email-Trond.Myklebust@netapp.com>
 <1376522698-44596-10-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c  |  7 ++++--
 fs/nfs/nfs4trace.h | 64 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 69 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 7f6c801..d269199 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2697,6 +2697,7 @@ static int nfs4_lookup_root(struct nfs_server *server, struct nfs_fh *fhandle,
 	int err;
 	do {
 		err = _nfs4_lookup_root(server, fhandle, info);
+		trace_nfs4_lookup_root(server, fhandle, info->fattr, err);
 		switch (err) {
 		case 0:
 		case -NFS4ERR_WRONGSEC:
@@ -2906,8 +2907,9 @@ static int nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle,
 	struct nfs4_exception exception = { };
 	int err;
 	do {
-		err = nfs4_handle_exception(server,
-				_nfs4_proc_getattr(server, fhandle, fattr, label),
+		err = _nfs4_proc_getattr(server, fhandle, fattr, label);
+		trace_nfs4_getattr(server, fhandle, fattr, err);
+		err = nfs4_handle_exception(server, err,
 				&exception);
 	} while (exception.retry);
 	return err;
@@ -3764,6 +3766,7 @@ static int nfs4_do_fsinfo(struct nfs_server *server, struct nfs_fh *fhandle, str
 
 	do {
 		err = _nfs4_do_fsinfo(server, fhandle, fsinfo);
+		trace_nfs4_fsinfo(server, fhandle, fsinfo->fattr, err);
 		if (err == 0) {
 			struct nfs_client *clp = server->nfs_client;
 
diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 429a7f4..7b3cfbf 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -170,6 +170,24 @@
 		{ FMODE_WRITE,			"WRITE" },		\
 		{ FMODE_EXEC,			"EXEC" })
 
+#define show_nfs_fattr_flags(valid)					\
+	__print_flags((unsigned long)valid, "|",			\
+		{ NFS_ATTR_FATTR_TYPE,		"TYPE" },		\
+		{ NFS_ATTR_FATTR_MODE,		"MODE" },		\
+		{ NFS_ATTR_FATTR_NLINK,		"NLINK" },		\
+		{ NFS_ATTR_FATTR_OWNER,		"OWNER" },		\
+		{ NFS_ATTR_FATTR_GROUP,		"GROUP" },		\
+		{ NFS_ATTR_FATTR_RDEV,		"RDEV" },		\
+		{ NFS_ATTR_FATTR_SIZE,		"SIZE" },		\
+		{ NFS_ATTR_FATTR_FSID,		"FSID" },		\
+		{ NFS_ATTR_FATTR_FILEID,	"FILEID" },		\
+		{ NFS_ATTR_FATTR_ATIME,		"ATIME" },		\
+		{ NFS_ATTR_FATTR_MTIME,		"MTIME" },		\
+		{ NFS_ATTR_FATTR_CTIME,		"CTIME" },		\
+		{ NFS_ATTR_FATTR_CHANGE,	"CHANGE" },		\
+		{ NFS_ATTR_FATTR_OWNER_NAME,	"OWNER_NAME" },		\
+		{ NFS_ATTR_FATTR_GROUP_NAME,	"GROUP_NAME" })
+
 DECLARE_EVENT_CLASS(nfs4_clientid_event,
 		TP_PROTO(const struct nfs_client *clp,
 			int error),
@@ -570,6 +588,52 @@ DEFINE_NFS4_INODE_EVENT(nfs4_set_security_label);
 DEFINE_NFS4_INODE_EVENT(nfs4_recall_delegation);
 DEFINE_NFS4_INODE_EVENT(nfs4_delegreturn);
 
+DECLARE_EVENT_CLASS(nfs4_getattr_event,
+		TP_PROTO(const struct nfs_server *server,
+			const struct nfs_fh *fhandle,
+			const struct nfs_fattr *fattr,
+			int error),
+
+		TP_ARGS(server, fhandle, fattr, error),
+
+		TP_STRUCT__entry(
+			__field(dev_t, dev)
+			__field(u32, fhandle)
+			__field(u64, fileid)
+			__field(unsigned int, valid)
+			__field(int, error)
+		),
+
+		TP_fast_assign(
+			__entry->dev = server->s_dev;
+			__entry->valid = fattr->valid;
+			__entry->fhandle = nfs_fhandle_hash(fhandle);
+			__entry->fileid = (fattr->valid & NFS_ATTR_FATTR_FILEID) ? fattr->fileid : 0;
+			__entry->error = error;
+		),
+
+		TP_printk("error=%d (%s) fileid=%02x:%02x:%lld fhandle=%0x08x "
+			  "valid=%s",
+			  __entry->error,
+			  show_nfsv4_errors(__entry->error),
+			  MAJOR(__entry->dev), MINOR(__entry->dev),
+			  (unsigned long long)__entry->fileid,
+			  __entry->fhandle,
+			  show_nfs_fattr_flags(__entry->valid)
+		)
+);
+
+#define DEFINE_NFS4_GETATTR_EVENT(name)		\
+DEFINE_EVENT(nfs4_getattr_event, name,			\
+		TP_PROTO(const struct nfs_server *server, \
+			const struct nfs_fh *fhandle,	\
+			const struct nfs_fattr *fattr,	\
+			int error),			\
+		TP_ARGS(server, fhandle, fattr, error))
+DEFINE_NFS4_GETATTR_EVENT(nfs4_getattr);
+DEFINE_NFS4_GETATTR_EVENT(nfs4_lookup_root);
+DEFINE_NFS4_GETATTR_EVENT(nfs4_fsinfo);
+
 DECLARE_EVENT_CLASS(nfs4_idmap_event,
 		TP_PROTO(const char *name,
 			int len,
-- 
1.8.3.1

