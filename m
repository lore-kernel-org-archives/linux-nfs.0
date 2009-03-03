From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 08/46] nfs41: client xdr definitions
Date: Wed,  4 Mar 2009 01:53:03 +0200
Message-ID: <1236124383-3193-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17405
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752996AbZCCXxR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:53:17 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define stubs for sequence args and res data structures and embed
them in all other nfs4 and nfs41 xdr types.  They are needed for
sending any op in a nfs41 compound rpc.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_xdr.h |   99 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 99 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index a550b52..c137ca0 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -113,6 +113,24 @@ struct nfs4_change_info {
 };
 
 struct nfs_seqid;
+
+struct nfs4_sequence_args {
+	/* stub */
+};
+
+struct nfs4_sequence_res {
+	/* stub */
+};
+
+struct nfs4_get_lease_time_args {
+	struct nfs4_sequence_args	la_seq_args;
+};
+
+struct nfs4_get_lease_time_res {
+	struct nfs_fsinfo	       *lr_fsinfo;
+	struct nfs4_sequence_res	lr_seq_res;
+};
+
 /*
  * Arguments to the open call.
  */
@@ -133,6 +151,7 @@ struct nfs_openargs {
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_openres {
@@ -149,6 +168,7 @@ struct nfs_openres {
 	__u32			do_recall;
 	__u64			maxsize;
 	__u32			attrset[NFS4_BITMAP_SIZE];
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -174,6 +194,7 @@ struct nfs_closeargs {
 	struct nfs_seqid *	seqid;
 	fmode_t			fmode;
 	const u32 *		bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_closeres {
@@ -181,6 +202,7 @@ struct nfs_closeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
 };
 /*
  *  * Arguments to the lock,lockt, and locku call.
@@ -201,12 +223,14 @@ struct nfs_lock_args {
 	unsigned char		block : 1;
 	unsigned char		reclaim : 1;
 	unsigned char		new_lock_owner : 1;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_lock_res {
 	nfs4_stateid		stateid;
 	struct nfs_seqid *	lock_seqid;
 	struct nfs_seqid *	open_seqid;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_locku_args {
@@ -214,32 +238,38 @@ struct nfs_locku_args {
 	struct file_lock *	fl;
 	struct nfs_seqid *	seqid;
 	nfs4_stateid *		stateid;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_locku_res {
 	nfs4_stateid		stateid;
 	struct nfs_seqid *	seqid;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_lockt_args {
 	struct nfs_fh *		fh;
 	struct file_lock *	fl;
 	struct nfs_lowner	lock_owner;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_lockt_res {
 	struct file_lock *	denied; /* LOCK, LOCKT failed */
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_delegreturnargs {
 	const struct nfs_fh *fhandle;
 	const nfs4_stateid *stateid;
 	const u32 * bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_delegreturnres {
 	struct nfs_fattr * fattr;
 	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -252,12 +282,14 @@ struct nfs_readargs {
 	__u32			count;
 	unsigned int		pgbase;
 	struct page **		pages;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_readres {
 	struct nfs_fattr *	fattr;
 	__u32			count;
 	int                     eof;
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -272,6 +304,7 @@ struct nfs_writeargs {
 	unsigned int		pgbase;
 	struct page **		pages;
 	const u32 *		bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_writeverf {
@@ -284,6 +317,7 @@ struct nfs_writeres {
 	struct nfs_writeverf *	verf;
 	__u32			count;
 	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -293,12 +327,14 @@ struct nfs_removeargs {
 	const struct nfs_fh	*fh;
 	struct qstr		name;
 	const u32 *		bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_removeres {
 	const struct nfs_server *server;
 	struct nfs4_change_info	cinfo;
 	struct nfs_fattr	dir_attr;
+	struct nfs4_sequence_res 	seq_res;
 };
 
 /*
@@ -351,6 +387,7 @@ struct nfs_setattrargs {
 	struct iattr *                  iap;
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs_setaclargs {
@@ -358,6 +395,11 @@ struct nfs_setaclargs {
 	size_t				acl_len;
 	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs_setaclres {
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_getaclargs {
@@ -365,11 +407,18 @@ struct nfs_getaclargs {
 	size_t				acl_len;
 	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
+	struct nfs4_sequence_args 	seq_args;
+};
+
+struct nfs_getaclres {
+	size_t				*acl_len;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
 	const struct nfs_server *	server;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_linkargs {
@@ -549,6 +598,7 @@ struct nfs4_accessargs {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
 	u32				access;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_accessres {
@@ -556,6 +606,7 @@ struct nfs4_accessres {
 	struct nfs_fattr *		fattr;
 	u32				supported;
 	u32				access;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_create_arg {
@@ -575,6 +626,7 @@ struct nfs4_create_arg {
 	const struct iattr *		attrs;
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs4_create_res {
@@ -583,21 +635,30 @@ struct nfs4_create_res {
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
 	struct nfs_fattr *		dir_fattr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_fsinfo_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_fsinfo_res {
+	struct nfs_fsinfo	       *fsinfo;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_getattr_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_getattr_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_link_arg {
@@ -605,6 +666,7 @@ struct nfs4_link_arg {
 	const struct nfs_fh *		dir_fh;
 	const struct qstr *		name;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs4_link_res {
@@ -612,6 +674,7 @@ struct nfs4_link_res {
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 
@@ -619,21 +682,30 @@ struct nfs4_lookup_arg {
 	const struct nfs_fh *		dir_fh;
 	const struct qstr *		name;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_lookup_res {
 	const struct nfs_server *	server;
 	struct nfs_fattr *		fattr;
 	struct nfs_fh *			fh;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_lookup_root_arg {
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_pathconf_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_pathconf_res {
+	struct nfs_pathconf	       *pathconf;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_readdir_arg {
@@ -644,11 +716,13 @@ struct nfs4_readdir_arg {
 	struct page **			pages;	/* zero-copy data */
 	unsigned int			pgbase;	/* zero-copy data */
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_readdir_res {
 	nfs4_verifier			verifier;
 	unsigned int			pgbase;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_readlink {
@@ -656,6 +730,11 @@ struct nfs4_readlink {
 	unsigned int			pgbase;
 	unsigned int			pglen;   /* zero-copy data */
 	struct page **			pages;   /* zero-copy data */
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_readlink_res {
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_rename_arg {
@@ -664,6 +743,7 @@ struct nfs4_rename_arg {
 	const struct qstr *		old_name;
 	const struct qstr *		new_name;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_rename_res {
@@ -672,6 +752,7 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		old_fattr;
 	struct nfs4_change_info		new_cinfo;
 	struct nfs_fattr *		new_fattr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 #define NFS4_SETCLIENTID_NAMELEN	(127)
@@ -690,6 +771,17 @@ struct nfs4_setclientid {
 struct nfs4_statfs_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_statfs_res {
+	struct nfs_fsstat	       *fsstat;
+	struct nfs4_sequence_res	seq_res;
+};
+
+struct nfs4_server_caps_arg {
+	struct nfs_fh		       *fhandle;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_server_caps_res {
@@ -697,6 +789,7 @@ struct nfs4_server_caps_res {
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_string {
@@ -731,6 +824,12 @@ struct nfs4_fs_locations_arg {
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
+	struct nfs4_sequence_args	seq_args;
+};
+
+struct nfs4_fs_locations_res {
+	struct nfs4_fs_locations       *fs_locations;
+	struct nfs4_sequence_res	seq_res;
 };
 
 #endif /* CONFIG_NFS_V4 */
-- 
1.6.1.3

