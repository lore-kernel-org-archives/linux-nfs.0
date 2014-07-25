Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:60096 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbaGYLer (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Jul 2014 07:34:47 -0400
Received: by mail-qa0-f46.google.com with SMTP id v10so4374593qac.5
        for <linux-nfs@vger.kernel.org>; Fri, 25 Jul 2014 04:34:47 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v6 4/9] nfsd: Convert delegation counter to an atomic_long_t type
Date: Fri, 25 Jul 2014 07:34:22 -0400
Message-Id: <1406288067-20663-5-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
References: <1406288067-20663-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

We want to convert to an atomic type so that we don't need to lock
across the call to alloc_init_deleg(). Then convert to a long type so
that we match the size of 'max_delegations'.

None of this is a problem today, but it will be once we remove
client_mutex protection.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4state.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9c912c004247..b421b51c3a9e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -342,7 +342,7 @@ find_any_file(struct nfs4_file *f)
 	return ret;
 }
 
-static int num_delegations;
+static atomic_long_t num_delegations;
 unsigned long max_delegations;
 
 /*
@@ -582,22 +582,23 @@ static struct nfs4_delegation *
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
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
 	 * 0 anyway just for consistency and use 1:
 	 */
 	dp->dl_stid.sc_stateid.si_generation = 1;
-	num_delegations++;
 	INIT_LIST_HEAD(&dp->dl_perfile);
 	INIT_LIST_HEAD(&dp->dl_perclnt);
 	INIT_LIST_HEAD(&dp->dl_recall_lru);
@@ -605,6 +606,9 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	fh_copy_shallow(&dp->dl_fh, &current_fh->fh_handle);
 	INIT_WORK(&dp->dl_recall.cb_work, nfsd4_run_cb_recall);
 	return dp;
+out_dec:
+	atomic_long_dec(&num_delegations);
+	return NULL;
 }
 
 static void remove_stid(struct nfs4_stid *s)
@@ -627,7 +631,7 @@ nfs4_put_delegation(struct nfs4_delegation *dp)
 			put_nfs4_file(dp->dl_file);
 		remove_stid(&dp->dl_stid);
 		nfs4_free_stid(deleg_slab, &dp->dl_stid);
-		num_delegations--;
+		atomic_long_dec(&num_delegations);
 	}
 }
 
-- 
1.9.3

