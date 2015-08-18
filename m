Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32993 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750916AbbHRHYO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Aug 2015 03:24:14 -0400
Subject: [PATCH 6/6 v9] nfsd: Allows user un-mounting filesystem where nfsd
 exports base on
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>
References: <55D2DBF6.3010406@gmail.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <55D2DD8F.6070501@gmail.com>
Date: Tue, 18 Aug 2015 15:23:59 +0800
MIME-Version: 1.0
In-Reply-To: <55D2DBF6.3010406@gmail.com>
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

v5, v4,
1. add a completion for pin_kill waiting the reference is decreased to zero.
2. add a work_struct for pin_kill decreases the reference indirectly.
3. free svc_export/svc_expkey in pin_kill, not svc_export_put/svc_expkey_put.
4. svc_export_put/svc_expkey_put go though pin_kill logic.

v6,
1. Pin vfsmnt to mount point at first, when reference increace (==2),
   grab a reference to vfsmnt by mntget. When decreace (==1),
   drop the reference to vfsmnt, left pin.
2. Delete cache_head directly from cache_detail.

v7, implement self reference increase and decrease for nfsd exports/expkey

v8, new method as,

1. There are only one outlet from each cache, exp_find_key() for expkey,
   exp_get_by_name() for export.
2. Any fsid to export or filehandle to export will call the function.
3. exp_get()/exp_put() increase/decrease the reference of export.

Call legitimize_mntget() in the only outlet function exp_find_key()/
exp_get_by_name(), if fail return STALE, otherwise, any valid
expkey/export from the cache is validated (Have get the reference of vfsmnt).

Add mntget() in exp_get() and mntput() in exp_put(), because the export
passed to exp_get/exp_put are returned from exp_find_key/exp_get_by_name.

For expkey cache,
1. At first, a fsid is passed to exp_find_key, and lookup a cache
   in svc_expkey_lookup, if success, ekey->ek_path is pined to mount.
2. Then call legitimize_mntget getting a reference of vfsmnt
   before return from exp_find_key.
3. Any calling exp_find_key with valid cache must put the vfsmnt.

for export cache,
1. At first, a path (returned from exp_find_key) with validate vfsmnt
   is passed to exp_get_by_name, if success, exp->ex_path is pined to mount.
2. Then call legitimize_mntget getting a reference of vfsmnt
   before return from exp_get_by_name.
3. Any calling exp_get_by_name with valid cache must put the vfsmnt
   by exp_put();
4. Any using the exp returned from exp_get_by_name must call exp_get(),
   will increase the reference of vfsmnt.

So that,
a. After getting the reference in 2, any umount of filesystem will get -EBUSY.
b. After put all reference after 4, or before get the reference in 2,
   any umount of filesystem will call pin_kill, and delete the cache directly,
   also unpin the vfsmount.
c. Between 1 and 2, have get the reference of exp/key cache, with invalidate vfsmnt.
   Umount of filesystem only wait exp_find_key/exp_get_by_name put the reference
   of cache when legitimize_mntget fail.

v9, thanks for NeilBrown's comments and update
1. Fix two string formats of path name.
2. Based on Neil's patch of
   "allow pin_remove() to be called other than from ->kill()"

