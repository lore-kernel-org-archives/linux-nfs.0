Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750876AbdCNHHb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:31 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org,
        keescook@chromium.org, Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 02/12] fs, nfsd: convert nfs4_cntl_odstate.co_odcount from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:10 +0200
Message-Id: <1489475240-6594-3-git-send-email-elena.reshetova@intel.com>
In-Reply-To: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
References: <1489475240-6594-1-git-send-email-elena.reshetova@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

refcount_t type and corresponding API should be
used instead of atomic_t when the variable is used as
a reference counter. This allows to avoid accidental
refcounter overflows that might lead to use-after-free
situations.

Signed-off-by: Elena Reshetova <elena.reshetova@intel.com>
Signed-off-by: Hans Liljestrand <ishkamiel@gmail.com>
Signed-off-by: Kees Cook <keescook@chromium.org>
Signed-off-by: David Windsor <dwindsor@gmail.com>
---
 fs/nfsd/nfs4state.c | 6 +++---
 fs/nfsd/state.h     | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index ea1ce57..253fc93 100644
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

