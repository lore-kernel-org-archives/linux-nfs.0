Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gh0-f170.google.com ([209.85.160.170]:60588 "EHLO
	mail-gh0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752182Ab3DJTgy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Apr 2013 15:36:54 -0400
Received: by mail-gh0-f170.google.com with SMTP id z2so125959ghb.15
        for <linux-nfs@vger.kernel.org>; Wed, 10 Apr 2013 12:36:54 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: remove unnecessary check for NULL inode->i_flock from nfs_delegation_claim_locks
Date: Wed, 10 Apr 2013 15:36:48 -0400
Message-Id: <1365622608-21015-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The second check was added in commit 65b62a29 but it will never be true.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/delegation.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index f30bd1e..57db324 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -71,10 +71,8 @@ static int nfs_delegation_claim_locks(struct nfs_open_context *ctx, struct nfs4_
 	int status = 0;
 
 	if (inode->i_flock == NULL)
-		return 0;
-
-	if (inode->i_flock == NULL)
 		goto out;
+
 	/* Protect inode->i_flock using the file locks lock */
 	lock_flocks();
 	for (fl = inode->i_flock; fl != NULL; fl = fl->fl_next) {
-- 
1.7.11.7

