Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f172.google.com ([209.85.213.172]:58025 "EHLO
	mail-ig0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754208AbaDRSpm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Apr 2014 14:45:42 -0400
Received: by mail-ig0-f172.google.com with SMTP id hn18so949305igb.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 11:45:42 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Bruce Fields <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 24/70] NFSd: Move the delegation reference counter into the struct nfs4_stid
Date: Fri, 18 Apr 2014 14:44:18 -0400
Message-Id: <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
In-Reply-To: <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
References: <1397846704-14567-1-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-2-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-3-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-4-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-5-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-6-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-7-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-8-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-9-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-17-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-18-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-19-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-20-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-21-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We will want to add reference counting to the lock stateid and open
stateids too.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 fs/nfsd/state.h     | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ab66f73643a9..afb767319f66 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -411,6 +411,7 @@ kmem_cache *slab)
 	stid->sc_stateid.si_opaque.so_clid = cl->cl_clientid;
 	/* Will be incremented before return to client: */
 	stid->sc_stateid.si_generation = 0;
+	atomic_set(&stid->sc_count, 1);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -457,7 +458,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	dp->dl_time = 0;
-	atomic_set(&dp->dl_count, 1);
 	nfsd4_init_callback(&dp->dl_recall);
 	return dp;
 }
@@ -480,7 +480,7 @@ static void nfs4_free_stid(struct kmem_cache *slab, struct nfs4_stid *s)
 void
 nfs4_put_delegation(struct nfs4_delegation *dp)
 {
-	if (atomic_dec_and_test(&dp->dl_count)) {
+	if (atomic_dec_and_test(&dp->dl_stid.sc_count)) {
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
 		num_delegations--;
 	}
@@ -2892,7 +2892,7 @@ static void nfsd_break_one_deleg(struct nfs4_delegation *dp)
 	 * callback (and since the lease code is serialized by the kernel
 	 * lock) we know the server hasn't removed the lease yet, we know
 	 * it's safe to take a reference: */
-	atomic_inc(&dp->dl_count);
+	atomic_inc(&dp->dl_stid.sc_count);
 	nfsd4_cb_recall(dp);
 }
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 559134675b5a..9d0088c244a8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -74,6 +74,7 @@ struct nfsd4_callback {
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
1.9.0

