Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yw0-f46.google.com ([209.85.213.46]:43958 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755014Ab2INVYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Sep 2012 17:24:14 -0400
Received: by mail-yw0-f46.google.com with SMTP id m54so1133966yhm.19
        for <linux-nfs@vger.kernel.org>; Fri, 14 Sep 2012 14:24:13 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] NFS: Introduce "migration" mount option
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 14 Sep 2012 17:24:11 -0400
Message-ID: <20120914212411.1635.12727.stgit@degas.1015granger.net>
In-Reply-To: <20120914211053.1635.74063.stgit@degas.1015granger.net>
References: <20120914211053.1635.74063.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the Linux client uses a unique nfs_client_id4.id string
when identifying itself to distinct NFS servers.

To support transparent state migration, the Linux client will have to
use the same nfs_client_id4 string for all servers it communicates
with (also known as the "uniform client string" approach).  Otherwise
NFS servers can not recognize that open and lock state need to be
merged after a file system transition.

Unfortunately, there are some NFSv4.0 servers currently in the field
that do not tolerate the uniform client string approach.

Thus, by default, our NFSv4.0 mounts will continue to use the current
approach, and we introduce a mount option that switches them to use
the uniform model.  Client administrators must identify which servers
can be mounted with this option.  Eventually most NFSv4.0 servers will
be able to handle the uniform approach, and we can change the default.

The first mount of a server controls the behavior for all subsequent
mounts for the lifetime of that set of mounts of that server.  After
the last mount of that server is gone, the client erases the data
structure that tracks the lease.  A subsequent lease may then honor
a different "migration" setting.

This patch adds only the infrastructure for parsing the new mount
option.  Support for uniform client strings is added in a subsequent
patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c           |    2 ++
 fs/nfs/super.c            |   20 ++++++++++++++++++++
 include/linux/nfs_fs_sb.h |    2 ++
 3 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 143149d..92aed2e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -752,6 +752,8 @@ static int nfs_init_server(struct nfs_server *server,
 			data->timeo, data->retrans);
 	if (data->flags & NFS_MOUNT_NORESVPORT)
 		set_bit(NFS_CS_NORESVPORT, &cl_init.init_flags);
+	if (server->options & NFS_OPTION_MIGRATION)
+		set_bit(NFS_CS_MIGRATION, &cl_init.init_flags);
 
 	/* Allocate or find a client reference we can use */
 	clp = nfs_get_client(&cl_init, &timeparms, NULL, RPC_AUTH_UNIX);
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 239aff7..4aabf19 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -88,6 +88,7 @@ enum {
 	Opt_sharecache, Opt_nosharecache,
 	Opt_resvport, Opt_noresvport,
 	Opt_fscache, Opt_nofscache,
+	Opt_migration, Opt_nomigration,
 
 	/* Mount options that take integer arguments */
 	Opt_port,
@@ -147,6 +148,8 @@ static const match_table_t nfs_mount_option_tokens = {
 	{ Opt_noresvport, "noresvport" },
 	{ Opt_fscache, "fsc" },
 	{ Opt_nofscache, "nofsc" },
+	{ Opt_migration, "migration" },
+	{ Opt_nomigration, "nomigration" },
 
 	{ Opt_port, "port=%s" },
 	{ Opt_rsize, "rsize=%s" },
@@ -676,6 +679,9 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	if (nfss->options & NFS_OPTION_FSCACHE)
 		seq_printf(m, ",fsc");
 
+	if (nfss->options & NFS_OPTION_MIGRATION)
+		seq_printf(m, ",migration");
+
 	if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONEG) {
 		if (nfss->flags & NFS_MOUNT_LOOKUP_CACHE_NONE)
 			seq_printf(m, ",lookupcache=none");
@@ -1243,6 +1249,12 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -1535,6 +1547,10 @@ static int nfs_parse_mount_options(char *raw,
 	if (mnt->minorversion && mnt->version != 4)
 		goto out_minorversion_mismatch;
 
+	if (mnt->options & NFS_OPTION_MIGRATION &&
+	    mnt->version != 4 && mnt->minorversion != 0)
+		goto out_migration_misuse;
+
 	/*
 	 * verify that any proto=/mountproto= options match the address
 	 * familiies in the addr=/mountaddr= options.
@@ -1572,6 +1588,10 @@ out_minorversion_mismatch:
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
index 310c63c..2e22fc7 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -39,6 +39,7 @@ struct nfs_client {
 	unsigned long		cl_flags;	/* behavior switches */
 #define NFS_CS_NORESVPORT	0		/* - use ephemeral src port */
 #define NFS_CS_DISCRTRY		1		/* - disconnect on RPC retry */
+#define NFS_CS_MIGRATION	2		/* - transparent state migr */
 	struct sockaddr_storage	cl_addr;	/* server identifier */
 	size_t			cl_addrlen;
 	char *			cl_hostname;	/* hostname of server */
@@ -125,6 +126,7 @@ struct nfs_server {
 	unsigned int		namelen;
 	unsigned int		options;	/* extra options enabled by mount */
 #define NFS_OPTION_FSCACHE	0x00000001	/* - local caching enabled */
+#define NFS_OPTION_MIGRATION	0x00000002	/* - NFSv4 migration enabled */
 
 	struct nfs_fsid		fsid;
 	__u64			maxfilesize;	/* maximum file size */

