Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754347Ab2GaOmx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jul 2012 10:42:53 -0400
From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/2] NFS: Combine the idmapper key types
To: Trond.Myklebust@netapp.com, bjschuma@netapp.com, sct@redhat.com
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, jlayton@redhat.com,
        David Howells <dhowells@redhat.com>
Date: Tue, 31 Jul 2012 15:42:46 +0100
Message-ID: <20120731144245.6664.49160.stgit@warthog.procyon.org.uk>
In-Reply-To: <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
References: <20120731144234.6664.85664.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS idmapper has two key types (normal and legacy) but should only use one
if it can - otherwise it risks having twice as many keys as it would otherwise
need.

Get rid of the legacy key type and have the normal key type have a
.request_key() op.  The choice of which instantiation method is then made by
the upcaller, in order:

 (1) If there's no auxdata, the normal method is called, invoking
     /sbin/request-key.

 (2) If there's something attached to the idmapper pipe (rpc.idmapd) then use
     that.

 (3) Fall back to (1).

Note that this does change the prioritisation of normal vs legacy if both are
available.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 fs/nfs/idmap.c              |  109 ++++++++++++++++++++-----------------------
 include/linux/key-type.h    |    3 +
 security/keys/request_key.c |    6 +-
 3 files changed, 57 insertions(+), 61 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index 1b5058b..ee7968d 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -55,7 +55,6 @@
 /* Default cache timeout is 10 minutes */
 unsigned int nfs_idmap_cache_timeout = 600;
 static const struct cred *id_resolver_cache;
