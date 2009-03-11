From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 11/14] nfsd4: put_nfs4_client does not require state lock
Date: Tue, 10 Mar 2009 20:26:59 -0400
Message-ID: <1236731222-3294-12-git-send-email-bfields@fieldses.org>
References: <1236731222-3294-1-git-send-email-bfields@fieldses.org>
 <1236731222-3294-2-git-send-email-bfields@fieldses.org>
 <1236731222-3294-3-git-send-email-bfields@fieldses.org>
 <1236731222-3294-4-git-send-email-bfields@fieldses.org>
 <1236731222-3294-5-git-send-email-bfields@fieldses.org>
 <1236731222-3294-6-git-send-email-bfields@fieldses.org>
 <1236731222-3294-7-git-send-email-bfields@fieldses.org>
 <1236731222-3294-8-git-send-email-bfields@fieldses.org>
 <1236731222-3294-9-git-send-email-bfields@fieldses.org>
 <1236731222-3294-10-git-send-email-bfields@fieldses.org>
 <1236731222-3294-11-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	Alexandros Batsakis <batsakis@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:44058 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752651AbZCKA1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2009 20:27:05 -0400
In-Reply-To: <1236731222-3294-11-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

Since free_client() is guaranteed to only be called once, and to only
touch the client structure itself (not any common data structures), it
has no need for the state lock.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Alexandros Batsakis <batsakis@netapp.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3ddc9fb..3fd7136 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -490,8 +490,8 @@ out_put_cred:
 	 * Success or failure, now we're either waiting for lease expiration
 	 * or deleg_return.
 	 */
-	nfs4_lock_state();
 	put_nfs4_client(clp);
+	nfs4_lock_state();
 	nfs4_put_delegation(dp);
 	nfs4_unlock_state();
 	return;
-- 
1.6.0.4

