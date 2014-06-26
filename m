Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f44.google.com ([209.85.192.44]:54918 "EHLO
	mail-qg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751744AbaFZTOW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:22 -0400
Received: by mail-qg0-f44.google.com with SMTP id j107so3500337qga.31
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:21 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 026/117] nfsd: Move the delegation reference counter into the struct nfs4_stid
Date: Thu, 26 Jun 2014 15:12:06 -0400
Message-Id: <1403810017-16062-27-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We will want to add reference counting to the lock stateid and open
stateids too in later patches.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 13 +++++++------
 fs/nfsd/state.h     |  2 +-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a4636aac165e..4cb64d12c9bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -363,6 +363,7 @@ kmem_cache *slab)
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
 	/* Will be incremented before return to client: */
 	stid->sc_stateid.si_generation = 0;
+	atomic_set(&stid->sc_count, 1);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -484,7 +485,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
-	atomic_set(&dp->dl_count, 1);
 	return dp;
 }
 
@@ -503,7 +503,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	if (atomic_dec_and_test(&dp->dl_count)) {
+	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -2951,10 +2951,11 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 {
 	/* We're assuming the state code never drops its reference
 	 * without first removing the lease.  Since we're in this lease
-	 * callback (and since the lease code is serialized by the kernel
-	 * lock) we know the server hasn't removed the lease yet, we know
-	 * it's safe to take a reference: */
-	atomic_inc(&dp->dl_count);
+	 * callback (and since the lease code is serialized by the i_lock
+	 * we know the server hasn't removed the lease yet, we know it's
+	 * safe to take a reference.
+	 */
+	atomic_inc(&dp->dl_stid.sc_count);
 	block_delegations(&dp->dl_fh);
 	nfsd4_cb_recall(dp);
 }
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index b2c9afce33bf..9eb4fe673014 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -73,6 +73,7 @@ struct nfsd4_callback {
 };
 
 struct nfs4_stid {
+	atomic_t sc_count;
 #define NFS4_OPEN_STID 1
 #define NFS4_LOCK_STID 2
 #define NFS4_DELEG_STID 4
@@ -90,7 +91,6 @@ struct nfs4_delegation {
 	struct list_head	dl_perfile;
 	struct list_head	dl_perclnt;
 	struct list_head	dl_recall_lru;  /* delegation recalled */
-	atomic_t		dl_count;       /* ref count */
 	struct nfs4_file	*dl_file;
 	u32			dl_type;
 	time_t			dl_time;
-- 
1.9.3

