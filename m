Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:31574 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752657AbdJTJzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 20 Oct 2017 05:55:45 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, bfields@fieldses.org,
        jlayton@poochiereds.net, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>
Subject: [PATCH 02/11] fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to refcount_t
Date: Fri, 20 Oct 2017 12:53:29 +0300
Message-Id: <1508493218-27760-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
References: <1508493218-27760-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

atomic_t variables are currently used to implement reference
counters with the following properties:
 - counter is initialized to 1 using atomic_set()
 - a resource is freed upon counter reaching zero
 - once counter reaches zero, its further
   increments aren't allowed
 - counter schema uses basic atomic operations
   (set, inc, inc_not_zero, dec_and_test, etc.)

Such atomic variables should be converted to a newly provided
refcount_t type and API that prevents accidental counter overflows
and underflows. This is important since overflows and underflows
can lead to use-after-free situation and be exploitable.

The variable nfs4_cntl_odstate.co_odcount is used as pure reference counter.
Convert it to refcount_t and fix up the operations.

Suggested-by: Kees Cook <keescook@chromium.org>
Reviewed-by: David Windsor <dwindsor@gmail.com>
Reviewed-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 fs/nfsd/state.h     | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d356b87..fb61d79 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -568,7 +568,7 @@ alloc_clnt_odstate(struct nfs4_client *clp)
 	co = kmem_cache_zalloc(odstate_slab, GFP_KERNEL);
 	if (co) {
 		co->co_client = clp;
-		atomic_set(&co->co_odcount, 1);
+		refcount_set(&co->co_odcount, 1);
 	}
 	return co;
 }
@@ -586,7 +586,7 @@ static inline void
 get_clnt_odstate(struct nfs4_clnt_odstate *co)
 {
 	if (co)
-		atomic_inc(&co->co_odcount);
+		refcount_inc(&co->co_odcount);
 }
 
 static void
@@ -598,7 +598,7 @@ put_clnt_odstate(struct nfs4_clnt_odstate *co)
 		return;
 
 	fp = co->co_file;
-	if (atomic_dec_and_lock(&co->co_odcount, &fp->fi_lock)) {
+	if (refcount_dec_and_lock(&co->co_odcount, &fp->fi_lock)) {
 		list_del(&co->co_perfile);
 		spin_unlock(&fp->fi_lock);
 
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f927aa4..58eb5f4 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -466,7 +466,7 @@ struct nfs4_clnt_odstate {
 	struct nfs4_client	*co_client;
 	struct nfs4_file	*co_file;
 	struct list_head	co_perfile;
-	atomic_t		co_odcount;
+	refcount_t		co_odcount;
 };
 
 /*
-- 
2.7.4

