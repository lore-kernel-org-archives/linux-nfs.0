Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34192 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750733AbdE3QIt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 30 May 2017 12:08:49 -0400
Subject: [RFC PATCH] KEYS: Allow a live daemon in a namespace to service
 request_key upcalls
From: David Howells <dhowells@redhat.com>
To: James.Bottomley@HansenPartnership.com, ebiederm@xmission.com
Cc: linux-nfs@vger.kernel.org, containers@lists.linux-foundation.org,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        keyrings@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        cgroups@vger.kernel.org
Date: Tue, 30 May 2017 17:08:44 +0100
Message-ID: <149616052408.10194.7774163568767478808.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Provide a mechanism by which a running daemon can intercept request_key
upcalls, filtered by namespace and key type, and service them.  The list of
active services is per-user_namespace.


======================================
CREATING A CHANNEL AND SETTING FILTERS
======================================

To intercept request_key upcalls, a daemon first creates a communication
channel:

	int fd = keyctl(KEYCTL_SERVICE_CREATE, unsigned int flags);

where flags is a bitwise-OR of:

	KEY_SERVICE_FD_CLOEXEC
	KEY_SERVICE_FD_NONBLOCK

The daemon can then add filters to intercept request_key upcalls by calling
the following one or more times:

	keyctl(KEYCTL_SERVICE_ADD, int fd,
	       const char *type_name, unsigned int ns_mask);

where fd is as returned by the creation call above, type_name is the name
of key type or NULL and ns_mask is a bitwise-OR of:

	KEY_SERVICE_NS_UTS
	KEY_SERVICE_NS_IPC
	KEY_SERVICE_NS_MNT
	KEY_SERVICE_NS_PID
	KEY_SERVICE_NS_NET
	KEY_SERVICE_NS_CGROUP

which select those namespaces of the caller that must match for the daemon
to be given the request.  So, for example, a daemon that wanted to service
DNS requests from the kernel would do something like:

	keyctl(KEYCTL_SERVICE_ADD, fd, "dns_resolver", KEY_SERVICE_NS_NET);

so that it gets all the DNS records issued by processes in the current
network namespace, no matter what other namespaces are in force at the
time.  On the other hand, the following call:

	keyctl(KEYCTL_SERVICE_ADD, fd, NULL, 0);

will match everything.

If conflicts arise between two filter records (and different daemons can
have filter records in the same list), the most specific record is matched
by preference, otherwise the first added gets the work.  So, in the example
above, the dns_resolver-specific record would match in preference to the
match-everything record as the former in more specific (it specifies a type
and a particular namespace).

Notes:

 (1) If two records are submitted that match exactly, the second will be
     rejected with EBUSY.

 (2) Note that anyone can create a channel, but only a sysadmin or the root
     user of the current user_namespace may add filters.

     [!] NOTE: I'm really not sure how to get the security right here.  Who
	 is allowed to intercept requests?  Getting it wrong opens a
	 definite security hole.

 (3) Multiple threads may listen on/read the same fd.

 (4) The filters are withdrawn when the file is destroyed.  Any outstanding
     requests at the time are rejected with ENOKEY rather than looking
     round for another daemon to handle them.

 (5) I'm not sure it really handles cases where some of the caller's
     namespaces aren't owned by the caller's user_namespace.


==================
SERVICING REQUESTS
==================

The fd may be polled to find out if it has any requests pending and, if it
has, read() is used to retrieve the request at the front of the queue.
read() will place into the buffer a record that looks like:

	<opname> <keyid> <uid> <gid> <threadring> <processring> <sessionring>

where opname is the operation desired (typically "create"), keyid is the ID
of the key under construction and the rest represent the credentials of the
process that called request_key().

and can be parsed with something like:

	sscanf(buf, "%12s %x %x %x %x %x %x",
	       op, &key_id, &uid, &gid, &t_ring, &p_ring, &s_ring);

If successful, read() will have placed an authorisation key into the
caller's thread keyring.  To access/instantiate a key, the caller should
do:

	keyctl_assume_authority(key_id);

After which it can do one of:

	keyctl_instantiate(key_id, "foo_bar", 7, 0);
	keyctl_negate(key_id, 0, 0);
	keyctl_reject(key_id, 0, ENOANO, 0);

and the authorisation key will be revoked and removed.

If the authorisation key is unlinked from the thread keyring, the target
key will be rejected if it hasn't been instantiated yet.
---

 fs/mount.h                       |    6 
 fs/namespace.c                   |    7 
 fs/nfs/nfs4idmap.c               |    6 
 include/linux/cgroup.h           |    3 
 include/linux/key-type.h         |   14 +
 include/linux/mnt_namespace.h    |    1 
 include/linux/user_namespace.h   |    4 
 include/linux/utsname.h          |    8 
 include/net/net_namespace.h      |    3 
 include/uapi/linux/keyctl.h      |   14 +
 include/uapi/linux/magic.h       |    1 
 kernel/user.c                    |    5 
 kernel/user_namespace.c          |    4 
 security/keys/Makefile           |    2 
 security/keys/compat.c           |    5 
 security/keys/internal.h         |    5 
 security/keys/keyctl.c           |    7 
 security/keys/process_keys.c     |    2 
 security/keys/request_key.c      |   28 +-
 security/keys/request_key_auth.c |    3 
 security/keys/service.c          |  633 ++++++++++++++++++++++++++++++++++++++
 21 files changed, 728 insertions(+), 33 deletions(-)
 create mode 100644 security/keys/service.c

diff --git a/fs/mount.h b/fs/mount.h
index 02ef292a77d7..ef66521c4153 100644
--- a/fs/mount.h
+++ b/fs/mount.h
@@ -108,12 +108,6 @@ static inline void detach_mounts(struct dentry *dentry)
 	__detach_mounts(dentry);
 }
 
