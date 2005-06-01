From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 009 of 28] nfsd4: clean up state initialization
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006i7-GK@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3I-0005vv-WE
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:09 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3H-0002Pb-BL
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:08 -0700
To: Andrew Morton <akpm@osdl.org>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Separate out stuff that needs initialization on startup from stuff that
only needs initialization on module init from static data.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c       |   35 +++++++++++++++++------------------
 ./fs/nfsd/nfsctl.c          |    1 +
 ./include/linux/nfsd/nfsd.h |    2 ++
 3 files changed, 20 insertions(+), 18 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:21:00.000000000 +1000
@@ -117,7 +117,7 @@ static void release_stateid(struct nfs4_
  */
 
 /* recall_lock protects the del_recall_lru */
-spinlock_t recall_lock;
+spinlock_t recall_lock = SPIN_LOCK_UNLOCKED;
 static struct list_head del_recall_lru;
 
 static void
@@ -3179,23 +3179,13 @@ nfs4_check_open_reclaim(clientid_t *clid
 	return nfs4_find_reclaim_client(clid) ? nfs_ok : nfserr_reclaim_bad;
 }
 
+/* initialization to perform at module load time: */
 
-/* 
- * Start and stop routines
- */
-
-static void
-__nfs4_state_start(void)
+void
+nfs4_state_init(void)
 {
 	int i;
-	time_t grace_time;
 
-	if (!nfs4_reclaim_init) {
-		for (i = 0; i < CLIENT_HASH_SIZE; i++)
-			INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
-		reclaim_str_hashtbl_size = 0;
-		nfs4_reclaim_init = 1;
-	}
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
@@ -3217,19 +3207,28 @@ __nfs4_state_start(void)
 		INIT_LIST_HEAD(&lock_ownerid_hashtbl[i]);
 		INIT_LIST_HEAD(&lock_ownerstr_hashtbl[i]);
 	}
-	memset(&zerostateid, 0, sizeof(stateid_t));
 	memset(&onestateid, ~0, sizeof(stateid_t));
-
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
 	INIT_LIST_HEAD(&del_recall_lru);
-	spin_lock_init(&recall_lock);
+	for (i = 0; i < CLIENT_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
+	reclaim_str_hashtbl_size = 0;
+	nfs4_reclaim_init = 1;
+}
+
+/* initialization to perform when the nfsd service is started: */
+
+static void
+__nfs4_state_start(void)
+{
+	time_t grace_time;
+
 	boot_time = get_seconds();
 	grace_time = max(user_lease_time, lease_time);
 	lease_time = user_lease_time;
 	printk("NFSD: starting %ld-second grace period\n", grace_time);
 	grace_end = boot_time + grace_time;
-	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
 	queue_delayed_work(laundry_wq, &laundromat_work, NFSD_LEASE_TIME*HZ);
 }

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2005-05-31 14:21:00.000000000 +1000
@@ -397,6 +397,7 @@ static int __init init_nfsd(void)
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
+	nfs4_state_init();	/* NFSv4 locking state */
 #ifdef CONFIG_NFSD_V4
 	nfsd_idmap_init();      /* Name to ID mapping */
 #endif /* CONFIG_NFSD_V4 */

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2005-05-31 14:21:00.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2005-05-31 14:21:00.000000000 +1000
@@ -145,11 +145,13 @@ int nfsd_set_posix_acl(struct svc_fh *, 
  * NFSv4 State
  */
 #ifdef CONFIG_NFSD_V4
+void nfs4_state_init(void);
 int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 time_t nfs4_lease_time(void);
 void nfs4_reset_lease(time_t leasetime);
 #else
+static inline void nfs4_state_init(void){};
 static inline int nfs4_state_start(void){return 0;}
 static inline void nfs4_state_shutdown(void){}
 static inline time_t nfs4_lease_time(void){return 0;}


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
