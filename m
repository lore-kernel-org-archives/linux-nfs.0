Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34832 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750961AbdCNHHf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 14 Mar 2017 03:07:35 -0400
From: Elena Reshetova <elena.reshetova@intel.com>
To: trond.myklebust@primarydata.com
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        anna.schumaker@netapp.com, peterz@infradead.org, keescook@chromium.org,
        Elena Reshetova <elena.reshetova@intel.com>,
        Hans Liljestrand <ishkamiel@gmail.com>,
        David Windsor <dwindsor@gmail.com>
Subject: [PATCH 03/12] fs, nfsd: convert nfs4_file.fi_ref from atomic_t to refcount_t
Date: Tue, 14 Mar 2017 09:07:11 +0200
Message-Id: <1489475240-6594-4-git-send-email-elena.reshetova@intel.com>
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
 fs/nfsd/state.h     | 4 ++--
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 253fc93..a19f56c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -359,7 +359,7 @@ put_nfs4_file(struct nfs4_file *fi)
 {
 	might_lock(&state_lock);
 
-	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
+	if (refcount_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del_rcu(&fi->fi_hash);
 		spin_unlock(&state_lock);
 		WARN_ON_ONCE(!list_empty(&fi->fi_clnt_odstate));
@@ -3352,7 +3352,7 @@ static void nfsd4_init_file(struct knfsd_fh *fh, unsigned int hashval,
 {
 	lockdep_assert_held(&state_lock);
 
-	atomic_set(&fp->fi_ref, 1);
+	refcount_set(&fp->fi_ref, 1);
 	spin_lock_init(&fp->fi_lock);
 	INIT_LIST_HEAD(&fp->fi_stateids);
 	INIT_LIST_HEAD(&fp->fi_delegations);
@@ -3648,7 +3648,7 @@ find_file_locked(struct knfsd_fh *fh, unsigned int hashval)
 
 	hlist_for_each_entry_rcu(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fh_match(&fp->fi_fhandle, fh)) {
-			if (atomic_inc_not_zero(&fp->fi_ref))
+			if (refcount_inc_not_zero(&fp->fi_ref))
 				return fp;
 		}
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 58eb5f4..4797429 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -482,7 +482,7 @@ struct nfs4_clnt_odstate {
  * the global state_lock spinlock.
  */
 struct nfs4_file {
-	atomic_t		fi_ref;
+	refcount_t		fi_ref;
 	spinlock_t		fi_lock;
 	struct hlist_node       fi_hash;	/* hash on fi_fhandle */
 	struct list_head        fi_stateids;
@@ -635,7 +635,7 @@ struct nfs4_file *find_file(struct knfsd_fh *fh);
 void put_nfs4_file(struct nfs4_file *fi);
 static inline void get_nfs4_file(struct nfs4_file *fi)
 {
-	atomic_inc(&fi->fi_ref);
+	refcount_inc(&fi->fi_ref);
 }
 struct file *find_any_file(struct nfs4_file *f);
 
-- 
2.7.4

