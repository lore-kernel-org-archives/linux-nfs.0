From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] NFS: Fix RCU warnings in
 nfs_inode_return_delegation_noreclaim() [ver #2]
Date: Mon, 29 Mar 2010 16:26:36 -0700
Message-ID: <20100329232636.GT2569@linux.vnet.ibm.com>
References: <20100329223609.GR2569@linux.vnet.ibm.com>
 <20100329210520.GN2569@linux.vnet.ibm.com>
 <20100329192159.GM2569@linux.vnet.ibm.com>
 <20100319022527.GC2894@linux.vnet.ibm.com>
 <20100318133302.29754.1584.stgit@warthog.procyon.org.uk>
 <19192.1269889348@redhat.com>
 <23274.1269893706@redhat.com>
 <25276.1269901350@redhat.com>
 <26760.1269903543@redhat.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Howells <dhowells@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:39856 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751637Ab0C2X0i (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Mar 2010 19:26:38 -0400
In-Reply-To: <26760.1269903543@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 29, 2010 at 11:59:03PM +0100, David Howells wrote:
> Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:
> 
> > Only on Alpha.  Otherwise only a volatile access.
> 
> Whilst that is true, it's the principle of the thing.  The extra barrier
> shouldn't be emitted on Alpha.  If Alpha's no longer important, then can we
> scrap smp_read_barrier_depends()?
> 
> My point is that some of these rcu_dereference*()'s are unnecessary.  If
> there're required for correctness tracking purposes, fine; but can we have a
> macro that is just a dummy for the purpose of stripping the pointer Sparse
> annotation?  One that doesn't invoke rcu_dereference_raw() and interpolate a
> barrier, pretend or otherwise, when there's no second reference to order
> against.

Interesting point.  Perhaps an rcu_dereference_update(p, c) for the
cases where the data structure cannot change.  Also, such a name makes
it more clear that this is an update-side access, and it further documents
the update-side lock.

Something like the following, then?  Untested, probably does not even
compile.

							Thanx, Paul

------------------------------------------------------------------------

rcu: Add update-side variant of rcu_dereference()

Upcoming consistency-checking features are requiring that even update-side
accesses to RCU-protected pointers use some variant of rcu_dereference().
Even though rcu_dereference() is quite lightweight, it does constrain the
compiler, thus producing code that is worse than required.  This patch
therefore adds rcu_dereference_update(), which allows lockdep-style
checks for holding the correct update-side lock, but which does not
constrain the compiler.

Suggested-by: David Howells <dhowells@redhat.com>
Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 rcupdate.h |   17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 872a98e..0a6047f 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -209,9 +209,26 @@ static inline int rcu_read_lock_sched_held(void)
 		rcu_dereference_raw(p); \
 	})
 
+/**
+ * rcu_dereference_update - rcu_dereference on structure that cannot change
+ *
+ * Do rcu_dereference() checking, but just pick up the pointer without
+ * the normal RCU read-side precautions.  These precautions are only
+ * needed if the data structure can change.  The caller is responsible
+ * for doing whatever is necessary (such as holding locks) to prevent
+ * such changes from occurring.
+ */
+#define rcu_dereference_update(p, c) \
+	({ \
+		if (debug_lockdep_rcu_enabled() && !(c)) \
+			lockdep_rcu_dereference(__FILE__, __LINE__); \
+		(p); \
+	})
+
 #else /* #ifdef CONFIG_PROVE_RCU */
 
 #define rcu_dereference_check(p, c)	rcu_dereference_raw(p)
+#define rcu_dereference_update(p, c)	(p)
 
 #endif /* #else #ifdef CONFIG_PROVE_RCU */
 
