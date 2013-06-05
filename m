Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33268 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab3FEDFz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Jun 2013 23:05:55 -0400
Date: Wed, 5 Jun 2013 13:05:41 +1000
From: NeilBrown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: [patch/rfc] allow exported (and *not* exported) filesystems to be
 unmounted.
Message-ID: <20130605130541.5968d5c2@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/a6yFowYv5p.izGlOewrFweI"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/a6yFowYv5p.izGlOewrFweI
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Hi Bruce,
 this is a little issue that seems to keep coming up so I thought it might =
be
 time to fix it.

 As you know, a filesystem that is exported cannot be unmounted as the expo=
rt
 cache holds a reference to it.  Though if it hasn't been accessed for a
 while then it can.

 As I hadn't realised before sometimes *non* exported filesystems can be
 pinned to.  A negative entry in the cache can pin a filesystem just as
 easily as a positive entry.
 An amusing, if somewhat contrived, example is that if you export '/' with
 crossmnt and:

    mount localhost:/ /mnt
    ls -l /
    umount /mnt

 the umount might fail.  This is because the "ls -l" tried to export every
 filesystem found mounted in '/'.  The export of "/mnt" failed of course
 because you cannot re-export an NFS filesystem.  But it is still in the
 cache.
 An 'exportfs -f' fixes this, but shouldn't be necessary.

 So this RFC patch makes it possible  to register a notifier which gets
 called on unmount, and links the export table in to the notifier chain.

 The "atomic" flavour is used so that notifiers can be registered under a
 spin_lock.  This is needed for "expkey_update" as ->update is called under=
 a
 lock.

 As notifier callees cannot unregister themselves, the unregister needs to
 happen in a workqueue item, and the unmount will wait for that.

 It seems to work for me (once I figured out all the locking issues and fou=
nd
 a way to make it work without deadlocking).

 If you are OK with in in general I'll make it into a proper patch series a=
nd
 include Al Viro for the VFS bits.

Thanks,
NeilBrown

diff --git a/fs/mount.h b/fs/mount.h
index cd50079..544ea17 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -44,6 +44,9 @@ struct mount {
 	struct hlist_head mnt_fsnotify_marks;
 	__u32 mnt_fsnotify_mask;
 #endif
+	/* Notifier chain to call when trying to unmount */
+	struct atomic_notifier_head mnt_holders;
+
 	int mnt_id;			/* mount identifier */
 	int mnt_group_id;		/* peer group identifier */
 	int mnt_expiry_mark;		/* true if marked for expiry */
diff --git a/fs/namespace.c b/fs/namespace.c
index 341d3f5..123fcba 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -160,6 +160,37 @@ unsigned int mnt_get_count(struct mount *mnt)
 #endif
 }
=20
+/* Each mount has a notifier call chain which is called on unmount
+ * so that in-kernel users can let go.  This is particularly used
+ * by nfsd.
+ * As a notify callee cannot unregister the notify block directly
+ * due to recursive locking, and as it must be unregistered before the
+ * unmount can be allow to complete (as unregistering afterwards is
+ * impossible), notify callees should arrange for the
+ * umount_notify_unregister() to happen via a scheduled worker.
+ * umount_notifier_call will wait for scheduled workers to finish.
+ * All callees should return NOTIFY_OK so that umount_notifier_call
+ * knows that at least one was called, and so to run flush_scheduled_work(=
).
+ */
+static void umount_notifier_call(struct mount *mnt)
+{
+	if (atomic_notifier_call_chain(&mnt->mnt_holders, 0, NULL))
+		flush_scheduled_work();
+}
+int umount_notifier_register(struct vfsmount *v, struct notifier_block *nb)
+{
+	struct mount *mnt =3D real_mount(v);
+	return atomic_notifier_chain_register(&mnt->mnt_holders, nb);
+}
+EXPORT_SYMBOL_GPL(umount_notifier_register);
+
+int umount_notifier_unregister(struct vfsmount *v, struct notifier_block *=
nb)
+{
+	struct mount *mnt =3D real_mount(v);
+	return atomic_notifier_chain_unregister(&mnt->mnt_holders, nb);
+}
+EXPORT_SYMBOL_GPL(umount_notifier_unregister);
+
 static struct mount *alloc_vfsmnt(const char *name)
 {
 	struct mount *mnt =3D kmem_cache_zalloc(mnt_cache, GFP_KERNEL);
@@ -198,6 +229,8 @@ static struct mount *alloc_vfsmnt(const char *name)
 #ifdef CONFIG_FSNOTIFY
 		INIT_HLIST_HEAD(&mnt->mnt_fsnotify_marks);
 #endif
+		ATOMIC_INIT_NOTIFIER_HEAD(&mnt->mnt_holders);
+
 	}
 	return mnt;
