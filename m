Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48738 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752822Ab2JDF3o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 4 Oct 2012 01:29:44 -0400
From: Jorge Mora <mora@netapp.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Jorge Mora <mora@netapp.com>
Subject: [PATCH] NFSv4.1: Use correct stateid for read/write
Date: Tue,  2 Oct 2012 17:35:49 -0700
Message-Id: <1349224549-11194-1-git-send-email-mora@cyclsvl29.eng.netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Jorge Mora <mora@netapp.com>

On pNFS, the correct stateid for read/write should not
be the LOCK stateid when the file has a byte range lock.

Signed-off-by: Jorge Mora <mora@netapp.com>
---
Fixes bug on Trond's testing branch
 fs/nfs/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index c351e6b..681e659 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1036,7 +1036,8 @@ void nfs4_select_rw_stateid(nfs4_stateid *dst, struct nfs4_state *state,
 {
 	if (nfs4_copy_delegation_stateid(dst, state->inode, fmode))
 		return;
-	if (nfs4_copy_lock_stateid(dst, state, lockowner))
+	if (pnfs_get_ds_info(state->inode) == NULL &&
+	    nfs4_copy_lock_stateid(dst, state, lockowner))
 		return;
 	nfs4_copy_open_stateid(dst, state);
 }
-- 
1.7.11.4

