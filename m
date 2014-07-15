Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:58707 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758402AbaGOKiD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 06:38:03 -0400
Received: by mail-qc0-f171.google.com with SMTP id i17so2214193qcy.30
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 03:38:02 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 5/7] nfsd: Move the delegation reference counter into the struct nfs4_stid
Date: Tue, 15 Jul 2014 06:37:47 -0400
Message-Id: <1405420669-4030-6-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We will want to add reference counting to the lock stateid and open
stateids too in later patches.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 fs/nfsd/state.h     | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b7b4cc8a30fb..87674a25a15b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -472,6 +472,7 @@ kmem_cache *slab)
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
 	/* Will be incremented before return to client: */
 	stid->sc_stateid.si_generation = 0;
+	atomic_set(&stid->sc_count, 1);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -595,7 +596,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
-	atomic_set(&dp->dl_count, 1);
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
 	return dp;
 }
@@ -616,7 +616,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	if (atomic_dec_and_test(&dp->dl_count)) {
+	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -3118,7 +3118,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * lock) we know the server hasn't removed the lease yet, we know
 	 * it's safe to take a reference.
 	 */
-	atomic_inc(&dp->dl_count);
+	atomic_inc(&dp->dl_stid.sc_count);
 	nfsd4_cb_recall(dp);
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 996d61eeb357..e68a9ae30fd7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -73,6 +73,7 @@ struct nfsd4_callback {
 };
 
 struct nfs4_stid {
+	atomic_t sc_count;
 #define NFS4_OPEN_STID 1
 #define NFS4_LOCK_STID 2
 #define NFS4_DELEG_STID 4
@@ -91,7 +92,6 @@ struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
-	atomic_t		dl_count;       /* ref count */
 	struct nfs4_file	*dl_file;
 	u32			dl_type;
 	time_t			dl_time;
-- 
1.9.3

