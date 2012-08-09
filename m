Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:29830 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754952Ab2HISGZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 9 Aug 2012 14:06:25 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFS: Use kzalloc() instead of kmalloc() in the idmapper
Date: Thu,  9 Aug 2012 14:05:51 -0400
Message-Id: <1344535551-4412-3-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
References: <1344535551-4412-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This will allocate memory that has already been zeroed, allowing us to
remove the memset later on.

Signed-off-by: Bryan Schumaker <bjchuma@netapp.com>
---
 fs/nfs/idmap.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9864b48..4af524e 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -626,9 +626,6 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
 	substring_t substr;
 	int token, ret;
 
-	memset(im,  0, sizeof(*im));
-	memset(msg, 0, sizeof(*msg));
-
 	im->im_type = IDMAP_TYPE_GROUP;
 	im->im_private = idmap;
 	token = match_token(desc, nfs_idmap_tokens, &substr);
@@ -671,11 +668,11 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	int ret = -ENOMEM;
 
 	/* msg and im are freed in idmap_pipe_destroy_msg */
-	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	msg = kzalloc(sizeof(*msg), GFP_KERNEL);
 	if (!msg)
 		goto out0;
 
-	im = kmalloc(sizeof(*im), GFP_KERNEL);
+	im = kzalloc(sizeof(*im), GFP_KERNEL);
 	if (!im)
 		goto out1;
 
-- 
1.7.11.4

