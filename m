From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 6 of 8 - RENEW and lease management for NFSv4 server
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-00083r-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBP-0002U8-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:11 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:28 +1000
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

From: "William A.(Andy) Adamson" <andros@citi.umich.edu>

Put all clients in a LRU list and use a "work_queue" to 
expire old clients periodically.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c         |    6 --
 ./fs/nfsd/nfs4state.c        |  122 ++++++++++++++++++++++++++++++++++++++++---
 ./include/linux/nfsd/nfsd.h  |    1 
 ./include/linux/nfsd/state.h |    5 +
 4 files changed, 121 insertions(+), 13 deletions(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2003-06-18 09:30:53.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2003-06-18 09:30:53.000000000 +1000
@@ -147,12 +147,6 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	return 0;
 }
 
-static inline int
-nfsd4_renew(clientid_t *clientid)
-{
-	return nfs_ok;
-}
-
 /*
  * filehandle-manipulating ops.
  */

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-06-18 09:30:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-06-18 09:30:53.000000000 +1000
@@ -43,6 +43,7 @@
 #include <linux/nfsd/nfsd.h>
 #include <linux/nfsd/cache.h>
 #include <linux/mount.h>
+#include <linux/workqueue.h>
 #include <linux/nfs4.h>
 #include <linux/nfsd/state.h>
 #include <linux/nfsd/xdr4.h>
@@ -105,11 +106,28 @@ static void release_stateid(struct nfs4_
  *
  * unconf_str_hastbl[] and unconf_id_hashtbl[] hold unconfirmed 
  * setclientid info.
+ *
+ * client_lru holds client queue ordered by nfs4_client.cl_time
+ * for lease renewal.
  */
 static struct list_head	conf_id_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	conf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_str_hashtbl[CLIENT_HASH_SIZE];
 static struct list_head	unconf_id_hashtbl[CLIENT_HASH_SIZE];
+static struct list_head client_lru;
+
+static inline void
+renew_client(struct nfs4_client *clp)
+{
+	/*
+	* Move client to the end to the LRU list.
+	*/
+	dprintk("renewing client (clientid %08x/%08x)\n", 
+			clp->cl_clientid.cl_boot, 
+			clp->cl_clientid.cl_id);
+	list_move_tail(&clp->cl_lru, &client_lru);
+	clp->cl_time = get_seconds();
+}
 
 /* SETCLIENTID and SETCLIENTID_CONFIRM Helper functions */
 static int
@@ -160,6 +178,7 @@ expire_client(struct nfs4_client *clp)
 	dprintk("NFSD: expire_client\n");
 	list_del(&clp->cl_idhash);
 	list_del(&clp->cl_strhash);
+	list_del(&clp->cl_lru);
 	while (!list_empty(&clp->cl_perclient)) {
 		sop = list_entry(clp->cl_perclient.next, struct nfs4_stateowner, so_perclient);
 		release_stateowner(sop);
@@ -176,6 +195,7 @@ create_client(struct xdr_netobj name) {
 	INIT_LIST_HEAD(&clp->cl_idhash);
 	INIT_LIST_HEAD(&clp->cl_strhash);
 	INIT_LIST_HEAD(&clp->cl_perclient);
+	INIT_LIST_HEAD(&clp->cl_lru);
 out:
 	return clp;
 }
@@ -264,6 +284,8 @@ add_to_unconfirmed(struct nfs4_client *c
 	list_add(&clp->cl_strhash, &unconf_str_hashtbl[strhashval]);
 	idhashval = clientid_hashval(clp->cl_clientid.cl_id);
 	list_add(&clp->cl_idhash, &unconf_id_hashtbl[idhashval]);
+	list_add_tail(&clp->cl_lru, &client_lru);
+	clp->cl_time = get_seconds();
 }
 
 void
@@ -271,13 +293,13 @@ move_to_confirmed(struct nfs4_client *cl
 {
 	unsigned int strhashval;
 
-	printk("ANDROS: move_to_confirm nfs4_client %p\n", clp);
 	list_del_init(&clp->cl_strhash);
 	list_del_init(&clp->cl_idhash);
 	list_add(&clp->cl_idhash, &conf_id_hashtbl[idhashval]);
 	strhashval = clientstr_hashval(clp->cl_name.data, 
 			clp->cl_name.len);
 	list_add(&clp->cl_strhash, &conf_str_hashtbl[strhashval]);
+	renew_client(clp);
 }
 
 /*
@@ -940,9 +962,7 @@ instantiate_new_owner:
 	open->op_stateowner = sop;
 	status = nfs_ok;
 renew:
-	/* XXX implement LRU and state recovery thread 
-	 * renew will place nfs4_client at end of LRU 
-	 */
+	renew_client(sop->so_client);
 out:
 	up(&client_sema); /*XXX need finer grained locking */
 	return status;
@@ -1048,11 +1068,94 @@ out_free:
 	kfree(stp);
 	goto out;
 }
+static struct work_struct laundromat_work;
+static void laundromat_main(void *);
+static DECLARE_WORK(laundromat_work, laundromat_main, NULL);
+
+int 
+nfsd4_renew(clientid_t *clid)
+{
+	struct nfs4_client *clp;
+	struct list_head *pos, *next;
+	unsigned int idhashval;
+	int status;
+
+	down(&client_sema);
+	printk("process_renew(%08x/%08x): starting\n", 
+			clid->cl_boot, clid->cl_id);
+	status = nfserr_stale_clientid;
+	if (STALE_CLIENTID(clid))
+		goto out;
+	status = nfs_ok;
+	idhashval = clientid_hashval(clid->cl_id);
+	list_for_each_safe(pos, next, &conf_id_hashtbl[idhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+		if (!cmp_clid(&clp->cl_clientid, clid))
+			continue;
+		renew_client(clp);
+		goto out;
+	}
+	list_for_each_safe(pos, next, &unconf_id_hashtbl[idhashval]) {
+		clp = list_entry(pos, struct nfs4_client, cl_idhash);
+		if (!cmp_clid(&clp->cl_clientid, clid))
+			continue;
+		renew_client(clp);
+	goto out;
+	}
+	/*
+	* Couldn't find an nfs4_client for this clientid.  
+	* Presumably this is because the client took too long to 
+	* RENEW, so return NFS4ERR_EXPIRED.
+	*/
+	printk("nfsd4_renew: clientid not found!\n");
+	status = nfserr_expired;
+out:
+	up(&client_sema);
+	return status;
+}
+
+time_t
+nfs4_laundromat(void)
+{
+	struct nfs4_client *clp;
+	struct list_head *pos, *next;
+	time_t cutoff = get_seconds() - NFSD_LEASE_TIME;
+	time_t t, return_val = NFSD_LEASE_TIME;
+
+	down(&client_sema);
+
+	dprintk("NFSD: laundromat service - starting, examining clients\n");
+	list_for_each_safe(pos, next, &client_lru) {
+		clp = list_entry(pos, struct nfs4_client, cl_lru);
+		if (time_after((unsigned long)clp->cl_time, (unsigned long)cutoff)) {
+			t = clp->cl_time - cutoff;
+			if (return_val > t)
+				return_val = t;
+			break;
+		}
+		dprintk("NFSD: purging unused client (clientid %08x)\n",
+			clp->cl_clientid.cl_id);
+		expire_client(clp);
+	}
+	if (return_val < NFSD_LAUNDROMAT_MINTIMEOUT)
+		return_val = NFSD_LAUNDROMAT_MINTIMEOUT;
+	up(&client_sema); 
+	return return_val;
+}
+
+void
+laundromat_main(void *not_used)
+{
+	time_t t;
+
+	t = nfs4_laundromat();
+	dprintk("NFSD: laundromat_main - sleeping for %ld seconds\n", t);
+	schedule_delayed_work(&laundromat_work, t*HZ);
+}
 
 void 
 nfs4_state_init(void)
 {
-	struct timespec 	tv;
 	int i;
 
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
@@ -1067,9 +1170,12 @@ nfs4_state_init(void)
 	for (i = 0; i < OWNER_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&ownerstr_hashtbl[i]);
 	}
+	INIT_LIST_HEAD(&client_lru);
 	init_MUTEX(&client_sema);
-	tv = CURRENT_TIME;
-	boot_time = tv.tv_sec;
+	boot_time = get_seconds();
+	INIT_WORK(&laundromat_work,laundromat_main, NULL);
+	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
+
 }
 
 static void
@@ -1089,6 +1195,8 @@ __nfs4_state_shutdown(void)
 		}
 	}
 	release_all_files();
