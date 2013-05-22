Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59838 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756689Ab3EVQu5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 22 May 2013 12:50:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 07/13] NFSv4: Introduce new label structure
Date: Wed, 22 May 2013 12:50:40 -0400
Message-Id: <1369241446-7680-8-git-send-email-SteveD@redhat.com>
In-Reply-To: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
References: <1369241446-7680-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

In order to mimic the way that NFSv4 ACLs are implemented we have created a
structure to be used to pass label data up and down the call chain. This patch
adds the new structure and new members to the required NFSv4 call structures.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/inode.c          | 28 ++++++++++++++++++++++++++++
 include/linux/nfs4.h    |  9 +++++++++
 include/linux/nfs_fs.h  | 18 ++++++++++++++++++
 include/linux/nfs_xdr.h | 11 +++++++++++
 4 files changed, 66 insertions(+)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index c1c7a9d..07fcf0b 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -257,6 +257,34 @@ nfs_init_locked(struct inode *inode, void *opaque)
 	return 0;
 }
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+struct nfs4_label *nfs4_label_alloc(struct nfs_server *server, gfp_t flags)
+{
+	struct nfs4_label *label = NULL;
+	int minor_version = server->nfs_client->cl_minorversion;
+
+	if (minor_version < 2)
+		return label;
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
index 4204600..e36dee5 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -32,6 +32,15 @@ struct nfs4_acl {
 	struct nfs4_ace	aces[0];
 };
 
+#define NFS4_MAXLABELLEN	2048
+
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
index fc01d5c..39b2404 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -497,6 +497,24 @@ extern int nfs_mountpoint_expiry_timeout;
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
index bfdf6e0..a454d83 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -349,6 +349,7 @@ struct nfs_openargs {
 	const u32 *		open_bitmap;
 	__u32			claim;
 	enum createmode4	createmode;
+	const struct nfs4_label *label;
 };
 
 struct nfs_openres {
@@ -358,6 +359,7 @@ struct nfs_openres {
 	struct nfs4_change_info	cinfo;
 	__u32                   rflags;
 	struct nfs_fattr *      f_attr;
+	struct nfs4_label	*f_label;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	fmode_t			delegation_type;
@@ -600,6 +602,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label  *label;
 	unsigned char		d_type;
 	struct nfs_server *	server;
 };
@@ -632,6 +635,7 @@ struct nfs_setattrargs {
 	struct iattr *                  iap;
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
+	const struct nfs4_label		*label;
 };
 
 struct nfs_setaclargs {
@@ -667,6 +671,7 @@ struct nfs_getaclres {
 struct nfs_setattrres {
 	struct nfs4_sequence_res	seq_res;
 	struct nfs_fattr *              fattr;
+	struct nfs4_label		*label;
 	const struct nfs_server *	server;
 };
 
@@ -712,6 +717,7 @@ struct nfs3_setaclargs {
 struct nfs_diropok {
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label	*label;
 };
 
 struct nfs_readlinkargs {
@@ -864,6 +870,7 @@ struct nfs4_create_arg {
 	const struct iattr *		attrs;
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
+	const struct nfs4_label		*label;
 };
 
 struct nfs4_create_res {
@@ -871,6 +878,7 @@ struct nfs4_create_res {
 	const struct nfs_server *	server;
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 	struct nfs4_change_info		dir_cinfo;
 };
 
@@ -895,6 +903,7 @@ struct nfs4_getattr_res {
 	struct nfs4_sequence_res	seq_res;
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 };
 
 struct nfs4_link_arg {
@@ -909,6 +918,7 @@ struct nfs4_link_res {
 	struct nfs4_sequence_res	seq_res;
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label		*label;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
 };
@@ -926,6 +936,7 @@ struct nfs4_lookup_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
+	struct nfs4_label		*label;
 };
 
 struct nfs4_lookup_root_arg {
-- 
1.8.1.4

