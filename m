Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:44166 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760091Ab2DKLOB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 07:14:01 -0400
Subject: [PATCH 4/4] nfsd: allocate export and expkey caches in per-net
 operations.
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 15:13:35 +0400
Message-ID: <20120411111335.13840.76893.stgit@localhost6.localdomain6>
In-Reply-To: <20120411111053.13840.66083.stgit@localhost6.localdomain6>
References: <20120411111053.13840.66083.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfsctl.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index b144177..08cd87a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1137,7 +1137,28 @@ static int create_proc_exports_entry(void)
 #endif
 
 int nfsd_net_id;
+
+static __net_init int nfsd_init_net(struct net *net)
+{
+	int retval;
+
+	retval = nfsd_export_init(net);
+	if (retval)
+		goto out_export_error;
+	return 0;
+
+out_export_error:
+	return retval;
+}
+
+static __net_exit void nfsd_exit_net(struct net *net)
+{
+	nfsd_export_shutdown(net);
+}
+
 static struct pernet_operations nfsd_net_ops = {
+	.init = nfsd_init_net,
+	.exit = nfsd_exit_net,
 	.id   = &nfsd_net_id,
 	.size = sizeof(struct nfsd_net),
 };
@@ -1164,9 +1185,6 @@ static int __init init_nfsd(void)
 	retval = nfsd_reply_cache_init();
 	if (retval)
 		goto out_free_stat;
-	retval = nfsd_export_init(&init_net);
-	if (retval)
-		goto out_free_cache;
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
 	retval = nfsd_idmap_init();
 	if (retval)
@@ -1185,8 +1203,6 @@ out_free_idmap:
 	nfsd_idmap_shutdown();
 out_free_lockd:
 	nfsd_lockd_shutdown();
-	nfsd_export_shutdown(&init_net);
-out_free_cache:
 	nfsd_reply_cache_shutdown();
 out_free_stat:
 	nfsd_stat_shutdown();
@@ -1202,7 +1218,6 @@ out_unregister_notifier:
 
 static void __exit exit_nfsd(void)
 {
-	nfsd_export_shutdown(&init_net);
 	nfsd_reply_cache_shutdown();
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);

