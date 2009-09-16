From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/4] nfsd4: allow nfs4 state startup to fail
Date: Tue, 15 Sep 2009 21:07:57 -0400
Message-ID: <1253063278-30137-3-git-send-email-bfields@citi.umich.edu>
References: <20090916010604.GA29397@fieldses.org>
 <1253063278-30137-1-git-send-email-bfields@citi.umich.edu>
 <1253063278-30137-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33109 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751580AbZIPBHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Sep 2009 21:07:54 -0400
In-Reply-To: <1253063278-30137-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The failure here is pretty unlikely, but we should handle it anyway.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c       |   17 ++++++++++++-----
 fs/nfsd/nfssvc.c          |    4 +++-
 include/linux/nfsd/nfsd.h |    4 ++--
 3 files changed, 17 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 46e9ac5..11db40c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -4004,7 +4004,7 @@ set_max_delegations(void)
 
 /* initialization to perform when the nfsd service is started: */
 
-static void
+static int
 __nfs4_state_start(void)
 {
 	unsigned long grace_time;
@@ -4016,19 +4016,26 @@ __nfs4_state_start(void)
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       grace_time/HZ);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
+	if (laundry_wq == NULL)
+		return -ENOMEM;
 	queue_delayed_work(laundry_wq, &laundromat_work, grace_time);
 	set_max_delegations();
+	return 0;
 }
 
-void
+int
 nfs4_state_start(void)
 {
+	int ret;
+
 	if (nfs4_init)
-		return;
+		return 0;
 	nfsd4_load_reboot_recovery_data();
-	__nfs4_state_start();
+	ret = __nfs4_state_start();
+	if (ret)
+		return ret;
 	nfs4_init = 1;
-	return;
+	return 0;
 }
 
 time_t
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 4472449..fcc0010 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -411,7 +411,9 @@ nfsd_svc(unsigned short port, int nrservs)
 	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)
 		goto out;
-	nfs4_state_start();
+	error = nfs4_state_start();
+	if (error)
+		goto out;
 
 	nfsd_reset_versions();
 
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index 2812ed5..24fdf89 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -166,7 +166,7 @@ extern int nfsd_max_blksize;
 extern unsigned int max_delegations;
 int nfs4_state_init(void);
 void nfsd4_free_slabs(void);
-void nfs4_state_start(void);
+int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
@@ -174,7 +174,7 @@ int nfs4_reset_recoverydir(char *recdir);
 #else
 static inline int nfs4_state_init(void) { return 0; }
 static inline void nfsd4_free_slabs(void) { }
-static inline void nfs4_state_start(void) { }
+static inline int nfs4_state_start(void) { }
 static inline void nfs4_state_shutdown(void) { }
 static inline time_t nfs4_lease_time(void) { return 0; }
 static inline void nfs4_reset_lease(time_t leasetime) { }
-- 
1.6.0.4

