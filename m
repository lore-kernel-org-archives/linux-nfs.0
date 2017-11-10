Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f49.google.com ([209.85.214.49]:55069 "EHLO
        mail-it0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754707AbdKJWhh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:37 -0500
Received: by mail-it0-f49.google.com with SMTP id 72so3398699itk.3
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:37 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 5/7] NFS: Add serverfailed mount option
Date: Fri, 10 Nov 2017 16:37:05 -0600
Message-Id: <20171110223707.17098-6-JPEWhacker@gmail.com>
In-Reply-To: <20171110223707.17098-1-JPEWhacker@gmail.com>
References: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Specifying the serverfailed mount option causes all subsequent RPC tasks
that are queued to fail with -EIO instead of timing out. For example, if
a server has disappeared, the sequence:

 mount -o remount,serverfailed
 umount -f

will ensure that all pending I/O requests are cancelled, and any new
requests will also fail. In the event that the server returns, the flag
can be removed with a remount:

 mount -o remount,noserverfailed

Although bringing the server back may result in a loss of data

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/inode.c                 |  6 ++++++
 fs/nfs/super.c                 | 30 +++++++++++++++++++++++++-----
 include/uapi/linux/nfs_mount.h |  1 +
 3 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 134d9f560240..55b7cd40508d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -723,6 +723,12 @@ static void nfs_readdirplus_parent_cache_hit(struct dentry *dentry)
 
 static bool nfs_need_revalidate_inode(struct inode *inode)
 {
+	/* If the server has failed, it is not going to respond, so don't try
+	 * and revalidated (otherwise, the serverfailed flag can't be cleared by
+	 * a remount)
+	 */
+	if (NFS_SERVER(inode)->flags & NFS_MOUNT_SERVERFAILED)
+		return false;
 	if (NFS_I(inode)->cache_validity &
 			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
 		return true;
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 777a0cc22704..bca38e1cdd85 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -90,6 +90,7 @@ enum {
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
+	Opt_serverfailed, Opt_noserverfailed,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_nofscache, "nofsc" },
 	{ Opt_migration, "migration" },
 	{ Opt_nomigration, "nomigration" },
+	{ Opt_serverfailed, "serverfailed" },
+	{ Opt_noserverfailed, "noserverfailed" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
+		{ NFS_MOUNT_SERVERFAILED, ",serverfailed", "" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -1330,6 +1334,11 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nomigration:
 			mnt->options &= ~NFS_OPTION_MIGRATION;
 			break;
+		case Opt_serverfailed:
+		case Opt_noserverfailed:
+			set_flag(mnt, NFS_MOUNT_SERVERFAILED,
+				 token == Opt_serverfailed);
+			break;
 
 		/*
 		 * options that take numeric values
@@ -2192,6 +2201,8 @@ static int nfs_validate_text_mount_data(void *options,
 	return -EINVAL;
 }
 
+#define NFS_REMOUNT_CHANGE_FLAGS (NFS_MOUNT_SERVERFAILED)
+
 #define NFS_REMOUNT_CMP_FLAGMASK ~(NFS_MOUNT_INTR \
 		| NFS_MOUNT_SECURE \
 		| NFS_MOUNT_TCP \
@@ -2200,7 +2211,8 @@ static int nfs_validate_text_mount_data(void *options,
 		| NFS_MOUNT_NONLM \
 		| NFS_MOUNT_BROKEN_SUID \
 		| NFS_MOUNT_STRICTLOCK \
-		| NFS_MOUNT_LEGACY_INTERFACE)
+		| NFS_MOUNT_LEGACY_INTERFACE \
+		| NFS_REMOUNT_CHANGE_FLAGS)
 
 #define NFS_MOUNT_CMP_FLAGMASK (NFS_REMOUNT_CMP_FLAGMASK & \
 		~(NFS_MOUNT_UNSHARED | NFS_MOUNT_NORESVPORT))
@@ -2209,12 +2221,15 @@ static int
 nfs_compare_and_set_remount_data(struct nfs_server *nfss,
 				 struct nfs_parsed_mount_data *data)
 {
+	int changed_flags_mask = data->flags_mask & NFS_REMOUNT_CHANGE_FLAGS;
+	struct rpc_clnt *cl = nfss->client;
+
 	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
 	    data->rsize != nfss->rsize ||
 	    data->wsize != nfss->wsize ||
 	    data->version != nfss->nfs_client->rpc_ops->version ||
 	    data->minorversion != nfss->nfs_client->cl_minorversion ||
-	    !nfs_auth_info_match(&data->auth_info, nfss->client->cl_auth->au_flavor) ||
+	    !nfs_auth_info_match(&data->auth_info, cl->cl_auth->au_flavor) ||
 	    data->acregmin != nfss->acregmin / HZ ||
 	    data->acregmax != nfss->acregmax / HZ ||
 	    data->acdirmin != nfss->acdirmin / HZ ||
@@ -2225,13 +2240,16 @@ nfs_compare_and_set_remount_data(struct nfs_server *nfss,
 			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
 		return -EINVAL;
 
-	if (data->retrans != nfss->client->cl_timeout->to_retries ||
-	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ)) {
+	/* Update flags */
+	nfss->flags = (nfss->flags & ~changed_flags_mask) |
+		(data->flags & changed_flags_mask);
+
+	if (data->retrans != cl->cl_timeout->to_retries ||
+	    data->timeo != (10U * cl->cl_timeout->to_initval / HZ)) {
 		/* Note that this will affect all mounts from the same server,
 		 * that use the same protocol.  The timeouts are always forced
 		 * to be the same.
 		 */
-		struct rpc_clnt *cl = nfss->client;
 		if (cl->cl_timeout != &cl->cl_timeout_default)
 			memcpy(&cl->cl_timeout_default, cl->cl_timeout,
 			       sizeof(struct rpc_timeout));
@@ -2239,6 +2257,8 @@ nfs_compare_and_set_remount_data(struct nfs_server *nfss,
 		cl->cl_timeout_default.to_initval = data->timeo * HZ / 10U;
 	}
 
+	cl->cl_kill_new_tasks = !!(nfss->flags & NFS_MOUNT_SERVERFAILED);
+
 	return 0;
 }
 
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index e44e00616ab5..8ad931cdca20 100644
--- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -74,5 +74,6 @@ struct nfs_mount_data {
 
 #define NFS_MOUNT_LOCAL_FLOCK	0x100000
 #define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_SERVERFAILED	0x400000
 
 #endif
-- 
2.13.6

