Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f170.google.com ([209.85.212.170]:44741 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755951Ab3JNKo6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 06:44:58 -0400
Received: by mail-wi0-f170.google.com with SMTP id l12so3809848wiv.1
        for <linux-nfs@vger.kernel.org>; Mon, 14 Oct 2013 03:44:57 -0700 (PDT)
From: Benny Halevy <bhalevy@primarydata.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@primarydata.com>
Subject: [PATCH v2] nfsd: nfs4_free_stid
Date: Mon, 14 Oct 2013 13:44:52 +0300
Message-Id: <1381747492-14026-1-git-send-email-bhalevy@primarydata.com>
In-Reply-To: <1381730691-18105-1-git-send-email-bhalevy@primarydata.com>
References: <1381730691-18105-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Make it symmetric to nfs4_alloc_stid.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 06984e3..64c167f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -402,11 +402,16 @@ static void remove_stid(struct nfs4_stid *s)
 	idr_remove(stateids, s->sc_stateid.si_opaque.so_id);
 }
 
+static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
+{
+	kmem_cache_free(slab, s);
+}
+
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
 	if (atomic_dec_and_test(&dp->dl_count)) {
-		kmem_cache_free(deleg_slab, dp);
+		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
 }
@@ -610,7 +615,7 @@ static void close_generic_stateid(struct nfs4_ol_stateid *stp)
 static void free_generic_stateid(struct nfs4_ol_stateid *stp)
 {
 	remove_stid(&stp->st_stid);
-	kmem_cache_free(stateid_slab, stp);
+	nfs4_free_stid(stateid_slab, &stp->st_stid);
 }
 
 static void release_lock_stateid(struct nfs4_ol_stateid *stp)
-- 
1.8.3.1

