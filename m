Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:39542 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaGUPDH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:07 -0400
Received: by mail-qg0-f44.google.com with SMTP id e89so5555680qgf.3
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:06 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 05/40] nfsd: Ensure atomicity of stateid destruction and idr tree removal
Date: Mon, 21 Jul 2014 11:02:17 -0400
Message-Id: <1405954972-28904-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Preparation for removal of the client_mutex. Ensure that they are done
while holding the clp->cl_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 30 ++++++++++++++++++------------
 1 file changed, 18 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 076de12c3fa6..0243a19dbef4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -604,13 +604,11 @@ out_dec:
 	return NULL;
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
@@ -620,14 +618,25 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 	kmem_cache_free(slab, s);
 }
 
+static bool nfs4_put_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+{
+	struct nfs4_client *clp = s->sc_client;
+
+	might_lock(&clp->cl_lock);
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
-		remove_stid(&dp->dl_stid);
-		nfs4_free_stid(deleg_slab, &dp->dl_stid);
+	if (nfs4_put_stid(deleg_slab, &dp->dl_stid))
 		atomic_long_dec(&num_delegations);
-	}
 }
 
 static void nfs4_put_deleg_lease(struct nfs4_file *fp)
@@ -885,10 +894,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void put_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	if (!atomic_dec_and_test(&stp->st_stid.sc_count))
-		return;
-	remove_stid(&stp->st_stid);
-	nfs4_free_stid(stateid_slab, &stp->st_stid);
+	nfs4_put_stid(stateid_slab, &stp->st_stid);
 }
 
 static void __release_lock_stateid(struct nfs4_ol_stateid *stp)
-- 
1.9.3

