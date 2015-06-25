Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:36140 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752094AbbFYOh1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Jun 2015 10:37:27 -0400
Message-ID: <558C121A.3020109@gmail.com>
Date: Thu, 25 Jun 2015 22:37:14 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 10/10 v6] nfsd: Allows user un-mounting filesystem where nfsd
 exports base on
References: <558C0D6A.9050104@gmail.com>
In-Reply-To: <558C0D6A.9050104@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there are some mount points(not exported for nfs) under pseudo root,
after client's operation of those entry under the root, anyone *can't*
unmount those mount points until export cache expired.

/nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
/nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
total 0
drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
Filesystem                      1K-blocks    Used Available Use% Mounted on
......
/dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
/dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
/dev/sde                           999320    1284    929224   1% /nfs/test
/mnt/pnfs/:
total 0
-rw-r--r--. 1 root root 0 Apr 21 22:23 attr
drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp

/mnt/xfs/:
total 0
umount: /nfs/test/: target is busy
        (In some cases useful info about processes that
        use the device is found by lsof(8) or fuser(1).)

It's caused by exports cache of nfsd holds the reference of
the path (here is /nfs/test/), so, it can't be umounted.

I don't think that's user expect, they want umount /nfs/test/.
Bruce think user can also umount /nfs/pnfs/ and /nfs/xfs.

Also, using kzalloc for all memory allocating without kmalloc.
Thanks for Al Viro's commets for the logic of fs_pin.

v3,
1. using path_get_pin/path_put_unpin for path pin
2. using kzalloc for memory allocating

v4,
1. add a completion for pin_kill waiting the reference is decreased to zero.
2. add a work_struct for pin_kill decreases the reference indirectly.
3. free svc_export/svc_expkey in pin_kill, not svc_export_put/svc_expkey_put.
4. svc_export_put/svc_expkey_put go though pin_kill logic.

v5, same as v4.

v6,
1. Pin vfsmnt to mount point at first, when reference increace (==2),
   grab a reference to vfsmnt by mntget. When decreace (==1),
   drop the reference to vfsmnt, left pin.
2. Delete cache_head directly from cache_detail.

Right now,
When reference of cahce_head increase(>1), grab a reference of mnt once.
and reference decrease to 1 (==1), drop the reference of mnt.

So after that,
When ref > 1, user cannot umount the filesystem with -EBUSY.
when ref ==1, means cache only reference by nfsd cache,
no other reference. So user can try umount, 
1. before set MNT_UMOUNT (protected by mount_lock), nfsd cache is
   referenced (ref > 1, legitimize_mntget), umount will fail with -EBUSY.
2. after set MNT_UMOUNT, nfsd cache is referenced (ref == 2),
   legitimize_mntget will fail, and set cache to CACHE_NEGATIVE,
   and the reference will be dropped, re-back to 1.
   So, pin_kill can delete the cache and umount success.
3. when umountting, no reference to nfsd cache, 
   pin_kill can delete the cache and umount success.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 169 +++++++++++++++++++++++++++++++++++++++++++++++++------
 fs/nfsd/export.h |  24 +++++++-
 2 files changed, 174 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 34a384c..f7b1aa8 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -37,15 +37,23 @@
 #define	EXPKEY_HASHMAX		(1 << EXPKEY_HASHBITS)
 #define	EXPKEY_HASHMASK		(EXPKEY_HASHMAX -1)
 
