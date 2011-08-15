Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:45519 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751770Ab1HONVc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 09:21:32 -0400
Date: Mon, 15 Aug 2011 09:21:30 -0400
To: Malcolm Locke <malc@wholemeal.co.nz>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Problems with locking, permanent 'lockd: server in grace
 period'
Message-ID: <20110815132130.GC28629@fieldses.org>
References: <20110808125114.GB5217@rudy>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110808125114.GB5217@rudy>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Aug 09, 2011 at 12:51:14AM +1200, Malcolm Locke wrote:
> First off, apologies for bringing such mundane matters to the list, but
> we're at the end of our tethers and way out of our depth on this.  We
> have a problem on our production machine that we are unable to replicate
> on a test machine, and would greatly appreciate any pointers of where to
> look next.
> 
> We're in the process of upgrading a DRBD pair running Ubuntu hardy to
> Debian squeeze.  The first of the pair has been upgraded, and NFS works
> correctly except for locking.  Calls to flock() from any client on an
> NFS mount hang indefinitely.
> 
> We've installed a fresh Debian squeeze machine to test, but are
> completely unable to reproduce the issue.  Pertinent details about the
> set up:
> 
> Kernel on both machines:
>   Linux debian 2.6.32-5-openvz-amd64 #1 SMP Tue Jun 14 10:46:15 UTC 2011
>   x86_64 GNU/Linux
> 
>   Debian package versions:
>   nfs-common 1.2.2-4
>   nfs-kernel-server 1.2.2-4
>   rpcbind 0.2.0-4.1
> 
>   Filesystem is ext3 rw,relatime,errors=remount-ro,data=ordered
>   /etc/exports has rw,no_root_squash,async,no_subtree_check
> 
> On both the working and failing hosts, the NFS is mounted with default
> options, e.g. mount host:/home /mnt
> 
> Below is the nlm debug from the working host (hostname debian on the
> left) and the failing host (itchy on the right).  Apologies for the wide
> text, I've aligned the log messages from a single flock() attempt so the
> corresponding lines match up for each host.  In both cases, the NFS
> client and server are the same host.
> 
> Points I note from this are:
> 
> - xdr_dec_stat_res doesn't get called on the failing host
> - nlm_lookup_host reports 'found host' on the failing host, and
>   'created host' on the working host.
> - vfs_lock_file returned 0 doesn't log on the failing host.  I think
>   this is because one of the following checks is returning true:
> 
>     // fs/lockd/svclock.c:411
>     if (locks_in_grace() && !reclaim) {
>             ret = nlm_lck_denied_grace_period;
>             goto out;
>     }
>     if (reclaim && !locks_in_grace()) {
>             ret = nlm_lck_denied_grace_period;
>             goto out;
>     }
>     
>   I've come to this conclusion because of the 'lockd: server in grace
>   period'.  The failing host has been up for several days, and on both
>   machines /proc/sys/fs/nfs/nlm_grace_period is 0.
> 
> Any help on this would be greatly appreciated, including where to go
> next.  If you require any more info let me know.  Thanks for your time.

It might be worth trying this in addition to the recoverydir fixes
previously posted.

--b.

commit c52560f10794b9fb8c050532d27ff999d8f5c23c
Author: J. Bruce Fields <bfields@redhat.com>
Date:   Fri Aug 12 11:59:44 2011 -0400

    some grace period fixes and debugging

diff --git a/fs/lockd/grace.c b/fs/lockd/grace.c
index 183cc1f..61272f7 100644
--- a/fs/lockd/grace.c
+++ b/fs/lockd/grace.c
@@ -22,6 +22,7 @@ static DEFINE_SPINLOCK(grace_lock);
 void locks_start_grace(struct lock_manager *lm)
 {
 	spin_lock(&grace_lock);
+	printk("lm->name starting grace period\n");
 	list_add(&lm->list, &grace_list);
 	spin_unlock(&grace_lock);
 }
@@ -40,6 +41,7 @@ EXPORT_SYMBOL_GPL(locks_start_grace);
 void locks_end_grace(struct lock_manager *lm)
 {
 	spin_lock(&grace_lock);
+	printk("%s ending grace period\n", lm->name);
 	list_del_init(&lm->list);
 	spin_unlock(&grace_lock);
 }
@@ -54,6 +56,15 @@ EXPORT_SYMBOL_GPL(locks_end_grace);
  */
 int locks_in_grace(void)
 {
-	return !list_empty(&grace_list);
+	if (!list_empty(&grace_list)) {
+		struct lock_manager *lm;
+
+		printk("in grace period due to: ");
+		list_for_each_entry(lm, &grace_list, list)
+			printk("%s ",lm->name);
+		printk("\n");
+		return 1;
+	}
+	return 0;
 }
 EXPORT_SYMBOL_GPL(locks_in_grace);
diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c061b9a..1638929 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -84,6 +84,7 @@ static unsigned long get_lockd_grace_period(void)
 }
 
 static struct lock_manager lockd_manager = {
+	.name = "lockd"
 };
 
 static void grace_ender(struct work_struct *not_used)
@@ -97,8 +98,8 @@ static void set_grace_period(void)
 {
 	unsigned long grace_period = get_lockd_grace_period();
 
-	locks_start_grace(&lockd_manager);
 	cancel_delayed_work_sync(&grace_period_end);
+	locks_start_grace(&lockd_manager);
 	schedule_delayed_work(&grace_period_end, grace_period);
 }
 
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3787ec1..b83ffdf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2942,6 +2942,7 @@ out:
 }
 
 static struct lock_manager nfsd4_manager = {
+	.name = "nfsd4",
 };
 
 static void
@@ -4563,7 +4564,6 @@ __nfs4_state_start(void)
 	int ret;
 
 	boot_time = get_seconds();
-	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       nfsd4_grace);
 	ret = set_callback_cred();
@@ -4575,6 +4575,7 @@ __nfs4_state_start(void)
 	ret = nfsd4_create_callback_queue();
 	if (ret)
 		goto out_free_laundry;
+	locks_start_grace(&nfsd4_manager);
 	queue_delayed_work(laundry_wq, &laundromat_work, nfsd4_grace * HZ);
 	set_max_delegations();
 	return 0;
diff --git a/include/linux/fs.h b/include/linux/fs.h
index ad35091..9501aa7 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1098,6 +1098,7 @@ struct lock_manager_operations {
 };
 
 struct lock_manager {
+	char *name;
 	struct list_head list;
 };
 
