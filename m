Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f195.google.com ([209.85.216.195]:33737 "EHLO
	mail-qc0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932334AbbFFOmE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 6 Jun 2015 10:42:04 -0400
Message-ID: <557306B5.1020509@gmail.com>
Date: Sat, 06 Jun 2015 22:41:57 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Al Viro <viro@zeniv.linux.org.uk>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        kinglongmee@gmail.com
Subject: [PATCH 5/5 v4] nfsd: Allows user un-mounting filesystem where nfsd
 exports base on
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

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 96 +++++++++++++++++++++++++++++++++++++++++++++-----------
 fs/nfsd/export.h | 18 ++++++++++-
 2 files changed, 95 insertions(+), 19 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a..d3e59bc 100644
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
@@ -120,6 +128,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 		goto out;
 
 	key.ek_client = dom;	
+	key.cd = cd;
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
 
@@ -210,6 +219,25 @@ static inline void expkey_init(struct cache_head *cnew,
 	new->ek_fsidtype = item->ek_fsidtype;
 
 	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
+	new->cd = item->cd;
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
+	cache_force_expire(key->cd, &key->h);
 }
 
 static inline void expkey_update(struct cache_head *cnew,
@@ -218,16 +246,19 @@ static inline void expkey_update(struct cache_head *cnew,
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
 		return &i->h;
-	else
+	} else
 		return NULL;
 }
 
@@ -306,14 +337,21 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
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
@@ -520,7 +558,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -694,15 +732,34 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 		path_equal(&orig->ex_path, &new->ex_path);
 }
 
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
+	cache_force_expire(exp->cd, &exp->h);
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
@@ -740,10 +797,12 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 
 static struct cache_head *svc_export_alloc(void)
 {
-	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
-	if (i)
+	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
+	if (i) {
+		INIT_WORK(&i->ex_work, export_close_work);
+		init_completion(&i->ex_done);
 		return &i->h;
-	else
+	} else
 		return NULL;
 }
 
@@ -811,6 +870,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 
 	key.ek_client = clp;
 	key.ek_fsidtype = fsid_type;
+	key.cd = cd;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
 	ek = svc_expkey_lookup(cd, &key);
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..ff8905d 100644
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
@@ -58,7 +61,13 @@ struct svc_export {
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	enum pnfs_layouttype	ex_layout_type;
 	struct nfsd4_deviceid_map *ex_devid_map;
-	struct cache_detail	*cd;
+
+	struct fs_pin		ex_pin;
+	struct rcu_head		rcu_head;
+
+	/* For cache_put and fs umounting window */
+	struct completion	ex_done;
+	struct work_struct	ex_work;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
@@ -67,12 +76,19 @@ struct svc_export {
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
+	/* For cache_put and fs umounting window */
+	struct completion	ek_done;
+	struct work_struct	ek_work;
 };
 
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
-- 
2.4.2

