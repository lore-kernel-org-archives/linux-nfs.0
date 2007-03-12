From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [PATCH] [RESEND] Improve idmap parallelism
Date: Mon, 12 Mar 2007 11:19:56 -0700
Message-ID: <1173723596.19257.12.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HQp80-0006wO-2E
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 11:20:13 -0700
Received: from e5.ny.us.ibm.com ([32.97.182.145])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HQp80-00027l-Mx
	for nfs@lists.sourceforge.net; Mon, 12 Mar 2007 11:20:14 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l2CIJasl030996
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 14:19:36 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id
	l2CIJThK285464
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 14:19:29 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l2CIJTj3004567
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 14:19:29 -0400
Received: from [9.47.22.153] (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	l2CIJSuc004553
	for <nfs@lists.sourceforge.net>; Mon, 12 Mar 2007 14:19:28 -0400
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

Resend: I sent this awhile ago, but it may have been missed with the excitement of Connectathon, weddings, and honeymoons. I've verified it compiles against 2.6.21 (I originally tested it on 2.6.20).

Frank

This patch improves idmap parallelism by reducing the serialization of
idmap lookups.  Currently, each client can only process one idmap lookup
at a time, potentially delaying other lookups that might be satisfied by
the in kernel cache while waiting for a user space lookup.

The existing code uses two mutexes, but one of them is held the entire
time of the lookup.

The biggest change this patch makes is to re-order lock use so that one
lock serializes multiple user space lookups (for the same nfs_client).
This lock is only held when the kernel cache lookup fails and a user
space lookup must occur. The other lock is used to protect the in kernel
cache (a pair of hash tables). This lock is only held when the internal
cache is being accessed. Further, since most accesses are lookups, this
second lock is changed to a read-write lock.

After acquiring the mutex, a second cache lookup is made just in case a
user space lookup had been in progress for this id.

I tested this using fsstress on an SMP machine. While testing, I put in
some metering code which showed as many as 1000 cache lookups satisfied
while an upcall was in progress, and noted occasional lookups for the id
that an upcall was in progress for.

This patch was modified from an initial patch by Usha Ketineni.

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 9d4a6b2..2877a02 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -86,9 +86,9 @@ struct idmap_hashtable {
 struct idmap {
 	struct dentry        *idmap_dentry;
 	wait_queue_head_t     idmap_wq;
-	struct idmap_msg      idmap_im;
+	struct idmap_msg      idmap_im;      /* protected by mutex */
 	struct mutex          idmap_lock;    /* Serializes upcalls */
-	struct mutex          idmap_im_lock; /* Protects the hashtable */
+	rwlock_t              idmap_im_lock; /* Protects the hashtable */
 	struct idmap_hashtable idmap_user_hash;
 	struct idmap_hashtable idmap_group_hash;
 };
@@ -127,7 +127,7 @@ nfs_idmap_new(struct nfs_client *clp)
 	}
 
         mutex_init(&idmap->idmap_lock);
-        mutex_init(&idmap->idmap_im_lock);
+        rwlock_init(&idmap->idmap_im_lock);
 	init_waitqueue_head(&idmap->idmap_wq);
 	idmap->idmap_user_hash.h_type = IDMAP_TYPE_USER;
 	idmap->idmap_group_hash.h_type = IDMAP_TYPE_GROUP;
@@ -243,14 +243,28 @@ nfs_idmap_id(struct idmap *idmap, struct
idmap_hashtable *h,
 	if (namelen >= IDMAP_NAMESZ)
 		return -EINVAL;
 
+	read_lock(&idmap->idmap_im_lock);
+	he = idmap_lookup_name(h, name, namelen);
+	if (he != NULL) {
+		*id = he->ih_id;
+		read_unlock(&idmap->idmap_im_lock);
+		return 0;
+	}
+	read_unlock(&idmap->idmap_im_lock);
+
 	mutex_lock(&idmap->idmap_lock);
-	mutex_lock(&idmap->idmap_im_lock);
 
+	/* Attempt lookup again in case we blocked
+	 * because another attempt on this name
+	 * was in progress.
+	 */
+	read_lock(&idmap->idmap_im_lock);
 	he = idmap_lookup_name(h, name, namelen);
 	if (he != NULL) {
 		*id = he->ih_id;
-		ret = 0;
-		goto out;
+		read_unlock(&idmap->idmap_im_lock);
+		mutex_unlock(&idmap->idmap_lock);
+		return 0;
 	}
 
 	memset(im, 0, sizeof(*im));
@@ -270,11 +284,10 @@ nfs_idmap_id(struct idmap *idmap, struct
idmap_hashtable *h,
 	}
 
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	mutex_unlock(&idmap->idmap_im_lock);
+	read_unlock(&idmap->idmap_im_lock);
 	schedule();
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&idmap->idmap_wq, &wq);
-	mutex_lock(&idmap->idmap_im_lock);
 
 	if (im->im_status & IDMAP_STATUS_SUCCESS) {
 		*id = im->im_id;
@@ -283,7 +296,6 @@ nfs_idmap_id(struct idmap *idmap, struct
idmap_hashtable *h,
 
  out:
 	memset(im, 0, sizeof(*im));
-	mutex_unlock(&idmap->idmap_im_lock);
 	mutex_unlock(&idmap->idmap_lock);
 	return (ret);
 }
@@ -304,14 +316,30 @@ nfs_idmap_name(struct idmap *idmap, struct
idmap_hashtable *h,
 
 	im = &idmap->idmap_im;
 
+	read_lock(&idmap->idmap_im_lock);
+	he = idmap_lookup_id(h, id);
+	if (he != 0) {
+		memcpy(name, he->ih_name, he->ih_namelen);
+		ret = he->ih_namelen;
+		read_unlock(&idmap->idmap_im_lock);
+		return ret;
+	}
+	read_unlock(&idmap->idmap_im_lock);
+
 	mutex_lock(&idmap->idmap_lock);
-	mutex_lock(&idmap->idmap_im_lock);
 
+	/* Attempt lookup again in case we blocked
+	 * because another attempt on this id
+	 * was in progress.
+	 */
+	read_lock(&idmap->idmap_im_lock);
 	he = idmap_lookup_id(h, id);
 	if (he != 0) {
 		memcpy(name, he->ih_name, he->ih_namelen);
 		ret = he->ih_namelen;
-		goto out;
+		read_unlock(&idmap->idmap_im_lock);
+		mutex_unlock(&idmap->idmap_lock);
+		return ret;
 	}
 
 	memset(im, 0, sizeof(*im));
@@ -331,11 +359,10 @@ nfs_idmap_name(struct idmap *idmap, struct
idmap_hashtable *h,
 	}
 
 	set_current_state(TASK_UNINTERRUPTIBLE);
-	mutex_unlock(&idmap->idmap_im_lock);
+	read_unlock(&idmap->idmap_im_lock);
 	schedule();
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&idmap->idmap_wq, &wq);
-	mutex_lock(&idmap->idmap_im_lock);
 
 	if (im->im_status & IDMAP_STATUS_SUCCESS) {
 		if ((len = strnlen(im->im_name, IDMAP_NAMESZ)) == 0)
@@ -346,7 +373,6 @@ nfs_idmap_name(struct idmap *idmap, struct
idmap_hashtable *h,
 
  out:
 	memset(im, 0, sizeof(*im));
-	mutex_unlock(&idmap->idmap_im_lock);
 	mutex_unlock(&idmap->idmap_lock);
 	return ret;
 }
@@ -391,7 +417,7 @@ idmap_pipe_downcall(struct file *filp, const char
__user *src, size_t mlen)
         if (copy_from_user(&im_in, src, mlen) != 0)
 		return (-EFAULT);
 
-	mutex_lock(&idmap->idmap_im_lock);
+	write_lock(&idmap->idmap_im_lock);
 
 	ret = mlen;
 	im->im_status = im_in.im_status;
@@ -451,7 +477,7 @@ idmap_pipe_downcall(struct file *filp, const char
__user *src, size_t mlen)
 		idmap_update_entry(he, im_in.im_name, namelen_in, im_in.im_id);
 	ret = mlen;
 out:
-	mutex_unlock(&idmap->idmap_im_lock);
+	write_unlock(&idmap->idmap_im_lock);
 	return ret;
 }
 
@@ -463,10 +489,10 @@ idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 
 	if (msg->errno >= 0)
 		return;
-	mutex_lock(&idmap->idmap_im_lock);
+	write_lock(&idmap->idmap_im_lock);
 	im->im_status = IDMAP_STATUS_LOOKUPFAIL;
 	wake_up(&idmap->idmap_wq);
-	mutex_unlock(&idmap->idmap_im_lock);
+	write_unlock(&idmap->idmap_im_lock);
 }
 
 /* 



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
