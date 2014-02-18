Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:46285 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755966AbaBRPgJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Feb 2014 10:36:09 -0500
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 01/12] NFS fix error return in nfs4_select_rw_stateid
Date: Tue, 18 Feb 2014 10:36:05 -0500
Message-ID: <1392737765-41942-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Do not return an error when nfs4_copy_delegation_stateid succeeds.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4state.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ba18958..1cfde97 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1120,8 +1120,11 @@ int nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 	if (ret == -EIO)
 		/* A lost lock - don't even consider delegations */
 		goto out;
-	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
+	/* returns true if delegation stateid found and copied */
+	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode)) {
+		ret = 0;
 		goto out;
+	}
 	if (ret != -ENOENT)
 		/* nfs4_copy_delegation_stateid() didn't over-write
 		 * dst, so it still has the lock stateid which we now
-- 
1.8.2.1

