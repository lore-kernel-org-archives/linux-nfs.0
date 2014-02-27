Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:16326 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750742AbaB0TN5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Feb 2014 14:13:57 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <steved@redhat.com>, <linux-nfs@vger.kernel.org>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/1] NFSv4 always compare stateids in nfs4_stateid_is_current
Date: Thu, 27 Feb 2014 14:13:50 -0500
Message-ID: <1393528430-5237-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

When nfs4_stateid_is_current does not compare the from the wire
stateid to the current stateid, nfs4_read/write_stateid_changed
can return a false positive resulting in a READ or WRITE looping
forever retrying a bad stateid and never triggering a stateid
recovery.

Do not check the non-boolean return from nfs4_set_rw_stateid.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4proc.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 8672323..11566a4 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4051,10 +4051,9 @@ static bool nfs4_stateid_is_current(nfs4_stateid *stateid,
 		const struct nfs_lock_context *l_ctx,
 		fmode_t fmode)
 {
-	nfs4_stateid current_stateid;
+	nfs4_stateid current_stateid = &zero_stateid;
 
-	if (nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode))
-		return false;
+	nfs4_set_rw_stateid(&current_stateid, ctx, l_ctx, fmode);
 	return nfs4_stateid_match(stateid, &current_stateid);
 }
 
-- 
1.8.3.1

