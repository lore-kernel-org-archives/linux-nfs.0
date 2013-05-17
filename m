Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mout.perfora.net ([74.208.4.194]:54557 "EHLO mout.perfora.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754333Ab3EQUQY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 May 2013 16:16:24 -0400
From: Jim Rees <rees@umich.edu>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: avoid undefined signed overflow
Date: Fri, 17 May 2013 16:16:19 -0400
Message-Id: <1368821779-9046-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In C, signed integer overflow results in undefined behavior, but unsigned
overflow wraps around. So do the subtraction first, then cast to signed.

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 316ec84..9850329 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3427,7 +3427,7 @@ grace_disallows_io(struct net *net, struct inode *inode)
 /* Returns true iff a is later than b: */
 static bool stateid_generation_after(stateid_t *a, stateid_t *b)
 {
-	return (s32)a->si_generation - (s32)b->si_generation > 0;
+	return (s32)(a->si_generation - b->si_generation) > 0;
 }
 
 static __be32 check_stateid_generation(stateid_t *in, stateid_t *ref, bool has_session)
-- 
1.8.2.3

