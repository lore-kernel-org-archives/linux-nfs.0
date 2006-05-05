From: Peter Staubach <staubach@redhat.com>
Subject: Re: Re: [PATCH][RFC] NFS: Improving the access cache
Date: Fri, 05 May 2006 10:53:26 -0400
Message-ID: <445B66E6.7030700@redhat.com>
References: <444EC96B.80400@RedHat.com>	<17486.64825.942642.594218@cse.unsw.edu.au>	<444F88EF.5090105@RedHat.com> <17487.62730.16297.979429@cse.unsw.edu.au> <44572B33.4070100@RedHat.com> <445834CB.4050408@citi.umich.edu> <445B5C2D.5040404@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: cel@citi.umich.edu, nfs@lists.sourceforge.net,
	linux-fsdevel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fc1gY-0002bg-7u
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 07:53:38 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1Fc1gV-0006Kz-P7
	for nfs@lists.sourceforge.net; Fri, 05 May 2006 07:53:38 -0700
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <445B5C2D.5040404@RedHat.com>
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

Steve Dickson wrote:

> Here is the second attempt at improving the access cache. I believe
> all of the concerns from the first patch have been addressed.
>
> Chuck Lever wrote:
>
>>
>> 1.  We already have cache shrinkage built in: when an inode is purged 
>> due to cache shrinkage, the access cache for that inode is purged as 
>> well.  In other words, there is already a mechanism for external 
>> memory pressure to shrink this cache.  I don't see a strong need to 
>> complicate matters by adding more cache shrinkage than already exists 
>> with normal inode and dentry cache shrinkage.
>
> I agree... so there no extra code to shrink this cache.
>

I think that this _may_ be okay, but since this cache is not required for
correctness, it would be nice to be able to shrink the entries from active
inodes off of it when system memory goes low enough.

>>
>> 2.  Use a radix tree per inode.  
>
> Using radix trees actual makes things much simpler... Good idea, imo.
>

It does seem like a good idea, although just using the uid is not sufficient
to identify the correct access cache entry.  The group and groups list must
also be used.  Can the radix tree implementation support this?

>------------------------------------------------------------------------
>
>This patch improves the caching of ACCESS information by storing
>the information in radix tree. It also serializes over-the-wire
>ACCESS calls. The patch greatly decreases the number of ACCESS 
>calls when processes with different uids access the same directory.
>
>  
>

Some comments intermixed below...

