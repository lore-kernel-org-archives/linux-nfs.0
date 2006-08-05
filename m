From: Olaf Kirch <okir@suse.de>
Subject: [PATCH 11/22] Change nlm_file to use a hlist
Date: Sat, 5 Aug 2006 15:06:48 +0200
Message-ID: <20060805130648.GA8070@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9Lrf-00078H-9A
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G9Lre-0003Kk-Qz
	for nfs@lists.sourceforge.net; Sat, 05 Aug 2006 06:06:51 -0700
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 951CD101B1
	for <nfs@lists.sourceforge.net>; Sat,  5 Aug 2006 15:06:48 +0200 (CEST)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Olaf Kirch <okir@suse.de>
Subject: Change nlm_file to use a hlist

  This changes struct nlm_file and the nlm_files hash table
  to use a hlist instead of the home-grown lists.

  It also increases the size of the nlm_files hash table from
  64 to 128.

Signed-off-by: Olaf Kirch <okir@suse.de>

 fs/lockd/svcsubs.c          |   42 ++++++++++++++++--------------------------
 include/linux/lockd/lockd.h |    3 +--
 2 files changed, 17 insertions(+), 28 deletions(-)

Index: build/fs/lockd/svcsubs.c
===================================================================
--- build.orig/fs/lockd/svcsubs.c
+++ build/fs/lockd/svcsubs.c
@@ -25,9 +25,9 @@
 /*
  * Global file hash table
  */
-#define FILE_HASH_BITS		5
+#define FILE_HASH_BITS		7
 #define FILE_NRHASH		(1<<FILE_HASH_BITS)
-static struct nlm_file *	nlm_files[FILE_NRHASH];
+static struct hlist_head	nlm_files[FILE_NRHASH];
 static DEFINE_MUTEX(nlm_file_mutex);
 
 #ifdef NFSD_DEBUG
@@ -82,6 +82,7 @@ u32
 nlm_lookup_file(struct svc_rqst *rqstp, struct nlm_file **result,
 					struct nfs_fh *f)
 {
+	struct hlist_node *pos;
 	struct nlm_file	*file;
 	unsigned int	hash;
 	u32		nfserr;
@@ -93,7 +94,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 	/* Lock file table */
 	mutex_lock(&nlm_file_mutex);
 
-	for (file = nlm_files[hash]; file; file = file->f_next)
+	hlist_for_each_entry(file, pos, &nlm_files[hash], f_list)
 		if (!nfs_compare_fh(&file->f_handle, f))
 			goto found;
 
@@ -105,8 +106,8 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 		goto out_unlock;
 
 	memcpy(&file->f_handle, f, sizeof(struct nfs_fh));
-	file->f_hash = hash;
 	init_MUTEX(&file->f_sema);
+	INIT_HLIST_NODE(&file->f_list);
 	INIT_LIST_HEAD(&file->f_blocks);
 
 	/* Open the file. Note that this must not sleep for too long, else
@@ -120,8 +121,7 @@ nlm_lookup_file(struct svc_rqst *rqstp, 
 		goto out_free;
 	}
 
-	file->f_next = nlm_files[hash];
-	nlm_files[hash] = file;
+	hlist_add_head(&file->f_list, &nlm_files[hash]);
 
 found:
 	dprintk("lockd: found file %p (count %d)\n", file, file->f_count);
@@ -150,22 +150,14 @@ out_free:
 static inline void
 nlm_delete_file(struct nlm_file *file)
 {
-	struct nlm_file	**fp, *f;
-
 	nlm_debug_print_file("closing file", file);
-
-	fp = nlm_files + file->f_hash;
-	while ((f = *fp) != NULL) {
-		if (f == file) {
-			*fp = file->f_next;
-			nlmsvc_ops->fclose(file->f_file);
-			kfree(file);
-			return;
-		}
-		fp = &f->f_next;
+	if (!hlist_unhashed(&file->f_list)) {
+		hlist_del(&file->f_list);
+		nlmsvc_ops->fclose(file->f_file);
+		kfree(file);
+	} else {
+		printk(KERN_WARNING "lockd: attempt to release unknown file!\n");
 	}
-
-	printk(KERN_WARNING "lockd: attempt to release unknown file!\n");
 }
 
 /*
@@ -236,13 +228,13 @@ nlm_inspect_file(struct nlm_host *host, 
 static int
 nlm_traverse_files(struct nlm_host *host, int action)
 {
-	struct nlm_file	*file, **fp;
+	struct hlist_node *pos, *next;
+	struct nlm_file	*file;
 	int		i;
 
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
-		fp = nlm_files + i;
-		while ((file = *fp) != NULL) {
+		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
 			/* Traverse locks, blocks and shares of this file
 			 * and update file->f_locks count */
 			if (nlm_inspect_file(host, file, action)) {
@@ -253,11 +245,9 @@ nlm_traverse_files(struct nlm_host *host
 			/* No more references to this file. Let go of it. */
 			if (list_empty(&file->f_blocks) && !file->f_locks
 			 && !file->f_shares && !file->f_count) {
-				*fp = file->f_next;
+				hlist_del(&file->f_list);
 				nlmsvc_ops->fclose(file->f_file);
 				kfree(file);
-			} else {
-				fp = &file->f_next;
 			}
 		}
 	}
Index: build/include/linux/lockd/lockd.h
===================================================================
--- build.orig/include/linux/lockd/lockd.h
+++ build/include/linux/lockd/lockd.h
@@ -105,7 +105,7 @@ struct nlm_rqst {
  * an NFS client.
  */
 struct nlm_file {
-	struct nlm_file *	f_next;		/* linked list */
+	struct hlist_node	f_list;		/* linked list */
 	struct nfs_fh		f_handle;	/* NFS file handle */
 	struct file *		f_file;		/* VFS file pointer */
 	struct nlm_share *	f_shares;	/* DOS shares */
@@ -113,7 +113,6 @@ struct nlm_file {
 	unsigned int		f_locks;	/* guesstimate # of locks */
 	unsigned int		f_count;	/* reference count */
 	struct semaphore	f_sema;		/* avoid concurrent access */
-	int		       	f_hash;		/* hash of f_handle */
 };
 
 /*

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
