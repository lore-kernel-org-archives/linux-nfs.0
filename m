From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 09/15] knfsd: move nfsv4 slab creation/destruction to
	module init/exit
Date: Mon, 27 Aug 2007 16:22:50 -0400
Message-ID: <1188246177192-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl73-0004kC-2X
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:05 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl76-0003Nl-Ia
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:09 -0700
In-Reply-To: <1188246177259-git-send-email-bfields@fieldses.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: J. Bruce Fields <bfields@citi.umich.edu>

We have some slabs that the nfs4 server uses to store state objects.
We're currently creating and destroying those slabs whenever the server
is brought up or down.  That seems excessive; may as well just do that
in module initialization and exit.

Also add some minor header cleanup.  (Thanks to Andrew Morton for that
and a compile fix.)

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c       |   22 ++++++++++------------
 fs/nfsd/nfsctl.c          |    5 ++++-
 fs/nfsd/nfssvc.c          |    4 +---
 include/linux/nfsd/nfsd.h |   18 ++++++++++--------
 4 files changed, 25 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2b20eb8..09573b9 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1021,7 +1021,7 @@ nfsd4_free_slab(struct kmem_cache **slab)
 	*slab = NULL;
 }
 
-static void
+void
 nfsd4_free_slabs(void)
 {
 	nfsd4_free_slab(&stateowner_slab);
@@ -3152,11 +3152,14 @@ nfs4_check_open_reclaim(clientid_t *clid)
 
 /* initialization to perform at module load time: */
 
-void
+int
 nfs4_state_init(void)
 {
-	int i;
+	int i, status;
 
+	status = nfsd4_init_slabs();
+	if (status)
+		return status;
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
@@ -3185,6 +3188,7 @@ nfs4_state_init(void)
 	for (i = 0; i < CLIENT_HASH_SIZE; i++)
 		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
 	reclaim_str_hashtbl_size = 0;
+	return 0;
 }
 
 static void
@@ -3245,20 +3249,15 @@ __nfs4_state_start(void)
 	set_max_delegations();
 }
 
-int
+void
 nfs4_state_start(void)
 {
-	int status;
-
 	if (nfs4_init)
-		return 0;
-	status = nfsd4_init_slabs();
-	if (status)
-		return status;
+		return;
 	nfsd4_load_reboot_recovery_data();
 	__nfs4_state_start();
 	nfs4_init = 1;
-	return 0;
+	return;
 }
 
 int
@@ -3316,7 +3315,6 @@ nfs4_state_shutdown(void)
 	nfs4_lock_state();
 	nfs4_release_reclaim();
 	__nfs4_state_shutdown();
-	nfsd4_free_slabs();
 	nfs4_unlock_state();
 }
 
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index baac89d..d135f5f 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -679,11 +679,13 @@ static int __init init_nfsd(void)
 	int retval;
 	printk(KERN_INFO "Installing knfsd (copyright (C) 1996 okir@monad.swb.de).\n");
 
+	retval = nfs4_state_init(); /* nfs4 locking state */
+	if (retval)
+		return retval;
 	nfsd_stat_init();	/* Statistics */
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
-	nfs4_state_init();	/* NFSv4 locking state */
 	nfsd_idmap_init();      /* Name to ID mapping */
 	if (proc_mkdir("fs/nfs", NULL)) {
 		struct proc_dir_entry *entry;
@@ -712,6 +714,7 @@ static void __exit exit_nfsd(void)
 	nfsd_stat_shutdown();
 	nfsd_lockd_shutdown();
 	nfsd_idmap_shutdown();
+	nfsd4_free_slabs();
 	unregister_filesystem(&nfsd_fs_type);
 }
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index ef46f32..1190aea 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -349,9 +349,7 @@ nfsd_svc(unsigned short port, int nrservs)
 	error =	nfsd_racache_init(2*nrservs);
 	if (error<0)
 		goto out;
-	error = nfs4_state_start();
-	if (error<0)
-		goto out;
+	nfs4_state_start();
 
 	nfsd_reset_versions();
 
diff --git a/include/linux/nfsd/nfsd.h b/include/linux/nfsd/nfsd.h
index e452256..604a0d7 100644
--- a/include/linux/nfsd/nfsd.h
+++ b/include/linux/nfsd/nfsd.h
@@ -153,19 +153,21 @@ extern int nfsd_max_blksize;
  */
 #ifdef CONFIG_NFSD_V4
 extern unsigned int max_delegations;
-void nfs4_state_init(void);
-int nfs4_state_start(void);
+int nfs4_state_init(void);
+void nfsd4_free_slabs(void);
+void nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
 #else
-static inline void nfs4_state_init(void){};
-static inline int nfs4_state_start(void){return 0;}
-static inline void nfs4_state_shutdown(void){}
-static inline time_t nfs4_lease_time(void){return 0;}
-static inline void nfs4_reset_lease(time_t leasetime){}
-static inline int nfs4_reset_recoverydir(char *recdir) {return 0;}
+static inline int nfs4_state_init(void) { return 0; }
+static inline void nfsd4_free_slabs(void) { }
+static inline void nfs4_state_start(void) { }
+static inline void nfs4_state_shutdown(void) { }
+static inline time_t nfs4_lease_time(void) { return 0; }
+static inline void nfs4_reset_lease(time_t leasetime) { }
+static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
 #endif
 
 /*
-- 
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
