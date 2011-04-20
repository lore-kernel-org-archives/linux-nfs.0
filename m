Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:57162 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752671Ab1DTR16 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 13:27:58 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC 13/27] pnfs: client stats
Date: Wed, 20 Apr 2011 20:27:55 +0300
Message-Id: <1303320475-21448-1-git-send-email-bhalevy@panasas.com>
In-Reply-To: <4DAF0DE1.6020609@panasas.com>
References: <4DAF0DE1.6020609@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@fieldses.org>

A pNFS client auto-negotiates a lot of features (minorversion level,
pNFS layout type, etc.).  This is convenient, but makes certain kinds of
failures hard for a user to detect.

For example, if the client falls back on 4.0, or falls back to MDS IO
because the user didn't connect to the right iscsi disks before
mounting, the only symptoms may be reduced performance, which may not be
noticed till long after the actual failure, and may be difficult for a
user to diagnose.

However, such "failures" may also be perfectly normal in some cases, so
we don't want to spam the system logs with them.

One approach would be to put some more information into
/proc/self/mountstats.

Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[pnfs: add commit client stats]
[fixup data types for "ret" variables in pnfs_try_to* inline funcs.]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[fix definition of show_pnfs for !CONFIG_PNFS]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
[nfs41: Fix show_sessions in the not CONFIG_NFS_V4_1 case]
    There is a build error when CONFIG_NFS_V4 is set but
    CONFIG_NFS_V4_1 is *not* set. show_sessions() prototype
    was unbalanced between the two cases.
Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
[pnfs: super.c remove CONFIG_PNFS]
Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/super.c |   25 +++++++++++++++++++++++++
 1 files changed, 25 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2b8e9a5..50f3987 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -63,6 +63,7 @@
 #include "iostat.h"
 #include "internal.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_VFS
 
@@ -732,6 +733,28 @@ static int nfs_show_options(struct seq_file *m, struct vfsmount *mnt)
 
 	return 0;
 }
+#ifdef CONFIG_NFS_V4_1
+void show_sessions(struct seq_file *m, struct nfs_server *server)
+{
+	if (nfs4_has_session(server->nfs_client))
+		seq_printf(m, ",sessions");
+}
+#else
+void show_sessions(struct seq_file *m, struct nfs_server *server) {}
+#endif
+
+#ifdef CONFIG_NFS_V4_1
+void show_pnfs(struct seq_file *m, struct nfs_server *server)
+{
+	seq_printf(m, ",pnfs=");
+	if (server->pnfs_curr_ld)
+		seq_printf(m, "%s", server->pnfs_curr_ld->name);
+	else
+		seq_printf(m, "not configured");
+}
+#else  /* CONFIG_NFS_V4_1 */
+void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
+#endif /* CONFIG_NFS_V4_1 */
 
 static int nfs_show_devname(struct seq_file *m, struct vfsmount *mnt)
 {
@@ -792,6 +815,8 @@ static int nfs_show_stats(struct seq_file *m, struct vfsmount *mnt)
 		seq_printf(m, "bm0=0x%x", nfss->attr_bitmask[0]);
 		seq_printf(m, ",bm1=0x%x", nfss->attr_bitmask[1]);
 		seq_printf(m, ",acl=0x%x", nfss->acl_bitmask);
+		show_sessions(m, nfss);
+		show_pnfs(m, nfss);
 	}
 #endif
 
-- 
1.7.3.4

