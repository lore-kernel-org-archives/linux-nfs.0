Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx11.netapp.com ([216.240.18.76]:45502 "EHLO mx11.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146Ab3JVOVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Oct 2013 10:21:23 -0400
From: <andros@netapp.com>
To: <trond.myklebust@netapp.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 2/5] SUNRPC set gss_cred gss-ctx key serial
Date: Tue, 22 Oct 2013 10:21:13 -0400
Message-ID: <1382451676-2963-3-git-send-email-andros@netapp.com>
In-Reply-To: <1382451676-2963-1-git-send-email-andros@netapp.com>
References: <1382451676-2963-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

the gc_serial will be used to find gss_cred's associated with the gss-ctx
key which in turn is associated with the user kerberos credentials.

Add the ccname to the gssd upcall. Gssd uses this name to locate the principals'
Kerbeos credential cache which helps gssd to stop rooting around the file
system.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 include/linux/sunrpc/auth_gss.h |  1 +
 net/sunrpc/auth_gss/auth_gss.c  | 91 +++++++++++++++++++++++++++++++++++++++--
 2 files changed, 89 insertions(+), 3 deletions(-)

diff --git a/include/linux/sunrpc/auth_gss.h b/include/linux/sunrpc/auth_gss.h
index f1cfd4c..4b20b53 100644
--- a/include/linux/sunrpc/auth_gss.h
+++ b/include/linux/sunrpc/auth_gss.h
@@ -79,6 +79,7 @@ struct gss_cl_ctx {
 struct gss_upcall_msg;
 struct gss_cred {
 	struct rpc_cred		gc_base;
+	key_serial_t		gc_serial;
 	enum rpc_gss_svc	gc_service;
 	struct gss_cl_ctx __rcu	*gc_ctx;
 	struct gss_upcall_msg	*gc_upcall;
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index ae42a83..10d6e53 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -161,13 +161,19 @@ gss_put_ctx(struct gss_cl_ctx *ctx)
  * and a new one is protected by the pipe->lock.
  */
 static void
-gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx)
+gss_cred_set_ctx(struct rpc_cred *cred, struct gss_cl_ctx *ctx, struct key *key)
 {
 	struct gss_cred *gss_cred = container_of(cred, struct gss_cred, gc_base);
 
 	if (!test_bit(RPCAUTH_CRED_NEW, &cred->cr_flags))
 		return;
 	gss_get_ctx(ctx);
+	if (key != NULL)
+		gss_cred->gc_serial = key->serial;
+	else
+		pr_warn_ratelimited("RPC        no gss-ctx key for uid %d "
+				"gss_cred and context will not be destroyed "
+				" upon kdestroy\n", cred->cr_uid);
 	rcu_assign_pointer(gss_cred->gc_ctx, ctx);
 	set_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags);
 	smp_mb__before_clear_bit();
@@ -302,6 +308,8 @@ err:
 struct gss_upcall_msg {
 	atomic_t count;
 	kuid_t	uid;
+	struct key *key;
+	char *cc_name;
 	struct rpc_pipe_msg msg;
 	struct list_head list;
 	struct gss_auth *auth;
@@ -347,7 +355,11 @@ gss_release_msg(struct gss_upcall_msg *gss_msg)
 	BUG_ON(!list_empty(&gss_msg->list));
 	if (gss_msg->ctx != NULL)
 		gss_put_ctx(gss_msg->ctx);
+	if (gss_msg->key != NULL)
+		/* balance key_get in keyring_search */
+		key_put(gss_msg->key);
 	rpc_destroy_wait_queue(&gss_msg->rpc_waitqueue);
+	kfree(gss_msg->cc_name);
 	kfree(gss_msg);
 }
 
@@ -417,7 +429,8 @@ gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss
 		if (gss_msg->ctx == NULL)
 			break;
 		clear_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
-		gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx);
+		gss_cred_set_ctx(&gss_cred->gc_base, gss_msg->ctx,
+				gss_msg->key);
 		break;
 	case -EKEYEXPIRED:
 		set_bit(RPCAUTH_CRED_NEGATIVE, &gss_cred->gc_base.cr_flags);
