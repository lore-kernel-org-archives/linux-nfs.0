From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 7 of 8 - Do NFSv4 server state initialisation when nfsd starts instead of when module loaded.
Date: Wed, 18 Jun 2003 09:51:37 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19SQEj-000840-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19SQBV-0002YH-00
	for <nfs@lists.sourceforge.net>; Tue, 17 Jun 2003 16:48:17 -0700
Received: From notabene ([129.94.172.124] == notabene.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Wed, 18 Jun 2003 09:47:29 +1000
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

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4state.c |    5 +++++
 ./fs/nfsd/nfsctl.c    |    1 -
 ./fs/nfsd/nfssvc.c    |    1 +
 3 files changed, 6 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2003-06-18 09:30:53.000000000 +1000
+++ ./fs/nfsd/nfs4state.c	2003-06-18 09:31:07.000000000 +1000
@@ -55,6 +55,7 @@ time_t boot_time;
 static u32 current_clientid = 1;
 static u32 current_ownerid = 0;
 static u32 current_fileid = 0;
+static u32 nfs4_init = 0;
 
 /* debug counters */
 u32 list_add_perfile = 0; 
@@ -1158,6 +1159,8 @@ nfs4_state_init(void)
 {
 	int i;
 
+	if (nfs4_init)
+		return;
 	for (i = 0; i < CLIENT_HASH_SIZE; i++) {
 		INIT_LIST_HEAD(&conf_id_hashtbl[i]);
 		INIT_LIST_HEAD(&conf_str_hashtbl[i]);
@@ -1175,6 +1178,7 @@ nfs4_state_init(void)
 	boot_time = get_seconds();
 	INIT_WORK(&laundromat_work,laundromat_main, NULL);
 	schedule_delayed_work(&laundromat_work, NFSD_LEASE_TIME*HZ);
+	nfs4_init = 1;
 
 }
 
@@ -1197,6 +1201,7 @@ __nfs4_state_shutdown(void)
 	release_all_files();
 	cancel_delayed_work(&laundromat_work);
 	flush_scheduled_work();
+	nfs4_init = 0;
 	dprintk("NFSD: list_add_perfile %d list_del_perfile %d\n",
 			list_add_perfile, list_del_perfile);
 	dprintk("NFSD: add_perclient %d del_perclient %d\n",

diff ./fs/nfsd/nfsctl.c~current~ ./fs/nfsd/nfsctl.c
--- ./fs/nfsd/nfsctl.c~current~	2003-06-18 09:31:07.000000000 +1000
+++ ./fs/nfsd/nfsctl.c	2003-06-18 09:31:07.000000000 +1000
@@ -453,7 +453,6 @@ static int __init init_nfsd(void)
 	nfsd_cache_init();	/* RPC reply cache */
 	nfsd_export_init();	/* Exports table */
 	nfsd_lockd_init();	/* lockd->nfsd callbacks */
-	nfs4_state_init();      /* NFSv4 State */
 	if (proc_mkdir("fs/nfs", 0)) {
 		struct proc_dir_entry *entry;
 		entry = create_proc_entry("fs/nfs/exports", 0, NULL);

diff ./fs/nfsd/nfssvc.c~current~ ./fs/nfsd/nfssvc.c
--- ./fs/nfsd/nfssvc.c~current~	2003-06-18 09:31:07.000000000 +1000
+++ ./fs/nfsd/nfssvc.c	2003-06-18 09:31:07.000000000 +1000
@@ -91,6 +91,7 @@ nfsd_svc(unsigned short port, int nrserv
 	
 	/* Readahead param cache - will no-op if it already exists */
 	error =	nfsd_racache_init(2*nrservs);
+	nfs4_state_init();
 	if (error<0)
 		goto out;
 	if (!nfsd_serv) {


-------------------------------------------------------
This SF.Net email is sponsored by: INetU
Attention Web Developers & Consultants: Become An INetU Hosting Partner.
Refer Dedicated Servers. We Manage Them. You Get 10% Monthly Commission!
INetU Dedicated Managed Hosting http://www.inetu.net/partner/index.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
