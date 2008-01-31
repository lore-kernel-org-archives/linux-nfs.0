From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/5] NFS: numeric mount parameters are unsigned
Date: Thu, 31 Jan 2008 15:00:20 -0500
Message-ID: <20080131200020.17975.38446.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: miklos@szeredi.hu, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:52794 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755940AbYAaUAb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Jan 2008 15:00:31 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: use %u instead of %d when displaying NFS mount options.

Nit: Fix reporting of "namlen=" option in nfs_show_mount_stats.  The mount
option is called "namlen" without the "e".

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 22c49c0..93ce01f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -460,17 +460,17 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	const struct proc_nfs_info *nfs_infop;
 	struct nfs_client *clp = nfss->nfs_client;
 
-	seq_printf(m, ",vers=%d", clp->rpc_ops->version);
-	seq_printf(m, ",rsize=%d", nfss->rsize);
-	seq_printf(m, ",wsize=%d", nfss->wsize);
+	seq_printf(m, ",vers=%u", clp->rpc_ops->version);
+	seq_printf(m, ",rsize=%u", nfss->rsize);
+	seq_printf(m, ",wsize=%u", nfss->wsize);
 	if (nfss->acregmin != 3*HZ || showdefaults)
-		seq_printf(m, ",acregmin=%d", nfss->acregmin/HZ);
+		seq_printf(m, ",acregmin=%u", nfss->acregmin/HZ);
 	if (nfss->acregmax != 60*HZ || showdefaults)
-		seq_printf(m, ",acregmax=%d", nfss->acregmax/HZ);
+		seq_printf(m, ",acregmax=%u", nfss->acregmax/HZ);
 	if (nfss->acdirmin != 30*HZ || showdefaults)
-		seq_printf(m, ",acdirmin=%d", nfss->acdirmin/HZ);
+		seq_printf(m, ",acdirmin=%u", nfss->acdirmin/HZ);
 	if (nfss->acdirmax != 60*HZ || showdefaults)
-		seq_printf(m, ",acdirmax=%d", nfss->acdirmax/HZ);
+		seq_printf(m, ",acdirmax=%u", nfss->acdirmax/HZ);
 	for (nfs_infop = nfs_info; nfs_infop->flag; nfs_infop++) {
 		if (nfss->flags & nfs_infop->flag)
 			seq_puts(m, nfs_infop->str);
@@ -526,10 +526,10 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 
 	seq_printf(m, "\n\tcaps:\t");
 	seq_printf(m, "caps=0x%x", nfss->caps);
-	seq_printf(m, ",wtmult=%d", nfss->wtmult);
-	seq_printf(m, ",dtsize=%d", nfss->dtsize);
-	seq_printf(m, ",bsize=%d", nfss->bsize);
-	seq_printf(m, ",namelen=%d", nfss->namelen);
+	seq_printf(m, ",wtmult=%u", nfss->wtmult);
+	seq_printf(m, ",dtsize=%u", nfss->dtsize);
+	seq_printf(m, ",bsize=%u", nfss->bsize);
+	seq_printf(m, ",namlen=%u", nfss->namelen);
 
 #ifdef CONFIG_NFS_V4
 	if (nfss->nfs_client->rpc_ops->version == 4) {
@@ -543,9 +543,9 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 	/*
 	 * Display security flavor in effect for this mount
 	 */
-	seq_printf(m, "\n\tsec:\tflavor=%d", auth->au_ops->au_flavor);
+	seq_printf(m, "\n\tsec:\tflavor=%u", auth->au_ops->au_flavor);
 	if (auth->au_flavor)
-		seq_printf(m, ",pseudoflavor=%d", auth->au_flavor);
+		seq_printf(m, ",pseudoflavor=%u", auth->au_flavor);
 
 	/*
 	 * Display superblock I/O counters

