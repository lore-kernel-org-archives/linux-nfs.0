From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 19] knfsd: Change nlm_file to use a hlist
Date: Fri, 1 Sep 2006 14:39:00 +1000
Message-ID: <1060901043900.27536@suse.de>
References: <20060901141639.27206.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Olaf Kirch <okir@suse.de>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GJ0o8-0005sR-Sp
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:10 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GJ0o8-0004Rf-Pq
	for nfs@lists.sourceforge.net; Thu, 31 Aug 2006 21:39:09 -0700
To: Andrew Morton <akpm@osdl.org>
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

  This changes struct nlm_file and the nlm_files hash table
  to use a hlist instead of the home-grown lists.

  This allows us to remove f_hash which was only used to find the right
  hash chain to delete an entry from.

  It also increases the size of the nlm_files hash table from
  32 to 128.

Signed-off-by: Olaf Kirch <okir@suse.de>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/svcsubs.c          |   42 ++++++++++++++++--------------------------
 ./include/linux/lockd/lockd.h |    3 +--
 2 files changed, 17 insertions(+), 28 deletions(-)

diff .prev/fs/lockd/svcsubs.c ./fs/lockd/svcsubs.c
--- .prev/fs/lockd/svcsubs.c	2006-09-01 10:42:51.000000000 +1000
+++ ./fs/lockd/svcsubs.c	2006-09-01 10:45:16.000000000 +1000
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
 	int i, ret = 0;
 
 	mutex_lock(&nlm_file_mutex);
 	for (i = 0; i < FILE_NRHASH; i++) {
-		fp = nlm_files + i;
-		while ((file = *fp) != NULL) {
+		hlist_for_each_entry_safe(file, pos, next, &nlm_files[i], f_list) {
 			file->f_count++;
 			mutex_unlock(&nlm_file_mutex);
 
@@ -256,11 +248,9 @@ nlm_traverse_files(struct nlm_host *host
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

diff .prev/include/linux/lockd/lockd.h ./include/linux/lockd/lockd.h
--- .prev/include/linux/lockd/lockd.h	2006-09-01 10:42:51.000000000 +1000
+++ ./include/linux/lockd/lockd.h	2006-09-01 10:45:16.000000000 +1000
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
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
