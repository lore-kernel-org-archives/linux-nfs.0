Return-Path: linux-nfs-owner@vger.kernel.org
Received: from discipline.rit.edu ([129.21.6.207]:40819 "HELO
	discipline.rit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751180AbbBYNn1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Feb 2015 08:43:27 -0500
From: Andrew Elble <aweits@rit.edu>
To: linux-nfs@vger.kernel.org, etmsys@rit.edu
Cc: Andrew Elble <aweits@rit.edu>, stable@vger.kernel.org
Subject: [PATCH] NFS: fix clp->cl_revoked list deletion causing softlock in nfsd
Date: Wed, 25 Feb 2015 08:42:55 -0500
Message-Id: <1424871775-98137-1-git-send-email-aweits@rit.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 2d4a532d385f ("nfsd: ensure that clp->cl_revoked list is
protected by clp->cl_lock") removed the use of the reaplist to
clean out clp->cl_revoked. It failed to change list_entry() to
walk clp->cl_revoked.next instead of reaplist.next

Fixes: 2d4a532d385f ("nfsd: ensure that clp->cl_revoked list is protected by clp->cl_lock")
Cc: stable@vger.kernel.org
Reported-by: Eric Meddaugh <etmsys@rit.edu>
Tested-by: Eric Meddaugh <etmsys@rit.edu>
Signed-off-by: Andrew Elble <aweits@rit.edu>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f6b2a09f793f..d2f2c37dc2db 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1638,7 +1638,7 @@ __destroy_client(struct nfs4_client *clp)
 		nfs4_put_stid(&dp->dl_stid);
 	}
 	while (!list_empty(&clp->cl_revoked)) {
-		dp = list_entry(reaplist.next, struct nfs4_delegation, dl_recall_lru);
+		dp = list_entry(clp->cl_revoked.next, struct nfs4_delegation, dl_recall_lru);
 		list_del_init(&dp->dl_recall_lru);
 		nfs4_put_stid(&dp->dl_stid);
 	}
-- 
2.2.1

