Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qe0-f53.google.com ([209.85.128.53]:49331 "EHLO
	mail-qe0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752440Ab3IZSlY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Sep 2013 14:41:24 -0400
Received: by mail-qe0-f53.google.com with SMTP id jy17so1105917qeb.26
        for <linux-nfs@vger.kernel.org>; Thu, 26 Sep 2013 11:41:23 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH RFC v0 22/49] nfsd: cleanup free_stid
Date: Thu, 26 Sep 2013 14:41:21 -0400
Message-Id: <1380220881-13687-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <52447EA0.7070004@primarydata.com>
References: <52447EA0.7070004@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it symmetric to alloc_stid

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 214e42d..099976e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -411,11 +411,16 @@ static void remove_stid(struct nfs4_stid *s)
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
 }
 
+static void free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+{
+	kmem_cache_free(slab, s);
+}
+
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
-		kmem_cache_free(deleg_slab, dp);
+		free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
 }
@@ -619,7 +624,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	remove_stid(&stp->st_stid);
-	kmem_cache_free(stateid_slab, stp);
+	free_stid(stateid_slab, &stp->st_stid);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
-- 
1.8.3.1

