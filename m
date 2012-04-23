Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43242 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755172Ab2DWUz1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Apr 2012 16:55:27 -0400
Received: by mail-iy0-f174.google.com with SMTP id i9so2498807iad.19
        for <linux-nfs@vger.kernel.org>; Mon, 23 Apr 2012 13:55:26 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/20] NFS: Introduce "migration" mount option
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 23 Apr 2012 16:55:25 -0400
Message-ID: <20120423205524.11446.95524.stgit@degas.1015granger.net>
In-Reply-To: <20120423205312.11446.67081.stgit@degas.1015granger.net>
References: <20120423205312.11446.67081.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the Linux client uses a unique nfs_client_id4 string
when identifying itself to unique NFS servers.

To support Transparent State Migration, the Linux client will have
to use the same nfs_client_id4 string for all servers it communicates
with (also known as the "uniform client string" model).  Otherwise
NFS servers will not be able to merge NFSv4 state appropriately after
a migration event.

Unfortunately, there are some server features now in the field that
are not compatible with the uniform client string model.

So, by default, our NFSv4.0 mounts will continue to use the current
model, and we will add a mount option that switches them to use
the uniform model.  Client administrators will have to identify
which servers can be mounted with this option in effect.

The first mount of a server controls the behavior for all subsequent
mounts until the client reboots.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/client.c           |    2 ++
 fs/nfs/super.c            |   20 ++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    2 ++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 76dec6a..07b106e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1431,6 +1431,8 @@ static int nfs4_set_client(struct nfs_server *server,
 
 	if (server->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+	if (server->options & NFS_OPTION_MIGRATION)
+		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init, timeparms, ip_addr, authflavour);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 6decf3c..c169dc3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -86,6 +86,7 @@ enum {
 	Opt_sharecache, Opt_nosharecache,
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
+	Opt_migration, Opt_nomigration,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -145,6 +146,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_noresvport, "noresvport" },
 	{ Opt_fscache, "fsc" },
 	{ Opt_nofscache, "nofsc" },
+	{ Opt_migration, "migration" },
+	{ Opt_nomigration, "nomigration" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -724,6 +727,9 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	if (nfss->options & NFS_OPTION_FSCACHE)
 		seq_printf(m, ",fsc");
 
+	if (nfss->options & NFS_OPTION_MIGRATION)
+		seq_printf(m, ",migration");
+
 	if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG) {
 		if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
 			seq_printf(m, ",lookupcache=none");
@@ -1286,6 +1292,12 @@ static int nfs_parse_mount_options(char *raw,
 			kfree(mnt->fscache_uniq);
 			mnt->fscache_uniq = NULL;
 			break;
+		case Opt_migration:
+			mnt->options |= NFS_OPTION_MIGRATION;
+			break;
+		case Opt_nomigration:
+			mnt->options &= NFS_OPTION_MIGRATION;
+			break;
 
 		/*
 		 * options that take numeric values
@@ -1578,6 +1590,10 @@ static int nfs_parse_mount_options(char *raw,
 	if (mnt->minorversion && mnt->version != 4)
 		goto out_minorversion_mismatch;
 
+	if (mnt->options & NFS_OPTION_MIGRATION &&
+	    mnt->version != 4 && mnt->minorversion != 0)
+		goto out_migration_misuse;
+
 	/*
 	 * verify that any proto=/mountproto= options match the address
 	 * familiies in the addr=/mountaddr= options.
@@ -1615,6 +1631,10 @@ out_minorversion_mismatch:
 	printk(KERN_INFO "NFS: mount option vers=%u does not support "
 			 "minorversion=%u\n", mnt->version, mnt->minorversion);
 	return 0;
+out_migration_misuse:
+	printk(KERN_INFO
+		"NFS: 'migration' not supported for this NFS version\n");
+	return 0;
 out_nomem:
 	printk(KERN_INFO "NFS: not enough memory to parse option\n");
 	return 0;
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 6f7a93c..1a5a4cc 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -38,6 +38,7 @@ struct nfs_client {
 	unsigned long		cl_flags;	/* behavior switches */
 #define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
+#define NFS_CS_MIGRATION	2		/* - transparent state migr */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
@@ -122,6 +123,7 @@ struct nfs_server {
 	unsigned int		namelen;
 	unsigned int		options;	/* extra options enabled by mount */
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
+#define NFS_OPTION_MIGRATION	0x00000002	/* - NFSv4 migration enabled */
 
 	struct nfs_fsid		fsid;
 	__u64			maxfilesize;	/* maximum file size */