+	cancel_delayed_work(&laundromat_work);
+	flush_scheduled_work();
 	dprintk("NFSD: list_add_perfile %d list_del_perfile %d\n",
 			list_add_perfile, list_del_perfile);
 	dprintk("NFSD: add_perclient %d del_perclient %d\n",

diff ./include/linux/nfsd/nfsd.h~current~ ./include/linux/nfsd/nfsd.h
--- ./include/linux/nfsd/nfsd.h~current~	2003-06-18 09:30:24.000000000 +1000
+++ ./include/linux/nfsd/nfsd.h	2003-06-18 09:30:53.000000000 +1000
@@ -228,6 +228,7 @@ extern struct timeval	nfssvc_boot;
 #define COMPOUND_ERR_SLACK_SPACE	12     /* OP_SETATTR */
 
 #define NFSD_LEASE_TIME			60  /* seconds */
+#define NFSD_LAUNDROMAT_MINTIMEOUT      10   /* seconds */
 
 /*
  * The following attributes are currently not supported by the NFSv4 server:

diff ./include/linux/nfsd/state.h~current~ ./include/linux/nfsd/state.h
--- ./include/linux/nfsd/state.h~current~	2003-06-18 09:30:53.000000000 +1000
+++ ./include/linux/nfsd/state.h	2003-06-18 09:30:53.000000000 +1000
@@ -73,14 +73,19 @@ struct nfs4_client {
 	struct list_head	cl_idhash; 	/* hash by cl_clientid.id */
 	struct list_head	cl_strhash; 	/* hash by cl_name */
 	struct list_head	cl_perclient; 	/* list: stateowners */
+	struct list_head        cl_lru;         /* tail queue */
 	struct xdr_netobj	cl_name; 	/* id generated by client */
 	nfs4_verifier		cl_verifier; 	/* generated by client */
+	time_t                  cl_time;        /* time of last lease renewal */
 	u32			cl_addr; 	/* client ipaddress */
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
 	nfs4_verifier		cl_confirm;	/* generated by server */
 };
 
+extern time_t nfs4_laundromat(void);
+int nfsd4_renew(clientid_t *clid);
+
 static inline void
 update_stateid(stateid_t *stateid)
 {


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