Besides the logical of waiting the last reference, others are same as v8.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 96 +++++++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/export.h | 14 +++++++--
 2 files changed, 90 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index b4d84b5..1d70324 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -37,15 +37,24 @@
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
+		if (path_put_unpin(&key->ek_path, &key->ek_pin))
+			return ;
+	}
+
+	expkey_destroy(key);
 }
 
 static void expkey_request(struct cache_detail *cd,
@@ -119,6 +128,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 	if (key.h.expiry_time == 0)
 		goto out;
 
+	key.cd = cd;
 	key.ek_client = dom;	
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
@@ -181,7 +191,11 @@ static int expkey_show(struct seq_file *m,
 	if (test_bit(CACHE_VALID, &h->flags) && 
 	    !test_bit(CACHE_NEGATIVE, &h->flags)) {
 		seq_printf(m, " ");
-		seq_path(m, &ek->ek_path, "\\ \t\n");
+		if (legitimize_mntget(ek->ek_path.mnt)) {
+			seq_path(m, &ek->ek_path, "\\ \t\n");
+			mntput(ek->ek_path.mnt);
+		} else
+			seq_printf(m, "Dir-unmounting");
 	}
 	seq_printf(m, "\n");
 	return 0;
@@ -210,6 +224,16 @@ static inline void expkey_init(struct cache_head *cnew,
 	new->ek_fsidtype = item->ek_fsidtype;
 
 	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
+	new->cd = item->cd;
+}
+
+static void expkey_pin_kill(struct fs_pin *pin)
+{
+	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
+	cache_delete_entry(key->cd, &key->h);
+	/* Must call pin_kill to wait the last reference be put */
+	pin_kill(&key->ek_pin);
+	expkey_destroy(key);
 }
 
 static inline void expkey_update(struct cache_head *cnew,
@@ -218,13 +242,14 @@ static inline void expkey_update(struct cache_head *cnew,
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
+	struct svc_expkey *i = kzalloc(sizeof(*i), GFP_KERNEL);
 	if (i)
 		return &i->h;
 	else
@@ -306,14 +331,21 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
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
+	if (!path_put_unpin(&exp->ex_path, &exp->ex_pin))
+		svc_export_destroy(exp);
 }
 
 static void svc_export_request(struct cache_detail *cd,
@@ -636,7 +668,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 	if (expp == NULL)
 		err = -ENOMEM;
 	else
-		exp_put(expp);
+		cache_put(&expp->h, expp->cd);
 out4:
 	nfsd4_fslocs_free(&exp.ex_fslocs);
 	kfree(exp.ex_uuid);
@@ -664,7 +696,12 @@ static int svc_export_show(struct seq_file *m,
 		return 0;
 	}
 	exp = container_of(h, struct svc_export, h);
-	seq_path(m, &exp->ex_path, " \t\n\\");
+	if (legitimize_mntget(exp->ex_path.mnt)) {
+		seq_path(m, &exp->ex_path, " \t\n\\");
+		mntput(exp->ex_path.mnt);
+	} else
+		seq_printf(m, "Dir-unmounting");
+
 	seq_putc(m, '\t');
 	seq_escape(m, exp->ex_client->name, " \t\n\\");
 	seq_putc(m, '(');
@@ -694,15 +731,25 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 		path_equal(&orig->ex_path, &new->ex_path);
 }
 
+static void export_pin_kill(struct fs_pin *pin)
+{
+	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
+	cache_delete_entry(exp->cd, &exp->h);
+	/* Must call pin_kill to wait the last reference be put */
+	pin_kill(&exp->ex_pin);
+	svc_export_destroy(exp);
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
@@ -740,7 +787,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 
 static struct cache_head *svc_export_alloc(void)
 {
-	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
+	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
 	if (i)
 		return &i->h;
 	else
@@ -809,6 +856,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 	if (!clp)
 		return ERR_PTR(-ENOENT);
 
+	key.cd = cd;
 	key.ek_client = clp;
 	key.ek_fsidtype = fsid_type;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
@@ -819,6 +867,12 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 	err = cache_check(cd, &ek->h, reqp);
 	if (err)
 		return ERR_PTR(err);
+
+	if (!legitimize_mntget(ek->ek_path.mnt)) {
+		cache_put(&ek->h, ek->cd);
+		return ERR_PTR(-ENOENT);
+	}
+
 	return ek;
 }
 
@@ -842,6 +896,8 @@ exp_get_by_name(struct cache_detail *cd, struct auth_domain *clp,
 	err = cache_check(cd, &exp->h, reqp);
 	if (err)
 		return ERR_PTR(err);
+
+	mntget(exp->ex_path.mnt);
 	return exp;
 }
 
@@ -858,6 +914,7 @@ exp_parent(struct cache_detail *cd, struct auth_domain *clp, struct path *path)
 		struct dentry *parent = dget_parent(path->dentry);
 		dput(path->dentry);
 		path->dentry = parent;
+		exp_put(exp);
 		exp = exp_get_by_name(cd, clp, path, NULL);
 	}
 	dput(path->dentry);
@@ -928,7 +985,10 @@ static struct svc_export *exp_find(struct cache_detail *cd,
 		return ERR_CAST(ek);
 
 	exp = exp_get_by_name(cd, clp, &ek->ek_path, reqp);
-	cache_put(&ek->h, nn->svc_expkey_cache);
+
+	/* Put the mnt get in exp_find_key() */
+	mntput(ek->ek_path.mnt);
+	cache_put(&ek->h, ek->cd);
 
 	if (IS_ERR(exp))
 		return ERR_CAST(exp);
@@ -1195,10 +1255,10 @@ static int e_show(struct seq_file *m, void *p)
 		return 0;
 	}
 
-	exp_get(exp);
+	cache_get(&exp->h);
 	if (cache_check(cd, &exp->h, NULL))
 		return 0;
-	exp_put(exp);
+	cache_put(&exp->h, exp->cd);
 	return svc_export_show(m, cd, cp);
 }
 
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..d186a0a 100644
--- a/fs/nfsd/export.h
+++ b/fs/nfsd/export.h
@@ -4,6 +4,7 @@
 #ifndef NFSD_EXPORT_H
 #define NFSD_EXPORT_H
 
+#include <linux/fs_pin.h>
 #include <linux/sunrpc/cache.h>
 #include <uapi/linux/nfsd/export.h>
 
@@ -46,9 +47,10 @@ struct exp_flavor_info {
 
 struct svc_export {
 	struct cache_head	h;
+	struct cache_detail	*cd;
+
 	struct auth_domain *	ex_client;
 	int			ex_flags;
-	struct path		ex_path;
 	kuid_t			ex_anon_uid;
 	kgid_t			ex_anon_gid;
 	int			ex_fsid;
@@ -58,7 +60,10 @@ struct svc_export {
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	enum pnfs_layouttype	ex_layout_type;
 	struct nfsd4_deviceid_map *ex_devid_map;
-	struct cache_detail	*cd;
+
+	struct path		ex_path;
+	struct fs_pin		ex_pin;
+	struct rcu_head		rcu_head;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
@@ -67,12 +72,15 @@ struct svc_export {
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
 };
 
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
@@ -100,12 +108,14 @@ __be32			nfserrno(int errno);
 
 static inline void exp_put(struct svc_export *exp)
 {
+	mntput(exp->ex_path.mnt);
 	cache_put(&exp->h, exp->cd);
 }
 
 static inline struct svc_export *exp_get(struct svc_export *exp)
 {
 	cache_get(&exp->h);
+	mntget(exp->ex_path.mnt);
 	return exp;
 }
 struct svc_export * rqst_exp_find(struct svc_rqst *, int, u32 *);
-- 
2.4.3