+static void expkey_destroy(struct svc_expkey *key)
+{
+	auth_domain_put(key->ek_client);
+	kfree_rcu(key, rcu_head);
+}
+
 static void expkey_put(struct kref *ref)
 {
 	struct svc_expkey *key = container_of(ref, struct svc_expkey, h.ref);
 
 	if (test_bit(CACHE_VALID, &key->h.flags) &&
-	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
-		path_put(&key->ek_path);
-	auth_domain_put(key->ek_client);
-	kfree(key);
+	    !test_bit(CACHE_NEGATIVE, &key->h.flags)) {
+		rcu_read_lock();
+		complete(&key->ek_done);
+		pin_kill(&key->ek_pin);
+	} else
+		expkey_destroy(key);
 }
 
 static void expkey_request(struct cache_detail *cd,
@@ -83,7 +91,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	err = -ENOMEM;
 	if (!buf)
 		goto out;
@@ -119,6 +127,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	if (key.h.expiry_time == 0)
 		goto out;
 
+	key.cd = cd;
 	key.ek_client = dom;	
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
@@ -210,6 +219,59 @@ static inline void expkey_init(struct cache_head *cnew,
 	new->ek_fsidtype = item->ek_fsidtype;
 
 	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
+	new->cd = item->cd;
+}
+
+static void expkey_validate(struct cache_head *h)
+{
+	struct svc_expkey *key = container_of(h, struct svc_expkey, h);
+
+	if (!test_bit(CACHE_VALID, &key->h.flags) ||
+	    test_bit(CACHE_NEGATIVE, &key->h.flags))
+		return;
+
+	if (atomic_read(&h->ref.refcount) == 1) {
+		mutex_lock(&key->ek_mutex);
+		if (legitimize_mntget(key->ek_path.mnt) == NULL) {
+			printk(KERN_WARNING "%s: Get mnt for %pd2 failed!\n",
+				__func__, key->ek_path.dentry);
+			set_bit(CACHE_NEGATIVE, &h->flags);
+		} else
+			key->ek_mnt_ref = true;
+		mutex_unlock(&key->ek_mutex);
+	}
+}
+
+static void expkey_invalidate(struct cache_head *h)
+{
+	struct svc_expkey *key = container_of(h, struct svc_expkey, h);
+
+	if (atomic_read(&h->ref.refcount) == 2) {
+		mutex_lock(&key->ek_mutex);
+		if (key->ek_mnt_ref) {
+			mntput(key->ek_path.mnt);
+			key->ek_mnt_ref = false;
+		}
+		mutex_unlock(&key->ek_mutex);
+	}
+}
+
+static void expkey_pin_kill(struct fs_pin *pin)
+{
+	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
+
+	if (!completion_done(&key->ek_done)) {
+		schedule_work(&key->ek_work);
+		wait_for_completion(&key->ek_done);
+	}
+	path_put_unpin(&key->ek_path, &key->ek_pin);
+	expkey_destroy(key);
+}
+
+static void expkey_close_work(struct work_struct *work)
+{
+	struct svc_expkey *key = container_of(work, struct svc_expkey, ek_work);
+	cache_delete_entry(key->cd, &key->h);
 }
 
 static inline void expkey_update(struct cache_head *cnew,
@@ -218,16 +280,20 @@ static inline void expkey_update(struct cache_head *cnew,
 	struct svc_expkey *new = container_of(cnew, struct svc_expkey, h);
 	struct svc_expkey *item = container_of(citem, struct svc_expkey, h);
 
+	init_fs_pin(&new->ek_pin, expkey_pin_kill);
 	new->ek_path = item->ek_path;
-	path_get(&item->ek_path);
+	path_get_pin(&new->ek_path, &new->ek_pin);
 }
 
 static struct cache_head *expkey_alloc(void)
 {
-	struct svc_expkey *i = kmalloc(sizeof(*i), GFP_KERNEL);
-	if (i)
+	struct svc_expkey *i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (i) {
+		INIT_WORK(&i->ek_work, expkey_close_work);
+		init_completion(&i->ek_done);
+		mutex_init(&i->ek_mutex);
 		return &i->h;
-	else
+	} else
 		return NULL;
 }
 
@@ -243,6 +309,8 @@ static struct cache_detail svc_expkey_cache_template = {
 	.init		= expkey_init,
 	.update       	= expkey_update,
 	.alloc		= expkey_alloc,
+	.validate	= expkey_validate,
+	.invalidate	= expkey_invalidate,
 };
 
 static int
@@ -306,14 +374,21 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 	fsloc->locations = NULL;
 }
 
-static void svc_export_put(struct kref *ref)
+static void svc_export_destroy(struct svc_export *exp)
 {
-	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
-	path_put(&exp->ex_path);
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp->ex_uuid);
-	kfree(exp);
+	kfree_rcu(exp, rcu_head);
+}
+
+static void svc_export_put(struct kref *ref)
+{
+	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
+
+	rcu_read_lock();
+	complete(&exp->ex_done);
+	pin_kill(&exp->ex_pin);
 }
 
 static void svc_export_request(struct cache_detail *cd,
@@ -520,7 +595,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -694,15 +769,67 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 		path_equal(&orig->ex_path, &new->ex_path);
 }
 
