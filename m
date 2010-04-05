From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 5 Apr 2010 10:57:54 -0700
Message-ID: <20100405175754.GE2525@linux.vnet.ibm.com>
References: <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
 <20100329232636.GT2569@linux.vnet.ibm.com>
 <2440.1269967151@redhat.com>
 <21972.1269993064@redhat.com>
 <10818.1270044273@redhat.com>
 <15371.1270057054@redhat.com>
 <19556.1270076008@redhat.com>
 <14003.1270122314@redhat.com>
 <4161.1270133211@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:33153 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751723Ab0DER55 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Apr 2010 13:57:57 -0400
In-Reply-To: <4161.1270133211@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 01, 2010 at 03:46:51PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > So you have objected to needless memory barriers.  How do you feel
> > about possibly needless ACCESS_ONCE() calls?
> 
> That would work here since it shouldn't emit any excess instructions.

And here is the corresponding patch.  Seem reasonable?

							Thanx, Paul

------------------------------------------------------------------------

 rcupdate.h |   19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

commit 61ad1405cd442fe54f87ff97febf52610817903e
Author: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
Date:   Mon Apr 5 10:52:53 2010 -0700

    rcu: add rcu_dereference_protect to avoid smp_read_barrier_depends overhead
    
    This patch adds a variant of rcu_dereference() that handles situations
    where the RCU-protected data structure cannot change, perhaps due to
    our holding the update-side lock, or where the RCU-protected pointer is
    only to be tested, not dereferenced.
    
    Suggested-by: David Howells <dhowells@redhat.com>
    Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 872a98e..123b834 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -209,9 +209,28 @@ static inline int rcu_read_lock_sched_held(void)
 		rcu_dereference_raw(p); \
 	})
 
+/**
+ * rcu_dereference_protected - fetch RCU pointer when protected by algorithm
+ *
+ * Return the value of the specified RCU-protected pointer, but omit
+ * the smp_read_barrier_depends() and keep the ACCESS_ONCE().  This
+ * is useful in cases where update-side locks prevent the value of the
+ * pointer from changing, and is also useful in cases where the value
+ * of this pointer is accessed, but the pointer is not dereferenced.
+ * An example of this latter occurs when testing an RCU-protected
+ * pointer against NULL.
+ */
+#define rcu_dereference_protected(p, c) \
+	({ \
+		if (debug_lockdep_rcu_enabled() && !(c)) \
+			lockdep_rcu_dereference(__FILE__, __LINE__); \
+		ACCESS_ONCE(p); \
+	})
+
 #else /* #ifdef CONFIG_PROVE_RCU */
 
 #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
+#define rcu_dereference_protected(p, c)	ACCESS_ONCE(p)
 
 #endif /* #else #ifdef CONFIG_PROVE_RCU */
 
