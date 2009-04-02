From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 08/67] nfs41: client xdr definitions
Date: Thu,  2 Apr 2009 16:51:26 +0300
Message-ID: <1238680286-13650-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:30315 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755505AbZDBNvh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:51:37 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Define stubs for sequence args and res data structures and embed
them in all other nfs4 and nfs41 xdr types.  They are needed for
sending any op in a nfs41 compound rpc.

Signed-off-by: Andy Adamson<andros@netapp.com>
[moved new args/res definitions away, to where they're first used]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 include/linux/nfs_xdr.h |   52 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 9708e78..00a0a1d 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -145,6 +145,15 @@ struct nfs4_change_info {
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
 /*
  * Arguments to the open call.
  */
@@ -165,6 +174,7 @@ struct nfs_openargs {
 	const struct nfs_server *server;	 /* Needed for ID mapping */
 	const u32 *		bitmask;
 	__u32			claim;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_openres {
@@ -181,6 +191,7 @@ struct nfs_openres {
 	__u32			do_recall;
 	__u64			maxsize;
 	__u32			attrset[NFS4_BITMAP_SIZE];
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -206,6 +217,7 @@ struct nfs_closeargs {
 	struct nfs_seqid *	seqid;
 	fmode_t			fmode;
 	const u32 *		bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_closeres {
@@ -213,6 +225,7 @@ struct nfs_closeres {
 	struct nfs_fattr *	fattr;
 	struct nfs_seqid *	seqid;
 	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
 };
 /*
  *  * Arguments to the lock,lockt, and locku call.
@@ -233,12 +246,14 @@ struct nfs_lock_args {
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
@@ -246,32 +261,38 @@ struct nfs_locku_args {
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
@@ -284,12 +305,14 @@ struct nfs_readargs {
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
@@ -304,6 +327,7 @@ struct nfs_writeargs {
 	unsigned int		pgbase;
 	struct page **		pages;
 	const u32 *		bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_writeverf {
@@ -316,6 +340,7 @@ struct nfs_writeres {
 	struct nfs_writeverf *	verf;
 	__u32			count;
 	const struct nfs_server *server;
+	struct nfs4_sequence_res	seq_res;
 };
 
 /*
@@ -325,12 +350,14 @@ struct nfs_removeargs {
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
@@ -383,6 +410,7 @@ struct nfs_setattrargs {
 	struct iattr *                  iap;
 	const struct nfs_server *	server; /* Needed for name mapping */
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs_setaclargs {
@@ -390,6 +418,7 @@ struct nfs_setaclargs {
 	size_t				acl_len;
 	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs_getaclargs {
@@ -397,11 +426,13 @@ struct nfs_getaclargs {
 	size_t				acl_len;
 	unsigned int			acl_pgbase;
 	struct page **			acl_pages;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs_setattrres {
 	struct nfs_fattr *              fattr;
 	const struct nfs_server *	server;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs_linkargs {
@@ -583,6 +614,7 @@ struct nfs4_accessargs {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
 	u32				access;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_accessres {
@@ -590,6 +622,7 @@ struct nfs4_accessres {
 	struct nfs_fattr *		fattr;
 	u32				supported;
 	u32				access;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_create_arg {
@@ -609,6 +642,7 @@ struct nfs4_create_arg {
 	const struct iattr *		attrs;
 	const struct nfs_fh *		dir_fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs4_create_res {
@@ -617,21 +651,25 @@ struct nfs4_create_res {
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		dir_cinfo;
 	struct nfs_fattr *		dir_fattr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_fsinfo_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
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
@@ -639,6 +677,7 @@ struct nfs4_link_arg {
 	const struct nfs_fh *		dir_fh;
 	const struct qstr *		name;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args 	seq_args;
 };
 
 struct nfs4_link_res {
@@ -646,6 +685,7 @@ struct nfs4_link_res {
 	struct nfs_fattr *		fattr;
 	struct nfs4_change_info		cinfo;
 	struct nfs_fattr *		dir_attr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 
@@ -653,21 +693,25 @@ struct nfs4_lookup_arg {
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
 };
 
 struct nfs4_readdir_arg {
@@ -678,11 +722,13 @@ struct nfs4_readdir_arg {
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
@@ -690,6 +736,7 @@ struct nfs4_readlink {
 	unsigned int			pgbase;
 	unsigned int			pglen;   /* zero-copy data */
 	struct page **			pages;   /* zero-copy data */
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_rename_arg {
@@ -698,6 +745,7 @@ struct nfs4_rename_arg {
 	const struct qstr *		old_name;
 	const struct qstr *		new_name;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_rename_res {
@@ -706,6 +754,7 @@ struct nfs4_rename_res {
 	struct nfs_fattr *		old_fattr;
 	struct nfs4_change_info		new_cinfo;
 	struct nfs_fattr *		new_fattr;
+	struct nfs4_sequence_res	seq_res;
 };
 
 #define NFS4_SETCLIENTID_NAMELEN	(127)
@@ -724,6 +773,7 @@ struct nfs4_setclientid {
 struct nfs4_statfs_arg {
 	const struct nfs_fh *		fh;
 	const u32 *			bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 struct nfs4_server_caps_res {
@@ -731,6 +781,7 @@ struct nfs4_server_caps_res {
 	u32				acl_bitmask;
 	u32				has_links;
 	u32				has_symlinks;
+	struct nfs4_sequence_res	seq_res;
 };
 
 struct nfs4_string {
@@ -765,6 +816,7 @@ struct nfs4_fs_locations_arg {
 	const struct qstr *name;
 	struct page *page;
 	const u32 *bitmask;
+	struct nfs4_sequence_args	seq_args;
 };
 
 #endif /* CONFIG_NFS_V4 */
-- 
1.6.2.1

