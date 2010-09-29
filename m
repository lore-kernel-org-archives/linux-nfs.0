Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42635 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755552Ab0I2Tlu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Sep 2010 15:41:50 -0400
Message-ID: <4CA3967D.4040502@netapp.com>
Date: Wed, 29 Sep 2010 15:41:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: new idmapper
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS new idmapper

This patch creates a new idmapper system that uses the request-key function to
place a call into userspace to map user and group ids to names.  The old
idmapper was single threaded, which prevented more than one request from running
at a single time.  This means that a user would have to wait for an upcall to
finish before accessing a cached result.

The upcall result is stored on a keyring of type id_resolver.  See the file
Documentation/filesystems/nfs/idmapper.txt for instructions.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/Documentation/filesystems/nfs/00-INDEX b/Documentation/filesystems/nfs/00-INDEX
index 2f68cd6..3225a56 100644
--- a/Documentation/filesystems/nfs/00-INDEX
+++ b/Documentation/filesystems/nfs/00-INDEX
@@ -14,3 +14,5 @@ nfsroot.txt
 	- short guide on setting up a diskless box with NFS root filesystem.
 rpc-cache.txt
 	- introduction to the caching mechanisms in the sunrpc layer.
+idmapper.txt
+	- information for configuring request-keys to be used by idmapper
diff --git a/Documentation/filesystems/nfs/idmapper.txt b/Documentation/filesystems/nfs/idmapper.txt
new file mode 100644
index 0000000..d9f1d1f
--- /dev/null
+++ b/Documentation/filesystems/nfs/idmapper.txt
@@ -0,0 +1,68 @@
+
+=========
+ID Mapper
+=========
+Id mapper is used by NFS to translate user and group ids into names, and to
+translate user and group names into ids.  Part of this translation involves
+performing an upcall to userspace to request the information.  Id mapper will
+user request-key to perform this upcall and cache the result.  The program
+/usr/sbin/nfs.upcall should be called by request-key, and will perform the
+translation and initialize a key with the resulting information.
+
+ NFS_USE_NEW_IDMAPPER must be selected when configuring the kernel to use this
+ feature.
+
+===========
+Configuring
+===========
+The file /etc/request-key.conf will need to be modified so /sbin/request-key can
+direct the upcall.  The following line should be added:
+
+#OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
+#======	=======	===============	===============	===============================
+create	id_resolver	*	*		/usr/sbin/nfs.upcall %k %d 600
+
+This will direct all id_resolver requests to the program /usr/sbin/nfs.upcall.
+The last parameter, 600, defines how many seconds into the future the key will
+expire.  This parameter is optional for /usr/sbin/nfs.upcall.  When the timeout
+is not specified, nfs.upcall will default to 600 seconds.
+
+id mapper uses for key descriptions:
+	  uid:  Find the UID for the given user
+	  gid:  Find the GID for the given group
+	 user:  Find the user  name for the given UID
+	group:  Find the group name for the given GID
+
+You can handle any of these individually, rather than using the generic upcall
+program.  If you would like to use your own program for a uid lookup then you
+would edit your request-key.conf so it look similar to this:
+
+#OP	TYPE	DESCRIPTION	CALLOUT INFO	PROGRAM ARG1 ARG2 ARG3 ...
+#======	=======	===============	===============	===============================
+create	id_resolver	uid:*	*		/some/other/program  %k %d 600
+create	id_resolver	*	*		/usr/sbin/nfs.upcall %k %d 600
+
+Notice that the new line was added above the line for the generic program.
+request-key will find the first matching line and corresponding program.  In
+this case, /some/other/program will handle all uid lookups and
+/usr/sbin/nfs.upcall will handle gid, user, and group lookups.
+
+See <file:Documentation/keys-request-keys.txt> for more information about the
+request-key function.
+
+
+==========
+nfs.upcall
+==========
+nfs.upcall is designed to be called by request-key, and should not be run "by
+hand".  This program takes two arguments, a serialized key and a key
+description.  The serialized key is first converted into a key_serial_t, and
+then passed as an argument to keyctl_instantiate (both are part of keyutils.h).
+
+The actual lookups are performed by functions found in nfsidmap.h.  nfs.upcall
+determines the correct function to call by looking at the first part of the
+description string.  For example, a uid lookup description will appear as
+"uid:user@domain".
+
+nfs.upcall will return 0 if the key was instantiated, and non-zero otherwise.
+
diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index f7e13db..d7695b2 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -117,3 +117,14 @@ config NFS_USE_KERNEL_DNS
 	select DNS_RESOLVER
 	select KEYS
 	default y
