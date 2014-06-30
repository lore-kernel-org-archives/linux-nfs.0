Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f178.google.com ([209.85.216.178]:35653 "EHLO
	mail-qc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754328AbaF3PwQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:16 -0400
Received: by mail-qc0-f178.google.com with SMTP id c9so7107465qcz.37
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:15 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 072/114] nfsd: add locking to stateowner release
Date: Mon, 30 Jun 2014 11:49:41 -0400
Message-Id: <1404143423-24381-73-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Once we remove the client_mutex, we'll need to properly protect
the stateowner reference counts using the cl_lock.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 1446cbfc42b4..90e92f671900 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -638,6 +638,8 @@ static void nfs4_put_stid(struct nfs4_stid *s)
 {
 	struct nfs4_client *clp = s->sc_client;
 
+	lockdep_assert_not_held(&clp->cl_lock);
+
 	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
 		wake_up_all(&close_wq);
 		return;
@@ -3012,9 +3014,14 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 
 static void nfs4_put_stateowner(struct nfs4_stateowner *sop)
 {
-	if (!atomic_dec_and_test(&sop->so_count))
+	struct nfs4_client *clp = sop->so_client;
+
+	lockdep_assert_not_held(&clp->cl_lock);
+
+	if (!atomic_dec_and_lock(&sop->so_count, &clp->cl_lock))
 		return;
 	sop->so_unhash(sop);
+	spin_unlock(&clp->cl_lock);
 	sop->so_free(sop);
 }
 
@@ -3029,11 +3036,7 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
-	struct nfs4_client *clp = so->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_openowner_locked(openowner(so));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -4799,11 +4802,7 @@ find_lockowner_str(clientid_t *clid, struct xdr_netobj *owner,
 
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