-static inline struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns)
-{
-	atomic_inc(&ns->count);
-	return ns;
-}
-
 extern seqlock_t mount_lock;
 
 static inline void lock_mount_hash(void)
diff --git a/fs/namespace.c b/fs/namespace.c
index 4e9ad16db79c..75e1fdf83185 100644
--- a/fs/namespace.c
+++ b/fs/namespace.c
@@ -3552,6 +3552,13 @@ void __init mnt_init(void)
 	init_mount_tree();
 }
 
+struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns)
+{
+	if (ns)
+		atomic_inc(&ns->count);
+	return ns;
+}
+
 void put_mnt_ns(struct mnt_namespace *ns)
 {
 	if (!atomic_dec_and_test(&ns->count))
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index 835c163f61af..978b7aaeff98 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -383,7 +383,7 @@ static const match_table_t nfs_idmap_tokens = {
 	{ Opt_find_err, NULL }
 };
 
-static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
+static int nfs_idmap_legacy_upcall(struct key_construction *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
 static void idmap_release_pipe(struct inode *);
@@ -558,9 +558,7 @@ nfs_idmap_abort_pipe_upcall(struct idmap *idmap, int ret)
 		nfs_idmap_complete_pipe_upcall_locked(idmap, ret);
 }
 
-static int nfs_idmap_legacy_upcall(struct key_construction *cons,
-				   const char *op,
-				   void *aux)
+static int nfs_idmap_legacy_upcall(struct key_construction *cons, void *aux)
 {
 	struct idmap_legacy_upcalldata *data;
 	struct rpc_pipe_msg *msg;
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ed2573e149fa..913a0fe863c7 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -693,10 +693,11 @@ copy_cgroup_ns(unsigned long flags, struct user_namespace *user_ns,
 
 #endif /* !CONFIG_CGROUPS */
 
-static inline void get_cgroup_ns(struct cgroup_namespace *ns)
+static inline struct cgroup_namespace *get_cgroup_ns(struct cgroup_namespace *ns)
 {
 	if (ns)
 		refcount_inc(&ns->count);
+	return ns;
 }
 
 static inline void put_cgroup_ns(struct cgroup_namespace *ns)
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index 8496cf64575c..6239a83d2da9 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -22,8 +22,11 @@
  * - passed to the request_key actor if supplied
  */
 struct key_construction {
-	struct key	*key;	/* key being constructed */
-	struct key	*authkey;/* authorisation for key being constructed */
+	struct key		*key;		/* Key being constructed */
+	struct key		*authkey;	/* Authorisation for key being constructed */
+	struct list_head	link;		/* Link in service daemon's list */
+	const struct cred	*cred;		/* Constructing process's creds */
+	char			operation[8];	/* The operation to perform */
 };
 
 /*
@@ -47,8 +50,7 @@ struct key_preparsed_payload {
 	time_t		expiry;		/* Expiry time of key */
 };
 
-typedef int (*request_key_actor_t)(struct key_construction *key,
-				   const char *op, void *aux);
+typedef int (*request_key_actor_t)(struct key_construction *key, void *aux);
 
 /*
  * Preparsed matching criterion.
@@ -72,8 +74,10 @@ struct key_match_data {
  * kernel managed key type definition
  */
 struct key_type {
+	struct module *owner;
+	
 	/* name of the type */
-	const char *name;
+	const char name[24];
 
 	/* default payload length for quota precalculation (optional)
 	 * - this can be used instead of calling key_payload_reserve(), that
diff --git a/include/linux/mnt_namespace.h b/include/linux/mnt_namespace.h
index 12b2ab510323..8d9fabe85756 100644
--- a/include/linux/mnt_namespace.h
+++ b/include/linux/mnt_namespace.h
@@ -8,6 +8,7 @@ struct user_namespace;
 
 extern struct mnt_namespace *copy_mnt_ns(unsigned long, struct mnt_namespace *,
 		struct user_namespace *, struct fs_struct *);
+extern struct mnt_namespace *get_mnt_ns(struct mnt_namespace *ns);
 extern void put_mnt_ns(struct mnt_namespace *ns);
 
 extern const struct file_operations proc_mounts_operations;
diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
index 32354b4b4b2b..8d43bea97872 100644
--- a/include/linux/user_namespace.h
+++ b/include/linux/user_namespace.h
@@ -54,11 +54,15 @@ struct user_namespace {
 	struct ns_common	ns;
 	unsigned long		flags;
 
+#ifdef CONFIG_KEYS
+	struct hlist_head	request_key_services;
+	spinlock_t		request_key_services_lock;
 	/* Register of per-UID persistent keyrings for this namespace */
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	struct key		*persistent_keyring_register;
 	struct rw_semaphore	persistent_keyring_register_sem;
 #endif
+#endif
 	struct work_struct	work;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_set	set;
diff --git a/include/linux/utsname.h b/include/linux/utsname.h
index 60f0bb83b313..d032ba490bc6 100644
--- a/include/linux/utsname.h
+++ b/include/linux/utsname.h
@@ -30,9 +30,11 @@ struct uts_namespace {
 extern struct uts_namespace init_uts_ns;
 
 #ifdef CONFIG_UTS_NS
-static inline void get_uts_ns(struct uts_namespace *ns)
+static inline struct uts_namespace *get_uts_ns(struct uts_namespace *ns)
 {
-	kref_get(&ns->kref);
+	if (ns)
+		kref_get(&ns->kref);
+	return ns;
 }
 
 extern struct uts_namespace *copy_utsname(unsigned long flags,
@@ -44,7 +46,7 @@ static inline void put_uts_ns(struct uts_namespace *ns)
 	kref_put(&ns->kref, free_uts_ns);
 }
 #else
-static inline void get_uts_ns(struct uts_namespace *ns)
+static inline struct uts_namespace *get_uts_ns(struct uts_namespace *ns)
 {
 }
 
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index fe80bb48ab1f..5e7da40b86fc 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -189,7 +189,8 @@ void __put_net(struct net *net);
 
 static inline struct net *get_net(struct net *net)
 {
-	atomic_inc(&net->count);
+	if (net)
+		atomic_inc(&net->count);
 	return net;
 }
 
diff --git a/include/uapi/linux/keyctl.h b/include/uapi/linux/keyctl.h
index 201c6644b237..8ced000bc819 100644
--- a/include/uapi/linux/keyctl.h
+++ b/include/uapi/linux/keyctl.h
@@ -35,6 +35,18 @@
 #define KEY_REQKEY_DEFL_GROUP_KEYRING		6
 #define KEY_REQKEY_DEFL_REQUESTOR_KEYRING	7
 
+/* Request_key service daemon namespace selection specifiers. */
+#define KEY_SERVICE_NS_UTS		0x0001
+#define KEY_SERVICE_NS_IPC		0x0002
+#define KEY_SERVICE_NS_MNT		0x0004
+#define KEY_SERVICE_NS_PID		0x0008
+#define KEY_SERVICE_NS_NET		0x0010
+#define KEY_SERVICE_NS_CGROUP		0x0020
+#define KEY_SERVICE___ALL_NS		0x003f
+
+#define KEY_SERVICE_FD_CLOEXEC		0x0001
+#define KEY_SERVICE_FD_NONBLOCK		0x0002
+
 /* keyctl commands */
 #define KEYCTL_GET_KEYRING_ID		0	/* ask for a keyring's ID */
 #define KEYCTL_JOIN_SESSION_KEYRING	1	/* join or start named session keyring */
@@ -61,6 +73,8 @@
 #define KEYCTL_GET_PERSISTENT		22	/* get a user's persistent keyring */
 #define KEYCTL_DH_COMPUTE		23	/* Compute Diffie-Hellman values */
 #define KEYCTL_RESTRICT_KEYRING		29	/* Restrict keys allowed to link to a keyring */
+#define KEYCTL_SERVICE_CREATE		30	/* Create a request_key() service channel */
+#define KEYCTL_SERVICE_ADD		31	/* Specify the a request pattern we can service */
 
 /* keyctl structures */
 struct keyctl_dh_params {
diff --git a/include/uapi/linux/magic.h b/include/uapi/linux/magic.h
index 88ae83492f7c..74c01bf5fd18 100644
--- a/include/uapi/linux/magic.h
+++ b/include/uapi/linux/magic.h
@@ -85,5 +85,6 @@
 #define BALLOON_KVM_MAGIC	0x13661366
 #define ZSMALLOC_MAGIC		0x58295829
 #define FS_FS_MAGIC		0x66736673
+#define KEY_SERVICEFS_MAGIC	0x6b657973
 
 #endif /* __LINUX_MAGIC_H__ */
diff --git a/kernel/user.c b/kernel/user.c
index 00281add65b2..b2761899463c 100644
--- a/kernel/user.c
+++ b/kernel/user.c
@@ -56,6 +56,11 @@ struct user_namespace init_user_ns = {
 	.ns.ops = &userns_operations,
 #endif
 	.flags = USERNS_INIT_FLAGS,
+#ifdef CONFIG_KEYS
+	.request_key_services = HLIST_HEAD_INIT,
+	.request_key_services_lock =
+	__SPIN_LOCK_UNLOCKED(init_user_ns.request_key_services_lock),
+#endif
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	.persistent_keyring_register_sem =
 	__RWSEM_INITIALIZER(init_user_ns.persistent_keyring_register_sem),
diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
index 2f735cbe05e8..cfc6333e60ff 100644
--- a/kernel/user_namespace.c
+++ b/kernel/user_namespace.c
@@ -131,6 +131,10 @@ int create_user_ns(struct cred *new)
 	ns->flags = parent_ns->flags;
 	mutex_unlock(&userns_state_mutex);
 
+#ifdef CONFIG_KEYS
+	INIT_HLIST_HEAD(&ns->request_key_services);
+	spin_lock_init(&ns->request_key_services_lock);
+#endif
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 	init_rwsem(&ns->persistent_keyring_register_sem);
 #endif
diff --git a/security/keys/Makefile b/security/keys/Makefile
index 57dff0c15809..430fdf614d79 100644
--- a/security/keys/Makefile
+++ b/security/keys/Makefile
@@ -14,7 +14,9 @@ obj-y := \
 	process_keys.o \
 	request_key.o \
 	request_key_auth.o \
+	service.o \
 	user_defined.o
+
 compat-obj-$(CONFIG_KEY_DH_OPERATIONS) += compat_dh.o
 obj-$(CONFIG_KEYS_COMPAT) += compat.o $(compat-obj-y)
 obj-$(CONFIG_PROC_FS) += proc.o
diff --git a/security/keys/compat.c b/security/keys/compat.c
index e87c89c0177c..e1b1c5259ab3 100644
--- a/security/keys/compat.c
+++ b/security/keys/compat.c
@@ -141,6 +141,11 @@ COMPAT_SYSCALL_DEFINE5(keyctl, u32, option,
 		return keyctl_restrict_keyring(arg2, compat_ptr(arg3),
 					       compat_ptr(arg4));
 
+	case KEYCTL_SERVICE_CREATE:
+		return keyctl_service_create(arg2);
+	case KEYCTL_SERVICE_ADD:
+		return keyctl_service_add(arg2, compat_ptr(arg3), arg4);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/internal.h b/security/keys/internal.h
index c0f8682eba69..1f7d01bc734f 100644
--- a/security/keys/internal.h
+++ b/security/keys/internal.h
@@ -143,6 +143,7 @@ extern key_ref_t search_process_keyrings(struct keyring_search_context *ctx);
 extern struct key *find_keyring_by_name(const char *name, bool skip_perm_check);
 
 extern int install_user_keyrings(void);
+extern int install_thread_keyring(void);
 extern int install_thread_keyring_to_cred(struct cred *);
 extern int install_process_keyring_to_cred(struct cred *);
 extern int install_session_keyring_to_cred(struct cred *, struct key *);
@@ -178,6 +179,7 @@ extern void key_gc_keytype(struct key_type *ktype);
 extern int key_task_permission(const key_ref_t key_ref,
 			       const struct cred *cred,
 			       key_perm_t perm);
+extern bool queue_request_key(struct key_construction *cons);
 
 /*
  * Check to see whether permission is granted to use a key in the desired way.
@@ -256,6 +258,9 @@ extern long keyctl_instantiate_key_common(key_serial_t,
 extern long keyctl_restrict_keyring(key_serial_t id,
 				    const char __user *_type,
 				    const char __user *_restriction);
+extern long keyctl_service_create(unsigned int);
+extern long keyctl_service_add(int, const char __user *, unsigned int);
+
 #ifdef CONFIG_PERSISTENT_KEYRINGS
 extern long keyctl_get_persistent(uid_t, key_serial_t);
 extern unsigned persistent_keyring_expiry;
diff --git a/security/keys/keyctl.c b/security/keys/keyctl.c
index 447a7d5cee0f..a4cfb9cbca2f 100644
--- a/security/keys/keyctl.c
+++ b/security/keys/keyctl.c
@@ -1743,6 +1743,13 @@ SYSCALL_DEFINE5(keyctl, int, option, unsigned long, arg2, unsigned long, arg3,
 					       (const char __user *) arg3,
 					       (const char __user *) arg4);
 
+	case KEYCTL_SERVICE_CREATE:
+		return keyctl_service_create((unsigned int)arg2);
+	case KEYCTL_SERVICE_ADD:
+		return keyctl_service_add((int)arg2,
+					  (const char __user *)arg3,
+					  (unsigned int)arg4);
+
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/security/keys/process_keys.c b/security/keys/process_keys.c
index 2217dfec7996..bb286b929428 100644
--- a/security/keys/process_keys.c
+++ b/security/keys/process_keys.c
@@ -156,7 +156,7 @@ int install_thread_keyring_to_cred(struct cred *new)
  *
  * Return: 0 if a thread keyring is now present; -errno on failure.
  */
-static int install_thread_keyring(void)
+int install_thread_keyring(void)
 {
 	struct cred *new;
 	int ret;
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 9822e500d50d..90949c00753d 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -17,6 +17,7 @@
 #include <linux/err.h>
 #include <linux/keyctl.h>
 #include <linux/slab.h>
+#include <linux/init_task.h>
 #include "internal.h"
 
 #define key_negative_timeout	60	/* default timeout on a negative key's existence */
@@ -42,6 +43,7 @@ void complete_request_key(struct key_construction *cons, int error)
 
 	key_put(cons->key);
 	key_put(cons->authkey);
+	put_cred(cons->cred);
 	kfree(cons);
 }
 EXPORT_SYMBOL(complete_request_key);
@@ -91,12 +93,10 @@ static int call_usermodehelper_keys(const char *path, char **argv, char **envp,
  * Request userspace finish the construction of a key
  * - execute "/sbin/request-key <op> <key> <uid> <gid> <keyring> <keyring> <keyring>"
  */
-static int call_sbin_request_key(struct key_construction *cons,
-				 const char *op,
-				 void *aux)
+static int call_sbin_request_key(struct key_construction *cons)
 {
 	static char const request_key[] = "/sbin/request-key";
-	const struct cred *cred = current_cred();
+	const struct cred *cred = cons->cred;
 	key_serial_t prkey, sskey;
 	struct key *key = cons->key, *authkey = cons->authkey, *keyring,
 		*session;
@@ -105,7 +105,7 @@ static int call_sbin_request_key(struct key_construction *cons,
 	char desc[20];
 	int ret, i;
 
-	kenter("{%d},{%d},%s", key->serial, authkey->serial, op);
+	kenter("{%d},{%d},%s", key->serial, authkey->serial, cons->operation);
 
 	ret = install_user_keyrings();
 	if (ret < 0)
@@ -163,7 +163,7 @@ static int call_sbin_request_key(struct key_construction *cons,
 	/* set up the argument list */
 	i = 0;
 	argv[i++] = (char *)request_key;
-	argv[i++] = (char *) op;
+	argv[i++] = cons->operation;
 	argv[i++] = key_str;
 	argv[i++] = uid_str;
 	argv[i++] = gid_str;
@@ -206,7 +206,6 @@ static int construct_key(struct key *key, const void *callout_info,
 			 struct key *dest_keyring)
 {
 	struct key_construction *cons;
-	request_key_actor_t actor;
 	struct key *authkey;
 	int ret;
 
@@ -216,6 +215,8 @@ static int construct_key(struct key *key, const void *callout_info,
 	if (!cons)
 		return -ENOMEM;
 
+	strcpy(cons->operation, "create");
+
 	/* allocate an authorisation key */
 	authkey = request_key_auth_new(key, callout_info, callout_len,
 				       dest_keyring);
@@ -224,15 +225,18 @@ static int construct_key(struct key *key, const void *callout_info,
 		ret = PTR_ERR(authkey);
 		authkey = NULL;
 	} else {
+		cons->cred = get_current_cred();
 		cons->authkey = key_get(authkey);
 		cons->key = key_get(key);
 
 		/* make the call */
-		actor = call_sbin_request_key;
-		if (key->type->request_key)
-			actor = key->type->request_key;
-
-		ret = actor(cons, "create", aux);
+		if (key->type->request_key) {
+			ret = key->type->request_key(cons, aux);
+		} else {
+			ret = 0;
+			if (!queue_request_key(cons))
+				ret = call_sbin_request_key(cons);
+		}
 
 		/* check that the actor called complete_request_key() prior to
 		 * returning an error */
diff --git a/security/keys/request_key_auth.c b/security/keys/request_key_auth.c
index 0f062156dfb2..c68dd02f5eec 100644
--- a/security/keys/request_key_auth.c
+++ b/security/keys/request_key_auth.c
@@ -134,6 +134,9 @@ static void request_key_auth_destroy(struct key *key)
 		rka->cred = NULL;
 	}
 
+	if (!test_bit(KEY_FLAG_INSTANTIATED, &rka->target_key->flags))
+		key_reject_and_link(rka->target_key, 0, -ENOKEY, NULL, NULL);
+	
 	key_put(rka->target_key);
 	key_put(rka->dest_keyring);
 	kfree(rka->callout_info);
diff --git a/security/keys/service.c b/security/keys/service.c
new file mode 100644
index 000000000000..bfa3cff2f4d6
--- /dev/null
+++ b/security/keys/service.c
@@ -0,0 +1,633 @@
+/* Service daemon interface
+ *
+ * Copyright (C) 2017 Red Hat, Inc. All Rights Reserved.
+ * Written by David Howells (dhowells@redhat.com)
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public Licence
+ * as published by the Free Software Foundation; either version
+ * 2 of the Licence, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/key.h>
+#include <linux/key-type.h>
+#include <linux/utsname.h>
+#include <linux/ipc_namespace.h>
+#include <linux/mnt_namespace.h>
+#include <linux/pid_namespace.h>
+#include <linux/cgroup.h>
+#include <linux/sched/signal.h>
+#include <linux/poll.h>
+#include <linux/mount.h>
+#include <linux/file.h>
+#include <linux/magic.h>
+#include <net/net_namespace.h>
+#include "internal.h"
+
+/*
+ * Request service filter record.
+ */
+struct request_key_service {
+	struct hlist_node	user_ns_link;	/* Link in the user_ns service list */
+	struct hlist_node	file_link;	/* Link in queue->services */
+	struct request_key_file	*queue;
+
+	/* The following fields define the selection criteria that we select
+	 * this record on.  All these references must be pinned just in case
+	 * the fd gets passed to another process or the owning process changes
+	 * its own namespaces.
+	 *
+	 * Most of the criteria can be NULL if that criterion is irrelevant to
+	 * the filter.
+	 */
+	char			type[24];	/* Key type of interest (or "") */
+	struct uts_namespace	*uts_ns;	/* Matching UTS namespace (or NULL) */
+	struct ipc_namespace	*ipc_ns;	/* Matching IPC namespace (or NULL) */
+	struct mnt_namespace	*mnt_ns;	/* Matching mount namespace (or NULL) */
+	struct pid_namespace	*pid_ns;	/* Matching process namespace (or NULL) */
+	struct net		*net_ns;	/* Matching network namespace (or NULL) */
+	struct cgroup_namespace *cgroup_ns;	/* Matching cgroup namespace (or NULL) */
+	u8			selectivity;	/* Number of exact-match fields */
+};
+
+/*
+ * File private data for request_key service fd.
+ */
+struct request_key_file {
+	struct user_namespace	*user_ns;	/* Owning user namespace */
+	struct hlist_head	services;	/* The services offered on this fd */
+	struct list_head	requests;	/* Request queue */
+	spinlock_t		requests_lock;	/* Lock for requests */
+	wait_queue_head_t	waitq;		/* Daemon wait queue */
+};
+
+static struct vfsmount *key_servicefs_mnt __read_mostly;
+
+/*
+ * Allow the user to read the next request.
+ */
+static ssize_t key_servicefs_read(struct file *file, char __user *buffer, size_t len,
+				  loff_t *ppos)
+{
+	struct request_key_file *kf = file->private_data;
+	struct key_construction *cons = NULL;
+	struct key *session;
+	key_serial_t sskey;
+	ssize_t size, osize, ret;
+	char str[1 + 9 + 9 + 9 + 9 + 9 + 9 + 1];
+
+	if (!current_cred()->thread_keyring) {
+		ret = install_thread_keyring();
+		if (ret < 0)
+			return ret;
+	}
+
+again:
+	if (list_empty(&kf->requests)) {
+		DEFINE_WAIT(wait);
+
+		if (hlist_empty(&kf->user_ns->request_key_services))
+			return -ENODATA;
+
+		if (file->f_flags & O_NONBLOCK)
+			return -EWOULDBLOCK;
+
+		ret = 0;
+		prepare_to_wait_exclusive(&kf->waitq, &wait, TASK_INTERRUPTIBLE);
+		if (list_empty(&kf->requests)) {
+			if (signal_pending(current))
+				ret = -ERESTARTSYS;
+			else
+				schedule();
+		}
+		finish_wait(&kf->waitq, &wait);
+		if (ret < 0)
+			return ret;
+	}
+
+	/* Dequeue the first request on the queue. */
+	spin_lock(&kf->requests_lock);
+	if (!list_empty(&kf->requests)) {
+		cons = list_entry(kf->requests.next,
+				  struct key_construction, link);
+		list_del_init(&cons->link);
+	}
+	spin_unlock(&kf->requests_lock);
+	if (!cons) {
+		if (signal_pending(current))
+			return -ERESTARTSYS;
+		goto again;
+	}
+
+	/* We need to information to userspace *before* we try to transfer the
+	 * authorisation key as we don't want to have to try retrieving the
+	 * auth key if we fail to copy the info.
+	 */
+	rcu_read_lock();
+	session = rcu_dereference(cons->cred->session_keyring);
+	if (!session)
+		session = cons->cred->user->session_keyring;
+	sskey = key_serial(session);
+	rcu_read_unlock();
+	size = sprintf(str, " %x %x %x %x %x %x",
+		       cons->key->serial,
+		       from_kuid(kf->user_ns, cons->cred->fsuid),
+		       from_kgid(kf->user_ns, cons->cred->fsgid),
+		       key_serial(cons->cred->thread_keyring),
+		       key_serial(cons->cred->process_keyring),
+		       sskey);
+
+	ret = -EMSGSIZE;
+	osize = strlen(cons->operation);
+	if (osize + size > len)
+		goto error;
+
+	ret = -EFAULT;
+	if (copy_to_user(buffer, cons->operation, osize) != 0 ||
+	    copy_to_user(buffer + osize, str, size) != 0)
+		goto error;
+	size += osize;
+
+	/* Now we transfer the key to the caller's thread keyring.  It's
+	 * probably worth making the keyring selectable, but it would need to
+	 * be done on a per-thread basis lest a multithreaded daemon be
+	 * listening on this fd.
+	 */
+	ret = key_link(current_cred()->thread_keyring, cons->authkey);
+	if (ret < 0)
+		goto error;
+
+	key_put(cons->key);
+	key_put(cons->authkey);
+	put_cred(cons->cred);
+	kfree(cons);
+
+	return size;
+
+error:
+	spin_lock(&kf->requests_lock);
+	list_add(&cons->link, &kf->requests);
+	spin_unlock(&kf->requests_lock);
+	wake_up(&kf->waitq);
+	return ret;
+}
+
+/*
+ * Allow the user to poll for requests.
+ */
+static unsigned int key_servicefs_poll(struct file *file, poll_table *wait)
+{
+	struct request_key_file *kf = file->private_data;
+	unsigned int mask = 0;
+
+	poll_wait(file, &kf->waitq, wait);
+
+	if (!list_empty(&kf->requests))
+		mask |= POLLIN | POLLRDNORM;
+
+	return mask;
+}
+
+/*
+ * Free a request_key service record
+ */
+static void free_key_service(struct request_key_service *svc)
+{
+	if (svc->uts_ns)
+		put_uts_ns(svc->uts_ns);
+	if (svc->ipc_ns)
+		put_ipc_ns(svc->ipc_ns);
+	if (svc->mnt_ns)
+		put_mnt_ns(svc->mnt_ns);
+	if (svc->pid_ns)
+		put_pid_ns(svc->pid_ns);
+	if (svc->net_ns)
+		put_net(svc->net_ns);
+	if (svc->cgroup_ns)
+		put_cgroup_ns(svc->cgroup_ns);
+	kfree(svc);
+}
+
+/*
+ * Clean up the request service record
+ */
+static int key_servicefs_release(struct inode *inode, struct file *file)
+{
+	struct request_key_service *svc;
+	struct request_key_file *kf = file->private_data;
+	struct key_construction *cons;
+
+	spin_lock(&kf->user_ns->request_key_services_lock);
+
+	hlist_for_each_entry(svc, &kf->services, file_link) {
+		hlist_del_rcu(&svc->user_ns_link);
+	}
+
+	spin_unlock(&kf->user_ns->request_key_services_lock);
+
+	/* Make sure no one else is adding to the list. */
+	synchronize_rcu();
+
+	while (!hlist_empty(&kf->services)) {
+		svc = hlist_entry(kf->services.first,
+				  struct request_key_service, file_link);
+		hlist_del(&svc->file_link);
+		free_key_service(svc);
+	}
+
+	/* We need to terminate all the requests that are waiting for us. */
+	while (!list_empty(&kf->requests)) {
+		cons = list_entry(kf->requests.next,
+				  struct key_construction, link);
+		list_del_init(&cons->link);
+		complete_request_key(cons, -ENOKEY);
+	}
+
+	put_user_ns(kf->user_ns);
+	BUG_ON(!list_empty(&kf->requests));
+	BUG_ON(waitqueue_active(&kf->waitq));
+	kfree(kf);
+	return 0;
+}
+
+const struct file_operations key_servicefs_fops = {
+	.read		= key_servicefs_read,
+	.poll		= key_servicefs_poll,
+	.release	= key_servicefs_release,
+};
+
+/*
+ * Indicate the name we want to display the container file as.
+ */
+static char *key_servicefs_dname(struct dentry *dentry, char *buffer, int buflen)
+{
+	return dynamic_dname(dentry, buffer, buflen, "key_service:[%lu]",
+			     d_inode(dentry)->i_ino);
+}
+
+static const struct dentry_operations key_servicefs_dentry_operations = {
+	.d_dname	= key_servicefs_dname,
+};
+
+/*
+ * Create an access file for polling and reading.
+ */
+static struct file *create_key_service_file(void)
+{
+	struct request_key_file *kf;
+	struct inode *inode;
+	struct file *f;
+	struct path path;
+	int ret;
+
+	kf = kmalloc(sizeof(*kf), GFP_KERNEL);
+	if (!kf)
+		return ERR_PTR(-ENOMEM);
+	INIT_HLIST_HEAD(&kf->services);
+	INIT_LIST_HEAD(&kf->requests);
+	spin_lock_init(&kf->requests_lock);
+	init_waitqueue_head(&kf->waitq);
+
+	inode = alloc_anon_inode(key_servicefs_mnt->mnt_sb);
+	if (IS_ERR(inode)) {
+		ret = PTR_ERR(inode);
+		goto err_kf;
+	}
+	inode->i_fop = &key_servicefs_fops;
+
+	ret = -ENOMEM;
+	path.dentry = d_alloc_pseudo(key_servicefs_mnt->mnt_sb, &empty_name);
+	if (!path.dentry)
+		goto err_inode;
+	path.mnt = mntget(key_servicefs_mnt);
+
+	d_instantiate(path.dentry, inode);
+
+	f = alloc_file(&path, FMODE_READ, &key_servicefs_fops);
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err_file;
+	}
+
+	kf->user_ns = get_user_ns(current_user_ns());
+	f->private_data = kf;
+	return f;
+
+err_file:
+	path_put(&path);
+	goto err_kf;
+
+err_inode:
+	iput(inode);
+err_kf:
+	kfree(kf);
+	return ERR_PTR(ret);
+}
+
+static const struct super_operations key_servicefs_ops = {
+	.drop_inode	= generic_delete_inode,
+	.destroy_inode	= free_inode_nonrcu,
+	.statfs		= simple_statfs,
+};
+
+/*
+ * key_servicefs should _never_ be mounted by userland - too much of security
+ * hassle, no real gain from having the whole whorehouse mounted.  So we don't
+ * need any operations on the root directory.  However, we need a non-trivial
+ * d_name - container: will go nicely and kill the special-casing in procfs.
+ */
+static struct dentry *key_servicefs_mount(struct file_system_type *fs_type,
+					int flags, const char *dev_name,
+					void *data)
+{
+	return mount_pseudo(fs_type, "key_service:", &key_servicefs_ops,
+			    &key_servicefs_dentry_operations,
+			    KEY_SERVICEFS_MAGIC);
+}
+
+static struct file_system_type key_servicefs_type = {
+	.name		= "key_servicefs",
+	.mount		= key_servicefs_mount,
+	.kill_sb	= kill_anon_super,
+};
+
+static int __init init_key_servicefs(void)
+{
+	int ret;
+
+	ret = register_filesystem(&key_servicefs_type);
+	if (ret < 0)
+		panic("Cannot register key_servicefs\n");
+
+	key_servicefs_mnt = kern_mount(&key_servicefs_type);
+	if (IS_ERR(key_servicefs_mnt))
+		panic("Cannot mount key_servicefs: %ld\n",
+		      PTR_ERR(key_servicefs_mnt));
+	return 0;
+}
+
+fs_initcall(init_key_servicefs);
+
+/*
+ * Create a service handler fd that we can add filters to and retrieve incoming
+ * requests through.
+ */
+long keyctl_service_create(unsigned int flags)
+{
+	unsigned long fd_flags = 0;
+	struct file *f;
+	int fd, ret;
+
+	if (flags & ~(KEY_SERVICE_FD_CLOEXEC | KEY_SERVICE_FD_NONBLOCK))
+		return -EINVAL;
+
+	f = create_key_service_file();
+	if (IS_ERR(f)) {
+		ret = PTR_ERR(f);
+		goto err;
+	}
+
+	if (flags & KEY_SERVICE_FD_CLOEXEC)
+		fd_flags |= O_CLOEXEC;
+	if (flags & KEY_SERVICE_FD_NONBLOCK)
+		f->f_flags |= O_NONBLOCK;
+
+	fd = get_unused_fd_flags(fd_flags);
+	if (fd < 0) {
+		ret = fd;
+		goto err_file;
+	}
+
+	fd_install(fd, f);
+	return fd;
+
+err_file:
+	fput(f);
+err:
+	return ret;
+}
+
+/*
+ * Allocate a service record.
+ */
+static struct request_key_service *alloc_key_service(const char __user *type_name,
+						     unsigned int ns_mask)
+{
+	struct request_key_service *svc;
+	struct key_type *type;
+	int ret;
+	u8 selectivity = 0;
+
+	svc = kzalloc(sizeof(struct request_key_service), GFP_KERNEL);
+	if (!svc)
+		return ERR_PTR(-ENOMEM);
+
+	/* Save the matching criteria.  Anything the caller doesn't care about
+	 * we leave as NULL.
+	 */
+	if (type_name) {
+		ret = strncpy_from_user(svc->type, type_name, sizeof(svc->type));
+		if (ret < 0)
+			goto err_svc;
+		if (ret >= sizeof(svc->type)) {
+			ret = -EINVAL;
+			goto err_svc;
+		}
+
+		type = key_type_lookup(type_name);
+		if (IS_ERR(type)) {
+			ret = -EINVAL;
+			goto err_svc;
+		}
+		memcpy(svc->type, type->name, sizeof(svc->type));
+		key_type_put(type);
+	}
+
+	if (ns_mask & KEY_SERVICE_NS_UTS) {
+		svc->uts_ns = get_uts_ns(current->nsproxy->uts_ns);
+		selectivity++;
+	}
+	if (ns_mask & KEY_SERVICE_NS_IPC) {
+		svc->ipc_ns = get_ipc_ns(current->nsproxy->ipc_ns);
+		selectivity++;
+	}
+	if (ns_mask & KEY_SERVICE_NS_MNT) {
+		svc->mnt_ns = get_mnt_ns(current->nsproxy->mnt_ns);
+		selectivity++;
+	}
+	if (ns_mask & KEY_SERVICE_NS_PID) {
+		svc->pid_ns = get_pid_ns(task_active_pid_ns(current));
+		selectivity++;
+	}
+	if (ns_mask & KEY_SERVICE_NS_NET) {
+		svc->net_ns = get_net(current->nsproxy->net_ns);
+		selectivity++;
+	}
+	if (ns_mask & KEY_SERVICE_NS_CGROUP) {
+		svc->cgroup_ns = get_cgroup_ns(current->nsproxy->cgroup_ns);
+		selectivity++;
+	}
+
+	svc->selectivity = selectivity;
+	return svc;
+
+err_svc:
+	kfree(svc);
+	return ERR_PTR(ret);
+}
+
+/*
+ * Install a request_key service into the list
+ */
+static int install_key_service(struct request_key_file *kf,
+			       struct request_key_service *svc)
+{
+	struct user_namespace *user_ns = kf->user_ns;
+	struct request_key_service *s;
+	struct hlist_node **pp;
+	int ret;
+
+	svc->queue = kf;
+
+	spin_lock(&user_ns->request_key_services_lock);
+
+	/* The services list is kept in order of selectivity.  The more exact
+	 * matches a service requires, the earlier it is in the list.
+	 */
+	for (pp = &user_ns->request_key_services.first; *pp; pp = &(*pp)->next) {
+		s = hlist_entry(*pp, struct request_key_service, user_ns_link);
+		if (s->selectivity < svc->selectivity)
+			goto insert_before;
+		if (s->selectivity > svc->selectivity)
+			continue;
+		if (memcmp(s->type, svc->type, sizeof(s->type)) == 0 &&
+		    s->uts_ns == svc->uts_ns &&
+		    s->ipc_ns == svc->ipc_ns &&
+		    s->mnt_ns == svc->mnt_ns &&
+		    s->pid_ns == svc->pid_ns &&
+		    s->net_ns == svc->net_ns &&
+		    s->cgroup_ns == svc->cgroup_ns)
+			goto duplicate;
+	}
+
+	svc->user_ns_link.pprev = pp;
+	rcu_assign_pointer(*pp, &svc->user_ns_link);
+	goto add_to_kf;
+
+insert_before:
+	hlist_add_before_rcu(&svc->user_ns_link, &s->user_ns_link);
+add_to_kf:
+	hlist_add_head(&svc->file_link, &kf->services);
+	ret = 0;
+	goto out;
+
+duplicate:
+	ret = -EBUSY;
+out:
+	spin_unlock(&user_ns->request_key_services_lock);
+	return ret;
+}
+
+/*
+ * Add a request_key service handler for a subset of the calling process's
+ * particular set of namespaces.
+ */
+long keyctl_service_add(int service_fd,
+			const char __user *type_name,
+			unsigned int ns_mask)
+{
+	struct request_key_service *svc;
+	struct request_key_file *kf;
+	struct fd fd;
+	int ret;
+
+	if (ns_mask & ~KEY_SERVICE___ALL_NS)
+		return -EINVAL;
+
+	fd = fdget(service_fd);
+	if (!fd.file)
+		return -EBADF;
+	ret = -EINVAL;
+	if (fd.file->f_op != &key_servicefs_fops)
+		goto err_file;
+
+	kf = fd.file->private_data;
+
+	/* Require the caller to be the owner of the user namespace in which
+	 * the fd was created if they're not the sysadmin.  Possibly we should
+	 * be more strict about what namespaces one can select, but it's not
+	 * clear how best to do that.
+	 */
+	ret = -EPERM;
+	if (!capable(CAP_SYS_ADMIN) &&
+	    !uid_eq(kf->user_ns->owner, current_cred()->euid))
+		goto err_file;
+
+	svc = alloc_key_service(type_name, ns_mask);
+	if (IS_ERR(svc)) {
+		ret = PTR_ERR(svc);
+		goto err_file;
+	}
+
+	ret = install_key_service(kf, svc);
+	if (ret < 0)
+		goto err_svc;
+
+	fdput(fd);
+	return 0;
+
+err_svc:
+	free_key_service(svc);
+err_file:
+	fdput(fd);
+	return ret;
+}
+
+/*
+ * Queue a construction record if we can find a handler.
+ *
+ * Returns true if we found a handler - in which case ownership of the
+ * construction record has been passed on to the service queue and the caller
+ * can no longer touch it.
+ */
+bool queue_request_key(struct key_construction *cons)
+{
+	struct request_key_service *svc;
+	struct request_key_file *kf;
+	struct user_namespace *user_ns = current_user_ns();
+	struct pid_namespace *pid_ns = task_active_pid_ns(current);
+	struct nsproxy *nsproxy = current->nsproxy;
+
+	if (hlist_empty(&user_ns->request_key_services))
+		return false;
+
+	rcu_read_lock();
+
+	hlist_for_each_entry_rcu(svc, &user_ns->request_key_services, user_ns_link) {
+		if (svc->type[0] &&
+		    memcmp(svc->type, cons->key->type->name, sizeof(svc->type)) != 0)
+			continue;
+		if ((svc->uts_ns && svc->uts_ns != nsproxy->uts_ns) ||
+		    (svc->ipc_ns && svc->ipc_ns != nsproxy->ipc_ns) ||
+		    (svc->mnt_ns && svc->mnt_ns != nsproxy->mnt_ns) ||
+		    (svc->pid_ns && svc->pid_ns != pid_ns) ||
+		    (svc->net_ns && svc->net_ns != nsproxy->net_ns) ||
+		    (svc->cgroup_ns && svc->cgroup_ns != nsproxy->cgroup_ns))
+			continue;
+		goto found_match;
+	}
+
+	rcu_read_unlock();
+	return false;
+
+found_match:
+	kf = svc->queue;
+	spin_lock(&kf->requests_lock);
+	list_add_tail(&cons->link, &kf->requests);
+	spin_unlock(&kf->requests_lock);
+	wake_up(&kf->waitq);
+
+	rcu_read_unlock();
+	return true;
+}

