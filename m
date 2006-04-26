From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH][RFC] NFS: Improving the access cache
Date: Tue, 25 Apr 2006 21:14:19 -0400
Message-ID: <444EC96B.80400@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060001080807020803060300"
Cc: linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: nfs@lists.sourceforge.net
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This is a multi-part message in MIME format.
--------------060001080807020803060300
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Currently the NFS client caches ACCESS information on a per uid basis
which fall apart when different process with different uid consistently
access the same directory. The end result being a storm of needless
ACCESS calls...

The attached patch used a hash table to store the nfs_access_entry
entires which cause the ACCESS request to only happen when the
attributes timeout.. The table is indexed by the addition of the
nfs_inode pointer and the cr_uid in the cred structure which should
spread things out nicely for some decent scalability (although the
locking scheme may need to be reworked a bit). The table has 256 entries
of struct list_head giving it a total size of 2k.

The patch is based on Trond's GIT tree...

Comments?

steved.

--------------060001080807020803060300
Content-Type: text/x-patch;
 name="linux-2.6.17.rc2-nfs-accesscache-hash.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.6.17.rc2-nfs-accesscache-hash.patch"

This patch improves the caching of ACCESS information by storing
the information in hash table. The patch will greatly decrease the
number of ACCESS calls with processes with different uids access
the same directory.

Signed-off-by: Steve Dickson <steved@redhat.com>
----------------------------------------------------

