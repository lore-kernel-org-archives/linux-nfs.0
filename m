Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:38888 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932184AbaFSOwa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:30 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so2254633qgf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 063/104] nfsd: add locking to stateowner release
Date: Thu, 19 Jun 2014 10:50:09 -0400
Message-Id: <1403189450-18729-64-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 858778cbcc7d..e5e1a7abee06 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -563,6 +563,8 @@ static void nfs4_put_stid(struct nfs4_stid *s)
 {
 	struct nfs4_client *clp = s->sc_client;
 
+	lockdep_assert_not_held(&clp->cl_lock);
+
 	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock)) {
 		wake_up_all(&close_wq);
 		return;
@@ -2923,9 +2925,14 @@ static inline void *alloc_stateowner(struct kmem_cache *slab, struct xdr_netobj
 
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
 
@@ -2939,11 +2946,7 @@ static void hash_openowner(struct nfs4_openowner *oo, struct nfs4_client *clp, u
 
 static void nfs4_unhash_openowner(struct nfs4_stateowner *so)
 {
-	struct nfs4_client *clp = so->so_client;
-
-	spin_lock(&clp->cl_lock);
 	unhash_openowner_locked(openowner(so));
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_openowner(struct nfs4_stateowner *so)
@@ -4730,11 +4733,7 @@ static void hash_lockowner(struct nfs4_lockowner *lo, unsigned int strhashval, s
 
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

