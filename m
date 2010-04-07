From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Tue, 6 Apr 2010 17:02:03 -0700
Message-ID: <20100407000203.GI2553@linux.vnet.ibm.com>
References: <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
 <14003.1270122314@redhat.com>
 <4161.1270133211@redhat.com>
 <23331.1270570443@redhat.com>
 <26510.1270582446@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:40752 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932085Ab0DGACG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 Apr 2010 20:02:06 -0400
In-Reply-To: <26510.1270582446@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 06, 2010 at 08:34:06PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > OK, just to make sure I understand you...  You are asking for two additional
> > RCU API members:
> > 
> > 1.	rcu_access_pointer() or some such that includes ACCESS_ONCE(),
> > 	but not smp_read_barrier_depends(), which may be used when
> > 	we are simply examining the value of the RCU-protected pointer
> > 	(as in the NFS case).  It could also be used when the
> > 	appropriate update-side lock is held, but for that we have:
> > 
> > 2.	rcu_dereference_protected() or some such that includes neither
> > 	ACCESS_ONCE() nor smp_read_barrier_depends(), and that may
> > 	only be used if updates are prevented, for example, by holding
> > 	the appropriate update-side lock.
> > 
> > Does this fit?
> 
> Yep.  I think so.

OK.  How about the following?

							Thanx, Paul

------------------------------------------------------------------------

commit 104e6c5f16ca5fc23af1b3f3e6197d3f599f934a
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Apr 5 10:52:53 2010 -0700

    rcu: add rcu_access_pointer and rcu_dereference_protect
    
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

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 872a98e..ed7539f 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -209,9 +209,47 @@ static inline int rcu_read_lock_sched_held(void)
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
+#define rcu_access_pointer(p, c) \
+	({ \
+		if (debug_lockdep_rcu_enabled() && !(c)) \
+			lockdep_rcu_dereference(__FILE__, __LINE__); \
+		ACCESS_ONCE(p); \
+	})
+
+/**
+ * rcu_dereference_protect - fetch RCU pointer when updates prevented
+ *
+ * Return the value of the specified RCU-protected pointer, but omit
+ * both the smp_read_barrier_depends() and the ACCESS_ONCE().  This
+ * is useful in cases where update-side locks prevent the value of the
+ * pointer from changing.  Please note that this primitive does -not-
+ * prevent the compiler from repeating this reference or combining it
+ * with other references, so it should not be used without protection
+ * of appropriate locks.
+ */
+#define rcu_dereference_protect(p, c) \
+	({ \
+		if (debug_lockdep_rcu_enabled() && !(c)) \
+			lockdep_rcu_dereference(__FILE__, __LINE__); \
+		(p); \
+	})
+
 #else /* #ifdef CONFIG_PROVE_RCU */
 
 #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
+#define rcu_access_pointer(p, c)	ACCESS_ONCE(p)
+#define rcu_dereference_protect(p, c) (p)
 
 #endif /* #else #ifdef CONFIG_PROVE_RCU */
 
