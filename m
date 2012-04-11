Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:45116 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932499Ab2DKNdb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 09:33:31 -0400
Subject: [PATCH 4/4] nfsd: allocate id-to-name and name-to-id caches in
 per-net operations.
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 11 Apr 2012 17:33:05 +0400
Message-ID: <20120411133305.26953.77258.stgit@localhost6.localdomain6>
In-Reply-To: <20120411133139.26953.85254.stgit@localhost6.localdomain6>
References: <20120411133139.26953.85254.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfsctl.c |   14 +++++++-------
 1 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d6e8b85..7269988 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1145,14 +1145,20 @@ static __net_init int nfsd_init_net(struct net *net)
 	retval = nfsd_export_init(net);
 	if (retval)
 		goto out_export_error;
+	retval = nfsd_idmap_init(net);
+	if (retval)
+		goto out_idmap_error;
 	return 0;
 
+out_idmap_error:
+	nfsd_export_shutdown(net);
 out_export_error:
 	return retval;
 }
 
 static __net_exit void nfsd_exit_net(struct net *net)
 {
+	nfsd_idmap_shutdown(net);
 	nfsd_export_shutdown(net);
 }
 
@@ -1186,12 +1192,9 @@ static int __init init_nfsd(void)
 	if (retval)
 		goto out_free_stat;
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
-	retval = nfsd_idmap_init(&init_net);
-	if (retval)
-		goto out_free_lockd;
 	retval = create_proc_exports_entry();
 	if (retval)
-		goto out_free_idmap;
+		goto out_free_lockd;
 	retval = register_filesystem(&nfsd_fs_type);
 	if (retval)
 		goto out_free_all;
@@ -1199,8 +1202,6 @@ static int __init init_nfsd(void)
 out_free_all:
 	remove_proc_entry("fs/nfs/exports", NULL);
 	remove_proc_entry("fs/nfs", NULL);
-out_free_idmap:
-	nfsd_idmap_shutdown(&init_net);
 out_free_lockd:
 	nfsd_lockd_shutdown();
 	nfsd_reply_cache_shutdown();
@@ -1223,7 +1224,6 @@ static void __exit exit_nfsd(void)
 	remove_proc_entry("fs/nfs", NULL);
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
-	nfsd_idmap_shutdown(&init_net);
 	nfsd4_free_slabs();
 	nfsd_fault_inject_cleanup();
 	unregister_filesystem(&nfsd_fs_type);

