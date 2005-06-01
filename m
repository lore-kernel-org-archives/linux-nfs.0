From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 006 of 28] nfsd4: simplify lease changing
Date: Thu, 02 Jun 2005 08:50:56 +1000
Message-ID: <E1Ddc36-0006hw-9Y@notabene.cse.unsw.edu.au>
References: <20050602084410.25538.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ddc3N-0005wv-Rn
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:13 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Ddc3L-0005Nu-Ug
	for nfs@lists.sourceforge.net; Wed, 01 Jun 2005 15:51:13 -0700
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


The only way the protocol gives to change the lease time on the fly is to
simulate a reboot.  We don't have that completely right in the current code;
among other things, we should probably put lockd in grace too while we do this.

For now, let's just keep this simple, and wait till the next time nfsd starts
to register any changes in lease time.  If the administrator really wants to
change the lease time *now*, they can go ahead and bring nfsd down and then
back up again after changing the lease time.

Also remove the "if (reclaim_str_hashtbl_size == 0)" case, a shortcut which
skips the grace period if we know of no clients in need of recovery.  This
isn't going to work well with nlm.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   63 +++++++++-----------------------------------------
 1 files changed, 12 insertions(+), 51 deletions(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2005-05-31 14:20:59.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2005-05-31 14:20:59.000000000 +1000
@@ -53,7 +53,7 @@
 
 /* Globals */
 static time_t lease_time = 90;     /* default lease time */
-static time_t old_lease_time = 90; /* past incarnation lease time */
+static time_t user_lease_time = 90;
 static u32 nfs4_reclaim_init = 0;
 time_t boot_time;
 static time_t grace_end = 0;
@@ -3205,11 +3205,9 @@ __nfs4_state_init(void)
 	INIT_LIST_HEAD(&del_recall_lru);
 	spin_lock_init(&recall_lock);
 	boot_time = get_seconds();
-	grace_time = max(old_lease_time, lease_time);
-	if (reclaim_str_hashtbl_size == 0)
-		grace_time = 0;
-	if (grace_time)
-		printk("NFSD: starting %ld-second grace period\n", grace_time);
+	grace_time = max(user_lease_time, lease_time);
+	lease_time = user_lease_time;
+	printk("NFSD: starting %ld-second grace period\n", grace_time);
 	grace_end = boot_time + grace_time;
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	laundry_wq = create_singlethread_workqueue("nfsd4");
@@ -3307,53 +3305,16 @@ nfs4_state_shutdown(void)
 /*
  * Called when leasetime is changed.
  *
- * if nfsd is not started, simply set the global lease.
- *
- * if nfsd(s) are running, lease change requires nfsv4 state to be reset.
- * e.g: boot_time is reset, existing nfs4_client structs are
- * used to fill reclaim_str_hashtbl, then all state (except for the
- * reclaim_str_hashtbl) is re-initialized.
- *
- * if the old lease time is greater than the new lease time, the grace
- * period needs to be set to the old lease time to allow clients to reclaim
- * their state. XXX - we may want to set the grace period == lease time
- * after an initial grace period == old lease time
- *
- * if an error occurs in this process, the new lease is set, but the server
- * will not honor OPEN or LOCK reclaims, and will return nfserr_no_grace
- * which means OPEN/LOCK/READ/WRITE will fail during grace period.
- *
- * clients will attempt to reset all state with SETCLIENTID/CONFIRM, and
- * OPEN and LOCK reclaims.
+ * The only way the protocol gives us to handle on-the-fly lease changes is to
+ * simulate a reboot.  Instead of doing that, we just wait till the next time
+ * we start to register any changes in lease time.  If the administrator
+ * really wants to change the lease time *now*, they can go ahead and bring
+ * nfsd down and then back up again after changing the lease time.
  */
 void
 nfs4_reset_lease(time_t leasetime)
 {
-	struct nfs4_client *clp;
-	int i;
-
-	printk("NFSD: New leasetime %ld\n",leasetime);
-	if (!nfs4_init)
-		return;
-	nfs4_lock_state();
-	old_lease_time = lease_time;
-	lease_time = leasetime;
-
-	nfs4_release_reclaim();
-
-	/* populate reclaim_str_hashtbl with current confirmed nfs4_clientid */
-	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
-		list_for_each_entry(clp, &conf_id_hashtbl[i], cl_idhash) {
-			if (!nfs4_client_to_reclaim(clp->cl_name.data,
-						clp->cl_name.len)) {
-				nfs4_release_reclaim();
-				goto init_state;
-			}
-		}
-	}
-init_state:
-	__nfs4_state_shutdown();
-	__nfs4_state_init();
-	nfs4_unlock_state();
+	lock_kernel();
+	user_lease_time = leasetime;
+	unlock_kernel();
 }
-


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