+static void export_validate(struct cache_head *h)
+{
+	struct svc_export *exp = container_of(h, struct svc_export, h);
+
+	if (test_bit(CACHE_NEGATIVE, &h->flags))
+		return;
+
+	if (atomic_read(&h->ref.refcount) == 1) {
+		mutex_lock(&exp->ex_mutex);
+		if (legitimize_mntget(exp->ex_path.mnt) == NULL) {
+			printk(KERN_WARNING "%s: Get mnt for %pd2 failed!\n",
+				__func__, exp->ex_path.dentry);
+			set_bit(CACHE_NEGATIVE, &h->flags);
+		} else
+			exp->ex_mnt_ref = true;
+		mutex_unlock(&exp->ex_mutex);
+	}
+}
+
+static void export_invalidate(struct cache_head *h)
+{
+	struct svc_export *exp = container_of(h, struct svc_export, h);
+
+	if (atomic_read(&h->ref.refcount) == 2) {
+		mutex_lock(&exp->ex_mutex);
+		if (exp->ex_mnt_ref) {
+			mntput(exp->ex_path.mnt);
+			exp->ex_mnt_ref = false;
+		}
+		mutex_unlock(&exp->ex_mutex);
+	}
+}
+
+static void export_pin_kill(struct fs_pin *pin)
+{
+	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
+
+	if (!completion_done(&exp->ex_done)) {
+		schedule_work(&exp->ex_work);
+		wait_for_completion(&exp->ex_done);
+	}
+	path_put_unpin(&exp->ex_path, &exp->ex_pin);
+	svc_export_destroy(exp);
+}
+
+static void export_close_work(struct work_struct *work)
+{
+	struct svc_export *exp = container_of(work, struct svc_export, ex_work);
+	cache_delete_entry(exp->cd, &exp->h);
+}
+
 static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 {
 	struct svc_export *new = container_of(cnew, struct svc_export, h);
 	struct svc_export *item = container_of(citem, struct svc_export, h);
 
+	init_fs_pin(&new->ex_pin, export_pin_kill);
 	kref_get(&item->ex_client->ref);
 	new->ex_client = item->ex_client;
 	new->ex_path = item->ex_path;
-	path_get(&item->ex_path);
+	path_get_pin(&new->ex_path, &new->ex_pin);
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
@@ -740,10 +867,13 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 
 static struct cache_head *svc_export_alloc(void)
 {
-	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
-	if (i)
+	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (i) {
+		INIT_WORK(&i->ex_work, export_close_work);
+		init_completion(&i->ex_done);
+		mutex_init(&i->ex_mutex);
 		return &i->h;
-	else
+	} else
 		return NULL;
 }
 
@@ -759,6 +889,8 @@ static struct cache_detail svc_export_cache_template = {
 	.init		= svc_export_init,
 	.update		= export_update,
 	.alloc		= svc_export_alloc,
+	.validate	= export_validate,
+	.invalidate	= export_invalidate,
 };
 
 static int
@@ -809,6 +941,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 	if (!clp)
 		return ERR_PTR(-ENOENT);
 
+	key.cd = cd;
 	key.ek_client = clp;
 	key.ek_fsidtype = fsid_type;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index b559acf..1b5c5f8 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -4,6 +4,7 @@
 #ifndef NFSD_EXPORT_H
 #define NFSD_EXPORT_H
 
+#include <linux/fs_pin.h>
 #include <linux/sunrpc/cache.h>
 #include <uapi/linux/nfsd/export.h>
 
@@ -46,6 +47,8 @@ struct exp_flavor_info {
 
 struct svc_export {
 	struct cache_head	h;
+	struct cache_detail	*cd;
+
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
@@ -58,7 +61,16 @@ struct svc_export {
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	enum pnfs_layouttype	ex_layout_type;
 	struct nfsd4_deviceid_map *ex_devid_map;
-	struct cache_detail	*cd;
+
+	struct fs_pin		ex_pin;
+	struct rcu_head		rcu_head;
+
+	bool			ex_mnt_ref;
+	struct mutex		ex_mutex;
+
+	/* For cache_put and fs umounting window */
+	struct completion	ex_done;
+	struct work_struct	ex_work;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
@@ -67,12 +79,22 @@ struct svc_export {
  */
 struct svc_expkey {
 	struct cache_head	h;
+	struct cache_detail	*cd;
 
 	struct auth_domain *	ek_client;
 	int			ek_fsidtype;
 	u32			ek_fsid[6];
 
 	struct path		ek_path;
+	struct fs_pin		ek_pin;
+	struct rcu_head		rcu_head;
+
+	bool			ek_mnt_ref;
+	struct mutex		ek_mutex;
+
+	/* For cache_put and fs umounting window */
+	struct completion	ek_done;
+	struct work_struct	ek_work;
 };
 
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
-- 
2.4.3

