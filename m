Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16166 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752873Ab2BXTPW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 24 Feb 2012 14:15:22 -0500
From: bjschuma@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, dhowells@redhat.com,
        Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH 2/2 v3] NFS: Store the legacy idmapper result in the keyring
Date: Fri, 24 Feb 2012 14:14:51 -0500
Message-Id: <1330110891-4273-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1330110891-4273-1-git-send-email-bjschuma@netapp.com>
References: <1330110891-4273-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

This patch removes the old hashmap-based caching and instead uses a
"request key actor" to place an upcall to the legacy idmapper rather
than going through /sbin/request-key.  This will only be used as a
fallback if /etc/request-key.conf isn't configured to use nfsidmap.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
v3: Allocate idmap messages as new memory, rather than storing a pointer to an
    address on the stack that goes out of scope before it is used.

 fs/nfs/idmap.c            |  555 ++++++++++++++-------------------------------
 include/linux/nfs_idmap.h |   11 -
 2 files changed, 166 insertions(+), 400 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index b5c6d8e..6c468d1 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -34,42 +34,27 @@
  *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
  */
 #include <linux/types.h>
-#include <linux/string.h>
-#include <linux/kernel.h>
-#include <linux/slab.h>
+#include <linux/parser.h>
+#include <linux/fs.h>
 #include <linux/nfs_idmap.h>
+#include <net/net_namespace.h>
+#include <linux/sunrpc/rpc_pipe_fs.h>
 #include <linux/nfs_fs.h>
-#include <linux/cred.h>
-#include <linux/sunrpc/sched.h>
-#include <linux/nfs4.h>
 #include <linux/nfs_fs_sb.h>
+#include <linux/key.h>
 #include <linux/keyctl.h>
 #include <linux/key-type.h>
-#include <linux/rcupdate.h>
-#include <linux/err.h>
 #include <keys/user-type.h>
-
-/* include files needed by legacy idmapper */
 #include <linux/module.h>
-#include <linux/mutex.h>
-#include <linux/init.h>
-#include <linux/socket.h>
-#include <linux/in.h>
-#include <linux/sched.h>
-#include <linux/sunrpc/clnt.h>
-#include <linux/workqueue.h>
-#include <linux/sunrpc/rpc_pipe_fs.h>
-#include <linux/nfs_fs.h>
-#include "nfs4_fs.h"
-#include "internal.h"
+
 #include "netns.h"
 
 #define NFS_UINT_MAXLEN 11
-#define IDMAP_HASH_SZ          128
 
 /* Default cache timeout is 10 minutes */
-unsigned int nfs_idmap_cache_timeout = 600 * HZ;
+unsigned int nfs_idmap_cache_timeout = 600;
 const struct cred *id_resolver_cache;
+struct key_type key_type_id_resolver_legacy;
 
 
 /**
@@ -261,8 +246,10 @@ static ssize_t nfs_idmap_get_desc(const char *name, size_t namelen,
 	return desclen;
 }
 
-static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
-		const char *type, void *data, size_t data_size)
+static ssize_t nfs_idmap_request_key(struct key_type *key_type,
+				     const char *name, size_t namelen,
+				     const char *type, void *data,
+				     size_t data_size, struct idmap *idmap)
 {
 	const struct cred *saved_cred;
 	struct key *rkey;
@@ -275,8 +262,12 @@ static ssize_t nfs_idmap_request_key(const char *name, size_t namelen,
 		goto out;
 
 	saved_cred = override_creds(id_resolver_cache);
-	rkey = request_key(&key_type_id_resolver, desc, "");
+	if (idmap)
+		rkey = request_key_with_auxdata(key_type, desc, "", 0, idmap);
+	else
+		rkey = request_key(&key_type_id_resolver, desc, "");
 	revert_creds(saved_cred);
+
 	kfree(desc);
 	if (IS_ERR(rkey)) {
 		ret = PTR_ERR(rkey);
@@ -309,31 +300,46 @@ out:
 	return ret;
 }
 
+static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
+				 const char *type, void *data,
+				 size_t data_size, struct idmap *idmap)
+{
+	ssize_t ret = nfs_idmap_request_key(&key_type_id_resolver,
+					    name, namelen, type, data,
+					    data_size, NULL);
+	if (ret < 0) {
+		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
+					    name, namelen, type, data,
+					    data_size, idmap);
+	}
+	return ret;
+}
 
 /* ID -> Name */