+
+config NFS_USE_NEW_IDMAPPER
+	bool "Use the new idmapper upcall routine"
+	depends on NFS_V4 && KEYS
+	help
+	  Say Y here if you want NFS to use the new idmapper upcall functions.
+	  You will need /sbin/request-key (usually provided by the keyutils
+	  package).  For details, read
+	  <file:Documentation/filesystems/nfs/idmapper.txt>.
+
+	  If you are unsure, say N.
diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 21a84d4..cca9a74 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -34,6 +34,208 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 
+#ifdef CONFIG_NFS_USE_NEW_IDMAPPER
+
+#include <linux/slab.h>
+#include <linux/cred.h>
+#include <linux/nfs_idmap.h>
+#include <linux/keyctl.h>
+#include <linux/key-type.h>
+#include <linux/rcupdate.h>
+#include <linux/kernel.h>
+
+#include <keys/user-type.h>
+
+#define NFS_UINT_MAXLEN 11
+
+const struct cred *id_resolver_cache;
+
+struct key_type key_type_id_resolver = {
+	.name		= "id_resolver",
+	.instantiate	= user_instantiate,
+	.match		= user_match,
+	.revoke		= user_revoke,
+	.destroy	= user_destroy,
+	.describe	= user_describe,
+	.read		= user_read,
+};
+
+int nfs_idmap_init(void)
+{
+	struct cred *cred;
+	struct key *keyring;
+	int ret = 0;
+
+	printk(KERN_NOTICE "Registering the %s key type\n", key_type_id_resolver.name);
+
+	cred = prepare_kernel_cred(NULL);
+	if (!cred)
+		return -ENOMEM;
+
+	keyring = key_alloc(&key_type_keyring, ".id_resolver", 0, 0, cred,
+			     (KEY_POS_ALL & ~KEY_POS_SETATTR) |
+			     KEY_USR_VIEW | KEY_USR_READ,
+			     KEY_ALLOC_NOT_IN_QUOTA);
+	if (IS_ERR(keyring)) {
+		ret = PTR_ERR(keyring);
+		goto failed_put_cred;
+	}
+
+	ret = key_instantiate_and_link(keyring, NULL, 0, NULL, NULL);
+	if (ret < 0)
+		goto failed_put_key;
+
+	ret = register_key_type(&key_type_id_resolver);
+	if (ret < 0)
+		goto failed_put_key;
+
+	cred->thread_keyring = keyring;
+	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
+	id_resolver_cache = cred;
+	return 0;
+
+failed_put_key:
+	key_put(keyring);
+failed_put_cred:
+	put_cred(cred);
+	return ret;
+}
+
+void nfs_idmap_quit(void)
+{
+	key_revoke(id_resolver_cache->thread_keyring);
+	unregister_key_type(&key_type_id_resolver);
+	put_cred(id_resolver_cache);
+}
+
+/*
+ * Assemble the description to pass to request_key()
+ * This function will allocate a new string and update dest to point
+ * at it.  The caller is responsible for freeing dest.
+ *
+ * On error 0 is returned.  Otherwise, the length of dest is returned.
+ */
+static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
+				const char *type, size_t typelen, char **desc)
+{
+	char *cp;
+	size_t desclen = typelen + namelen + 2;
+
+	*desc = kmalloc(desclen, GFP_KERNEL);
+	if (!desc)
+		return -ENOMEM;
+
+	cp = *desc;
+	memcpy(cp, type, typelen);
+	cp += typelen;
+	*cp++ = ':';
+
+	memcpy(cp, name, namelen);
+	cp += namelen;
+	*cp = '\0';
+	return desclen;
+}
+
+static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
+				 char *type, void *data, size_t data_size)
+{
+	const struct cred *saved_cred;
+	struct key *rkey;
+	char *desc;
+	struct user_key_payload *payload;
+	ssize_t ret;
+
+	memset(data, 0, data_size);
+	ret = nfs_idmap_get_desc(name, namelen, type, strlen(type), &desc);
+	if (ret <= 0)
+		goto out;
+
+	saved_cred = override_creds(id_resolver_cache);
+	rkey = request_key(&key_type_id_resolver, desc, "");
+	revert_creds(saved_cred);
+	kfree(desc);
+	if (IS_ERR(rkey)) {
+		ret = PTR_ERR(rkey);
+		goto out;
+	}
+
+	rcu_read_lock();
+	rkey->perm |= KEY_USR_VIEW;
+
+	ret = key_validate(rkey);
+	if (ret < 0)
+		goto out_up;
+
+	payload = rcu_dereference(rkey->payload.data);
+	if (IS_ERR_OR_NULL(payload)) {
+		ret = PTR_ERR(payload);
+		goto out_up;
+	}
+
+	ret = payload->datalen;
+	if (ret > 0 && ret <= data_size)
+		memcpy(data, payload->data, ret);
+	else
+		ret = -EINVAL;
+
+out_up:
+	rcu_read_unlock();
+	key_put(rkey);
+out:
+	return ret;
+}
+
+
+/* ID -> Name */
+static int nfs_idmap_lookup_name(__u32 id, char *name, char *type, size_t buflen)
+{
+	char id_str[NFS_UINT_MAXLEN];
+	snprintf(id_str, buflen, "%u", id);
+	if (nfs_idmap_request_key(id_str, strlen(id_str), type, (void *)name, buflen) < 0)
+		return -EINVAL;
+	return 0;
+}
+
+/* Name -> ID */
+static int nfs_idmap_lookup_id(const char *name, size_t namelen,
+				__u32 *id, char *type)
+{
+	char id_str[NFS_UINT_MAXLEN];
+	long id_long;
+	ssize_t data_size;
+	int ret = 0;
+
+	data_size = nfs_idmap_request_key(name, namelen, type, id_str, NFS_UINT_MAXLEN);
+	if (data_size <= 0) {
+		ret = -EINVAL;
+	} else {
+		ret = strict_strtol(id_str, 10, &id_long);
+		*id = (__u32)id_long;
+	}
+	return ret;
+}
+
+int nfs_map_name_to_uid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *uid)
+{
+	return nfs_idmap_lookup_id(name, namelen, uid, "uid");
+}
+
+int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namelen, __u32 *gid)
+{
+	return nfs_idmap_lookup_id(name, namelen, gid, "gid");
+}
+
+int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
+{
+	return nfs_idmap_lookup_name(uid, buf, "user", buflen);
+}
+int nfs_map_gid_to_group(struct nfs_client *clp, __u32 gid, char *buf, size_t buflen)
+{
+	return nfs_idmap_lookup_name(gid, buf, "group", buflen);
+}
+
+#else  /* CONFIG_NFS_USE_IDMAPPER not defined */
+
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/init.h>
@@ -503,16 +705,17 @@ int nfs_map_group_to_gid(struct nfs_client *clp, const char *name, size_t namele
 	return nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, uid);
 }
 
