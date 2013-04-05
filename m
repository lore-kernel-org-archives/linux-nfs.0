Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51615 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161757Ab3DEOIJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 10:08:09 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: shut down more of delegation earlier
Date: Fri,  5 Apr 2013 10:08:04 -0400
Message-Id: <1365170886-2267-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1365170886-2267-1-git-send-email-bfields@redhat.com>
References: <1365170886-2267-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Once we've unhashed the delegation, it's only hanging around for the
benefit of an oustanding recall, which only needs the encoded
filehandle, stateid, and dl_retries counter.  No point keeping the file
around any longer, or keeping it hashed.

This also fixes a race: calls to idr_remove should really be serialized
by the caller, but the nfs4_put_delegation call from the callback code
isn't taking the state lock.

(Better might be to cancel the callback before destroying the
delegation, and remove any need for reference counting--but I don't see
an easy way to cancel an rpc call.)

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7293e29..26a03fa 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -417,21 +417,18 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	return dp;
 }
 
-static void free_stid(struct nfs4_stid *s, struct kmem_cache *slab)
+static void remove_stid(struct nfs4_stid *s)
 {
 	struct idr *stateids = &s->sc_client->cl_stateids;
 
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
-	kmem_cache_free(slab, s);
 }
 
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
-		dprintk("NFSD: freeing dp %p\n",dp);
-		put_nfs4_file(dp->dl_file);
-		free_stid(&dp->dl_stid, deleg_slab);
+		kmem_cache_free(deleg_slab, dp);
 		num_delegations--;
 	}
 }
@@ -462,6 +459,9 @@ unhash_delegation(struct nfs4_delegation *dp)
 	list_del_init(&dp->dl_recall_lru);
 	spin_unlock(&recall_lock);
 	nfs4_put_deleg_lease(dp->dl_file);
+	put_nfs4_file(dp->dl_file);
+	dp->dl_file = NULL;
+	remove_stid(&dp->dl_stid);
 	nfs4_put_delegation(dp);
 }
 
@@ -605,7 +605,8 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
-	free_stid(&stp->st_stid, stateid_slab);
+	remove_stid(&stp->st_stid);
+	kmem_cache_free(stateid_slab, stp);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
-- 
1.7.11.7

