From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 9 of 9] Allow user to set NFSv4 lease time.
Date: Thu, 24 Jun 2004 14:46:52 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8S-0001Lz-2r@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8v-000263-Dt
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:21 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8u-0007FE-2b
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:20 -0700
To: Andrew Morton <akpm@osdl.org>
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



Allow the lease to be set from /proc/fs/nfs/nfsv4leasetime.

To comply with rfc3530, this appears as a server reboot from the point of view
of the client, which must reclaim state with the grace period.

>From Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c         |    9 -
 ./fs/nfsd/nfs4state.c        |  222 ++++++++++++++++++++++++++++++++++++++++---
 ./fs/nfsd/nfsctl.c           |   31 +++++-
 ./include/linux/nfsd/nfsd.h  |    6 -
 ./include/linux/nfsd/state.h |   15 ++
 5 files changed, 263 insertions(+), 20 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-06-23 14:40:28.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-06-23 14:49:46.000000000 +1000
@@ -135,9 +135,11 @@ do_open_fhandle(struct svc_rqst *rqstp, 
 {
 	int status;
 
-	dprintk("NFSD: do_open_fhandle\n");
+	/* Only reclaims from previously confirmed clients are valid */
+	if ((status = nfs4_check_open_reclaim(&open->op_clientid)))
+		return status;
 
-	/* we don't know the target directory, and therefore can not
+	/* We don't know the target directory, and therefore can not
 	* set the change info
 	*/
 
@@ -172,8 +174,7 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	if (nfs4_in_grace() && open->op_claim_type != NFS4_OPEN_CLAIM_PREVIOUS)
 		return nfserr_grace;
 
-	if (nfs4_in_no_grace() &&
-		           open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
+	if (!nfs4_in_grace() && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
 		return nfserr_no_grace;
 
 	/* This check required by spec. */

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-06-23 14:37:55.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2004-06-23 14:49:46.000000000 +1000
@@ -51,6 +51,9 @@
 #define NFSDDBG_FACILITY                NFSDDBG_PROC
 
 /* Globals */
+static time_t lease_time = 90;     /* default lease time */
+static time_t old_lease_time = 90; /* past incarnation lease time */
+static u32 nfs4_reclaim_init = 0;
 time_t boot_time;
 static time_t grace_end = 0;
 static u32 current_clientid = 1;
@@ -82,7 +85,7 @@ struct nfs4_stateid * find_stateid(state
  * 	protects clientid_hashtbl[], clientstr_hashtbl[],
  * 	unconfstr_hashtbl[], uncofid_hashtbl[].
  */
-static struct semaphore client_sema;
+static DECLARE_MUTEX(client_sema);
 
 void
 nfs4_lock_state(void)
@@ -131,8 +134,11 @@ static void release_file(struct nfs4_fil
 	((id) & CLIENT_HASH_MASK)
 #define clientstr_hashval(name, namelen) \
 	(opaque_hashval((name), (namelen)) & CLIENT_HASH_MASK)
-
-/* conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
+/*
+ * reclaim_str_hashtbl[] holds known client info from previous reset/reboot
+ * used in reboot/reset lease grace period processing
+ * 
+ * conf_id_hashtbl[], and conf_str_hashtbl[] hold confirmed
  * setclientid_confirmed info. 
  *
  * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
@@ -144,6 +150,8 @@ static void release_file(struct nfs4_fil
  * close_lru holds (open) stateowner queue ordered by nfs4_stateowner.so_time
  * for last close replay.
  */
+static struct list_head	reclaim_str_hashtbl[CLIENT_HASH_SIZE];
+static int reclaim_str_hashtbl_size;
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
@@ -1693,6 +1701,17 @@ check_replay:
 }
 
 /*
+ * eventually, this will perform an upcall to the 'state daemon' as well as
+ * set the cl_first_state field.
+ */
+void
+first_state(struct nfs4_client *clp)
+{
+	if (!clp->cl_first_state)
+		clp->cl_first_state = get_seconds();
+}
+
+/*
  * nfs4_unlock_state(); called in encode
  */
 int
@@ -1729,6 +1748,7 @@ nfsd4_open_confirm(struct svc_rqst *rqst
 		         stp->st_stateid.si_fileid,
 		         stp->st_stateid.si_generation);
 	status = nfs_ok;
+	first_state(sop->so_client);
 out:
 	return status;
 }
@@ -2078,7 +2098,7 @@ nfsd4_lock(struct svc_rqst *rqstp, struc
 
 	if (nfs4_in_grace() && !lock->lk_reclaim)
 		return nfserr_grace;
-	if (nfs4_in_no_grace() && lock->lk_reclaim)
+	if (!nfs4_in_grace() && lock->lk_reclaim)
 		return nfserr_no_grace;
 
 	if (check_lock_length(lock->lk_offset, lock->lk_length))
@@ -2467,6 +2487,112 @@ out:
 	return status;
 }
 
+static inline struct nfs4_client_reclaim *
+alloc_reclaim(int namelen)
+{
+	struct nfs4_client_reclaim *crp = NULL;
+
+	crp = kmalloc(sizeof(struct nfs4_client_reclaim), GFP_KERNEL);
+	if (!crp)
+		return NULL;
+	crp->cr_name.data = kmalloc(namelen, GFP_KERNEL);
+	if (!crp->cr_name.data) {
+		kfree(crp);
+		return NULL;
+	}
+       	return crp;
+}
+
+/*
+ * failure => all reset bets are off, nfserr_no_grace...
+ */
+static int
+nfs4_client_to_reclaim(struct nfs4_client *clp)
+{
+	unsigned int strhashval;
+	struct nfs4_client_reclaim *crp = NULL;
+
+	crp = alloc_reclaim(clp->cl_name.len);
+	if (!crp)
+		return 0;
+	strhashval = clientstr_hashval(clp->cl_name.data, clp->cl_name.len);
+	INIT_LIST_HEAD(&crp->cr_strhash);
+	list_add(&crp->cr_strhash, &reclaim_str_hashtbl[strhashval]);
+	memcpy(crp->cr_name.data, clp->cl_name.data, clp->cl_name.len);
+	crp->cr_name.len = clp->cl_name.len;
+	crp->cr_first_state = clp->cl_first_state;
+	crp->cr_expired = 0;
+	return 1;
+}
+
+static void
+nfs4_release_reclaim(void)
+{
+	struct nfs4_client_reclaim *crp = NULL;
+	int i;
+
+	BUG_ON(!nfs4_reclaim_init);
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		while (!list_empty(&reclaim_str_hashtbl[i])) {
+			crp = list_entry(reclaim_str_hashtbl[i].next,
+			                struct nfs4_client_reclaim, cr_strhash);
+			list_del(&crp->cr_strhash);
+			kfree(crp->cr_name.data);
+			kfree(crp);
+			reclaim_str_hashtbl_size--;
+		}
+	}
+	BUG_ON(reclaim_str_hashtbl_size);
+}
+
+/*
+ * called from OPEN, CLAIM_PREVIOUS with a new clientid. */
+struct nfs4_client_reclaim *
+nfs4_find_reclaim_client(clientid_t *clid)
+{
+	unsigned int idhashval = clientid_hashval(clid->cl_id);
+	unsigned int strhashval;
+	struct nfs4_client *clp, *client = NULL;
+	struct nfs4_client_reclaim *crp = NULL;
+
+
+	/* find clientid in conf_id_hashtbl */
+	list_for_each_entry(clp, &conf_id_hashtbl[idhashval], cl_idhash) {
+		if (cmp_clid(&clp->cl_clientid, clid)) {
+			client = clp;
+			break;
+		}
+	}
+	if (!client)
+		return NULL;
+
+	/* find clp->cl_name in reclaim_str_hashtbl */
+	strhashval = clientstr_hashval(client->cl_name.data, 
+	                              client->cl_name.len);
+	list_for_each_entry(crp, &reclaim_str_hashtbl[strhashval], cr_strhash) {
+		if(cmp_name(&crp->cr_name, &client->cl_name)) {
+			return crp;
+		}
+	}
+	return NULL;
+}
+
+/*
+* Called from OPEN. Look for clientid in reclaim list.
+*/
+int
+nfs4_check_open_reclaim(clientid_t *clid)
+{
+	struct nfs4_client_reclaim *crp;
+
+	if ((crp = nfs4_find_reclaim_client(clid)) == NULL)
+		return nfserr_reclaim_bad;
+	if (crp->cr_expired)
+		return nfserr_no_grace;
+	return nfs_ok;
+}
+
+
 /* 
  * Start and stop routines
  */
@@ -2475,10 +2601,16 @@ void 
 nfs4_state_init(void)
 {
 	int i;
-	time_t start = get_seconds();
+	time_t grace_time;
 
 	if (nfs4_init)
 		return;
+	if (!nfs4_reclaim_init) {
+		for (i = 0; i < CLIENT_HASH_SIZE; i++)
+			INIT_LIST_HEAD(&reclaim_str_hashtbl[i]);
+		reclaim_str_hashtbl_size = 0;
+		nfs4_reclaim_init = 1;
+	}
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
@@ -2505,27 +2637,36 @@ nfs4_state_init(void)
 
 	INIT_LIST_HEAD(&close_lru);
 	INIT_LIST_HEAD(&client_lru);
-	init_MUTEX(&client_sema);
-	boot_time = start;
-	grace_end = start + NFSD_LEASE_TIME;
+	boot_time = get_seconds();
+	grace_time = max(old_lease_time, lease_time);
+	if (reclaim_str_hashtbl_size == 0)
+		grace_time = 0;
+	if (grace_time)
+		printk("NFSD: starting %ld-second grace period\n", grace_time);
+	grace_end = boot_time + grace_time;
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
 	nfs4_init = 1;
-
 }
 
 int
 nfs4_in_grace(void)
 {
-	return time_before(get_seconds(), (unsigned long)grace_end);
+	return get_seconds() < grace_end;
 }
 
-int
-nfs4_in_no_grace(void)
+void
+set_no_grace(void)
 {
-	return (grace_end < get_seconds());
+	printk("NFSD: ERROR in reboot recovery.  State reclaims will fail.\n");
+	grace_end = get_seconds();
 }
 
+time_t
+nfs4_lease_time(void)
+{
+	return lease_time;
+}
 
 static void
 __nfs4_state_shutdown(void)
@@ -2563,6 +2704,61 @@ void
 nfs4_state_shutdown(void)
 {
 	nfs4_lock_state();
+	nfs4_release_reclaim();
+	__nfs4_state_shutdown();
+	nfs4_unlock_state();
+}
+
+/*
+ * Called when leasetime is changed.
+ *
+ * if nfsd is not started, simply set the global lease.
+ *
+ * if nfsd(s) are running, lease change requires nfsv4 state to be reset.
+ * e.g: boot_time is reset, existing nfs4_client structs are
+ * used to fill reclaim_str_hashtbl, then all state (except for the
+ * reclaim_str_hashtbl) is re-initialized.
+ *
+ * if the old lease time is greater than the new lease time, the grace
+ * period needs to be set to the old lease time to allow clients to reclaim
+ * their state. XXX - we may want to set the grace period == lease time
+ * after an initial grace period == old lease time
+ * 
+ * if an error occurs in this process, the new lease is set, but the server
+ * will not honor OPEN or LOCK reclaims, and will return nfserr_no_grace
+ * which means OPEN/LOCK/READ/WRITE will fail during grace period.
+ *
+ * clients will attempt to reset all state with SETCLIENTID/CONFIRM, and
+ * OPEN and LOCK reclaims.
+ */
+void
+nfs4_reset_lease(time_t leasetime)
+{
+	struct nfs4_client *clp;
+	int i;
+
+	printk("NFSD: New leasetime %ld\n",leasetime);
+	if (!nfs4_init)
+		return;
+	nfs4_lock_state();
+	old_lease_time = lease_time;
+	lease_time = leasetime;
+
+	nfs4_release_reclaim();
+
+	/* populate reclaim_str_hashtbl with current confirmed nfs4_clientid */
+	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
+		list_for_each_entry(clp, &conf_id_hashtbl[i], cl_idhash) {
+			if (!nfs4_client_to_reclaim(clp)) {
+				nfs4_release_reclaim();
+				goto init_state;
+			}
+			reclaim_str_hashtbl_size++;
+		}
+	}
+init_state:
 	__nfs4_state_shutdown();
+	nfs4_state_init();
 	nfs4_unlock_state();
 }
+

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2004-06-23 14:51:41.000000000 +1000
@@ -36,7 +36,7 @@
 #include <asm/uaccess.h>
 
 /*
- *	We have a single directory with 8 nodes in it.
+ *	We have a single directory with 9 nodes in it.
  */
 enum {
 	NFSD_Root = 1,
@@ -50,6 +50,7 @@ enum {
 	NFSD_List,
 	NFSD_Fh,
 	NFSD_Threads,
+	NFSD_Leasetime,
 };
 
 /*
@@ -64,6 +65,7 @@ static ssize_t write_getfd(struct file *
 static ssize_t write_getfs(struct file *file, char *buf, size_t size);
 static ssize_t write_filehandle(struct file *file, char *buf, size_t size);
 static ssize_t write_threads(struct file *file, char *buf, size_t size);
+static ssize_t write_leasetime(struct file *file, char *buf, size_t size);
 
 static ssize_t (*write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Svc] = write_svc,
@@ -75,6 +77,7 @@ static ssize_t (*write_op[])(struct file
 	[NFSD_Getfs] = write_getfs,
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_Threads] = write_threads,
+	[NFSD_Leasetime] = write_leasetime,
 };
 
 /* an argresp is stored in an allocated page and holds the 
@@ -393,6 +396,29 @@ static ssize_t write_threads(struct file
 	return strlen(buf);
 }
 
+extern time_t nfs4_leasetime(void);
+
+static ssize_t write_leasetime(struct file *file, char *buf, size_t size)
+{
+	/* if size > 10 seconds, call 
+	 * nfs4_reset_lease() then write out the new lease (seconds) as reply
+	 */
+	char *mesg = buf;
+	int rv;
+
+	if (size > 0) {
+		int lease;
+		rv = get_int(&mesg, &lease);
+		if (rv)
+			return rv;
+		if (lease < 10 || lease > 3600)
+			return -EINVAL;
+		nfs4_reset_lease(lease);
+	}
+	sprintf(buf, "%ld\n", nfs4_lease_time());
+	return strlen(buf);
+}
+
 /*----------------------------------------------------------------------------*/
 /*
  *	populating the filesystem.
@@ -411,6 +437,9 @@ static int nfsd_fill_super(struct super_
 		[NFSD_List] = {"exports", &exports_operations, S_IRUGO},
 		[NFSD_Fh] = {"filehandle", &transaction_ops, S_IWUSR|S_IRUSR},
 		[NFSD_Threads] = {"threads", &transaction_ops, S_IWUSR|S_IRUSR},
+#ifdef CONFIG_NFSD_V4
+		[NFSD_Leasetime] = {"nfsv4leasetime", &transaction_ops, S_IWUSR|S_IRUSR},
+#endif
 		/* last one */ {""}
 	};
 	return simple_fill_super(sb, 0x6e667364, nfsd_files);

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2004-06-23 14:49:46.000000000 +1000
@@ -126,9 +126,13 @@ int		nfsd_permission(struct svc_export *
 #ifdef CONFIG_NFSD_V4
 void nfs4_state_init(void);
 void nfs4_state_shutdown(void);
+time_t nfs4_lease_time(void);
+void nfs4_reset_lease(time_t leasetime);
 #else
 void static inline nfs4_state_init(void){}
 void static inline nfs4_state_shutdown(void){}
+time_t static inline nfs4_lease_time(void){return 0;}
+void static inline nfs4_reset_lease(time_t leasetime){}
 #endif
 
 /*
@@ -249,7 +253,7 @@ static inline int is_fsid(struct svc_fh 
 #define	COMPOUND_SLACK_SPACE		140    /* OP_GETFH */
 #define COMPOUND_ERR_SLACK_SPACE	12     /* OP_SETATTR */
 
-#define NFSD_LEASE_TIME			60  /* seconds */
+#define NFSD_LEASE_TIME                 (nfs4_lease_time())
 #define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
 
 /*

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2004-06-23 14:38:35.000000000 +1000
+++ ./include/linux/nfsd/state.h	2004-06-23 14:50:18.000000000 +1000
@@ -105,6 +105,19 @@ struct nfs4_client {
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
 	struct nfs4_callback	cl_callback;    /* callback info */
+	time_t			cl_first_state; /* first state aquisition*/
+};
+
+/* struct nfs4_client_reset  
+ * one per old client. Populates reset_str_hashtbl. Filled from conf_id_hashtbl 
+ * upon lease reset, or from upcall to state_daemon (to read in state 
+ * from non-volitile storage) upon reboot.
+ */
+struct nfs4_client_reclaim {
+	struct list_head	cr_strhash;	/* hash by cr_name */
+	struct xdr_netobj 	cr_name; 	/* id generated by client */
+	time_t			cr_first_state; /* first state aquisition */
+	u32			cr_expired;     /* boolean: lease expired? */
 };
 
 static inline void
@@ -234,5 +247,5 @@ extern int nfs4_share_conflict(struct sv
 extern void nfs4_lock_state(void);
 extern void nfs4_unlock_state(void);
 extern int nfs4_in_grace(void);
-extern int nfs4_in_no_grace(void);
+extern int nfs4_check_open_reclaim(clientid_t *clid);
 #endif   /* NFSD4_STATE_H */


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
