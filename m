Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:46033 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbaF3Pv3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:29 -0400
Received: by mail-qg0-f45.google.com with SMTP id a108so2120981qge.32
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:29 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 040/114] nfsd: Ensure atomicity of stateid destruction and idr tree removal
Date: Mon, 30 Jun 2014 11:49:09 -0400
Message-Id: <1404143423-24381-41-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparation for removal of the client_mutex. Ensure that they are done
while holding the clp->cl_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 27 ++++++++++++++++-----------
 1 file changed, 16 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 902e5f54c166..e51df8c590be 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -585,30 +585,37 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
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
@@ -853,9 +860,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
-		return;
-	nfs4_free_stid(stateid_slab, &stp->st_stid);
+	nfs4_put_stid(stateid_slab, &stp->st_stid);
 }
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
-- 
1.9.3

