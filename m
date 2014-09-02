Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f49.google.com ([209.85.220.49]:46692 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753540AbaIBOMi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:12:38 -0400
Received: by mail-pa0-f49.google.com with SMTP id kq14so14871590pab.36
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:12:38 -0700 (PDT)
Message-ID: <5405D041.4060303@gmail.com>
Date: Tue, 02 Sep 2014 22:12:17 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 3/6] NFSD: Fix a memory leak if nfsd4_recdir_load fail
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4recover.c | 30 +++++++++++++++++-------------
 1 file changed, 17 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index e37ac1c..bb66037 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -480,6 +480,16 @@ nfsd4_init_recdir(struct net *net)
 	return status;
 }
 
+static void
+nfsd4_shutdown_recdir(struct net *net)
+{
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (!nn->rec_file)
+		return;
+	fput(nn->rec_file);
+	nn->rec_file = NULL;
+}
 
 static int
 nfs4_legacy_state_init(struct net *net)
@@ -513,10 +523,13 @@ nfsd4_load_reboot_recovery_data(struct net *net)
 	int status;
 
 	status = nfsd4_init_recdir(net);
-	if (!status)
-		status = nfsd4_recdir_load(net);
 	if (status)
-		printk(KERN_ERR "NFSD: Failure reading reboot recovery data\n");
+		return status;
+
+	status = nfsd4_recdir_load(net);
+	if (status)
+		nfsd4_shutdown_recdir(net);
+
 	return status;
 }
 
@@ -547,21 +560,12 @@ err:
 }
 
 static void
-nfsd4_shutdown_recdir(struct nfsd_net *nn)
-{
-	if (!nn->rec_file)
-		return;
-	fput(nn->rec_file);
-	nn->rec_file = NULL;
-}
-
-static void
 nfsd4_legacy_tracking_exit(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	nfs4_release_reclaim(nn);
-	nfsd4_shutdown_recdir(nn);
+	nfsd4_shutdown_recdir(net);
 	nfs4_legacy_state_shutdown(net);
 }
 
-- 
1.9.3

