From: andros@netapp.com
Subject: [PATCH 11/13] SQUASHME pnfs_submit: remove layout_name
Date: Wed, 28 Apr 2010 18:24:23 -0400
Message-ID: <1272493465-3398-12-git-send-email-andros@netapp.com>
References: <1272493465-3398-1-git-send-email-andros@netapp.com>
 <1272493465-3398-2-git-send-email-andros@netapp.com>
 <1272493465-3398-3-git-send-email-andros@netapp.com>
 <1272493465-3398-4-git-send-email-andros@netapp.com>
 <1272493465-3398-5-git-send-email-andros@netapp.com>
 <1272493465-3398-6-git-send-email-andros@netapp.com>
 <1272493465-3398-7-git-send-email-andros@netapp.com>
 <1272493465-3398-8-git-send-email-andros@netapp.com>
 <1272493465-3398-9-git-send-email-andros@netapp.com>
 <1272493465-3398-10-git-send-email-andros@netapp.com>
 <1272493465-3398-11-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30259 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932242Ab0D1VYh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 28 Apr 2010 17:24:37 -0400
In-Reply-To: <1272493465-3398-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use the pnfs_curr_ld name field.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/super.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7cec8e5..8366ad9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -662,29 +662,13 @@ void show_sessions(struct seq_file *m, struct nfs_server *server) {}
 #endif
 
 #ifdef CONFIG_NFS_V4_1
-char *layout_name(u32 layouttype)
-{
-	switch (layouttype) {
-	case LAYOUT_NFSV4_FILES:
-		return "files";
-	case LAYOUT_OSD2_OBJECTS:
-		return "objects";
-	case LAYOUT_BLOCK_VOLUME:
-		return "blocks";
-	default:
-		return NULL;
-	}
-}
-
 void show_pnfs(struct seq_file *m, struct nfs_server *server)
 {
-	char *name = layout_name(server->pnfs_curr_ld->id);
-
 	seq_printf(m, ",pnfs=");
-	if (name)
-		seq_printf(m, "%s", name);
+	if (server->pnfs_curr_ld)
+		seq_printf(m, "%s", server->pnfs_curr_ld->name);
 	else
-		seq_printf(m, "unknown(%d)", server->pnfs_curr_ld->id);
+		seq_printf(m, "not configured");
 }
 #else  /* CONFIG_NFS_V4_1 */
 void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
-- 
1.6.6

