From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/2] rcu: add rcu_access_pointer and rcu_dereference_protect
Date: Wed, 07 Apr 2010 14:57:32 +0100
Message-ID: <20100407135732.12414.16416.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: eric.dumazet@gmail.com, dhowells@redhat.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:32394 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932593Ab0DGN6C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Apr 2010 09:58:02 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

This patch adds variants of rcu_dereference() that handle situations
where the RCU-protected data structure cannot change, perhaps due to
our holding the update-side lock, or where the RCU-protected pointer is
only to be fetched, not dereferenced.

The new rcu_access_pointer() primitive is for the case where the pointer
is be fetch and not dereferenced.  This primitive may be used without
protection, RCU or otherwise, due to the fact that it uses ACCESS_ONCE().

The new rcu_dereference_protect() primitive is for the case where updates
are prevented, for example, due to holding the update-side lock.  This
primitive does neither ACCESS_ONCE() nor smp_read_barrier_depends(), so
can only be used when updates are somehow prevented.

Suggested-by: David Howells <dhowells@redhat.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Signed-off-by: David Howells <dhowells@redhat.com>
---

 include/linux/rcupdate.h |   34 ++++++++++++++++++++++++++++++++++
 1 files changed, 34 insertions(+), 0 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 872a98e..a1b14b6 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -209,9 +209,43 @@ static inline int rcu_read_lock_sched_held(void)
 		rcu_dereference_raw(p); \
 	})
 
+/**
+ * rcu_access_pointer - fetch RCU pointer with no dereferencing
+ *
+ * Return the value of the specified RCU-protected pointer, but omit the
+ * smp_read_barrier_depends() and keep the ACCESS_ONCE().  This is useful
+ * when the value of this pointer is accessed, but the pointer is not
+ * dereferenced, for example, when testing an RCU-protected pointer against
+ * NULL.  This may also be used in cases where update-side locks prevent
+ * the value of the pointer from changing, but rcu_dereference_protect()
+ * is a lighter-weight primitive for this use case.
+ */
+#define rcu_access_pointer(p) \
+	({ \
+		ACCESS_ONCE(p); \
+	})
+
+/**
+ * rcu_dereference_protected - fetch RCU pointer when updates prevented
+ *
+ * Return the value of the specified RCU-protected pointer, but omit
+ * both the smp_read_barrier_depends() and the ACCESS_ONCE().  This
+ * is useful in cases where update-side locks prevent the value of the
+ * pointer from changing.  Please note that this primitive does -not-
+ * prevent the compiler from repeating this reference or combining it
+ * with other references, so it should not be used without protection
+ * of appropriate locks.
+ */
+#define rcu_dereference_protected(p) \
+	({ \
+		(p); \
+	})
+
 #else /* #ifdef CONFIG_PROVE_RCU */
 
 #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
+#define rcu_access_pointer(p)		ACCESS_ONCE(p)
+#define rcu_dereference_protect(p)	(p)
 
 #endif /* #else #ifdef CONFIG_PROVE_RCU */
 

