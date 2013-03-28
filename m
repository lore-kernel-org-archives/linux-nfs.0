Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25525 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756209Ab3C1N50 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 28 Mar 2013 09:57:26 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 06/14] NFSv4: Introduce new label structure
Date: Thu, 28 Mar 2013 09:53:57 -0400
Message-Id: <1364478845-29796-7-git-send-email-SteveD@redhat.com>
In-Reply-To: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
References: <1364478845-29796-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

In order to mimic the way that NFSv4 ACLs are implemented we have created a
structure to be used to pass label data up and down the call chain. This patch
adds the new structure and new members to the required NFSv4 call structures.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/inode.c            | 24 ++++++++++++++++++++++++
 include/linux/nfs4.h      |  7 +++++++
 include/linux/nfs_fs.h    | 18 ++++++++++++++++++
 include/linux/nfs_xdr.h   | 21 +++++++++++++++++++++
 include/uapi/linux/nfs4.h |  2 +-
 5 files changed, 71 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 1f94167..dc85ab3 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -257,6 +257,30 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	return 0;
 }
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
+{
+	struct nfs4_label *label = NULL;
+
+	if (!(server->caps & NFS_CAP_SECURITY_LABEL))
+		return label;
+
+	label = kzalloc(sizeof(struct nfs4_label), flags);
+	if (label == NULL)
+		return ERR_PTR(-ENOMEM);
+
+	label->label = kzalloc(NFS4_MAXLABELLEN, flags);
+	if (label->label == NULL) {
+		kfree(label);
+		return ERR_PTR(-ENOMEM);
+	}
+	label->len = NFS4_MAXLABELLEN;
+
+	return label;
+}
+EXPORT_SYMBOL_GPL(nfs4_label_alloc);
+#endif
+
 /*
  * This is our front-end to iget that looks up inodes by file handle
  * instead of inode number.
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 0fa29f4..650a678 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -32,6 +32,13 @@ struct nfs4_acl {
 	struct nfs4_ace	aces[0];
 };
 
+struct nfs4_label {
+	uint32_t	lfs;
+	uint32_t	pi;
+	u32		len;
+	char	*label;
+};
+
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
 
 struct nfs_stateid4 {
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 1cc2568..e0e1806 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -489,6 +489,24 @@ extern int nfs_mountpoint_expiry_timeout;
 extern void nfs_release_automount_timer(void);
 
 /*
+ * linux/fs/nfs/nfs4proc.c
+ */
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+extern struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags);
+static inline void nfs4_label_free(struct nfs4_label *label)
+{
+	if (label) {
+		kfree(label->label);
+		kfree(label);
+	}
+	return;
+}
+#else
+static inline struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags) { return NULL; }
+static inline void nfs4_label_free(void *label) {}
+#endif
+
+/*
  * linux/fs/nfs/unlink.c
  */
 extern void nfs_complete_unlink(struct dentry *dentry, struct inode *);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9f2dba3..4d2fdf6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -351,6 +351,7 @@ struct nfs_openargs {
 	const u32 *		bitmask;
 	const u32 *		open_bitmap;
 	__u32			claim;
+	const struct nfs4_label *label;
 };
 
 struct nfs_openres {
@@ -360,6 +361,7 @@ struct nfs_openres {
 	struct nfs4_change_info	cinfo;
 	__u32                   rflags;
 	struct nfs_fattr *      f_attr;
+	struct nfs4_label	*f_label;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	fmode_t			delegation_type;
@@ -404,6 +406,7 @@ struct nfs_closeres {
 	struct nfs4_sequence_res	seq_res;
 	nfs4_stateid            stateid;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label	*label;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 };
@@ -477,6 +480,7 @@ struct nfs4_delegreturnargs {
 struct nfs4_delegreturnres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr * fattr;
+	struct nfs4_label	*label;
 	const struct nfs_server *server;
 };
 
@@ -497,6 +501,7 @@ struct nfs_readargs {
 struct nfs_readres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label	*label;
 	__u32			count;
 	int                     eof;
 };
@@ -565,6 +570,7 @@ struct nfs_removeres {
 	struct nfs4_sequence_res 	seq_res;
 	const struct nfs_server *server;
 	struct nfs_fattr	*dir_attr;
+	struct nfs4_label	*dir_label;
 	struct nfs4_change_info	cinfo;
 };
 
@@ -577,6 +583,8 @@ struct nfs_renameargs {
 	const struct nfs_fh		*new_dir;
 	const struct qstr		*old_name;
 	const struct qstr		*new_name;
+	const struct nfs4_label		*old_label;
+	const struct nfs4_label		*new_label;
 };
 
 struct nfs_renameres {
@@ -584,8 +592,10 @@ struct nfs_renameres {
 	const struct nfs_server		*server;
 	struct nfs4_change_info		old_cinfo;
 	struct nfs_fattr		*old_fattr;
+	struct nfs4_label		*old_label;
 	struct nfs4_change_info		new_cinfo;
 	struct nfs_fattr		*new_fattr;
+	struct nfs4_label		*new_label;
 };
 
 /*
@@ -600,6 +610,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label  *label;
 	unsigned char		d_type;
 	struct nfs_server *	server;
 };
@@ -632,6 +643,7 @@ struct nfs_setattrargs {
 	struct iattr *                  iap;
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
+	const struct nfs4_label		*label;
 };
 
 struct nfs_setaclargs {
@@ -667,6 +679,7 @@ struct nfs_getaclres {
 struct nfs_setattrres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *              fattr;
+	struct nfs4_label		*label;
 	const struct nfs_server *	server;
 };
 
@@ -712,6 +725,7 @@ struct nfs3_setaclargs {
 struct nfs_diropok {
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label	*label;
 };
 
 struct nfs_readlinkargs {
@@ -842,6 +856,7 @@ struct nfs4_accessres {
 	struct nfs4_sequence_res	seq_res;
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 	u32				supported;
 	u32				access;
 };
@@ -864,6 +879,7 @@ struct nfs4_create_arg {
 	const struct iattr *		attrs;
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
+	const struct nfs4_label		*label;
 };
 
 struct nfs4_create_res {
@@ -871,6 +887,7 @@ struct nfs4_create_res {
 	const struct nfs_server *	server;
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 	struct nfs4_change_info		dir_cinfo;
 };
 
@@ -895,6 +912,7 @@ struct nfs4_getattr_res {
 	struct nfs4_sequence_res	seq_res;
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 };
 
 struct nfs4_link_arg {
@@ -909,8 +927,10 @@ struct nfs4_link_res {
 	struct nfs4_sequence_res	seq_res;
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
+	struct nfs4_label		*dir_label;
 };
 
 
@@ -926,6 +946,7 @@ struct nfs4_lookup_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
+	struct nfs4_label		*label;
 };
 
 struct nfs4_lookup_root_arg {
diff --git a/include/uapi/linux/nfs4.h b/include/uapi/linux/nfs4.h
index 788128e..19a7b6d 100644
--- a/include/uapi/linux/nfs4.h
+++ b/include/uapi/linux/nfs4.h
@@ -25,7 +25,7 @@
 #define NFS4_MAXNAMLEN		NAME_MAX
 #define NFS4_OPAQUE_LIMIT	1024
 #define NFS4_MAX_SESSIONID_LEN	16
-
+#define NFS4_MAXLABELLEN	128 
 #define NFS4_ACCESS_READ        0x0001
 #define NFS4_ACCESS_LOOKUP      0x0002
 #define NFS4_ACCESS_MODIFY      0x0004
-- 
1.8.1.4

