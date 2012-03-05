Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:63818 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752440Ab2CEQu3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:29 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/16] NFS: Fix a compile issue when !CONFIG_NFS_V4_1
Date: Mon,  5 Mar 2012 11:50:06 -0500
Message-Id: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The attempt to display the implementation ID needs to be conditional on
whether or not CONFIG_NFS_V4_1 is defined

Reported-by: Bryan Schumaker <Bryan.Schumaker@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/super.c |   22 +++++++++++++++-------
 1 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3935a37..61419c9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -785,8 +785,22 @@ static void show_pnfs(struct seq_file *m, struct nfs_server *server)
 	else
 		seq_printf(m, "not configured");
 }
+
+static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
+{
+	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
+		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
+		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
+			   "date='%llu,%u'",
+			   impl_id->name, impl_id->domain,
+			   impl_id->date.seconds, impl_id->date.nseconds);
+	}
+}
 #else
 static void show_pnfs(struct seq_file *m, struct nfs_server *server) {}
+static void show_implementation_id(struct seq_file *m, struct nfs_server *nfss)
+{
+}
 #endif
 #endif
 
@@ -836,13 +850,7 @@ static int nfs_show_stats(struct seq_file *m, struct dentry *root)
 
 	seq_printf(m, "\n\tage:\t%lu", (jiffies - nfss->mount_time) / HZ);
 
-	if (nfss->nfs_client && nfss->nfs_client->impl_id) {
-		struct nfs41_impl_id *impl_id = nfss->nfs_client->impl_id;
-		seq_printf(m, "\n\timpl_id:\tname='%s',domain='%s',"
-			   "date='%llu,%u'",
-			   impl_id->name, impl_id->domain,
-			   impl_id->date.seconds, impl_id->date.nseconds);
-	}
+	show_implementation_id(m, nfss);
 
 	seq_printf(m, "\n\tcaps:\t");
 	seq_printf(m, "caps=0x%x", nfss->caps);
-- 
1.7.7.6

