Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:49510 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752627AbdKHPAX (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 10:00:23 -0500
Received: by mail-it0-f66.google.com with SMTP id y15so7128915ita.4
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 07:00:22 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC 4/4] NFS: Add forcekill mount option
Date: Wed,  8 Nov 2017 08:59:42 -0600
Message-Id: <20171108145942.5127-5-JPEWhacker@gmail.com>
In-Reply-To: <20171108145942.5127-1-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
 <20171108145942.5127-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Specifying the forcekill mount option causes umount() with the MNT_FORCE
flag to not only kill all currently pending RPC tasks with -EIO, but
also all future RPC tasks. This prevents the long delays caused by tasks
queuing after rpc_killall_tasks() that can occur if the server drops off
the network.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/super.c                 | 17 ++++++++++++++---
 include/uapi/linux/nfs_mount.h |  1 +
 2 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 66fda2dcadd0..d972f6289aca 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -90,6 +90,7 @@ enum {
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
 	Opt_migration, Opt_nomigration,
+	Opt_forcekill, Opt_noforcekill,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -151,6 +152,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_nofscache, "nofsc" },
 	{ Opt_migration, "migration" },
 	{ Opt_nomigration, "nomigration" },
+	{ Opt_forcekill, "forcekill" },
+	{ Opt_noforcekill, "noforcekill" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -637,6 +640,7 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 		{ NFS_MOUNT_NORDIRPLUS, ",nordirplus", "" },
 		{ NFS_MOUNT_UNSHARED, ",nosharecache", "" },
 		{ NFS_MOUNT_NORESVPORT, ",noresvport", "" },
+		{ NFS_MOUNT_FORCEKILL, ",forcekill", ",noforcekill" },
 		{ 0, NULL, NULL }
 	};
 	const struct proc_nfs_info *nfs_infop;
@@ -896,17 +900,18 @@ EXPORT_SYMBOL_GPL(nfs_show_stats);
  */
 void nfs_umount_begin(struct super_block *sb)
 {
-	struct nfs_server *server;
+	struct nfs_server *server = NFS_SB(sb);
 	struct rpc_clnt *rpc;
+	int kill_new_tasks = !!(server->flags & NFS_MOUNT_FORCEKILL);
 
 	server = NFS_SB(sb);
 	/* -EIO all pending I/O */
 	rpc = server->client_acl;
 	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc, 0);
+		rpc_killall_tasks(rpc, kill_new_tasks);
 	rpc = server->client;
 	if (!IS_ERR(rpc))
-		rpc_killall_tasks(rpc, 0);
+		rpc_killall_tasks(rpc, kill_new_tasks);
 }
 EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
@@ -1334,6 +1339,12 @@ static int nfs_parse_mount_options(char *raw,
 		case Opt_nomigration:
 			mnt->options &= ~NFS_OPTION_MIGRATION;
 			break;
+		case Opt_forcekill:
+			mnt->flags |= NFS_MOUNT_FORCEKILL;
+			break;
+		case Opt_noforcekill:
+			mnt->flags &= ~NFS_MOUNT_FORCEKILL;
+			break;
 
 		/*
 		 * options that take numeric values
diff --git a/include/uapi/linux/nfs_mount.h b/include/uapi/linux/nfs_mount.h
index e44e00616ab5..66821542a38f 100644
--- a/include/uapi/linux/nfs_mount.h
+++ b/include/uapi/linux/nfs_mount.h
@@ -74,5 +74,6 @@ struct nfs_mount_data {
 
 #define NFS_MOUNT_LOCAL_FLOCK	0x100000
 #define NFS_MOUNT_LOCAL_FCNTL	0x200000
+#define NFS_MOUNT_FORCEKILL	0x400000
 
 #endif
-- 
2.13.6

