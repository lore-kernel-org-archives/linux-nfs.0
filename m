Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:36301 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751132AbbEXPK5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 May 2015 11:10:57 -0400
Message-ID: <5561E9FA.4050808@gmail.com>
Date: Sun, 24 May 2015 23:10:50 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
Subject: [PATCH 5/5] nfsd: allows user un-mounting filesystem where nfsd exports
 base on
References: <5561E7E4.50604@gmail.com>
In-Reply-To: <5561E7E4.50604@gmail.com>
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

I don't think that's user expect, they want umount /nfs/test/.

It's caused by exports cache of nfsd holds the reference of
the path (here is /nfs/test/), so, it can't be umounted.

v2,
1. Update exports according to the "allow_umount" option.
   Pin to vfsmnt default, change when updating.
2. Using kzalloc for all memory allocating without kmalloc.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c                 | 52 ++++++++++++++++++++++++++++++++--------
 fs/nfsd/export.h                 | 11 ++++++++-
 include/uapi/linux/nfsd/export.h |  3 ++-
 3 files changed, 54 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index f79521a..cc34b0b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -43,9 +43,9 @@ static void expkey_put(struct kref *ref)
 
 	if (test_bit(CACHE_VALID, &key->h.flags) &&
 	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
-		path_put(&key->ek_path);
+		path_put_unpin(&key->ek_path, &key->ek_pin);
 	auth_domain_put(key->ek_client);
-	kfree(key);
+	kfree_rcu(key, rcu_head);
 }
 
 static void expkey_request(struct cache_detail *cd,
@@ -83,7 +83,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	err = -ENOMEM;
 	if (!buf)
 		goto out;
@@ -120,6 +120,7 @@ static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 		goto out;
 
 	key.ek_client = dom;	
+	key.cd = cd;
 	key.ek_fsidtype = fsidtype;
 	memcpy(key.ek_fsid, buf, len);
 
@@ -210,6 +211,13 @@ static inline void expkey_init(struct cache_head *cnew,
 	new->ek_fsidtype = item->ek_fsidtype;
 
 	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
+	new->cd = item->cd;
+}
+
+static void expkey_pin_kill(struct fs_pin *pin)
+{
+	struct svc_expkey *key = container_of(pin, struct svc_expkey, ek_pin);
+	cache_force_expire(key->cd, &key->h);
 }
 
 static inline void expkey_update(struct cache_head *cnew,
@@ -218,13 +226,14 @@ static inline void expkey_update(struct cache_head *cnew,
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
@@ -309,11 +318,16 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations *fsloc)
 static void svc_export_put(struct kref *ref)
 {
 	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
-	path_put(&exp->ex_path);
+
+	if (EX_ALLOW_UMOUNT(exp))
+		path_put_unpin(&exp->ex_path, &exp->ex_pin);
+	else
+		path_put(&exp->ex_path);
+
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp->ex_uuid);
-	kfree(exp);
+	kfree_rcu(exp, rcu_head);
 }
 
 static void svc_export_request(struct cache_detail *cd,
@@ -520,7 +534,7 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 		return -EINVAL;
 	mesg[mlen-1] = 0;
 
-	buf = kmalloc(PAGE_SIZE, GFP_KERNEL);
+	buf = kzalloc(PAGE_SIZE, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
@@ -694,15 +708,23 @@ static int svc_export_match(struct cache_head *a, struct cache_head *b)
 		path_equal(&orig->ex_path, &new->ex_path);
 }
 
+static void export_pin_kill(struct fs_pin *pin)
+{
+	struct svc_export *exp = container_of(pin, struct svc_export, ex_pin);
+	cache_force_expire(exp->cd, &exp->h);
+}
+
 static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 {
 	struct svc_export *new = container_of(cnew, struct svc_export, h);
 	struct svc_export *item = container_of(citem, struct svc_export, h);
 
+	init_fs_pin(&new->ex_pin, export_pin_kill);
 	kref_get(&item->ex_client->ref);
+	new->ex_flags = NFSEXP_ALLOW_UMOUNT;
 	new->ex_client = item->ex_client;
 	new->ex_path = item->ex_path;
-	path_get(&item->ex_path);
+	path_get_pin(&new->ex_path, &new->ex_pin);
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
@@ -717,6 +739,14 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 	struct svc_export *item = container_of(citem, struct svc_export, h);
 	int i;
 
+	if (!EX_ALLOW_UMOUNT(item)) {
+		path_get(&new->ex_path);
+		if (EX_ALLOW_UMOUNT(new))
+			path_put_unpin(&new->ex_path, &new->ex_pin);
+		else
+			path_put(&new->ex_path);
+	}
+
 	new->ex_flags = item->ex_flags;
 	new->ex_anon_uid = item->ex_anon_uid;
 	new->ex_anon_gid = item->ex_anon_gid;
@@ -740,7 +770,7 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 
 static struct cache_head *svc_export_alloc(void)
 {
-	struct svc_export *i = kmalloc(sizeof(*i), GFP_KERNEL);
+	struct svc_export *i = kzalloc(sizeof(*i), GFP_KERNEL);
 	if (i)
 		return &i->h;
 	else
@@ -811,6 +841,7 @@ exp_find_key(struct cache_detail *cd, struct auth_domain *clp, int fsid_type,
 
 	key.ek_client = clp;
 	key.ek_fsidtype = fsid_type;
+	key.cd = cd;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
 
 	ek = svc_expkey_lookup(cd, &key);
@@ -1159,6 +1190,7 @@ static struct flags {
 	{ NFSEXP_NOAUTHNLM, {"insecure_locks", ""}},
 	{ NFSEXP_V4ROOT, {"v4root", ""}},
 	{ NFSEXP_PNFS, {"pnfs", ""}},
+	{ NFSEXP_ALLOW_UMOUNT, {"allow_umount", ""}},
 	{ 0, {"", ""}}
 };
 
diff --git a/fs/nfsd/export.h b/fs/nfsd/export.h
index 1f52bfc..1134875 100644
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
@@ -58,7 +61,9 @@ struct svc_export {
 	struct exp_flavor_info	ex_flavors[MAX_SECINFO_LIST];
 	enum pnfs_layouttype	ex_layout_type;
 	struct nfsd4_deviceid_map *ex_devid_map;
-	struct cache_detail	*cd;
+
+	struct fs_pin		ex_pin;
+	struct rcu_head		rcu_head;
 };
 
 /* an "export key" (expkey) maps a filehandlefragement to an
@@ -67,17 +72,21 @@ struct svc_export {
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
 #define EX_NOHIDE(exp)		((exp)->ex_flags & NFSEXP_NOHIDE)
 #define EX_WGATHER(exp)		((exp)->ex_flags & NFSEXP_GATHERED_WRITES)
+#define EX_ALLOW_UMOUNT(exp)	((exp)->ex_flags & NFSEXP_ALLOW_UMOUNT)
 
 int nfsexp_flags(struct svc_rqst *rqstp, struct svc_export *exp);
 __be32 check_nfsd_access(struct svc_export *exp, struct svc_rqst *rqstp);
diff --git a/include/uapi/linux/nfsd/export.h b/include/uapi/linux/nfsd/export.h
index 0df7bd5..61aa8bb 100644
--- a/include/uapi/linux/nfsd/export.h
+++ b/include/uapi/linux/nfsd/export.h
@@ -51,9 +51,10 @@
  */
 #define	NFSEXP_V4ROOT		0x10000
 #define NFSEXP_PNFS		0x20000
+#define NFSEXP_ALLOW_UMOUNT	0x40000
 
 /* All flags that we claim to support.  (Note we don't support NOACL.) */
-#define NFSEXP_ALLFLAGS		0x3FE7F
+#define NFSEXP_ALLFLAGS		0x7FE7F
 
 /* The flags that may vary depending on security flavor: */
 #define NFSEXP_SECINFO_FLAGS	(NFSEXP_READONLY | NFSEXP_ROOTSQUASH \
-- 
2.4.1

