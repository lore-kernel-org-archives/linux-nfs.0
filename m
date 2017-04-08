Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40668 "EHLO
        youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752337AbdDHRKI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Apr 2017 13:10:08 -0400
From: Colin King <colin.king@canonical.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        linux-nfs@vger.kernel.org
Cc: kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] lockd: remove redundant check on block
Date: Sat,  8 Apr 2017 18:09:59 +0100
Message-Id: <20170408170959.19805-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

A null check followed by a return is being performed already, so block
is always non-null at the second check on block, hence we can remove
this redundant null-check (Detected by PVS-Studio).  Also re-work
comment to clean up a check-patch warning.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 fs/lockd/svclock.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 5581e020644b..3507c80d1d4b 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -870,15 +870,15 @@ nlmsvc_grant_reply(struct nlm_cookie *cookie, __be32 status)
 	if (!(block = nlmsvc_find_block(cookie)))
 		return;
 
-	if (block) {
-		if (status == nlm_lck_denied_grace_period) {
-			/* Try again in a couple of seconds */
-			nlmsvc_insert_block(block, 10 * HZ);
-		} else {
-			/* Lock is now held by client, or has been rejected.
-			 * In both cases, the block should be removed. */
-			nlmsvc_unlink_block(block);
-		}
+	if (status == nlm_lck_denied_grace_period) {
+		/* Try again in a couple of seconds */
+		nlmsvc_insert_block(block, 10 * HZ);
+	} else {
+		/*
+		 * Lock is now held by client, or has been rejected.
+		 * In both cases, the block should be removed.
+		 */
+		nlmsvc_unlink_block(block);
 	}
 	nlmsvc_release_block(block);
 }
-- 
2.11.0

