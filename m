Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:42296 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751372AbeCRMhH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 18 Mar 2018 08:37:07 -0400
From: Jeff Layton <jlayton@kernel.org>
To: trondmy@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] nfs4: don't compare clientid in nfs4_wake_lock_waiter
Date: Sun, 18 Mar 2018 08:37:02 -0400
Message-Id: <20180318123703.11256-3-jlayton@kernel.org>
In-Reply-To: <20180318123703.11256-1-jlayton@kernel.org>
References: <20180318123703.11256-1-jlayton@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jeff Layton <jlayton@redhat.com>

The task is expected to sleep for a while here, and it's possible that
a new EXCHANGE_ID has occurred in the interim, and we were assigned a
new clientid. Since this is a per-client list, there isn't a lot of
value in vetting the clientid on the incoming request.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/nfs4proc.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5ab28454f117..669ba9211177 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6626,10 +6626,8 @@ nfs4_wake_lock_waiter(wait_queue_entry_t *wait, unsigned int mode, int flags, vo
 	struct nfs_lowner	*lowner = &cbnl->cbnl_owner,
 				*wowner = waiter->owner;
 
-	/* Only wake if the callback was for the same owner */
-	if (lowner->clientid != wowner->clientid ||
-	    lowner->id != wowner->id		 ||
-	    lowner->s_dev != wowner->s_dev)
+	/* Only wake if the callback was for the same owner. */
+	if (lowner->id != wowner->id || lowner->s_dev != wowner->s_dev)
 		return 0;
 
 	/* Make sure it's for the right inode */
-- 
2.14.3

