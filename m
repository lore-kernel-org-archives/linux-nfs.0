From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/7] nfsd4: simplify references to nfsd4 lease time
Date: Tue,  2 Mar 2010 18:12:47 -0500
Message-ID: <1267571573-11844-2-git-send-email-bfields@citi.umich.edu>
References: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:54588 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753049Ab0CBXLn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 18:11:43 -0500
In-Reply-To: <1267571573-11844-1-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of accessing the lease time directly, some users call
nfs4_lease_time(), and some a macro, NFSD_LEASE_TIME, defined as
nfs4_lease_time().  Neither layer of indirection serves any purpose.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4state.c    |   22 ++++++++--------------
 fs/nfsd/nfs4xdr.c      |    2 +-
 fs/nfsd/nfsctl.c       |    5 +----
 fs/nfsd/nfsd.h         |    5 ++---
 5 files changed, 13 insertions(+), 23 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 8fa412c..cb6b011 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -455,7 +455,7 @@ static struct rpc_program cb_program = {
 
 static int max_cb_time(void)
 {
-	return max(NFSD_LEASE_TIME/10, (time_t)1) * HZ;
+	return max(nfsd4_lease/10, (time_t)1) * HZ;
 }
 
 /* Reference counting, callback cleanup, etc., all look racy as heck.
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3a20c09..cc9164a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -44,7 +44,7 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
-static time_t lease_time = 90;     /* default lease time */
+time_t nfsd4_lease = 90;     /* default lease time */
 static time_t user_lease_time = 90;
 static time_t boot_time;
 static u32 current_ownerid = 1;
@@ -2560,9 +2560,9 @@ nfs4_laundromat(void)
 	struct nfs4_stateowner *sop;
 	struct nfs4_delegation *dp;
 	struct list_head *pos, *next, reaplist;
-	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
-	time_t t, clientid_val = NFSD_LEASE_TIME;
-	time_t u, test_val = NFSD_LEASE_TIME;
+	time_t cutoff = get_seconds() - nfsd4_lease;
+	time_t t, clientid_val = nfsd4_lease;
+	time_t u, test_val = nfsd4_lease;
 
 	nfs4_lock_state();
 
@@ -2602,7 +2602,7 @@ nfs4_laundromat(void)
 		list_del_init(&dp->dl_recall_lru);
 		unhash_delegation(dp);
 	}
-	test_val = NFSD_LEASE_TIME;
+	test_val = nfsd4_lease;
 	list_for_each_safe(pos, next, &close_lru) {
 		sop = list_entry(pos, struct nfs4_stateowner, so_close_lru);
 		if (time_after((unsigned long)sop->so_time, (unsigned long)cutoff)) {
@@ -2672,7 +2672,7 @@ EXPIRED_STATEID(stateid_t *stateid)
 {
 	if (time_before((unsigned long)boot_time,
 			((unsigned long)stateid->si_boot)) &&
-	    time_before((unsigned long)(stateid->si_boot + lease_time), get_seconds())) {
+	    time_before((unsigned long)(stateid->si_boot + nfsd4_lease), get_seconds())) {
 		dprintk("NFSD: expired stateid " STATEID_FMT "!\n",
 			STATEID_VAL(stateid));
 		return 1;
@@ -3976,7 +3976,7 @@ nfsd4_load_reboot_recovery_data(void)
 unsigned long
 get_nfs4_grace_period(void)
 {
-	return max(user_lease_time, lease_time) * HZ;
+	return max(user_lease_time, nfsd4_lease) * HZ;
 }
 
 /*
@@ -4009,7 +4009,7 @@ __nfs4_state_start(void)
 
 	boot_time = get_seconds();
 	grace_time = get_nfs4_grace_period();
-	lease_time = user_lease_time;
+	nfsd4_lease = user_lease_time;
 	locks_start_grace(&nfsd4_manager);
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       grace_time/HZ);
@@ -4036,12 +4036,6 @@ nfs4_state_start(void)
 	return 0;
 }
 
-time_t
-nfs4_lease_time(void)
-{
-	return lease_time;
-}
-
 static void
 __nfs4_state_shutdown(void)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c458fb1..f61bd73 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1899,7 +1899,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	if (bmval0 & FATTR4_WORD0_LEASE_TIME) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		WRITE32(NFSD_LEASE_TIME);
+		WRITE32(nfsd4_lease);
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
 		if ((buflen -= 4) < 0)
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 0f0e77f..8bff674 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1203,8 +1203,6 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 }
 
 #ifdef CONFIG_NFSD_V4
-extern time_t nfs4_leasetime(void);
-
 static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 {
 	/* if size > 10 seconds, call
@@ -1224,8 +1222,7 @@ static ssize_t __write_leasetime(struct file *file, char *buf, size_t size)
 		nfs4_reset_lease(lease);
 	}
 
-	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n",
-							nfs4_lease_time());
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%ld\n", nfsd4_lease);
 }
 
 /**
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index e942a1a..b463093 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -82,7 +82,6 @@ int nfs4_state_init(void);
 void nfsd4_free_slabs(void);
 int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
-time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 #else
@@ -90,7 +89,6 @@ static inline int nfs4_state_init(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
 static inline int nfs4_state_start(void) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
-static inline time_t nfs4_lease_time(void) { return 0; }
 static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
 #endif
@@ -229,6 +227,8 @@ extern struct timeval	nfssvc_boot;
 
 #ifdef CONFIG_NFSD_V4
 
+extern time_t nfsd4_lease;
+
 /* before processing a COMPOUND operation, we have to check that there
  * is enough space in the buffer for XDR encode to succeed.  otherwise,
  * we might process an operation with side effects, and be unable to
@@ -247,7 +247,6 @@ extern struct timeval	nfssvc_boot;
 #define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
 #define COMPOUND_ERR_SLACK_SPACE	12     /* OP_SETATTR */
 
-#define NFSD_LEASE_TIME                 (nfs4_lease_time())
 #define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
 
 /*
-- 
1.6.3.3

