Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f48.google.com ([209.85.216.48]:60724 "EHLO
	mail-qa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaFZTOx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:14:53 -0400
Received: by mail-qa0-f48.google.com with SMTP id x12so3210830qac.35
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:14:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 049/117] nfsd: Convert delegation counter to an atomic_long_t type
Date: Thu, 26 Jun 2014 15:12:29 -0400
Message-Id: <1403810017-16062-50-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We want to convert to an atomic type so that we don't need to lock
across the call to alloc_init_deleg(). Then convert to a long type so
that we match the size of 'max_delegations'.

None of this is a problem today, but it will be once we remove
client_mutex protection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6e918aa0829c..714273b942ce 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -338,7 +338,7 @@ static struct file *find_any_file(struct nfs4_file *f)
 	return ret;
 }
 
-static int num_delegations;
+static atomic_long_t num_delegations;
 unsigned long max_delegations;
 
 /*
@@ -548,7 +548,7 @@ static struct nfs4_ol_stateid * nfs4_alloc_stateid(struct nfs4_client *clp)
 static void nfs4_free_deleg(struct nfs4_stid *stid)
 {
 	nfs4_free_stid(deleg_slab, stid);
-	num_delegations--;
+	atomic_long_dec(&num_delegations);
 }
 
 /*
@@ -628,15 +628,17 @@ static struct nfs4_delegation *
 alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct svc_fh *current_fh)
 {
 	struct nfs4_delegation *dp;
+	long n;
 
 	dprintk("NFSD alloc_init_deleg\n");
-	if (num_delegations > max_delegations)
-		return NULL;
+	n = atomic_long_inc_return(&num_delegations);
+	if (n < 0 || n > max_delegations)
+		goto out_dec;
 	if (delegation_blocked(&current_fh->fh_handle))
-		return NULL;
+		goto out_dec;
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
-		return dp;
+		goto out_dec;
 
 	dp->dl_stid.sc_free = nfs4_free_deleg;
 	/*
@@ -645,13 +647,15 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	 * 0 anyway just for consistency and use 1:
 	 */
 	dp->dl_stid.sc_stateid.si_generation = 1;
-	num_delegations++;
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
 	dp->dl_type = NFS4_OPEN_DELEGATE_READ;
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	return dp;
+out_dec:
+	atomic_long_dec(&num_delegations);
+	return NULL;
 }
 
 static void remove_stid_locked(struct nfs4_client *clp, struct nfs4_stid *s)
-- 
1.9.3

