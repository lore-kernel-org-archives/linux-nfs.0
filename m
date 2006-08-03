From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 2/4] Add /proc/sys/fs/nfs sysctls to nfs module
Date: Thu, 3 Aug 2006 13:05:38 +0200
Message-ID: <20060803110538.GA17168@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G8b1I-0007da-Tq
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:40 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G8b1I-0001dW-Qd
	for nfs@lists.sourceforge.net; Thu, 03 Aug 2006 04:05:41 -0700
Received: from Relay2.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 2FB9AFE7F
	for <nfs@lists.sourceforge.net>; Thu,  3 Aug 2006 13:05:38 +0200 (CEST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: okir@suse.de
Subject: Add /proc/sys/fs/nfs sysctls to nfs module

This patch adds the plumbing for adding nfs-specific sysctls to
fs/nfs, and makes nfs_max_readahead tunable as suggested.

Signed-off-by: okir@suse.de

 fs/nfs/inode.c |   48 +++++++++++++++++++++++++++++++++++++++++-------
 1 files changed, 41 insertions(+), 7 deletions(-)

Index: linux-2.6.18/fs/nfs/inode.c
===================================================================
--- linux-2.6.18.orig/fs/nfs/inode.c
+++ linux-2.6.18/fs/nfs/inode.c
@@ -33,6 +33,7 @@
 #include <linux/lockd/bind.h>
 #include <linux/smp_lock.h>
 #include <linux/seq_file.h>
+#include <linux/sysctl.h>
 #include <linux/mount.h>
 #include <linux/nfs_idmap.h>
 #include <linux/vfs.h>
@@ -48,13 +49,15 @@
 #define NFSDBG_FACILITY		NFSDBG_VFS
 #define NFS_PARANOIA 1
 
-/* Maximum number of readahead requests
- * FIXME: this should really be a sysctl so that users may tune it to suit
- *        their needs. People that do NFS over a slow network, might for
- *        instance want to reduce it to something closer to 1 for improved
- *        interactive response.
+/* Maximum number of readahead requests.
+ *
+ * People who do NFS over a slow network may want to reduce it to
+ * something closer to 1 for improved interactive response.
  */
-#define NFS_MAX_READAHEAD	(RPC_DEF_SLOT_TABLE - 1)
+static unsigned int	nfs_max_readahead = RPC_DEF_SLOT_TABLE - 1;
+static unsigned int	nfs_max_readahead_min = 0;
+static unsigned int	nfs_max_readahead_max = RPC_MAX_SLOT_TABLE - 1;
+
 
 static void nfs_invalidate_inode(struct inode *);
 static int nfs_update_inode(struct inode *, struct nfs_fattr *);
@@ -341,7 +344,7 @@ nfs_sb_init(struct super_block *sb, rpc_
 		server->acdirmin = server->acdirmax = 0;
 		sb->s_flags |= MS_SYNCHRONOUS;
 	}
-	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
+	server->backing_dev_info.ra_pages = server->rpages * nfs_max_readahead;
 
 	sb->s_maxbytes = fsinfo.maxfilesize;
 	if (sb->s_maxbytes > MAX_LFS_FILESIZE) 
@@ -2289,12 +2292,35 @@ static void nfs_destroy_inodecache(void)
 }
 
 /*
+ * NFS sysctls
+ */
+static struct ctl_table_header *nfs_sysctl_table;
+
+static ctl_table nfs_sysctls[] = {
+	{
+		.ctl_name	= -2,
+		.procname	= "nfs_max_readahead",
+		.data		= &nfs_max_readahead,
+		.maxlen		= sizeof(unsigned int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.strategy	= &sysctl_intvec,
+		.extra1		= &nfs_max_readahead_min,
+		.extra2		= &nfs_max_readahead_max
+	},
+	{ .ctl_name = 0 }
+};
+
+/*
  * Initialize NFS
  */
 static int __init init_nfs_fs(void)
 {
+	struct ctl_path ctl_path[] = { { CTL_FS, "fs", 0555 }, { -2, "nfs", 0555 }, { 0 } };
 	int err;
 
+	nfs_sysctl_table = register_sysctl_table_path(nfs_sysctls, ctl_path);
+
 	err = nfs_init_nfspagecache();
 	if (err)
 		goto out4;
@@ -2342,6 +2368,10 @@ out2:
 out3:
 	nfs_destroy_nfspagecache();
 out4:
+	if (nfs_sysctl_table)
+		unregister_sysctl_table(nfs_sysctl_table);
+	nfs_sysctl_table = NULL;
+
 	return err;
 }
 
@@ -2359,6 +2389,10 @@ static void __exit exit_nfs_fs(void)
 #endif
 	unregister_filesystem(&nfs_fs_type);
 	unregister_nfs4fs();
+
+	if (nfs_sysctl_table)
+		unregister_sysctl_table(nfs_sysctl_table);
+	nfs_sysctl_table = NULL;
 }
 
 /* Not quite true; I just maintain it */

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