-static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf, size_t buflen)
+static ssize_t nfs_idmap_lookup_name(__u32 id, const char *type, char *buf,
+				     size_t buflen, struct idmap *idmap)
 {
 	char id_str[NFS_UINT_MAXLEN];
 	int id_len;
 	ssize_t ret;
 
 	id_len = snprintf(id_str, sizeof(id_str), "%u", id);
-	ret = nfs_idmap_request_key(id_str, id_len, type, buf, buflen);
+	ret = nfs_idmap_get_key(id_str, id_len, type, buf, buflen, idmap);
 	if (ret < 0)
 		return -EINVAL;
 	return ret;
 }
 
 /* Name -> ID */
-static int nfs_idmap_lookup_id(const char *name, size_t namelen,
-				const char *type, __u32 *id)
+static int nfs_idmap_lookup_id(const char *name, size_t namelen, const char *type,
+			       __u32 *id, struct idmap *idmap)
 {
 	char id_str[NFS_UINT_MAXLEN];
 	long id_long;
 	ssize_t data_size;
 	int ret = 0;
 
-	data_size = nfs_idmap_request_key(name, namelen, type, id_str, NFS_UINT_MAXLEN);
+	data_size = nfs_idmap_get_key(name, namelen, type, id_str, NFS_UINT_MAXLEN, idmap);
 	if (data_size <= 0) {
 		ret = -EINVAL;
 	} else {
@@ -344,54 +350,47 @@ static int nfs_idmap_lookup_id(const char *name, size_t namelen,
 }
 
 /* idmap classic begins here */
-static int param_set_idmap_timeout(const char *val, struct kernel_param *kp)
-{
-	char *endp;
-	int num = simple_strtol(val, &endp, 0);
-	int jif = num * HZ;
-	if (endp == val || *endp || num < 0 || jif < num)
-		return -EINVAL;
-	*((int *)kp->arg) = jif;
-	return 0;
-}
-
-module_param_call(idmap_cache_timeout, param_set_idmap_timeout, param_get_int,
-		 &nfs_idmap_cache_timeout, 0644);
+module_param(nfs_idmap_cache_timeout, int, 0644);
 
-struct idmap_hashent {
-	unsigned long		ih_expires;
-	__u32			ih_id;
-	size_t			ih_namelen;
-	const char		*ih_name;
+struct idmap {
+	struct rpc_pipe		*idmap_pipe;
+	struct key_construction	*idmap_key_cons;
 };
 
-struct idmap_hashtable {
-	__u8			h_type;
-	struct idmap_hashent	*h_entries;
+enum {
+	Opt_find_uid, Opt_find_gid, Opt_find_user, Opt_find_group, Opt_find_err
 };
 
-struct idmap {
-	struct rpc_pipe		*idmap_pipe;
-	wait_queue_head_t	idmap_wq;
-	struct idmap_msg	idmap_im;
-	struct mutex		idmap_lock;	/* Serializes upcalls */
-	struct mutex		idmap_im_lock;	/* Protects the hashtable */
-	struct idmap_hashtable	idmap_user_hash;
-	struct idmap_hashtable	idmap_group_hash;
+static const match_table_t nfs_idmap_tokens = {
+	{ Opt_find_uid, "uid:%s" },
+	{ Opt_find_gid, "gid:%s" },
+	{ Opt_find_user, "user:%s" },
+	{ Opt_find_group, "group:%s" },
+	{ Opt_find_err, NULL }
 };
 
+static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
 
-static unsigned int fnvhash32(const void *, size_t);
-
 static const struct rpc_pipe_ops idmap_upcall_ops = {
 	.upcall		= rpc_pipe_generic_upcall,
 	.downcall	= idmap_pipe_downcall,
 	.destroy_msg	= idmap_pipe_destroy_msg,
 };
 
+struct key_type key_type_id_resolver_legacy = {
+	.name		= "id_resolver",
+	.instantiate	= user_instantiate,
+	.match		= user_match,
+	.revoke		= user_revoke,
+	.destroy	= user_destroy,
+	.describe	= user_describe,
+	.read		= user_read,
+	.request_key	= nfs_idmap_legacy_upcall,
+};
+
 static void __nfs_idmap_unregister(struct rpc_pipe *pipe)
 {
 	if (pipe->dentry)
@@ -468,38 +467,11 @@ nfs_idmap_new(struct nfs_client *clp)
 		return error;
 	}
 	idmap->idmap_pipe = pipe;
-	mutex_init(&idmap->idmap_lock);
-	mutex_init(&idmap->idmap_im_lock);
-	init_waitqueue_head(&idmap->idmap_wq);
-	idmap->idmap_user_hash.h_type = IDMAP_TYPE_USER;
-	idmap->idmap_group_hash.h_type = IDMAP_TYPE_GROUP;
 
 	clp->cl_idmap = idmap;
 	return 0;
 }
 
-static void
-idmap_alloc_hashtable(struct idmap_hashtable *h)
-{
-	if (h->h_entries != NULL)
-		return;
-	h->h_entries = kcalloc(IDMAP_HASH_SZ,
-			sizeof(*h->h_entries),
-			GFP_KERNEL);
-}
-
-static void
-idmap_free_hashtable(struct idmap_hashtable *h)
-{
-	int i;
-
-	if (h->h_entries == NULL)
-		return;
-	for (i = 0; i < IDMAP_HASH_SZ; i++)
-		kfree(h->h_entries[i].ih_name);
-	kfree(h->h_entries);
-}
-
 void
 nfs_idmap_delete(struct nfs_client *clp)
 {
@@ -510,8 +482,6 @@ nfs_idmap_delete(struct nfs_client *clp)
 	nfs_idmap_unregister(clp, idmap->idmap_pipe);
 	rpc_destroy_pipe_data(idmap->idmap_pipe);
 	clp->cl_idmap = NULL;
-	idmap_free_hashtable(&idmap->idmap_user_hash);
-	idmap_free_hashtable(&idmap->idmap_group_hash);
 	kfree(idmap);
 }
 
@@ -599,222 +569,107 @@ void nfs_idmap_quit(void)
 	nfs_idmap_quit_keyring();
 }
 
-/*
- * Helper routines for manipulating the hashtable
- */
-static inline struct idmap_hashent *
-idmap_name_hash(struct idmap_hashtable* h, const char *name, size_t len)
-{
-	if (h->h_entries == NULL)
-		return NULL;
-	return &h->h_entries[fnvhash32(name, len) % IDMAP_HASH_SZ];
-}
-
-static struct idmap_hashent *
-idmap_lookup_name(struct idmap_hashtable *h, const char *name, size_t len)
+static int nfs_idmap_prepare_message(char *desc, struct idmap_msg *im,
+				     struct rpc_pipe_msg *msg)
 {
-	struct idmap_hashent *he = idmap_name_hash(h, name, len);
+	substring_t substr;
+	int token, ret;
 
-	if (he == NULL)
-		return NULL;
-	if (he->ih_namelen != len || memcmp(he->ih_name, name, len) != 0)
-		return NULL;
-	if (time_after(jiffies, he->ih_expires))
-		return NULL;
-	return he;
-}
+	memset(im,  0, sizeof(*im));
+	memset(msg, 0, sizeof(*msg));
 
-static inline struct idmap_hashent *
-idmap_id_hash(struct idmap_hashtable* h, __u32 id)
-{
-	if (h->h_entries == NULL)
-		return NULL;
-	return &h->h_entries[fnvhash32(&id, sizeof(id)) % IDMAP_HASH_SZ];
-}
+	im->im_type = IDMAP_TYPE_GROUP;
+	token = match_token(desc, nfs_idmap_tokens, &substr);
 
-static struct idmap_hashent *
-idmap_lookup_id(struct idmap_hashtable *h, __u32 id)
-{
-	struct idmap_hashent *he = idmap_id_hash(h, id);
+	switch (token) {
+	case Opt_find_uid:
+		im->im_type = IDMAP_TYPE_USER;
+	case Opt_find_gid:
+		im->im_conv = IDMAP_CONV_NAMETOID;
+		ret = match_strlcpy(im->im_name, &substr, IDMAP_NAMESZ);
+		break;
 
-	if (he == NULL)
-		return NULL;
-	if (he->ih_id != id || he->ih_namelen == 0)
-		return NULL;
-	if (time_after(jiffies, he->ih_expires))
-		return NULL;
-	return he;
-}
+	case Opt_find_user:
+		im->im_type = IDMAP_TYPE_USER;
+	case Opt_find_group:
+		im->im_conv = IDMAP_CONV_IDTONAME;
+		ret = match_int(&substr, &im->im_id);
+		break;
 
-/*
- * Routines for allocating new entries in the hashtable.
- * For now, we just have 1 entry per bucket, so it's all
- * pretty trivial.
- */
-static inline struct idmap_hashent *
-idmap_alloc_name(struct idmap_hashtable *h, char *name, size_t len)
-{
-	idmap_alloc_hashtable(h);
-	return idmap_name_hash(h, name, len);
-}
+	default:
+		ret = -EINVAL;
+		goto out;
+	}
 
-static inline struct idmap_hashent *
-idmap_alloc_id(struct idmap_hashtable *h, __u32 id)
-{
-	idmap_alloc_hashtable(h);
-	return idmap_id_hash(h, id);
-}
+	msg->data = im;
+	msg->len  = sizeof(struct idmap_msg);
 
-static void
-idmap_update_entry(struct idmap_hashent *he, const char *name,
-		size_t namelen, __u32 id)
-{
-	char *str = kmalloc(namelen + 1, GFP_KERNEL);
-	if (str == NULL)
-		return;
-	kfree(he->ih_name);
-	he->ih_id = id;
-	memcpy(str, name, namelen);
-	str[namelen] = '\0';
-	he->ih_name = str;
-	he->ih_namelen = namelen;
-	he->ih_expires = jiffies + nfs_idmap_cache_timeout;
+out:
+	return ret;
 }
 
-/*
- * Name -> ID
- */
-static int
-nfs_idmap_id(struct idmap *idmap, struct idmap_hashtable *h,
-		const char *name, size_t namelen, __u32 *id)
+static int nfs_idmap_legacy_upcall(struct key_construction *cons,
+				   const char *op,
+				   void *aux)
 {
-	struct rpc_pipe_msg msg;
+	struct rpc_pipe_msg *msg;
 	struct idmap_msg *im;
-	struct idmap_hashent *he;
-	DECLARE_WAITQUEUE(wq, current);
-	int ret = -EIO;
-
-	im = &idmap->idmap_im;
-
-	/*
-	 * String sanity checks
-	 * Note that the userland daemon expects NUL terminated strings
-	 */
-	for (;;) {
-		if (namelen == 0)
-			return -EINVAL;
-		if (name[namelen-1] != '\0')
-			break;
-		namelen--;
-	}
-	if (namelen >= IDMAP_NAMESZ)
-		return -EINVAL;
-
-	mutex_lock(&idmap->idmap_lock);
-	mutex_lock(&idmap->idmap_im_lock);
+	struct idmap *idmap = (struct idmap *)aux;
+	struct key *key = cons->key;
+	int ret;
 
-	he = idmap_lookup_name(h, name, namelen);
-	if (he != NULL) {
-		*id = he->ih_id;
-		ret = 0;
-		goto out;
+	/* msg and im are freed in idmap_pipe_destroy_msg */
+	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+	if (IS_ERR(msg)) {
+		ret = PTR_ERR(msg);
+		goto out0;
 	}
 
-	memset(im, 0, sizeof(*im));
-	memcpy(im->im_name, name, namelen);
-
-	im->im_type = h->h_type;
-	im->im_conv = IDMAP_CONV_NAMETOID;
-
-	memset(&msg, 0, sizeof(msg));
-	msg.data = im;
-	msg.len = sizeof(*im);
-
-	add_wait_queue(&idmap->idmap_wq, &wq);
-	if (rpc_queue_upcall(idmap->idmap_pipe, &msg) < 0) {
-		remove_wait_queue(&idmap->idmap_wq, &wq);
-		goto out;
+	im = kmalloc(sizeof(*im), GFP_KERNEL);
+	if (IS_ERR(im)) {
+		ret = PTR_ERR(im);
+		goto out1;
 	}
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	mutex_unlock(&idmap->idmap_im_lock);
-	schedule();
-	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&idmap->idmap_wq, &wq);
-	mutex_lock(&idmap->idmap_im_lock);
+	ret = nfs_idmap_prepare_message(key->description, im, msg);
+	if (ret < 0)
+		goto out2;
 
-	if (im->im_status & IDMAP_STATUS_SUCCESS) {
-		*id = im->im_id;
-		ret = 0;
-	}
+	idmap->idmap_key_cons = cons;
 
- out:
-	memset(im, 0, sizeof(*im));
-	mutex_unlock(&idmap->idmap_im_lock);
-	mutex_unlock(&idmap->idmap_lock);
+	return rpc_queue_upcall(idmap->idmap_pipe, msg);
+
+out2:
+	kfree(im);
+out1:
+	kfree(msg);
+out0:
+	complete_request_key(cons, ret);
 	return ret;
 }
 
-/*
- * ID -> Name
- */
-static int
-nfs_idmap_name(struct idmap *idmap, struct idmap_hashtable *h,
-		__u32 id, char *name)
+static int nfs_idmap_instantiate(struct key *key, struct key *authkey, char *data)
 {
-	struct rpc_pipe_msg msg;
-	struct idmap_msg *im;
-	struct idmap_hashent *he;
-	DECLARE_WAITQUEUE(wq, current);
-	int ret = -EIO;
-	unsigned int len;
-
-	im = &idmap->idmap_im;
-
-	mutex_lock(&idmap->idmap_lock);
-	mutex_lock(&idmap->idmap_im_lock);
-
-	he = idmap_lookup_id(h, id);
-	if (he) {
-		memcpy(name, he->ih_name, he->ih_namelen);
-		ret = he->ih_namelen;
-		goto out;
-	}
-
-	memset(im, 0, sizeof(*im));
-	im->im_type = h->h_type;
-	im->im_conv = IDMAP_CONV_IDTONAME;
-	im->im_id = id;
-
-	memset(&msg, 0, sizeof(msg));
-	msg.data = im;
-	msg.len = sizeof(*im);
-
-	add_wait_queue(&idmap->idmap_wq, &wq);
+	return key_instantiate_and_link(key, data, strlen(data) + 1,
+					id_resolver_cache->thread_keyring,
+					authkey);
+}
 
-	if (rpc_queue_upcall(idmap->idmap_pipe, &msg) < 0) {
-		remove_wait_queue(&idmap->idmap_wq, &wq);
-		goto out;
-	}
+static int nfs_idmap_read_message(struct idmap_msg *im, struct key *key, struct key *authkey)
+{
+	char id_str[NFS_UINT_MAXLEN];
+	int ret = -EINVAL;
 
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	mutex_unlock(&idmap->idmap_im_lock);
-	schedule();
-	__set_current_state(TASK_RUNNING);
-	remove_wait_queue(&idmap->idmap_wq, &wq);
-	mutex_lock(&idmap->idmap_im_lock);
-
-	if (im->im_status & IDMAP_STATUS_SUCCESS) {
-		if ((len = strnlen(im->im_name, IDMAP_NAMESZ)) == 0)
-			goto out;
-		memcpy(name, im->im_name, len);
-		ret = len;
+	switch (im->im_conv) {
+	case IDMAP_CONV_NAMETOID:
+		sprintf(id_str, "%d", im->im_id);
+		ret = nfs_idmap_instantiate(key, authkey, id_str);
+		break;
+	case IDMAP_CONV_IDTONAME:
+		ret = nfs_idmap_instantiate(key, authkey, im->im_name);
+		break;
 	}
 
- out:
-	memset(im, 0, sizeof(*im));
-	mutex_unlock(&idmap->idmap_im_lock);
-	mutex_unlock(&idmap->idmap_lock);
 	return ret;
 }
 
@@ -823,141 +678,69 @@ idmap_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
 {
 	struct rpc_inode *rpci = RPC_I(filp->f_path.dentry->d_inode);
 	struct idmap *idmap = (struct idmap *)rpci->private;
-	struct idmap_msg im_in, *im = &idmap->idmap_im;
-	struct idmap_hashtable *h;
-	struct idmap_hashent *he = NULL;
+	struct key_construction *cons = idmap->idmap_key_cons;
+	struct idmap_msg im;
 	size_t namelen_in;
 	int ret;
 
-	if (mlen != sizeof(im_in))
-		return -ENOSPC;
-
-	if (copy_from_user(&im_in, src, mlen) != 0)
-		return -EFAULT;
-
-	mutex_lock(&idmap->idmap_im_lock);
-
-	ret = mlen;
-	im->im_status = im_in.im_status;
-	/* If we got an error, terminate now, and wake up pending upcalls */
-	if (!(im_in.im_status & IDMAP_STATUS_SUCCESS)) {
-		wake_up(&idmap->idmap_wq);
+	if (mlen != sizeof(im)) {
+		ret = -ENOSPC;
 		goto out;
 	}
 
-	/* Sanity checking of strings */
-	ret = -EINVAL;
-	namelen_in = strnlen(im_in.im_name, IDMAP_NAMESZ);
-	if (namelen_in == 0 || namelen_in == IDMAP_NAMESZ)
+	if (copy_from_user(&im, src, mlen) != 0) {
+		ret = -EFAULT;
 		goto out;
+	}
 
-	switch (im_in.im_type) {
-		case IDMAP_TYPE_USER:
-			h = &idmap->idmap_user_hash;
-			break;
-		case IDMAP_TYPE_GROUP:
-			h = &idmap->idmap_group_hash;
-			break;
-		default:
-			goto out;
+	if (!(im.im_status & IDMAP_STATUS_SUCCESS)) {
+		ret = mlen;
+		complete_request_key(idmap->idmap_key_cons, -ENOKEY);
+		goto out_incomplete;
 	}
 
-	switch (im_in.im_conv) {
-	case IDMAP_CONV_IDTONAME:
-		/* Did we match the current upcall? */
-		if (im->im_conv == IDMAP_CONV_IDTONAME
-				&& im->im_type == im_in.im_type
-				&& im->im_id == im_in.im_id) {
-			/* Yes: copy string, including the terminating '\0'  */
-			memcpy(im->im_name, im_in.im_name, namelen_in);
-			im->im_name[namelen_in] = '\0';
-			wake_up(&idmap->idmap_wq);
-		}
-		he = idmap_alloc_id(h, im_in.im_id);
-		break;
-	case IDMAP_CONV_NAMETOID:
-		/* Did we match the current upcall? */
-		if (im->im_conv == IDMAP_CONV_NAMETOID
-				&& im->im_type == im_in.im_type
-				&& strnlen(im->im_name, IDMAP_NAMESZ) == namelen_in
-				&& memcmp(im->im_name, im_in.im_name, namelen_in) == 0) {
-			im->im_id = im_in.im_id;
-			wake_up(&idmap->idmap_wq);
-		}
-		he = idmap_alloc_name(h, im_in.im_name, namelen_in);
-		break;
-	default:
+	namelen_in = strnlen(im.im_name, IDMAP_NAMESZ);
+	if (namelen_in == 0 || namelen_in == IDMAP_NAMESZ) {
+		ret = -EINVAL;
 		goto out;
 	}
 
-	/* If the entry is valid, also copy it to the cache */
-	if (he != NULL)
-		idmap_update_entry(he, im_in.im_name, namelen_in, im_in.im_id);
-	ret = mlen;
+	ret = nfs_idmap_read_message(&im, cons->key, cons->authkey);
+	if (ret >= 0) {
+		key_set_timeout(cons->key, nfs_idmap_cache_timeout);
+		ret = mlen;
+	}
+
 out:
-	mutex_unlock(&idmap->idmap_im_lock);
+	complete_request_key(idmap->idmap_key_cons, ret);
+out_incomplete:
 	return ret;
 }
 
 static void
 idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
-	struct idmap_msg *im = msg->data;
-	struct idmap *idmap = container_of(im, struct idmap, idmap_im); 
-
-	if (msg->errno >= 0)
-		return;
-	mutex_lock(&idmap->idmap_im_lock);
-	im->im_status = IDMAP_STATUS_LOOKUPFAIL;
-	wake_up(&idmap->idmap_wq);
-	mutex_unlock(&idmap->idmap_im_lock);
-}
-
-/* 
- * Fowler/Noll/Vo hash
- *    http://www.isthe.com/chongo/tech/comp/fnv/
- */
-
-#define FNV_P_32 ((unsigned int)0x01000193) /* 16777619 */
-#define FNV_1_32 ((unsigned int)0x811c9dc5) /* 2166136261 */
-
-static unsigned int fnvhash32(const void *buf, size_t buflen)
-{
-	const unsigned char *p, *end = (const unsigned char *)buf + buflen;
-	unsigned int hash = FNV_1_32;
-
-	for (p = buf; p < end; p++) {
-		hash *= FNV_P_32;
-		hash ^= (unsigned int)*p;
-	}
-
-	return hash;
+	/* Free memory allocated in nfs_idmap_legacy_upcall() */
+	kfree(msg->data);
+	kfree(msg);
 }
 
 int nfs_map_name_to_uid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *uid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
-	int ret = -EINVAL;
 
 	if (nfs_map_string_to_numeric(name, namelen, uid))
 		return 0;
-	ret = nfs_idmap_lookup_id(name, namelen, "uid", uid);
-	if (ret < 0)
-		ret = nfs_idmap_id(idmap, &idmap->idmap_user_hash, name, namelen, uid);
-	return ret;
+	return nfs_idmap_lookup_id(name, namelen, "uid", uid, idmap);
 }
 
 int nfs_map_group_to_gid(const struct nfs_server *server, const char *name, size_t namelen, __u32 *gid)
 {
 	struct idmap *idmap = server->nfs_client->cl_idmap;
-	int ret = -EINVAL;
 
 	if (nfs_map_string_to_numeric(name, namelen, gid))
 		return 0;
-	ret = nfs_idmap_lookup_id(name, namelen, "gid", gid);
-	if (ret < 0)
-		ret = nfs_idmap_id(idmap, &idmap->idmap_group_hash, name, namelen, gid);
-	return ret;
+	return nfs_idmap_lookup_id(name, namelen, "gid", gid, idmap);
 }
 
 int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, size_t buflen)
@@ -965,11 +748,8 @@ int nfs_map_uid_to_name(const struct nfs_server *server, __u32 uid, char *buf, s
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret = -EINVAL;
 
-	if (!(server->caps & NFS_CAP_UIDGID_NOMAP)) {
-		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen);
-		if (ret < 0)
-			ret = nfs_idmap_name(idmap, &idmap->idmap_user_hash, uid, buf);
-	}
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_lookup_name(uid, "user", buf, buflen, idmap);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(uid, buf, buflen);
 	return ret;
@@ -979,11 +759,8 @@ int nfs_map_gid_to_group(const struct nfs_server *server, __u32 gid, char *buf,
 	struct idmap *idmap = server->nfs_client->cl_idmap;
 	int ret = -EINVAL;
 
-	if (!(server->caps & NFS_CAP_UIDGID_NOMAP)) {
-		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen);
-		if (ret < 0)
-			ret = nfs_idmap_name(idmap, &idmap->idmap_group_hash, gid, buf);
-	}
+	if (!(server->caps & NFS_CAP_UIDGID_NOMAP))
+		ret = nfs_idmap_lookup_name(gid, "group", buf, buflen, idmap);
 	if (ret < 0)
 		ret = nfs_map_numeric_to_string(gid, buf, buflen);
 	return ret;
diff --git a/include/linux/nfs_idmap.h b/include/linux/nfs_idmap.h
index 7eed201..717fa50 100644
--- a/include/linux/nfs_idmap.h
+++ b/include/linux/nfs_idmap.h
@@ -69,19 +69,8 @@ struct nfs_server;
 struct nfs_fattr;
 struct nfs4_string;
 
-#ifdef CONFIG_NFS_V4
 int nfs_idmap_init(void);
 void nfs_idmap_quit(void);
-#else
-static inline int nfs_idmap_init(void)
-{
-	return 0;
-}
-
-static inline void nfs_idmap_quit(void)
-{}
-#endif
-
 int nfs_idmap_new(struct nfs_client *);
 void nfs_idmap_delete(struct nfs_client *);
 
-- 
1.7.9.2

