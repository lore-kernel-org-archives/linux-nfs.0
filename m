From: andros@netapp.com
Subject: [PATCH 1/1] NFS: fix ERR_PTR with un mapped NFSv4 error
Date: Wed, 26 Nov 2008 17:49:00 -0500
Message-ID: <1227739740-5885-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:65034 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019AbYKZWtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Nov 2008 17:49:03 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

NFSv4 errors need to be mapped prior to ERR_PTR.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/client.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 7547600..49f06ce 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1154,7 +1154,7 @@ struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 error:
 	nfs_free_server(server);
 	dprintk("<-- nfs4_create_server() = error %d\n", error);
-	return ERR_PTR(error);
+	return ERR_PTR(nfs4_map_errors(error));
 }
 
 /*
@@ -1231,7 +1231,7 @@ struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *data,
 error:
 	nfs_free_server(server);
 	dprintk("<-- nfs4_create_referral_server() = error %d\n", error);
-	return ERR_PTR(error);
+	return ERR_PTR(nfs4_map_errors(error));
 }
 
 #endif /* CONFIG_NFS_V4 */
@@ -1299,7 +1299,7 @@ struct nfs_server *nfs_clone_server(struct nfs_server *source,
 out_free_server:
 	nfs_free_server(server);
 	dprintk("<-- nfs_clone_server() = error %d\n", error);
-	return ERR_PTR(error);
+	return ERR_PTR(nfs4_map_errors(error));
 }
 
 #ifdef CONFIG_PROC_FS
-- 
1.5.4.3

