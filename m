Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45934 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754149AbcKNQvq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Nov 2016 11:51:46 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Handle NFS4ERR_OLD_STATEID in nfs4_reclaim_open_state
Date: Mon, 14 Nov 2016 11:51:37 -0500
Message-Id: <dae29a90096c7366d235135e8cfec6edc2c4a9b2.1479142267.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that we're doing TEST_STATEID in nfs4_reclaim_open_state(), we can have
a NFS4ERR_OLD_STATEID returned from nfs41_open_expired() .  Instead of
marking state recovery as failed, mark the state for recovery again.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 5f4281ec5f72..0959c9661662 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1547,6 +1547,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 				ssleep(1);
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_STALE_STATEID:
+			case -NFS4ERR_OLD_STATEID:
 			case -NFS4ERR_BAD_STATEID:
 			case -NFS4ERR_RECLAIM_BAD:
 			case -NFS4ERR_RECLAIM_CONFLICT:
-- 
2.5.5

