Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f174.google.com ([209.85.161.174]:57466 "EHLO
	mail-gg0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752221Ab2JALvs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2012 07:51:48 -0400
Received: by ggnr5 with SMTP id r5so1332440ggn.19
        for <linux-nfs@vger.kernel.org>; Mon, 01 Oct 2012 04:51:47 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, bharrosh@panasas.com, steved@redhat.com,
        skinsbursky@parallels.com
Subject: [PATCH 2/2] nfsd: change algorithm for selecting the client_tracking_ops
Date: Mon,  1 Oct 2012 07:51:38 -0400
Message-Id: <1349092298-23872-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
References: <1349092298-23872-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the legacy tracking dir exists, use that. Next try the usermodehelper
upcall. It should succeed or fail quickly, so trying it first should be
harmless. If that fails, fall back to using nfsdcld.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index d8e07d5..3584313 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1067,17 +1067,35 @@ nfsd4_client_tracking_init(struct net *net)
 	int status;
 	struct path path;
 
-	if (!client_tracking_ops) {
-		client_tracking_ops = &nfsd4_cld_tracking_ops;
-		status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
-		if (!status) {
-			if (S_ISDIR(path.dentry->d_inode->i_mode))
-				client_tracking_ops =
-						&nfsd4_legacy_tracking_ops;
-			path_put(&path);
-		}
+	/* just run the init if it the method is already decided */
+	if (client_tracking_ops)
+		goto do_init;
+
+	/*
+	 * See if the recoverydir exists and is a directory. If it is,
+	 * then use the legacy ops.
+	 */
+	client_tracking_ops = &nfsd4_legacy_tracking_ops;
+	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
+	if (!status) {
+		status = S_ISDIR(path.dentry->d_inode->i_mode);
+		path_put(&path);
+		if (status)
+			goto do_init;
 	}
 
+	/*
+	 * Next, try a UMH upcall. It should succeed or fail quickly, so
+	 * there's little harm in trying that first.
+	 */
+	client_tracking_ops = &nfsd4_umh_tracking_ops;
+	status = client_tracking_ops->init(net);
+	if (!status)
+		return status;
+
+	/* Finally, try to use nfsdcld */
+	client_tracking_ops = &nfsd4_cld_tracking_ops;
+do_init:
 	status = client_tracking_ops->init(net);
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
-- 
1.7.11.4

