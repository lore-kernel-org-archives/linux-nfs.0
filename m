Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f53.google.com ([209.85.192.53]:47918 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754785AbaF3PwO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:14 -0400
Received: by mail-qg0-f53.google.com with SMTP id i50so2129699qgf.26
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:13 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>,
        Ingo Molnar <mingo@redhat.com>
Subject: [PATCH v3 071/114] lockdep: add lockdep_assert_not_held
Date: Mon, 30 Jun 2014 11:49:40 -0400
Message-Id: <1404143423-24381-72-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We currently have the ability to call lockdep_assert_held to throw a
warning when a spinlock isn't held in a codepath. There are also times
when we'd like to throw a warning when a lock is held (i.e. when there
is the potential for deadlock with atomic_dec_and_lock or similar).

Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c     | 4 ++++
 include/linux/lockdep.h | 4 ++++
 2 files changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4f82e502f53a..1446cbfc42b4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -263,6 +263,8 @@ static void nfsd4_free_file(struct nfs4_file *f)
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
+	lockdep_assert_not_held(&state_lock);
+
 	if (atomic_dec_and_lock(&fi->fi_ref, &state_lock)) {
 		hlist_del(&fi->fi_hash);
 		spin_unlock(&state_lock);
@@ -420,6 +422,8 @@ static __be32 nfs4_file_check_deny(struct nfs4_file *fp, u32 deny)
 
 static void __nfs4_file_put_access(struct nfs4_file *fp, int oflag)
 {
+	lockdep_assert_not_held(&fp->fi_lock);
+
 	if (atomic_dec_and_lock(&fp->fi_access[oflag], &fp->fi_lock)) {
 		struct file *f1 = NULL;
 		struct file *f2 = NULL;
diff --git a/include/linux/lockdep.h b/include/linux/lockdep.h
index 008388f920d7..1e5f1d544029 100644
--- a/include/linux/lockdep.h
+++ b/include/linux/lockdep.h
@@ -362,6 +362,8 @@ extern void lockdep_trace_alloc(gfp_t mask);
 		WARN_ON(debug_locks && !lockdep_is_held(l));	\
 	} while (0)
 
+#define lockdep_assert_not_held(l) WARN_ON(debug_locks && lockdep_is_held(l))
+
 #define lockdep_recursing(tsk)	((tsk)->lockdep_recursion)
 
 #else /* !CONFIG_LOCKDEP */
@@ -413,6 +415,8 @@ struct lock_class_key { };
 
 #define lockdep_assert_held(l)			do { (void)(l); } while (0)
 
+#define lockdep_assert_not_held(l)		(void)(l)
+
 #define lockdep_recursing(tsk)			(0)
 
 #endif /* !LOCKDEP */
-- 
1.9.3

