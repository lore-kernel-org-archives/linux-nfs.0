Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail209.messagelabs.com ([216.82.255.3]:32803 "EHLO
	mail209.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756076Ab1IBVjl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Sep 2011 17:39:41 -0400
From: H Hartley Sweeten <hartleys@visionengravers.com>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Subject: [PATCH] nfs/super.c: local functions should be static
Date: Fri, 2 Sep 2011 14:39:12 -0700
CC: <linux-nfs@vger.kernel.org>, <Trond.Myklebust@netapp.com>
Content-Type: text/plain; charset="utf-8"
Message-ID: <201109021439.13146.hartleys@visionengravers.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

commit ae50c0b5 "pnfs: client stats" added additional information to
the output of /proc/self/mountstats. The new functions introduced are
only used in this file and should be marked static.

If CONFIG_NFS_V4_1 is not defined, empty stub functions are used.  If
CONFIG_NFS_V4 is not defined these stub functions are not used at all.
Adding static for the functions results in compile warnings:

fs/nfs/super.c:743: warning: 'show_sessions' defined but not used
fs/nfs/super.c:756: warning: 'show_pnfs' defined but not used

Fix this by adding a #ifdef CONFIG_NFS_V4 guard around the two
show_ functions.

Signed-off-by: H Hartley Sweeten <hsweeten@visionengravers.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>

---

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b961cea..4b07e9b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -733,18 +733,22 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 
 	return 0;
 }
+
+#ifdef CONFIG_NFS_V4
 #ifdef CONFIG_NFS_V4_1
-void show_sessions(struct seq_file *m, struct nfs_server *server)
+static void show_sessions(struct seq_file *m, struct nfs_server *server)
 {
 	if (nfs4_has_session(server->nfs_client))
 		seq_printf(m, ",sessions");
 }
 #else
-void show_sessions(struct seq_file *m, struct nfs_server *server) {}
+static void show_sessions(struct seq_file *m, struct nfs_server *server) {}
+#endif
 #endif
 
+#ifdef CONFIG_NFS_V4
 #ifdef CONFIG_NFS_V4_1
-void show_pnfs(struct seq_file *m, struct nfs_server *server)
+static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
 	seq_printf(m, ",pnfs=");
 	if (server->pnfs_curr_ld)
@@ -752,9 +756,10 @@ void show_pnfs(struct seq_file *m, struct nfs_server *server)
 	else
 		seq_printf(m, "not configured");
 }
-#else  /* CONFIG_NFS_V4_1 */
-void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
-#endif /* CONFIG_NFS_V4_1 */
+#else
+static void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
+#endif
+#endif
 
 static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
 {