-int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf)
+int nfs_map_uid_to_name(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = clp->cl_idmap;
 
 	return nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
 }
-int nfs_map_gid_to_group(struct nfs_client *clp, __u32 uid, char *buf)
+int nfs_map_gid_to_group(struct nfs_client *clp, __u32 uid, char *buf, size_t buflen)
 {
 	struct idmap *idmap = clp->cl_idmap;
 
 	return nfs_idmap_name(idmap, &idmap->idmap_group_hash, uid, buf);
 }
 
+#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 7d2d6c7..1bf86de 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1521,6 +1521,10 @@ static int __init init_nfs_fs(void)
 {
 	int err;
 
+	err = nfs_idmap_init();
+	if (err < 0)
+		goto out9;
+
 	err = nfs_dns_resolver_init();
 	if (err < 0)
 		goto out8;
@@ -1585,6 +1589,8 @@ out6:
 out7:
 	nfs_dns_resolver_destroy();
 out8:
+	nfs_idmap_quit();
+out9:
 	return err;
 }
 
@@ -1597,6 +1603,7 @@ static void __exit exit_nfs_fs(void)
 	nfs_destroy_nfspagecache();
 	nfs_fscache_unregister();
 	nfs_dns_resolver_destroy();
+	nfs_idmap_quit();
 #ifdef CONFIG_PROC_FS
 	rpc_proc_unregister("nfs");
 #endif
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 08ef912..e1724c9 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -816,7 +816,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	if (iap->ia_valid & ATTR_MODE)
 		len += 4;
 	if (iap->ia_valid & ATTR_UID) {
-		owner_namelen = nfs_map_uid_to_name(server->nfs_client, iap->ia_uid, owner_name);
+		owner_namelen = nfs_map_uid_to_name(server->nfs_client, iap->ia_uid, owner_name, IDMAP_NAMESZ);
 		if (owner_namelen < 0) {
 			dprintk("nfs: couldn't resolve uid %d to string\n",
 					iap->ia_uid);
@@ -828,7 +828,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 		len += 4 + (XDR_QUADLEN(owner_namelen) << 2);
 	}
 	if (iap->ia_valid & ATTR_GID) {
-		owner_grouplen = nfs_map_gid_to_group(server->nfs_client, iap->ia_gid, owner_group);
+		owner_grouplen = nfs_map_gid_to_group(server->nfs_client, iap->ia_gid, owner_group, IDMAP_NAMESZ);
 		if (owner_grouplen < 0) {
 			dprintk("nfs: couldn't resolve gid %d to string\n",
 					iap->ia_gid);
diff --git a/fs/nfs/sysctl.c b/fs/nfs/sysctl.c
index ad4d2e7..978aaeb 100644
--- a/fs/nfs/sysctl.c
+++ b/fs/nfs/sysctl.c
@@ -32,6 +32,7 @@ static ctl_table nfs_cb_sysctls[] = {
 		.extra1 = (int *)&nfs_set_port_min,
 		.extra2 = (int *)&nfs_set_port_max,
 	},
+#ifndef CONFIG_NFS_USE_NEW_IDMAPPER
 	{
 		.procname = "idmap_cache_timeout",
 		.data = &nfs_idmap_cache_timeout,
@@ -39,6 +40,7 @@ static ctl_table nfs_cb_sysctls[] = {
 		.mode = 0644,
 		.proc_handler = proc_dointvec_jiffies,
 	},
+#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
 #endif
 	{
 		.procname	= "nfs_mountpoint_timeout",
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 91a1c24..e8352dc 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -66,13 +66,40 @@ struct idmap_msg {
 /* Forward declaration to make this header independent of others */
 struct nfs_client;
 
+#ifdef CONFIG_NFS_USE_NEW_IDMAPPER
+
+int nfs_idmap_init(void);
+void nfs_idmap_quit(void);
+
+static inline int nfs_idmap_new(struct nfs_client *clp)
+{
+	return 0;
+}
+
+static inline void nfs_idmap_delete(struct nfs_client *clp)
+{
+}
+
+#else /* CONFIG_NFS_USE_NEW_IDMAPPER not set */
+
+static inline int nfs_idmap_init(void)
+{
+	return 0;
+}
+
+static inline void nfs_idmap_quit(void)
+{
+}
+
 int nfs_idmap_new(struct nfs_client *);
 void nfs_idmap_delete(struct nfs_client *);
 
+#endif /* CONFIG_NFS_USE_NEW_IDMAPPER */
+
 int nfs_map_name_to_uid(struct nfs_client *, const char *, size_t, __u32 *);
 int nfs_map_group_to_gid(struct nfs_client *, const char *, size_t, __u32 *);
-int nfs_map_uid_to_name(struct nfs_client *, __u32, char *);
-int nfs_map_gid_to_group(struct nfs_client *, __u32, char *);
+int nfs_map_uid_to_name(struct nfs_client *, __u32, char *, size_t);
+int nfs_map_gid_to_group(struct nfs_client *, __u32, char *, size_t);
 
 extern unsigned int nfs_idmap_cache_timeout;
 #endif /* __KERNEL__ */
