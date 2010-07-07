From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 07/10] NFSv4: Introduce new label structure
Date: Wed,  7 Jul 2010 10:31:23 -0400
Message-ID: <1278513086-23964-8-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In order to mimic the way that NFSv4 ACLs are implemented we have created a
structure to be used to pass label data up and down the call chain. This patch
adds the new structure and new members to the required NFSv4 call structures.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfs/nfs4proc.c       |   26 ++++++++++++++++++++++++++
 fs/nfsd/xdr4.h          |    3 +++
 include/linux/nfs4.h    |    7 +++++++
 include/linux/nfs_fs.h  |    7 +++++++
 include/linux/nfs_xdr.h |   22 ++++++++++++++++++++++
 5 files changed, 65 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 071fced..71bb8da 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -148,6 +148,32 @@ const u32 nfs4_fs_locations_bitmap[2] = {
 	| FATTR4_WORD1_MOUNTED_ON_FILEID
 };
 
+#ifdef CONFIG_NFS_V4_SECURITY_LABEL
+
+struct nfs4_label * nfs4_label_alloc (gfp_t flags)
+{
+	struct nfs4_label *label = NULL;
+
+	label = kzalloc(sizeof(struct nfs4_label) + NFS4_MAXLABELLEN, flags);
+	if (label == NULL)
+		return NULL;
+
+	label->label = (void *)(label + 1);
+	label->len = NFS4_MAXLABELLEN;
+	/* 0 is the null format meaning that the data is not to be translated */
+ 	label->lfs = 0;
+	return label;
+}
+
+void nfs4_label_free (struct nfs4_label *label)
+{
+	if (label)
+		kfree(label);
+	return;
+}
+
+#endif
+
 static void nfs4_setup_readdir(u64 cookie, __be32 *verifier, struct dentry *dentry,
 		struct nfs4_readdir_arg *readdir)
 {
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index efa3377..c217277 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -108,6 +108,7 @@ struct nfsd4_create {
 	struct iattr	cr_iattr;           /* request */
 	struct nfsd4_change_info  cr_cinfo; /* response */
 	struct nfs4_acl *cr_acl;
+	struct nfs4_label *cr_label;
 };
 #define cr_linklen	u.link.namelen
 #define cr_linkname	u.link.name
@@ -235,6 +236,7 @@ struct nfsd4_open {
 	int		op_truncate;        /* used during processing */
 	struct nfs4_stateowner *op_stateowner; /* used during processing */
 	struct nfs4_acl *op_acl;
+	struct nfs4_label *op_label;
 };
 #define op_iattr	iattr
 #define op_verf		verf
@@ -316,6 +318,7 @@ struct nfsd4_setattr {
 	u32		sa_bmval[3];        /* request */
 	struct iattr	sa_iattr;           /* request */
 	struct nfs4_acl *sa_acl;
+	struct nfs4_label *sa_label;
 };
 
 struct nfsd4_setclientid {
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a2abd1a..c512a0c 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -167,6 +167,13 @@ struct nfs4_acl {
 	struct nfs4_ace	aces[0];
 };
 
+struct nfs4_label {
+	void		*label;
+	u32		len;
+	uint32_t	lfs;
+};
+
+
 typedef struct { char data[NFS4_VERIFIER_SIZE]; } nfs4_verifier;
 typedef struct { char data[NFS4_STATEID_SIZE]; } nfs4_stateid;
 
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 07ce460..2813b71 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -454,6 +454,13 @@ extern int nfs_mountpoint_expiry_timeout;
 extern void nfs_release_automount_timer(void);
 
 /*
+ * linux/fs/nfs/nfs4proc.c
+ */
+
+struct nfs4_label *	nfs4_label_alloc (gfp_t flags);
+void			nfs4_label_free (struct nfs4_label *);
+
+/*
  * linux/fs/nfs/unlink.c
  */
 extern int  nfs_async_unlink(struct inode *dir, struct dentry *dentry);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 28cde54..dc505e4 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -207,6 +207,7 @@ struct nfs_openargs {
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
+	const struct nfs4_label *label;
 	struct nfs4_sequence_args	seq_args;
 };
 
@@ -216,7 +217,9 @@ struct nfs_openres {
 	struct nfs4_change_info	cinfo;
 	__u32                   rflags;
 	struct nfs_fattr *      f_attr;
+	struct nfs4_label *	f_label;
 	struct nfs_fattr *      dir_attr;
+	struct nfs4_label *	dir_label;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	fmode_t			delegation_type;
@@ -256,6 +259,7 @@ struct nfs_closeargs {
 struct nfs_closeres {
 	nfs4_stateid            stateid;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label *	label;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
 	struct nfs4_sequence_res	seq_res;
@@ -324,6 +328,7 @@ struct nfs4_delegreturnargs {
 
 struct nfs4_delegreturnres {
 	struct nfs_fattr * fattr;
+	struct nfs4_label * label;
 	const struct nfs_server *server;
 	struct nfs4_sequence_res	seq_res;
 };
@@ -343,6 +348,7 @@ struct nfs_readargs {
 
 struct nfs_readres {
 	struct nfs_fattr *	fattr;
+	struct nfs4_label *	label;
 	__u32			count;
 	int                     eof;
 	struct nfs4_sequence_res	seq_res;
@@ -390,6 +396,7 @@ struct nfs_removeres {
 	const struct nfs_server *server;
 	struct nfs4_change_info	cinfo;
 	struct nfs_fattr	dir_attr;
+	struct nfs4_label	*dir_label;
 	struct nfs4_sequence_res 	seq_res;
 };
 
@@ -405,6 +412,7 @@ struct nfs_entry {
 	int			eof;
 	struct nfs_fh *		fh;
 	struct nfs_fattr *	fattr;
+	struct nfs4_label *	label;
 };
 
 /*
@@ -443,6 +451,7 @@ struct nfs_setattrargs {
 	struct iattr *                  iap;
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
+	const struct nfs4_label *	label;
 	struct nfs4_sequence_args 	seq_args;
 };
 
@@ -473,6 +482,7 @@ struct nfs_getaclres {
 
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
+	struct nfs4_label *		label;
 	const struct nfs_server *	server;
 	struct nfs4_sequence_res	seq_res;
 };
@@ -662,6 +672,7 @@ struct nfs4_accessargs {
 struct nfs4_accessres {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label *		label;
 	u32				supported;
 	u32				access;
 	struct nfs4_sequence_res	seq_res;
@@ -684,6 +695,7 @@ struct nfs4_create_arg {
 	const struct iattr *		attrs;
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
+	const struct nfs4_label *	label;
 	struct nfs4_sequence_args 	seq_args;
 };
 
@@ -691,8 +703,10 @@ struct nfs4_create_res {
 	const struct nfs_server *	server;
 	struct nfs_fh *			fh;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label *		label;
 	struct nfs4_change_info		dir_cinfo;
 	struct nfs_fattr *		dir_fattr;
+	struct nfs4_label *		dir_label;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -717,6 +731,7 @@ struct nfs4_getattr_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
 	struct nfs4_sequence_res	seq_res;
+	struct nfs4_label *		label;
 };
 
 struct nfs4_link_arg {
@@ -730,8 +745,10 @@ struct nfs4_link_arg {
 struct nfs4_link_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_label *		label;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
+	struct nfs4_label *		dir_label;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -747,6 +764,7 @@ struct nfs4_lookup_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
+	struct nfs4_label *		label;
 	struct nfs4_sequence_res	seq_res;
 };
 
@@ -800,6 +818,8 @@ struct nfs4_rename_arg {
 	const struct nfs_fh *		new_dir;
 	const struct qstr *		old_name;
 	const struct qstr *		new_name;
+	const struct nfs4_label *	old_label;
+	const struct nfs4_label *	new_label;
 	const u32 *			bitmask;
 	struct nfs4_sequence_args	seq_args;
 };
@@ -808,8 +828,10 @@ struct nfs4_rename_res {
 	const struct nfs_server *	server;
 	struct nfs4_change_info		old_cinfo;
 	struct nfs_fattr *		old_fattr;
+	struct nfs4_label *		old_label;
 	struct nfs4_change_info		new_cinfo;
 	struct nfs_fattr *		new_fattr;
+	struct nfs4_label *		new_label;
 	struct nfs4_sequence_res	seq_res;
 };
 
-- 
1.6.2.5