@@ -427,6 +440,67 @@ gss_handle_downcall_result(struct gss_cred *gss_cred, struct gss_upcall_msg *gss
 	rpc_wake_up_status(&gss_msg->rpc_waitqueue, gss_msg->msg.errno);
 }
 
+
+#define GSS_CTX_ID_MAXLEN 20 /* "gss-ctx_" + NFS_UINT_MAXLEN  + 1 */
+
+static void
+gss_find_ctx_key(uid_t uid, struct gss_upcall_msg *msg)
+{
+	key_ref_t rkey;
+	struct key *key;
+	struct user_key_payload *payload;
+	char *id;
+	const struct cred *cred = get_current_cred();
+	int ret;
+
+	if (!cred->user->session_keyring)
+		goto out;
+
+	id = kzalloc(GSS_CTX_ID_MAXLEN, GFP_NOFS);
+	if (!id)
+		goto out;
+
+	snprintf(id, GSS_CTX_ID_MAXLEN,  "gss-ctx_%d", uid);
+
+        /* Search the session keyring. Note that the user key create
+         * needs to also use the same keyring. */
+	rkey = keyring_search(make_key_ref(cred->user->session_keyring, 1),
+				&key_type_gss_ctx, id);
+	kfree(id);
+
+	if (IS_ERR(rkey))
+		goto out;
+
+	key = key_ref_to_ptr(rkey);
+
+	rcu_read_lock();
+	key->perm |= KEY_USR_VIEW;
+
+	ret = key_validate(key);
+	if (ret < 0)
+		goto out_unlock;
+
+	payload = rcu_dereference(key->payload.data);
+	if (IS_ERR_OR_NULL(payload))
+		goto out_unlock;
+
+	if (key->uid != uid || payload->datalen <= 0)
+		goto out_unlock;
+
+	msg->cc_name = kzalloc(payload->datalen + 1, GFP_NOFS);
+	if (!msg->cc_name)
+		goto out_unlock;
+
+	memcpy(msg->cc_name, payload->data, payload->datalen);
+	msg->key = key;
+	dprintk("RPC    krb5 ccache %s has gss-ctx key with serial %u \n",
+		msg->cc_name, msg->key->serial);
+out_unlock:
+	rcu_read_unlock();
+out:
+	return;
+}
+
 static void
 gss_upcall_callback(struct rpc_task *task)
 {
@@ -478,6 +552,11 @@ static void gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		p += len;
 		gss_msg->msg.len += len;
 	}
+	if (gss_msg->cc_name != NULL) {
+		len = sprintf(p, "ccache=%s ", gss_msg->cc_name);
+		p += len;
+		gss_msg->msg.len += len;
+	}
 	len = sprintf(p, "\n");
 	gss_msg->msg.len += len;
 
@@ -500,6 +579,9 @@ gss_alloc_msg(struct gss_auth *gss_auth,
 		kfree(gss_msg);
 		return ERR_PTR(vers);
 	}
+	/* Use a gss-ctx key if available */
+	gss_find_ctx_key(uid, gss_msg);
+
 	gss_msg->pipe = gss_auth->gss_pipe[vers]->pipe;
 	INIT_LIST_HEAD(&gss_msg->list);
 	rpc_init_wait_queue(&gss_msg->rpc_waitqueue, "RPCSEC_GSS upcall waitq");
@@ -532,6 +614,9 @@ gss_setup_upcall(struct gss_auth *gss_auth, struct rpc_cred *cred)
 		int res = rpc_queue_upcall(gss_new->pipe, &gss_new->msg);
 		if (res) {
 			gss_unhash_msg(gss_new);
+			if (gss_new->key)
+				/* balance key_get in keyring_search */
+				key_put(gss_new->key);
 			gss_msg = ERR_PTR(res);
 		}
 	} else
@@ -654,7 +739,7 @@ retry:
 		schedule();
 	}
 	if (gss_msg->ctx)
-		gss_cred_set_ctx(cred, gss_msg->ctx);
+		gss_cred_set_ctx(cred, gss_msg->ctx, gss_msg->key);
 	else
 		err = gss_msg->msg.errno;
 	spin_unlock(&pipe->lock);
-- 
1.8.3.1