=20
@@ -1201,6 +1234,11 @@ static int do_umount(struct mount *mnt, int flags)
 		sb->s_op->umount_begin(sb);
 	}
=20
+	/* Some in-kernel users (nfsd) might need to be asked to release
+	 * the filesystem
+	 */
+	umount_notifier_call(mnt);
+
 	/*
 	 * No sense to grab the lock for this test, but test itself looks
 	 * somewhat bogus. Suggestions for better replacement?
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5f38ea3..e4dbd5b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -46,8 +46,11 @@ static void expkey_put(struct kref *ref)
 	struct svc_expkey *key =3D container_of(ref, struct svc_expkey, h.ref);
=20
 	if (test_bit(CACHE_VALID, &key->h.flags) &&
-	    !test_bit(CACHE_NEGATIVE, &key->h.flags))
+	    !test_bit(CACHE_NEGATIVE, &key->h.flags)) {
+		umount_notifier_unregister(key->ek_path.mnt,
+					   &key->ek_umount);
 		path_put(&key->ek_path);
+	}
 	auth_domain_put(key->ek_client);
 	kfree(key);
 }
@@ -71,6 +74,16 @@ static struct svc_expkey *svc_expkey_update(struct cache=
_detail *cd, struct svc_
 					    struct svc_expkey *old);
 static struct svc_expkey *svc_expkey_lookup(struct cache_detail *cd, struc=
t svc_expkey *);
=20
+static int purge_expkey(struct notifier_block *nb,
+			unsigned long mode, void *unused)
+{
+	struct svc_expkey *ek =3D container_of(nb, struct svc_expkey, ek_umount);
+	ek->h.expiry_time =3D 1;
+	ek->cd->nextcheck =3D 1;
+	queue_sunrpc_cache_flush();
+	return NOTIFY_OK;
+}
+
 static int expkey_parse(struct cache_detail *cd, char *mesg, int mlen)
 {
 	/* client fsidtype fsid [path] */
@@ -123,8 +136,9 @@ static int expkey_parse(struct cache_detail *cd, char *=
mesg, int mlen)
 	if (key.h.expiry_time =3D=3D 0)
 		goto out;
=20
-	key.ek_client =3D dom;=09
+	key.ek_client =3D dom;
 	key.ek_fsidtype =3D fsidtype;
+	key.cd =3D cd;
 	memcpy(key.ek_fsid, buf, len);
=20
 	ek =3D svc_expkey_lookup(cd, &key);
@@ -212,6 +226,7 @@ static inline void expkey_init(struct cache_head *cnew,
 	kref_get(&item->ek_client->ref);
 	new->ek_client =3D item->ek_client;
 	new->ek_fsidtype =3D item->ek_fsidtype;
+	new->cd =3D item->cd;
=20
 	memcpy(new->ek_fsid, item->ek_fsid, sizeof(new->ek_fsid));
 }
