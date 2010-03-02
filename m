From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/7] nfsd4: simplify lease/grace interaction
Date: Tue,  2 Mar 2010 18:12:49 -0500
Message-ID: <1267571573-11844-4-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
 <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54587 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752963Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-3-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The original code here assumed we'd allow the user to change the lease
any time, but only allow the change to take effect on restart.  Since
then we modified the code to allow setting the lease on when the server
is down.  Update the rest of the code to reflect that fact, clarify
variable names, and add document.

Also, the code insisted that the grace period always be the longer of
the old and new lease periods, but that's overly conservative--as long
as it lasts at least the old lease period, old clients should still know
to recover in time.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   32 +++++++++++---------------------
 1 files changed, 11 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index cc9164a..eb8d124 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -45,7 +45,7 @@
 
 /* Globals */
 time_t nfsd4_lease = 90;     /* default lease time */
-static time_t user_lease_time = 90;
+static time_t nfsd4_grace = 90;
 static time_t boot_time;
 static u32 current_ownerid = 1;
 static u32 current_fileid = 1;
@@ -2551,6 +2551,12 @@ nfsd4_end_grace(void)
 	dprintk("NFSD: end of grace period\n");
 	nfsd4_recdir_purge_old();
 	locks_end_grace(&nfsd4_manager);
+	/*
+	 * Now that every NFSv4 client has had the chance to recover and
+	 * to see the (possibly new, possibly shorter) lease time, we
+	 * can safely set the next grace time to the current lease time:
+	 */
+	nfsd4_grace = nfsd4_lease;
 }
 
 static time_t
@@ -3973,12 +3979,6 @@ nfsd4_load_reboot_recovery_data(void)
 		printk("NFSD: Failure reading reboot recovery data\n");
 }
 
-unsigned long
-get_nfs4_grace_period(void)
-{
-	return max(user_lease_time, nfsd4_lease) * HZ;
-}
-
 /*
  * Since the lifetime of a delegation isn't limited to that of an open, a
  * client may quite reasonably hang on to a delegation as long as it has
@@ -4005,18 +4005,14 @@ set_max_delegations(void)
 static int
 __nfs4_state_start(void)
 {
-	unsigned long grace_time;
-
 	boot_time = get_seconds();
-	grace_time = get_nfs4_grace_period();
-	nfsd4_lease = user_lease_time;
 	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
-	       grace_time/HZ);
+	       nfsd4_grace);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
 	if (laundry_wq == NULL)
 		return -ENOMEM;
-	queue_delayed_work(laundry_wq, &laundromat_work, grace_time);
+	queue_delayed_work(laundry_wq, &laundromat_work, nfsd4_grace * HZ);
 	set_max_delegations();
 	return set_callback_cred();
 }
@@ -4123,17 +4119,11 @@ nfs4_recoverydir(void)
 /*
  * Called when leasetime is changed.
  *
- * The only way the protocol gives us to handle on-the-fly lease changes is to
- * simulate a reboot.  Instead of doing that, we just wait till the next time
- * we start to register any changes in lease time.  If the administrator
- * really wants to change the lease time *now*, they can go ahead and bring
- * nfsd down and then back up again after changing the lease time.
- *
- * user_lease_time is protected by nfsd_mutex since it's only really accessed
+ * nfsd4_lease is protected by nfsd_mutex since it's only really accessed
  * when nfsd is starting
  */
 void
 nfs4_reset_lease(time_t leasetime)
 {
-	user_lease_time = leasetime;
+	nfsd4_lease = leasetime;
 }
-- 
1.6.3.3

