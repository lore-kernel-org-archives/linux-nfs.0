Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f43.google.com ([209.85.192.43]:34221 "EHLO
	mail-qg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428AbaG2UfT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:35:19 -0400
Received: by mail-qg0-f43.google.com with SMTP id a108so302331qge.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:35:19 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH v2 33/38] nfsd: add locking to stateowner release
Date: Tue, 29 Jul 2014 16:34:16 -0400
Message-Id: <1406666061-14175-34-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, we'll need to properly protect
the stateowner reference counts using the cl_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cd7d7df03afa..9b342e164407 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -937,9 +937,14 @@ release_all_access(struct nfs4_ol_stateid *stp)
 
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
-	if (!atomic_dec_and_test(&sop->so_count))
+	struct nfs4_client *clp = sop->so_client;
+
+	might_lock(&clp->cl_lock);
+
+	if (!atomic_dec_and_lock(&sop->so_count, &clp->cl_lock))
 		return;
 	sop->so_ops->so_unhash(sop);
+	spin_unlock(&clp->cl_lock);
 	kfree(sop->so_owner.data);
 	sop->so_ops->so_free(sop);
 }
@@ -3078,11 +3083,7 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
-	struct nfs4_client *clp = so->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_openowner_locked(openowner(so));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -4842,11 +4843,7 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 
 static void nfs4_unhash_lockowner(struct nfs4_stateowner *sop)
 {
-	struct nfs4_client *clp = sop->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_lockowner_locked(lockowner(sop));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_lockowner(struct nfs4_stateowner *sop)
-- 
1.9.3

