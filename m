From: andros@netapp.com
Subject: [PATCH 11/13] SQUASHME pnfs_submit: remove layout_name
Date: Thu, 29 Apr 2010 16:34:49 -0400
Message-ID: <1272573291-8986-12-git-send-email-andros@netapp.com>
References: <1272573291-8986-1-git-send-email-andros@netapp.com>
 <1272573291-8986-2-git-send-email-andros@netapp.com>
 <1272573291-8986-3-git-send-email-andros@netapp.com>
 <1272573291-8986-4-git-send-email-andros@netapp.com>
 <1272573291-8986-5-git-send-email-andros@netapp.com>
 <1272573291-8986-6-git-send-email-andros@netapp.com>
 <1272573291-8986-7-git-send-email-andros@netapp.com>
 <1272573291-8986-8-git-send-email-andros@netapp.com>
 <1272573291-8986-9-git-send-email-andros@netapp.com>
 <1272573291-8986-10-git-send-email-andros@netapp.com>
 <1272573291-8986-11-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46364 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755941Ab0D3Qs6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 Apr 2010 12:48:58 -0400
In-Reply-To: <1272573291-8986-11-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Use the pnfs_curr_ld name field.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/super.c |   22 +++-------------------
 1 files changed, 3 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index fce7d47..36b0fe9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -663,29 +663,13 @@ void show_sessions(struct seq_file *m, struct nfs_server *server) {}
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