-static struct key_type key_type_id_resolver_legacy;
 
 struct idmap {
 	struct rpc_pipe		*idmap_pipe;
@@ -63,6 +62,8 @@ struct idmap {
 	struct mutex		idmap_mutex;
 };
 
+static int nfs_idmap_upcall(struct key_construction *, const char *, void *);
+
 /**
  * nfs_fattr_init_names - initialise the nfs_fattr owner_name/group_name fields
  * @fattr: fully initialised struct nfs_fattr
@@ -173,6 +174,7 @@ static struct key_type key_type_id_resolver = {
 	.destroy	= user_destroy,
 	.describe	= user_describe,
 	.read		= user_read,
+	.request_key	= nfs_idmap_upcall,
 };
 
 static int nfs_idmap_init_keyring(void)
@@ -205,18 +207,12 @@ static int nfs_idmap_init_keyring(void)
 	if (ret < 0)
 		goto failed_put_key;
 
-	ret = register_key_type(&key_type_id_resolver_legacy);
-	if (ret < 0)
-		goto failed_reg_legacy;
-
 	set_bit(KEY_FLAG_ROOT_CAN_CLEAR, &keyring->flags);
 	cred->thread_keyring = keyring;
 	cred->jit_keyring = KEY_REQKEY_DEFL_THREAD_KEYRING;
 	id_resolver_cache = cred;
 	return 0;
 
-failed_reg_legacy:
-	unregister_key_type(&key_type_id_resolver);
 failed_put_key:
 	key_put(keyring);
 failed_put_cred:
@@ -228,7 +224,6 @@ static void nfs_idmap_quit_keyring(void)
 {
 	key_revoke(id_resolver_cache->thread_keyring);
 	unregister_key_type(&key_type_id_resolver);
-	unregister_key_type(&key_type_id_resolver_legacy);
 	put_cred(id_resolver_cache);
 }
 
@@ -276,10 +271,7 @@ static ssize_t nfs_idmap_request_key(struct key_type *key_type,
 		goto out;
 
 	saved_cred = override_creds(id_resolver_cache);
-	if (idmap)
-		rkey = request_key_with_auxdata(key_type, desc, "", 0, idmap);
-	else
-		rkey = request_key(&key_type_id_resolver, desc, "");
+	rkey = request_key_with_auxdata(key_type, desc, "", 0, idmap);
 	revert_creds(saved_cred);
 
 	kfree(desc);
@@ -318,16 +310,12 @@ static ssize_t nfs_idmap_get_key(const char *name, size_t namelen,
 				 const char *type, void *data,
 				 size_t data_size, struct idmap *idmap)
 {
-	ssize_t ret = nfs_idmap_request_key(&key_type_id_resolver,
-					    name, namelen, type, data,
-					    data_size, NULL);
-	if (ret < 0) {
-		mutex_lock(&idmap->idmap_mutex);
-		ret = nfs_idmap_request_key(&key_type_id_resolver_legacy,
-					    name, namelen, type, data,
-					    data_size, idmap);
-		mutex_unlock(&idmap->idmap_mutex);
-	}
+	ssize_t ret;
+	mutex_lock(&idmap->idmap_mutex);
+	ret = nfs_idmap_request_key(&key_type_id_resolver,
+				    name, namelen, type, data,
+				    data_size, idmap);
+	mutex_unlock(&idmap->idmap_mutex);
 	return ret;
 }
 
@@ -380,7 +368,6 @@ static const match_table_t nfs_idmap_tokens = {
 	{ Opt_find_err, NULL }
 };
 
-static int nfs_idmap_legacy_upcall(struct key_construction *, const char *, void *);
 static ssize_t idmap_pipe_downcall(struct file *, const char __user *,
 				   size_t);
 static void idmap_pipe_destroy_msg(struct rpc_pipe_msg *);
@@ -391,17 +378,6 @@ static const struct rpc_pipe_ops idmap_upcall_ops = {
 	.destroy_msg	= idmap_pipe_destroy_msg,
 };
 
-static struct key_type key_type_id_resolver_legacy = {
-	.name		= "id_legacy",
-	.instantiate	= user_instantiate,
-	.match		= user_match,
-	.revoke		= user_revoke,
-	.destroy	= user_destroy,
-	.describe	= user_describe,
-	.read		= user_read,
-	.request_key	= nfs_idmap_legacy_upcall,
-};
-
 static void __nfs_idmap_unregister(struct rpc_pipe *pipe)
 {
 	if (pipe->dentry)
@@ -658,9 +634,13 @@ out:
 	return ret;
 }
 
-static int nfs_idmap_legacy_upcall(struct key_construction *cons,
-				   const char *op,
-				   void *aux)
+/*
+ * Upcall to userspace to attempt the mapping.  We try the legacy call to
+ * rpc.idmapd first (if it is listening on its pipe) otherwise we fall back to
+ * invoking /sbin/request-key.
+ */
+static int nfs_idmap_upcall(struct key_construction *cons,
+			    const char *op, void *aux)
 {
 	struct rpc_pipe_msg *msg;
 	struct idmap_msg *im;
@@ -668,27 +648,40 @@ static int nfs_idmap_legacy_upcall(struct key_construction *cons,
 	struct key *key = cons->key;
 	int ret = -ENOMEM;
 
-	/* msg and im are freed in idmap_pipe_destroy_msg */
-	msg = kmalloc(sizeof(*msg), GFP_KERNEL);
-	if (!msg)
-		goto out0;
-
-	im = kmalloc(sizeof(*im), GFP_KERNEL);
-	if (!im)
-		goto out1;
-
-	ret = nfs_idmap_prepare_message(key->description, im, msg);
-	if (ret < 0)
-		goto out2;
-
-	BUG_ON(idmap->idmap_key_cons != NULL);
-	idmap->idmap_key_cons = cons;
-
-	ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
-	if (ret < 0)
-		goto out2;
+	/* See if it's worth trying to talk to rpc.idmapd */
+	if (idmap->idmap_pipe->nreaders ||
+	    idmap->idmap_pipe->flags & RPC_PIPE_WAIT_FOR_OPEN) {
+		/* msg and im are freed in idmap_pipe_destroy_msg */
+		msg = kmalloc(sizeof(*msg), GFP_KERNEL);
+		if (!msg)
+			goto out0;
+
+		im = kmalloc(sizeof(*im), GFP_KERNEL);
+		if (!im)
+			goto out1;
+
+		ret = nfs_idmap_prepare_message(key->description, im, msg);
+		if (ret < 0)
+			goto out2;
+
+		BUG_ON(idmap->idmap_key_cons != NULL);
+		idmap->idmap_key_cons = cons;
+
+		ret = rpc_queue_upcall(idmap->idmap_pipe, msg);
+		if (ret < 0) {
+			idmap->idmap_key_cons = NULL;
+			if (ret == -EPIPE) {
+				kfree(im);
+				kfree(msg);
+				goto rpc_idmapd_is_not_listening;
+			}
+			goto out2;
+		}
+		return ret;
+	}
 
-	return ret;
+rpc_idmapd_is_not_listening:
+	return call_sbin_request_key(cons, op, NULL);
 
 out2:
 	kfree(im);
@@ -778,7 +771,7 @@ out_incomplete:
 static void
 idmap_pipe_destroy_msg(struct rpc_pipe_msg *msg)
 {
-	/* Free memory allocated in nfs_idmap_legacy_upcall() */
+	/* Free memory allocated in the legacy side of nfs_idmap_upcall() */
 	kfree(msg->data);
 	kfree(msg);
 }
diff --git a/include/linux/key-type.h b/include/linux/key-type.h
index f0c651c..c095b90 100644
--- a/include/linux/key-type.h
+++ b/include/linux/key-type.h
@@ -29,6 +29,9 @@ struct key_construction {
 typedef int (*request_key_actor_t)(struct key_construction *key,
 				   const char *op, void *aux);
 
+extern int call_sbin_request_key(struct key_construction *cons,
+				 const char *op, void *aux);
+
 /*
  * kernel managed key type definition
  */
diff --git a/security/keys/request_key.c b/security/keys/request_key.c
index 275c4f9..bac83d1 100644
--- a/security/keys/request_key.c
+++ b/security/keys/request_key.c
@@ -102,9 +102,8 @@ static int call_usermodehelper_keys(char *path, char **argv, char **envp,
  * Request userspace finish the construction of a key
  * - execute "/sbin/request-key <op> <key> <uid> <gid> <keyring> <keyring> <keyring>"
  */
-static int call_sbin_request_key(struct key_construction *cons,
-				 const char *op,
-				 void *aux)
+int call_sbin_request_key(struct key_construction *cons,
+			  const char *op, void *aux)
 {
 	const struct cred *cred = current_cred();
 	key_serial_t prkey, sskey;
@@ -204,6 +203,7 @@ error_alloc:
 	kleave(" = %d", ret);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(call_sbin_request_key);
 
 /*
  * Call out to userspace for key construction.