@@ -223,7 +238,10 @@ static inline void expkey_update(struct cache_head *cn=
ew,
 	struct svc_expkey *item =3D container_of(citem, struct svc_expkey, h);
=20
 	new->ek_path =3D item->ek_path;
-	path_get(&item->ek_path);
+	path_get(&new->ek_path);
+	new->ek_umount.notifier_call =3D purge_expkey;
+	umount_notifier_register(new->ek_path.mnt,
+				 &new->ek_umount);
 }
=20
 static struct cache_head *expkey_alloc(void)
@@ -307,6 +325,7 @@ static void nfsd4_fslocs_free(struct nfsd4_fs_locations=
 *fsloc)
 static void svc_export_put(struct kref *ref)
 {
 	struct svc_export *exp =3D container_of(ref, struct svc_export, h.ref);
+	umount_notifier_unregister(exp->ex_path.mnt, &exp->ex_umount);
 	path_put(&exp->ex_path);
 	auth_domain_put(exp->ex_client);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
@@ -653,6 +672,16 @@ static int svc_export_match(struct cache_head *a, stru=
ct cache_head *b)
 		orig->ex_path.mnt =3D=3D new->ex_path.mnt;
 }
=20
+static int purge_export(struct notifier_block *nb,
+			unsigned long mode, void *unused)
+{
+	struct svc_export *exp =3D container_of(nb, struct svc_export, ex_umount);
+	exp->h.expiry_time =3D 1;
+	exp->cd->nextcheck =3D 1;
+	queue_sunrpc_cache_flush();
+	return NOTIFY_OK;
+}
+
 static void svc_export_init(struct cache_head *cnew, struct cache_head *ci=
tem)
 {
 	struct svc_export *new =3D container_of(cnew, struct svc_export, h);
@@ -662,6 +691,8 @@ static void svc_export_init(struct cache_head *cnew, st=
ruct cache_head *citem)
 	new->ex_client =3D item->ex_client;
 	new->ex_path.dentry =3D dget(item->ex_path.dentry);
 	new->ex_path.mnt =3D mntget(item->ex_path.mnt);
+	new->ex_umount.notifier_call =3D purge_export;
+	umount_notifier_register(new->ex_path.mnt, &new->ex_umount);
 	new->ex_fslocs.locations =3D NULL;
 	new->ex_fslocs.locations_count =3D 0;
 	new->ex_fslocs.migrated =3D 0;
@@ -766,6 +797,7 @@ exp_find_key(struct cache_detail *cd, svc_client *clp, =
int fsid_type,
=20
 	key.ek_client =3D clp;
 	key.ek_fsidtype =3D fsid_type;
+	key.cd =3D cd;
 	memcpy(key.ek_fsid, fsidv, key_len(fsid_type));
=20
 	ek =3D svc_expkey_lookup(cd, &key);
diff --git a/include/linux/mount.h b/include/linux/mount.h
index 73005f9..1e18926 100644
--- a/include/linux/mount.h
+++ b/include/linux/mount.h
@@ -76,6 +76,10 @@ extern struct vfsmount *vfs_kern_mount(struct file_syste=
m_type *type,
 extern void mnt_set_expiry(struct vfsmount *mnt, struct list_head *expiry_=
list);
 extern void mark_mounts_for_expiry(struct list_head *mounts);
=20
+struct notifier_block;
+extern int umount_notifier_register(struct vfsmount *v, struct notifier_bl=
ock *nb);
+extern int umount_notifier_unregister(struct vfsmount *v, struct notifier_=
block *nb);
+
 extern dev_t name_to_dev_t(char *name);
=20
 #endif /* _LINUX_MOUNT_H */
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 7898c99..696cf62 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -49,6 +49,7 @@ struct svc_export {
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
+	struct notifier_block	ex_umount;
 	kuid_t			ex_anon_uid;
 	kgid_t			ex_anon_gid;
 	int			ex_fsid;
@@ -71,6 +72,8 @@ struct svc_expkey {
 	u32			ek_fsid[6];
=20
 	struct path		ek_path;
+	struct notifier_block	ek_umount;
+	struct cache_detail	*cd;
 };
=20
 #define EX_ISSYNC(exp)		(!((exp)->ex_flags & NFSEXP_ASYNC))
diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
index 303399b..ed23c31 100644
--- a/include/linux/sunrpc/cache.h
+++ b/include/linux/sunrpc/cache.h
@@ -195,6 +195,7 @@ static inline int cache_valid(struct cache_head *h)
 extern int cache_check(struct cache_detail *detail,
 		       struct cache_head *h, struct cache_req *rqstp);
 extern void cache_flush(void);
+extern void queue_sunrpc_cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
 #define NEVER (0x7FFFFFFF)
 extern void __init cache_initialize(void);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 25d58e76..bf7d351 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -471,10 +471,15 @@ static int cache_clean(void)
 /*
  * We want to regularly clean the cache, so we need to schedule some work =
...
  */
+static int cache_flush_required =3D 0;
 static void do_cache_clean(struct work_struct *work)
 {
 	int delay =3D 5;
-	if (cache_clean() =3D=3D -1)
+
+	if (cache_flush_required) {
+		cache_flush_required =3D 0;
+		cache_flush();
+	} else if (cache_clean() =3D=3D -1)
 		delay =3D round_jiffies_relative(30*HZ);
=20
 	if (list_empty(&cache_list))
@@ -508,6 +513,13 @@ void cache_purge(struct cache_detail *detail)
 }
 EXPORT_SYMBOL_GPL(cache_purge);
=20
+void queue_sunrpc_cache_flush(void)
+{
+	cache_flush_required =3D 1;
+	cancel_delayed_work(&cache_cleaner);
+	schedule_delayed_work(&cache_cleaner, 0);
+}
+EXPORT_SYMBOL_GPL(queue_sunrpc_cache_flush);
=20
 /*
  * Deferral and Revisiting of Requests.

--Sig_/a6yFowYv5p.izGlOewrFweI
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iQIVAwUBUa6rBTnsnt1WYoG5AQIilBAAi2TZYGr/nXImMUFuRmH3NrM9sebk8Dmp
rhH4MdaTD5NCnk+kstDdoxH8X/f7y0hRbWHV29Agefr99E8S+2wq4jHy51KEb5h+
VmLK0s3Fghg5oictWz5TUXYg4SXZSPwbXggshdHyXNkHIsER2aqkI3P+DSaMVP/n
gwNmPPyFkMG7dm++Ajoq0uoHI4L+etJtFCR3R9K9tkpb5Uzw/lxSh8stNTjMqa9s
M7tJ15VFj18+ZYQT7y7w2tFDsdXHrIFu0yOAoCEDbEsIB0uFQuozJ/7Sn4N48BRn
RRMEV4aB0tU8hc2SZZzQFv0IOx+R3038fHDcTFtYa1+BG+fiT1YfJOihTBYKyGBU
vkZm85jLigMQwaZLzCCrHDo6v7DXW9R+8HJ3zeKmJ7hYSK3ZJ+OYMwXr8jLzw58B
t351gMwl1v9nX2mpe4DSqnraAKfsolVm0XMUyXvvK0chra8+K91G1R5xhcRteC1D
zt7GgOB67Dh6tXbMHP+xYzyS6qRCFob6Pn7atyYiYGnbWBTKzQpWi9heDz6+41Ur
YozOuD0FNSDnekkZLIL8R/8jiqOfyOuUTDr/CucIKIKBnJlj2d4Oyr5kWYgoZji7
M0ort806XB/ajF7WwnPrGdzUpjSqiON6S6f9y8znH0P9LdQKdO7N5nBdg7u/GyZH
30HCOoG0i/c=
=HVma
-----END PGP SIGNATURE-----

--Sig_/a6yFowYv5p.izGlOewrFweI--
