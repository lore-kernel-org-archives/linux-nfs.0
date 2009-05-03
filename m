From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: setclientid_confirm callback-change fixes
Date: Sun,  3 May 2009 14:16:29 -0400
Message-ID: <1241374599-20348-4-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58594 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-3-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

This setclientid_confirm case should allow the client to change
callbacks, but it currently has a dummy implementation that just turns
off callbacks completely.  That dummy implementation isn't completely
correct either, though:

	- There's no need to remove any client recovery directory in
	  this case.
	- New clientid confirm verifiers should be generated (and
	  returned) in setclientid; there's no need to generate a new
	  one here.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d24dd12..7e1fcc3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1688,8 +1688,6 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 			/* XXX: We just turn off callbacks until we can handle
 			  * change request correctly. */
 			atomic_set(&conf->cl_callback.cb_set, 0);
-			gen_confirm(conf);
-			nfsd4_remove_clid_dir(unconf);
 			expire_client(unconf);
 			status = nfs_ok;
 
-- 
1.6.0.4

