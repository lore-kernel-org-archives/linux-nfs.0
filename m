From: Greg Banks <gnb@sgi.com>
Subject: [patch 22/29] knfsd: make svc_authenticate() scale
Date: Wed, 01 Apr 2009 07:28:22 +1100
Message-ID: <20090331202946.068419000@sgi.com>
References: <20090331202800.739621000@sgi.com>
Cc: Linux NFS ML <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from [218.185.19.242] ([218.185.19.242]:22579 "EHLO inara.melbourne"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756196AbZCaVCp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Mar 2009 17:02:45 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the global spinlock which protects the table of registered
RPC authentication flavours, with an RCU scheme.  The spinlock was
taken by nfsd on every CPU for every NFS call, resulting in lots
of spinlock contention and one very hot and bouncy cacheline.

Tests on a 16 CPU Altix A4700 with 2 10gige Myricom cards, configured
separately (no bonding).  Workload is 640 client threads doing directory
traverals with random small reads, from server RAM.

Before: 242 KIOPS, with an oprofile like:
  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  5.01   2276.00  2276.00     2666     0.85     1.00  nfsd_ofcache_lookup
  4.61   4370.00  2094.00     2092     1.00     1.00  ia64_spinlock_contention	<----
  4.20   6279.00  1909.00     3141     0.61     0.78  svc_sock_enqueue
  4.03   8108.00  1829.00     1824     1.00     1.00  spin_unlock_irqrestore
  3.32   9618.00  1510.00     3588     0.42     1.00  spin_lock

             2090.00    0.00    2088/2092        spin_lock [22]
[40]     4.6 2094.00    0.00    2092         ia64_spinlock_contention [40]

             1473.39 2039.32    3501/3588        svc_authenticate [21]
[22]     7.9 1510.00 2090.00    3588         spin_lock [22]

After: 253 KIOPS, with a oprofile like:
  %   cumulative   self              self     total
 time   samples   samples    calls   1/call   1/call  name
  5.20   2250.00  2250.00     2638     0.85     1.00  nfsd_ofcache_lookup
  4.31   4117.00  1867.00     1863     1.00     1.00  spin_unlock_irqrestore
  3.13   5470.00  1353.00     1447     0.94     1.01  svcauth_unix_set_client
  2.79   6677.00  1207.00     1203     1.00     1.00  exp_readunlock
  2.77   7875.00  1198.00     1186     1.01     1.01  svc_export_put
  ...
  0.03  43095.00    13.00       13     1.00     1.00  ia64_spinlock_contention	<----

Before anyone asks, going to a rwlock_t kept similar performance and
just turned the time spent spinning on the lock to time spent waiting
for the cacheline to bounce.

Signed-off-by: Greg Banks <gnb-cP1dWloDopni96+mSzHFpQC/G2K4zDHf@public.gmane.org>
Reviewed-by: David Chinner <dgc@sgi.com>
---

 net/sunrpc/svcauth.c |   26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

Index: bfields/net/sunrpc/svcauth.c
===================================================================
--- bfields.orig/net/sunrpc/svcauth.c
+++ bfields/net/sunrpc/svcauth.c
@@ -42,17 +42,19 @@ svc_authenticate(struct svc_rqst *rqstp,
 	*authp = rpc_auth_ok;
 
 	flavor = svc_getnl(&rqstp->rq_arg.head[0]);
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		return SVC_DENIED;
 
 	dprintk("svc: svc_authenticate (%d)\n", flavor);
 
-	spin_lock(&authtab_lock);
-	if (flavor >= RPC_AUTH_MAXFLAVOR || !(aops = authtab[flavor])
-			|| !try_module_get(aops->owner)) {
-		spin_unlock(&authtab_lock);
+	rcu_read_lock();
+	aops = rcu_dereference(authtab[flavor]);
+	if (!aops || !try_module_get(aops->owner)) {
+		rcu_read_unlock();
 		*authp = rpc_autherr_badcred;
 		return SVC_DENIED;
 	}
-	spin_unlock(&authtab_lock);
+	rcu_read_unlock();
 
 	rqstp->rq_authop = aops;
 	return aops->accept(rqstp, authp);
@@ -87,9 +89,13 @@ int
 svc_auth_register(rpc_authflavor_t flavor, struct auth_ops *aops)
 {
 	int rv = -EINVAL;
+
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		return -EINVAL;
+
 	spin_lock(&authtab_lock);
-	if (flavor < RPC_AUTH_MAXFLAVOR && authtab[flavor] == NULL) {
-		authtab[flavor] = aops;
+	if (authtab[flavor] == NULL) {
+		rcu_assign_pointer(authtab[flavor], aops);
 		rv = 0;
 	}
 	spin_unlock(&authtab_lock);
@@ -100,9 +106,11 @@ EXPORT_SYMBOL_GPL(svc_auth_register);
 void
 svc_auth_unregister(rpc_authflavor_t flavor)
 {
+	if (flavor >= RPC_AUTH_MAXFLAVOR)
+		return;
+
 	spin_lock(&authtab_lock);
-	if (flavor < RPC_AUTH_MAXFLAVOR)
-		authtab[flavor] = NULL;
+	rcu_assign_pointer(authtab[flavor], NULL);
 	spin_unlock(&authtab_lock);
 }
 EXPORT_SYMBOL_GPL(svc_auth_unregister);

--
Greg
