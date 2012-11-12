Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:38044 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752655Ab2KLUBJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Nov 2012 15:01:09 -0500
Received: by mail-vc0-f174.google.com with SMTP id fk26so6536744vcb.19
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2012 12:01:08 -0800 (PST)
From: Jeff Layton <jlayton@redhat.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 02/11] nfsd: change heuristic for selecting the client_tracking_ops
Date: Mon, 12 Nov 2012 15:00:49 -0500
Message-Id: <1352750458-16857-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
References: <1352750458-16857-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

First, try to use the new usermodehelper upcall. It should succeed or
fail quickly, so there's little cost to doing so.

If it fails, and the legacy tracking dir exists, use that. If it
doesn't exist then fall back to using nfsdcld.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfsd/nfs4recover.c | 36 +++++++++++++++++++++++++++---------
 1 file changed, 27 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 2fc2f6c..e71f713 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -1064,17 +1064,35 @@ nfsd4_client_tracking_init(struct net *net)
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
+	 * First, try a UMH upcall. It should succeed or fail quickly, so
+	 * there's little harm in trying that first.
+	 */
+	client_tracking_ops = &nfsd4_umh_tracking_ops;
+	status = client_tracking_ops->init(net);
+	if (!status)
+		return status;
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
 
+	/* Finally, try to use nfsdcld */
+	client_tracking_ops = &nfsd4_cld_tracking_ops;
+do_init:
 	status = client_tracking_ops->init(net);
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
-- 
1.7.11.7

