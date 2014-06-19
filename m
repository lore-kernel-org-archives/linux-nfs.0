Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:49123 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:35 -0400
Received: by mail-qa0-f53.google.com with SMTP id j15so2052271qaq.12
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:35 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 026/104] NFSd: Ensure atomicity of stateid destruction and idr tree removal
Date: Thu, 19 Jun 2014 10:49:32 -0400
Message-Id: <1403189450-18729-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6c04b5bb10f7..827e749e258e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -511,30 +511,37 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	return dp;
 }
 
-static void remove_stid(struct nfs4_stid *s)
+static void remove_stid_locked(struct nfs4_client *clp, struct nfs4_stid *s)
 {
-	struct nfs4_client *clp = s->sc_client;
+	lockdep_assert_held(&clp->cl_lock);
 
-	spin_lock(&clp->cl_lock);
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
-	spin_unlock(&clp->cl_lock);
 }
 
 static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 {
-	remove_stid(s);
 	if (s->sc_file)
 		put_nfs4_file(s->sc_file);
 	kmem_cache_free(slab, s);
 }
 
+static bool nfs4_put_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+{
+	struct nfs4_client *clp = s->sc_client;
+
+	if (!atomic_dec_and_lock(&s->sc_count, &clp->cl_lock))
+		return false;
+	remove_stid_locked(clp, s);
+	spin_unlock(&clp->cl_lock);
+	nfs4_free_stid(slab, s);
+	return true;
+}
+
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
-		nfs4_free_stid(deleg_slab, &dp->dl_stid);
+	if (nfs4_put_stid(deleg_slab, &dp->dl_stid))
 		num_delegations--;
-	}
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -753,9 +760,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
-		return;
-	nfs4_free_stid(stateid_slab, &stp->st_stid);
+	nfs4_put_stid(stateid_slab, &stp->st_stid);
 }
 
 static void __release_lock_stateid(struct nfs4_lockowner *lo,
-- 
1.9.3