--- mynfs-2.6/fs/nfs/inode.c.acc	2006-04-21 15:02:07.000000000 -0400
+++ mynfs-2.6/fs/nfs/inode.c	2006-04-25 19:12:05.000000000 -0400
@@ -74,6 +74,9 @@ static void nfs_zap_acl_cache(struct ino
 
 static struct rpc_program	nfs_program;
 
+extern void nfs_zap_access_cache(struct inode *);
+extern void nfs_init_access_cache(void);
+
 static struct super_operations nfs_sops = { 
 	.alloc_inode	= nfs_alloc_inode,
 	.destroy_inode	= nfs_destroy_inode,
@@ -170,14 +173,11 @@ static void
 nfs_clear_inode(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct rpc_cred *cred;
 
 	nfs_wb_all(inode);
 	BUG_ON (!list_empty(&nfsi->open_files));
 	nfs_zap_acl_cache(inode);
-	cred = nfsi->cache_access.cred;
-	if (cred)
-		put_rpccred(cred);
+	nfs_zap_access_cache(inode);
 	BUG_ON(atomic_read(&nfsi->data_updates) != 0);
 }
 
@@ -940,7 +940,6 @@ nfs_fhget(struct super_block *sb, struct
 		nfsi->attrtimeo = NFS_MINATTRTIMEO(inode);
 		nfsi->attrtimeo_timestamp = jiffies;
 		memset(nfsi->cookieverf, 0, sizeof(nfsi->cookieverf));
-		nfsi->cache_access.cred = NULL;
 
 		unlock_new_inode(inode);
 	} else
@@ -2892,6 +2891,8 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
+	nfs_init_access_cache();
+
 	err = nfs_init_nfspagecache();
 	if (err)
 		goto out4;
--- mynfs-2.6/fs/nfs/dir.c.acc	2006-04-21 15:02:07.000000000 -0400
+++ mynfs-2.6/fs/nfs/dir.c	2006-04-25 19:13:01.000000000 -0400
@@ -54,6 +54,16 @@ static int nfs_rename(struct inode *, st
 static int nfs_fsync_dir(struct file *, struct dentry *, int);
 static loff_t nfs_llseek_dir(struct file *, loff_t, int);
 
+/*
+ * access cache
+ */
+#define ACCESS_HASH_BITS             8
+#define ACCESS_HASH_SIZE             (1 << ACCESS_HASH_BITS)
+#define ACCESS_HASH_MASK             (ACCESS_HASH_SIZE - 1)
+#define access_hashval(iptr, id) ((((uid_t)iptr) + (id)) & ACCESS_HASH_MASK)
+static struct list_head	access_hashtbl[ACCESS_HASH_SIZE];
+static spinlock_t access_hashlock;
+
 const struct file_operations nfs_dir_operations = {
 	.llseek		= nfs_llseek_dir,
 	.read		= generic_read_dir,
@@ -1635,36 +1645,102 @@ out:
 	unlock_kernel();
 	return error;
 }
+void nfs_init_access_cache(void)
+{
+	int i;
 
-int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
+	for (i=0; i < ACCESS_HASH_SIZE; i++)
+		INIT_LIST_HEAD(&access_hashtbl[i]);
+
+	spin_lock_init(&access_hashlock);
+
+	return;
+}
+void nfs_zap_access_cache(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_access_entry *cache = &nfsi->cache_access;
+	struct nfs_access_entry *cache;
+	struct list_head *head, *pos, *next;
+	int i;
+
+	spin_lock(&access_hashlock);
+	for (i=0; i < ACCESS_HASH_SIZE; i++) {
+		head = &access_hashtbl[access_hashval(nfsi, i)];
+		if (list_empty(head))
+			continue;
 
-	if (cache->cred != cred
-			|| time_after(jiffies, cache->jiffies + NFS_ATTRTIMEO(inode))
-			|| (nfsi->cache_validity & NFS_INO_INVALID_ACCESS))
-		return -ENOENT;
-	memcpy(res, cache, sizeof(*res));
-	return 0;
+		list_for_each_safe(pos, next, head) {
+			cache = list_entry(pos, struct nfs_access_entry, acc_list);
+			if (cache->id != (void *)nfsi)
+				continue;
+
+			list_del(&cache->acc_list);
+			put_rpccred(cache->cred);
+			kfree(cache);
+		}
+	}
+	spin_unlock(&access_hashlock);
+	return;
 }
 
-void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
+int nfs_access_get_cached(struct inode *inode, struct rpc_cred *cred, struct nfs_access_entry *res)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	struct nfs_access_entry *cache = &nfsi->cache_access;
+	int invalid = (nfsi->cache_validity & NFS_INO_INVALID_ACCESS);
+	struct nfs_access_entry *cache = NULL;
+	struct list_head *head;
+	int expired;
+
+	spin_lock(&access_hashlock);
+	head = &access_hashtbl[access_hashval(nfsi, cred->cr_uid)];
+	list_for_each_entry(cache, head, acc_list) {
+		if (cache->id != nfsi)
+			continue;
+		if (cache->cred != cred)
+			continue;
 
-	if (cache->cred != set->cred) {
-		if (cache->cred)
+		expired = time_after(jiffies, 
+			cache->jiffies + NFS_ATTRTIMEO(inode));
+		if (expired || invalid) {
+			list_del(&cache->acc_list);
+			spin_unlock(&access_hashlock);
 			put_rpccred(cache->cred);
-		cache->cred = get_rpccred(set->cred);
+			kfree(cache);
+			goto nolock;
+		}
+		memcpy(res, cache, sizeof(*res));
+		spin_unlock(&access_hashlock);
+		return 0;
 	}
-	/* FIXME: replace current access_cache BKL reliance with inode->i_lock */
-	spin_lock(&inode->i_lock);
+	spin_unlock(&access_hashlock);
+
+nolock:
+	return -ENOENT;
+}
+
+void nfs_access_add_cache(struct inode *inode, struct nfs_access_entry *set)
+{
+	struct nfs_inode *nfsi = NFS_I(inode);
+	struct nfs_access_entry *cache = NULL;
+	struct list_head *head;
+
+	cache = (struct nfs_access_entry *)kmalloc(sizeof(*cache), GFP_KERNEL);
+	if (!cache)
+		return;
+
+	spin_lock(&access_hashlock);
+	head = &access_hashtbl[access_hashval(nfsi, set->cred->cr_uid)];
 	nfsi->cache_validity &= ~NFS_INO_INVALID_ACCESS;
-	spin_unlock(&inode->i_lock);
+	INIT_LIST_HEAD(&cache->acc_list);
+	list_add(&cache->acc_list, head);
+	spin_unlock(&access_hashlock);
+
+	cache->cred = get_rpccred(set->cred);
 	cache->jiffies = set->jiffies;
 	cache->mask = set->mask;
+	cache->id = (void *)nfsi;
+
+	return;
 }
 
 static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
--- mynfs-2.6/include/linux/nfs_fs.h.acc	2006-04-21 15:02:08.000000000 -0400
+++ mynfs-2.6/include/linux/nfs_fs.h	2006-04-25 19:12:05.000000000 -0400
@@ -72,6 +72,8 @@ struct nfs_access_entry {
 	unsigned long		jiffies;
 	struct rpc_cred *	cred;
 	int			mask;
+	void   *id;
+	struct list_head acc_list;
 };
 
 struct nfs4_state;
@@ -145,7 +147,6 @@ struct nfs_inode {
 	 */
 	atomic_t		data_updates;
 
-	struct nfs_access_entry	cache_access;
 #ifdef CONFIG_NFS_V3_ACL
 	struct posix_acl	*acl_access;
 	struct posix_acl	*acl_default;

--------------060001080807020803060300--
