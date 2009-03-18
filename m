From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 12/14] nfsd4: remove use of mutex for file_hashtable
Date: Wed, 18 Mar 2009 16:28:59 -0400
Message-ID: <20090318202859.GA18894@fieldses.org>
References: <1236731222-3294-8-git-send-email-bfields@fieldses.org> <1236731222-3294-9-git-send-email-bfields@fieldses.org> <1236731222-3294-10-git-send-email-bfields@fieldses.org> <1236731222-3294-11-git-send-email-bfields@fieldses.org> <1236731222-3294-12-git-send-email-bfields@fieldses.org> <1236731222-3294-13-git-send-email-bfields@fieldses.org> <49B8085E.5080808@panasas.com> <20090312000540.GB21854@fieldses.org> <49B8E8B5.4010205@panasas.com> <20090313171831.GA26916@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org,
	Alexandros Batsakis <batsakis@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37561 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbZCRU3L (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 16:29:11 -0400
In-Reply-To: <20090313171831.GA26916@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 13, 2009 at 01:18:31PM -0400, bfields wrote:
> On Thu, Mar 12, 2009 at 12:49:25PM +0200, Benny Halevy wrote:
> > On Mar. 12, 2009, 2:05 +0200, "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > > On Wed, Mar 11, 2009 at 08:52:14PM +0200, Benny Halevy wrote:
> > >>> @@ -1177,12 +1179,15 @@ find_file(struct inode *ino)
> > >>>  	unsigned int hashval = file_hashval(ino);
> > >>>  	struct nfs4_file *fp;
> > >>>  
> > >>> +	spin_lock(&recall_lock);
> > >>>  	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
> > >>>  		if (fp->fi_inode == ino) {
> > >>> +			spin_unlock(&recall_lock);
> > >> Hmm, I'm afraid there's a race here since potentially
> > >> you could take the reference on the file after it has been freed.
> > >> find_file should call get_nfs4_file if and only if it's still hashed,
> > >> i.e. atomically with looking it up on the list.
> > >>
> > >> On the same lines, the lock should be taken in put_nfs4_file
> > >> rather than in free_nfs4_file.
> > >>
> > >> That being said, I'm not sure we're unhashing the file in the right
> > >> place... it's too late for me right now but my hunch is that open
> > >> should alloc_init the nfs4_file as done today and close should unhash
> > >> it (under the recall spinlock), and then put it.
> > >> put_nfs4_file can stay the same and free_nfs4_file should just do the
> > >> iput and kmem_cache_free.
> > >>
> > >> The main difference is that find_file will fail finding the nfs4_file
> > >> struct after close.  (get_nfs4_file in find_file should still happen
> > >> under the lock though)
> > > 
> > > It's probably better for the nfs4_file to be visible longer, but either
> > > is correct.
> > 
> > I see. What matters is the stateids associated with the file.
> 
> Right.  So for now I'm taking your first suggestion.  Thanks again for
> the review.

By the way, what I've got now is the following.--b.

commit 466c8f95fa8a70335002c2002f7a6c27b65e6e93
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Sun Feb 22 14:51:34 2009 -0800

    nfsd4: remove use of mutex for file_hashtable
    
    As part of reducing the scope of the client_mutex, and in order to
    remove the need for mutexes from the callback code (so that callbacks
    can be done as asynchronous rpc calls), move manipulations of the
    file_hashtable under the recall_lock.
    
    Update the relevant comments while we're here.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
    Cc: Alexandros Batsakis <batsakis@netapp.com>
    Reviewed-by: Benny Halevy <bhalevy@panasas.com>

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 3fd7136..5dcd38e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -491,8 +491,6 @@ out_put_cred:
 	 * or deleg_return.
 	 */
 	put_nfs4_client(clp);
-	nfs4_lock_state();
 	nfs4_put_delegation(dp);
-	nfs4_unlock_state();
 	return;
 }
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fdcd7cf..a4bcfe0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -78,14 +78,18 @@ static struct nfs4_delegation * find_delegation_stateid(struct inode *ino, state
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static void nfs4_set_recdir(char *recdir);
 
-/* Locking:
- *
- * client_mutex:
- * 	protects clientid_hashtbl[], clientstr_hashtbl[],
- * 	unconfstr_hashtbl[], uncofid_hashtbl[].
- */
+/* Locking: */
+
+/* Currently used for almost all code touching nfsv4 state: */
 static DEFINE_MUTEX(client_mutex);
 
+/*
+ * Currently used for the del_recall_lru and file hash table.  In an
+ * effort to decrease the scope of the client_mutex, this spinlock may
+ * eventually cover more:
+ */
+static DEFINE_SPINLOCK(recall_lock);
+
 static struct kmem_cache *stateowner_slab = NULL;
 static struct kmem_cache *file_slab = NULL;
 static struct kmem_cache *stateid_slab = NULL;
@@ -116,33 +120,23 @@ opaque_hashval(const void *ptr, int nbytes)
 	return x;
 }
 
-/*
- * Delegation state
- */
-
-/* recall_lock protects the del_recall_lru */
-static DEFINE_SPINLOCK(recall_lock);
 static struct list_head del_recall_lru;
 
-static void
-free_nfs4_file(struct kref *kref)
-{
-	struct nfs4_file *fp = container_of(kref, struct nfs4_file, fi_ref);
-	list_del(&fp->fi_hash);
-	iput(fp->fi_inode);
-	kmem_cache_free(file_slab, fp);
-}
-
 static inline void
 put_nfs4_file(struct nfs4_file *fi)
 {
-	kref_put(&fi->fi_ref, free_nfs4_file);
+	if (atomic_dec_and_lock(&fi->fi_ref, &recall_lock)) {
+		list_del(&fi->fi_hash);
+		spin_unlock(&recall_lock);
+		iput(fi->fi_inode);
+		kmem_cache_free(file_slab, fi);
+	}
 }
 
 static inline void
 get_nfs4_file(struct nfs4_file *fi)
 {
-	kref_get(&fi->fi_ref);
+	atomic_inc(&fi->fi_ref);
 }
 
 static int num_delegations;
@@ -1000,11 +994,13 @@ alloc_init_file(struct inode *ino)
 
 	fp = kmem_cache_alloc(file_slab, GFP_KERNEL);
 	if (fp) {
-		kref_init(&fp->fi_ref);
+		atomic_set(&fp->fi_ref, 1);
 		INIT_LIST_HEAD(&fp->fi_hash);
 		INIT_LIST_HEAD(&fp->fi_stateids);
 		INIT_LIST_HEAD(&fp->fi_delegations);
+		spin_lock(&recall_lock);
 		list_add(&fp->fi_hash, &file_hashtbl[hashval]);
+		spin_unlock(&recall_lock);
 		fp->fi_inode = igrab(ino);
 		fp->fi_id = current_fileid++;
 		fp->fi_had_conflict = false;
@@ -1177,12 +1173,15 @@ find_file(struct inode *ino)
 	unsigned int hashval = file_hashval(ino);
 	struct nfs4_file *fp;
 
+	spin_lock(&recall_lock);
 	list_for_each_entry(fp, &file_hashtbl[hashval], fi_hash) {
 		if (fp->fi_inode == ino) {
 			get_nfs4_file(fp);
+			spin_unlock(&recall_lock);
 			return fp;
 		}
 	}
+	spin_unlock(&recall_lock);
 	return NULL;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 503b6bb..a6e4a00 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -214,7 +214,7 @@ struct nfs4_stateowner {
 *      share_acces, share_deny on the file.
 */
 struct nfs4_file {
-	struct kref		fi_ref;
+	atomic_t		fi_ref;
 	struct list_head        fi_hash;    /* hash by "struct inode *" */
 	struct list_head        fi_stateids;
 	struct list_head	fi_delegations;