>Signed-off-by: Steve Dickson <steved@redhat.com>
>----------------------------------------------------
>--- mynfs-2.6/fs/nfs/nfs4proc.c.orig	2006-05-03 11:25:58.000000000 -0400
>+++ mynfs-2.6/fs/nfs/nfs4proc.c	2006-05-04 15:17:11.000000000 -0400
>@@ -785,6 +785,10 @@ static int _nfs4_do_access(struct inode 
> 	status = _nfs4_proc_access(inode, &cache);
> 	if (status != 0)
> 		return status;
>+
>+	/* Zero masks are turned into a negative entry */
>+	if (!cache.mask) 
>+		cache.mask |= ~mask;
> 	nfs_access_add_cache(inode, &cache);
> out:
> 	if ((cache.mask & mask) == mask)
>--- mynfs-2.6/fs/nfs/inode.c.orig	2006-05-03 11:25:58.000000000 -0400
>+++ mynfs-2.6/fs/nfs/inode.c	2006-05-05 09:35:20.000000000 -0400
>@@ -170,14 +170,11 @@ static void
> nfs_clear_inode(struct inode *inode)
> {
> 	struct nfs_inode *nfsi = NFS_I(inode);
>-	struct rpc_cred *cred;
> 
> 	nfs_wb_all(inode);
> 	BUG_ON (!list_empty(&nfsi->open_files));
> 	nfs_zap_acl_cache(inode);
>-	cred = nfsi->cache_access.cred;
>-	if (cred)
>-		put_rpccred(cred);
>+	nfs_zap_access_cache(inode);
> 	BUG_ON(atomic_read(&nfsi->data_updates) != 0);
> }
> 
>@@ -940,7 +937,6 @@ nfs_fhget(struct super_block *sb, struct
> 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
> 		nfsi->attrtimeo_timestamp = jiffies;
> 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
>-		nfsi->cache_access.cred = NULL;
> 
> 		unlock_new_inode(inode);
> 	} else
>@@ -1039,7 +1035,7 @@ static int nfs_wait_schedule(void *word)
> /*
>  * Wait for the inode to get unlocked.
>  */
>-static int nfs_wait_on_inode(struct inode *inode)
>+int nfs_wait_on_inode(struct inode *inode, int bit)
> {
> 	struct rpc_clnt	*clnt = NFS_CLIENT(inode);
> 	struct nfs_inode *nfsi = NFS_I(inode);
>@@ -1047,20 +1043,20 @@ static int nfs_wait_on_inode(struct inod
> 	int error;
> 
> 	rpc_clnt_sigmask(clnt, &oldmask);
>-	error = wait_on_bit_lock(&nfsi->flags, NFS_INO_REVALIDATING,
>+	error = wait_on_bit_lock(&nfsi->flags, bit,
> 					nfs_wait_schedule, TASK_INTERRUPTIBLE);
> 	rpc_clnt_sigunmask(clnt, &oldmask);
> 
> 	return error;
> }
> 
>-static void nfs_wake_up_inode(struct inode *inode)
>+void nfs_wake_up_inode(struct inode *inode, int bit)
> {
> 	struct nfs_inode *nfsi = NFS_I(inode);
> 
>-	clear_bit(NFS_INO_REVALIDATING, &nfsi->flags);
>+	clear_bit(bit, &nfsi->flags);
> 	smp_mb__after_clear_bit();
>-	wake_up_bit(&nfsi->flags, NFS_INO_REVALIDATING);
>+	wake_up_bit(&nfsi->flags, bit);
> }
> 
> int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
>@@ -1235,7 +1231,7 @@ __nfs_revalidate_inode(struct nfs_server
> 	if (NFS_STALE(inode))
>  		goto out_nowait;
> 
>-	status = nfs_wait_on_inode(inode);
>+	status = nfs_wait_on_inode(inode, NFS_INO_REVALIDATING);
> 	if (status < 0)
> 		goto out;
> 	if (NFS_STALE(inode)) {
>@@ -1283,7 +1279,7 @@ __nfs_revalidate_inode(struct nfs_server
> 		(long long)NFS_FILEID(inode));
> 
>  out:
>-	nfs_wake_up_inode(inode);
>+	nfs_wake_up_inode(inode, NFS_INO_REVALIDATING);
> 
>  out_nowait:
> 	unlock_kernel();
>@@ -2874,6 +2870,8 @@ static void init_once(void * foo, kmem_c
> 		INIT_LIST_HEAD(&nfsi->commit);
> 		INIT_LIST_HEAD(&nfsi->open_files);
> 		INIT_RADIX_TREE(&nfsi->nfs_page_tree, GFP_ATOMIC);
>+		INIT_RADIX_TREE(&nfsi->access_cache, GFP_ATOMIC);
>+		spin_lock_init(&nfsi->access_lock);
> 		atomic_set(&nfsi->data_updates, 0);
> 		nfsi->ndirty = 0;
> 		nfsi->ncommit = 0;
>--- mynfs-2.6/fs/nfs/dir.c.orig	2006-05-03 11:25:58.000000000 -0400
>+++ mynfs-2.6/fs/nfs/dir.c	2006-05-05 09:34:47.000000000 -0400
>@@ -1636,35 +1636,67 @@ out:
> 	return error;
> }
> 
>-int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
>+int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, 
>+	struct nfs_access_entry *res)
> {
> 	struct nfs_inode *nfsi = NFS_I(inode);
>-	struct nfs_access_entry *cache = &nfsi->cache_access;
>+	int invalid = (nfsi->cache_validity & NFS_INO_INVALID_ACCESS);
>+	struct nfs_access_entry *cache;
>+	int expired;
>+
>+	spin_lock(&nfsi->access_lock);
>+	cache = (struct nfs_access_entry *)
>+		radix_tree_lookup(&nfsi->access_cache, cred->cr_uid);
>+
>+	if (cache) {
>+		expired = time_after(jiffies, 
>+				cache->jiffies + NFS_ATTRTIMEO(inode));
>+		if (expired || invalid) {
>+			(void)radix_tree_delete(&nfsi->access_cache, cred->cr_uid);
>+			spin_unlock(&nfsi->access_lock);
>+			put_rpccred(cache->cred);
>+			kfree(cache);
>+			goto nolock;
>+		}
>+		memcpy(res, cache, sizeof(*res));
>+		spin_unlock(&nfsi->access_lock);
>+		return 0;
>+	}
>+	spin_unlock(&nfsi->access_lock);
> 
>-	if (cache->cred != cred
>-			|| time_after(jiffies, cache->jiffies + NFS_ATTRTIMEO(inode))
>-			|| (nfsi->cache_validity & NFS_INO_INVALID_ACCESS))
>-		return -ENOENT;
>-	memcpy(res, cache, sizeof(*res));
>-	return 0;
>+nolock:
>+	return -ENOENT;
> }
> 
> void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
> {
> 	struct nfs_inode *nfsi = NFS_I(inode);
>-	struct nfs_access_entry *cache = &nfsi->cache_access;
>-
>-	if (cache->cred != set->cred) {
>-		if (cache->cred)
>-			put_rpccred(cache->cred);
>-		cache->cred = get_rpccred(set->cred);
>+	struct nfs_access_entry *cache = NULL;
>+	uid_t cr_uid = set->cred->cr_uid;
>+	int error;
>+
>+	cache = (struct nfs_access_entry *)kmalloc(sizeof(*cache), GFP_KERNEL);
>+	if (!cache)
>+		return;
>+
>+	spin_lock(&nfsi->access_lock);
>+	error = radix_tree_insert(&nfsi->access_cache, cr_uid, cache);
>+	if (error) {
>+		spin_unlock(&nfsi->access_lock);
>+		kfree(cache);
>+		return;
> 	}
>-	/* FIXME: replace current access_cache BKL reliance with inode->i_lock */
>+
>+	cache->cred = get_rpccred(set->cred);
>+	cache->jiffies = jiffies;
>+	cache->mask = set->mask;
>+	spin_unlock(&nfsi->access_lock);
>+
> 	spin_lock(&inode->i_lock);
> 	nfsi->cache_validity &= ~NFS_INO_INVALID_ACCESS;
> 	spin_unlock(&inode->i_lock);
>-	cache->jiffies = set->jiffies;
>-	cache->mask = set->mask;
>+
>+	return;
> }
> 
> static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
>@@ -1674,19 +1706,42 @@ static int nfs_do_access(struct inode *i
> 
> 	status = nfs_access_get_cached(inode, cred, &cache);
> 	if (status == 0)
>-		goto out;
>+		goto out_nowait;
>+
>+	if (test_and_set_bit(NFS_INO_ACCESS, &NFS_FLAGS(inode))) {
>+		status = nfs_wait_on_inode(inode, NFS_INO_ACCESS);
>+		if (status < 0)
>+			return status;
>+
>+		nfs_access_get_cached(inode, cred, &cache);
>+		goto out_nowait;
>  
>

You can't just go to out_nowait here, can you?  What happens if something
happened to the file while you were asleep?  Or an entry could be added to
the cache for some reason such as kmalloc failure?  I would suggest going
back to the top and starting the process all over again.

>+	}
> 
> 	/* Be clever: ask server to check for all possible rights */
> 	cache.mask = MAY_EXEC | MAY_WRITE | MAY_READ;
> 	cache.cred = cred;
>-	cache.jiffies = jiffies;
> 	status = NFS_PROTO(inode)->access(inode, &cache);
>-	if (status != 0)
>+	if (status != 0) {
>+		if (status == -ESTALE) {
>+			nfs_zap_caches(inode);
>+			if (!S_ISDIR(inode->i_mode))
>+				set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
>+		}
>+		nfs_wake_up_inode(inode, NFS_INO_ACCESS);
> 		return status;
>+	}
>+
>+	/* Zero masks are turned into a negative entry */
>+	if (!cache.mask) 
>+		cache.mask |= ~mask;
> 	nfs_access_add_cache(inode, &cache);
>-out:
>+
>+	nfs_wake_up_inode(inode, NFS_INO_ACCESS);
>+
>+out_nowait:
> 	if ((cache.mask & mask) == mask)
> 		return 0;
>+
> 	return -EACCES;
> }
> 
>--- mynfs-2.6/include/linux/nfs_fs.h.orig	2006-05-03 11:26:19.000000000 -0400
>+++ mynfs-2.6/include/linux/nfs_fs.h	2006-05-05 09:34:08.000000000 -0400
>@@ -145,7 +145,8 @@ struct nfs_inode {
> 	 */
> 	atomic_t		data_updates;
> 
>-	struct nfs_access_entry	cache_access;
>+	struct radix_tree_root	access_cache;
>+	spinlock_t access_lock;
> #ifdef CONFIG_NFS_V3_ACL
> 	struct posix_acl	*acl_access;
> 	struct posix_acl	*acl_default;
>@@ -199,6 +200,7 @@ struct nfs_inode {
> #define NFS_INO_REVALIDATING	(0)		/* revalidating attrs */
> #define NFS_INO_ADVISE_RDPLUS	(1)		/* advise readdirplus */
> #define NFS_INO_STALE		(2)		/* possible stale inode */
>+#define NFS_INO_ACCESS		(3)		/* checking access bits */
> 
> static inline struct nfs_inode *NFS_I(struct inode *inode)
> {
>@@ -256,6 +258,17 @@ static inline int NFS_USE_READDIRPLUS(st
> 	return test_bit(NFS_INO_ADVISE_RDPLUS, &NFS_FLAGS(inode));
> }
> 
>+static inline void nfs_zap_access_cache(struct inode *inode)
>+{
>+	struct nfs_access_entry *cache;
>+
>+	cache = radix_tree_delete(&NFS_I(inode)->access_cache, inode->i_uid);
>  
>

Do you need to be hold access_lock here?

>+	if (cache) {
>+		put_rpccred(cache->cred);
>+		kfree(cache);
>+	}
>  
>

What happens if there was more than 1 entry in the cache?

>+}
>+
> /**
>  * nfs_save_change_attribute - Returns the inode attribute change cookie
>  * @inode - pointer to inode
>@@ -299,6 +312,8 @@ extern int nfs_attribute_timeout(struct 
> extern int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode);
> extern int __nfs_revalidate_inode(struct nfs_server *, struct inode *);
> extern void nfs_revalidate_mapping(struct inode *inode, struct address_space *mapping);
>+extern int nfs_wait_on_inode(struct inode *inode, int bit);
>+extern void nfs_wake_up_inode(struct inode *inode, int bit);
> extern int nfs_setattr(struct dentry *, struct iattr *);
> extern void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr);
> extern void nfs_begin_attr_update(struct inode *);
>  
>

    Thanx...

       ps


-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
