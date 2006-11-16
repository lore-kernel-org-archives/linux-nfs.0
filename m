From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/21] SUNRPC: fix print format for tk_pid in auth_gss
	support
Date: Thu, 16 Nov 2006 15:05:00 -0500
Message-ID: <20061116200500.32549.27677.stgit@localhost.localdomain>
References: <20061116200151.32549.88898.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gko1y-0006y7-KI
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:18 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gko1y-0000hZ-Pm
	for nfs@lists.sourceforge.net; Thu, 16 Nov 2006 12:40:20 -0800
To: trond.myklebust@fys.uio.no
In-Reply-To: <20061116200151.32549.88898.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The tk_pid field is an unsigned short.  The proper print format specifier for
that type is %5u, not %4d.

Also clean up some miscellaneous print formatting nits.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/auth_gss/auth_gss.c         |   46 ++++++++++++++++----------------
 net/sunrpc/auth_gss/gss_krb5_crypto.c  |   18 ++++++-------
 net/sunrpc/auth_gss/gss_krb5_mech.c    |    3 +-
 net/sunrpc/auth_gss/gss_krb5_seal.c    |    8 +++---
 net/sunrpc/auth_gss/gss_krb5_seqnum.c  |    2 +
 net/sunrpc/auth_gss/gss_krb5_unseal.c  |    2 +
 net/sunrpc/auth_gss/gss_krb5_wrap.c    |   10 +++----
 net/sunrpc/auth_gss/gss_mech_switch.c  |    6 ++--
 net/sunrpc/auth_gss/gss_spkm3_mech.c   |   12 ++++----
 net/sunrpc/auth_gss/gss_spkm3_seal.c   |   10 +++----
 net/sunrpc/auth_gss/gss_spkm3_token.c  |   12 ++++----
 net/sunrpc/auth_gss/gss_spkm3_unseal.c |   12 ++++----
 net/sunrpc/auth_gss/svcauth_gss.c      |    6 ++--
 13 files changed, 74 insertions(+), 73 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index b36b946..81e52f4 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -282,7 +282,7 @@ gss_fill_context(const void *p, const vo
 	}
 	return q;
 err:
-	dprintk("RPC:      gss_fill_context returning %ld\n", -PTR_ERR(p));
+	dprintk("RPC:       gss_fill_context returning %ld\n", -PTR_ERR(p));
 	return p;
 }
 
@@ -317,10 +317,10 @@ __gss_find_upcall(struct gss_auth *gss_a
 		if (pos->uid != uid)
 			continue;
 		atomic_inc(&pos->count);
-		dprintk("RPC:      gss_find_upcall found msg %p\n", pos);
+		dprintk("RPC:       gss_find_upcall found msg %p\n", pos);
 		return pos;
 	}
-	dprintk("RPC:      gss_find_upcall found nothing\n");
+	dprintk("RPC:       gss_find_upcall found nothing\n");
 	return NULL;
 }
 
@@ -434,7 +434,7 @@ gss_refresh_upcall(struct rpc_task *task
 	struct gss_upcall_msg *gss_msg;
 	int err = 0;
 
-	dprintk("RPC: %4u gss_refresh_upcall for uid %u\n", task->tk_pid, cred->cr_uid);
+	dprintk("RPC: %5u gss_refresh_upcall for uid %u\n", task->tk_pid, cred->cr_uid);
 	gss_msg = gss_setup_upcall(task->tk_client, gss_auth, cred);
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -454,7 +454,7 @@ gss_refresh_upcall(struct rpc_task *task
 	spin_unlock(&gss_auth->lock);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC: %4u gss_refresh_upcall for uid %u result %d\n", task->tk_pid,
+	dprintk("RPC: %5u gss_refresh_upcall for uid %u result %d\n", task->tk_pid,
 			cred->cr_uid, err);
 	return err;
 }
@@ -467,7 +467,7 @@ gss_create_upcall(struct gss_auth *gss_a
 	DEFINE_WAIT(wait);
 	int err = 0;
 
-	dprintk("RPC: gss_upcall for uid %u\n", cred->cr_uid);
+	dprintk("RPC:       gss_upcall for uid %u\n", cred->cr_uid);
 	gss_msg = gss_setup_upcall(gss_auth->client, gss_auth, cred);
 	if (IS_ERR(gss_msg)) {
 		err = PTR_ERR(gss_msg);
@@ -495,7 +495,7 @@ out_intr:
 	finish_wait(&gss_msg->waitqueue, &wait);
 	gss_release_msg(gss_msg);
 out:
-	dprintk("RPC: gss_create_upcall for uid %u result %d\n", cred->cr_uid, err);
+	dprintk("RPC:       gss_create_upcall for uid %u result %d\n", cred->cr_uid, err);
 	return err;
 }
 
@@ -587,14 +587,14 @@ gss_pipe_downcall(struct file *filp, con
 	}
 	gss_put_ctx(ctx);
 	kfree(buf);
-	dprintk("RPC:      gss_pipe_downcall returning length %Zu\n", mlen);
+	dprintk("RPC:       gss_pipe_downcall returning length %Zu\n", mlen);
 	return mlen;
 err_put_ctx:
 	gss_put_ctx(ctx);
 err:
 	kfree(buf);
 out:
-	dprintk("RPC:      gss_pipe_downcall returning %d\n", err);
+	dprintk("RPC:       gss_pipe_downcall returning %d\n", err);
 	return err;
 }
 
@@ -632,7 +632,7 @@ gss_pipe_destroy_msg(struct rpc_pipe_msg
 	static unsigned long ratelimit;
 
 	if (msg->errno < 0) {
-		dprintk("RPC:      gss_pipe_destroy_msg releasing msg %p\n",
+		dprintk("RPC:       gss_pipe_destroy_msg releasing msg %p\n",
 				gss_msg);
 		atomic_inc(&gss_msg->count);
 		gss_unhash_msg(gss_msg);
@@ -659,7 +659,7 @@ gss_create(struct rpc_clnt *clnt, rpc_au
 	struct rpc_auth * auth;
 	int err = -ENOMEM; /* XXX? */
 
-	dprintk("RPC:      creating GSS authenticator for client %p\n",clnt);
+	dprintk("RPC:       creating GSS authenticator for client %p\n",clnt);
 
 	if (!try_module_get(THIS_MODULE))
 		return ERR_PTR(err);
@@ -711,7 +711,7 @@ gss_destroy(struct rpc_auth *auth)
 {
 	struct gss_auth *gss_auth;
 
-	dprintk("RPC:      destroying GSS authenticator %p flavor %d\n",
+	dprintk("RPC:       destroying GSS authenticator %p flavor %d\n",
 		auth, auth->au_flavor);
 
 	gss_auth = container_of(auth, struct gss_auth, rpc_auth);
@@ -730,7 +730,7 @@ gss_destroy(struct rpc_auth *auth)
 static void
 gss_destroy_ctx(struct gss_cl_ctx *ctx)
 {
-	dprintk("RPC:      gss_destroy_ctx\n");
+	dprintk("RPC:       gss_destroy_ctx\n");
 
 	if (ctx->gc_gss_ctx)
 		gss_delete_sec_context(&ctx->gc_gss_ctx);
@@ -744,7 +744,7 @@ gss_destroy_cred(struct rpc_cred *rc)
 {
 	struct gss_cred *cred = container_of(rc, struct gss_cred, gc_base);
 
-	dprintk("RPC:      gss_destroy_cred \n");
+	dprintk("RPC:       gss_destroy_cred \n");
 
 	if (cred->gc_ctx)
 		gss_put_ctx(cred->gc_ctx);
@@ -767,7 +767,7 @@ gss_create_cred(struct rpc_auth *auth, s
 	struct gss_cred	*cred = NULL;
 	int err = -ENOMEM;
 
-	dprintk("RPC:      gss_create_cred for uid %d, flavor %d\n",
+	dprintk("RPC:       gss_create_cred for uid %d, flavor %d\n",
 		acred->uid, auth->au_flavor);
 
 	if (!(cred = kzalloc(sizeof(*cred), GFP_KERNEL)))
@@ -786,7 +786,7 @@ gss_create_cred(struct rpc_auth *auth, s
 	return &cred->gc_base;
 
 out_err:
-	dprintk("RPC:      gss_create_cred failed with error %d\n", err);
+	dprintk("RPC:       gss_create_cred failed with error %d\n", err);
 	return ERR_PTR(err);
 }
 
@@ -840,7 +840,7 @@ gss_marshal(struct rpc_task *task, __be3
 	struct kvec	iov;
 	struct xdr_buf	verf_buf;
 
-	dprintk("RPC: %4u gss_marshal\n", task->tk_pid);
+	dprintk("RPC: %5u gss_marshal\n", task->tk_pid);
 
 	*p++ = htonl(RPC_AUTH_GSS);
 	cred_len = p++;
@@ -906,7 +906,7 @@ gss_validate(struct rpc_task *task, __be
 	u32		flav,len;
 	u32		maj_stat;
 
-	dprintk("RPC: %4u gss_validate\n", task->tk_pid);
+	dprintk("RPC: %5u gss_validate\n", task->tk_pid);
 
 	flav = ntohl(*p++);
 	if ((len = ntohl(*p++)) > RPC_MAX_AUTH_SIZE)
@@ -929,12 +929,12 @@ gss_validate(struct rpc_task *task, __be
 	 * calculate the length of the verifier: */
 	task->tk_auth->au_verfsize = XDR_QUADLEN(len) + 2;
 	gss_put_ctx(ctx);
-	dprintk("RPC: %4u GSS gss_validate: gss_verify_mic succeeded.\n",
+	dprintk("RPC: %5u gss_validate: gss_verify_mic succeeded.\n",
 			task->tk_pid);
 	return p + XDR_QUADLEN(len);
 out_bad:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %4u gss_validate failed.\n", task->tk_pid);
+	dprintk("RPC: %5u gss_validate failed.\n", task->tk_pid);
 	return NULL;
 }
 
@@ -1104,7 +1104,7 @@ gss_wrap_req(struct rpc_task *task,
 	struct gss_cl_ctx *ctx = gss_cred_get_ctx(cred);
 	int             status = -EIO;
 
-	dprintk("RPC: %4u gss_wrap_req\n", task->tk_pid);
+	dprintk("RPC: %5u gss_wrap_req\n", task->tk_pid);
 	if (ctx->gc_proc != RPC_GSS_PROC_DATA) {
 		/* The spec seems a little ambiguous here, but I think that not
 		 * wrapping context destruction requests makes the most sense.
@@ -1127,7 +1127,7 @@ gss_wrap_req(struct rpc_task *task,
 	}
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %4u gss_wrap_req returning %d\n", task->tk_pid, status);
+	dprintk("RPC: %5u gss_wrap_req returning %d\n", task->tk_pid, status);
 	return status;
 }
 
@@ -1233,7 +1233,7 @@ out_decode:
 	status = decode(rqstp, p, obj);
 out:
 	gss_put_ctx(ctx);
-	dprintk("RPC: %4u gss_unwrap_resp returning %d\n", task->tk_pid,
+	dprintk("RPC: %5u gss_unwrap_resp returning %d\n", task->tk_pid,
 			status);
 	return status;
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index e11a40b..cb4d915 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -61,14 +61,14 @@ krb5_encrypt(
 	u8 local_iv[16] = {0};
 	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
-	dprintk("RPC:      krb5_encrypt: input data:\n");
+	dprintk("RPC:       krb5_encrypt: input data:\n");
 	print_hexl((u32 *)in, length, 0);
 
 	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
 	if (crypto_blkcipher_ivsize(tfm) > 16) {
-		dprintk("RPC:      gss_k5encrypt: tfm iv size to large %d\n",
+		dprintk("RPC:       gss_k5encrypt: tfm iv size to large %d\n",
 		         crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
@@ -81,10 +81,10 @@ krb5_encrypt(
 
 	ret = crypto_blkcipher_encrypt_iv(&desc, sg, sg, length);
 
-	dprintk("RPC:      krb5_encrypt: output data:\n");
+	dprintk("RPC:       krb5_encrypt: output data:\n");
 	print_hexl((u32 *)out, length, 0);
 out:
-	dprintk("RPC:      krb5_encrypt returns %d\n",ret);
+	dprintk("RPC:       krb5_encrypt returns %d\n",ret);
 	return(ret);
 }
 
@@ -103,14 +103,14 @@ krb5_decrypt(
 	u8 local_iv[16] = {0};
 	struct blkcipher_desc desc = { .tfm = tfm, .info = local_iv };
 
-	dprintk("RPC:      krb5_decrypt: input data:\n");
+	dprintk("RPC:       krb5_decrypt: input data:\n");
 	print_hexl((u32 *)in, length, 0);
 
 	if (length % crypto_blkcipher_blocksize(tfm) != 0)
 		goto out;
 
 	if (crypto_blkcipher_ivsize(tfm) > 16) {
-		dprintk("RPC:      gss_k5decrypt: tfm iv size to large %d\n",
+		dprintk("RPC:       gss_k5decrypt: tfm iv size to large %d\n",
 			crypto_blkcipher_ivsize(tfm));
 		goto out;
 	}
@@ -122,10 +122,10 @@ krb5_decrypt(
 
 	ret = crypto_blkcipher_decrypt_iv(&desc, sg, sg, length);
 
-	dprintk("RPC:      krb5_decrypt: output_data:\n");
+	dprintk("RPC:       krb5_decrypt: output_data:\n");
 	print_hexl((u32 *)out, length, 0);
 out:
-	dprintk("RPC:      gss_k5decrypt returns %d\n",ret);
+	dprintk("RPC:       gss_k5decrypt returns %d\n",ret);
 	return(ret);
 }
 
@@ -220,7 +220,7 @@ make_checksum(s32 cksumtype, char *heade
 			cksumname = "md5";
 			break;
 		default:
-			dprintk("RPC:      krb5_make_checksum:"
+			dprintk("RPC:       krb5_make_checksum:"
 				" unsupported checksum %d", cksumtype);
 			return GSS_S_FAILURE;
 	}
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_krb5_mech.c
index 325e72e..838e1c8 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -170,7 +170,8 @@ gss_import_sec_context_kerberos(const vo
 	}
 
 	ctx_id->internal_ctx_id = ctx;
-	dprintk("RPC:      Successfully imported new context.\n");
+
+	dprintk("RPC:       Successfully imported new context.\n");
 	return 0;
 
 out_err_free_key2:
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_krb5_seal.c
index 08601ee..3b97d5a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -84,7 +84,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss
 	s32			now;
 	u32			seq_send;
 
-	dprintk("RPC:     gss_krb5_seal\n");
+	dprintk("RPC:       gss_krb5_seal\n");
 
 	now = get_seconds();
 
@@ -93,12 +93,12 @@ gss_get_mic_kerberos(struct gss_ctx *gss
 			checksum_type = CKSUMTYPE_RSA_MD5;
 			break;
 		default:
-			dprintk("RPC:      gss_krb5_seal: ctx->signalg %d not"
+			dprintk("RPC:       gss_krb5_seal: ctx->signalg %d not"
 				" supported\n", ctx->signalg);
 			goto out_err;
 	}
 	if (ctx->sealalg != SEAL_ALG_NONE && ctx->sealalg != SEAL_ALG_DES) {
-		dprintk("RPC:      gss_krb5_seal: ctx->sealalg %d not supported\n",
+		dprintk("RPC:       gss_krb5_seal: ctx->sealalg %d not supported\n",
 			ctx->sealalg);
 		goto out_err;
 	}
@@ -130,7 +130,7 @@ gss_get_mic_kerberos(struct gss_ctx *gss
 		       md5cksum.data + md5cksum.len - KRB5_CKSUM_LENGTH,
 		       KRB5_CKSUM_LENGTH);
 
-		dprintk("RPC:      make_seal_token: cksum data: \n");
+		dprintk("RPC:       make_seal_token: cksum data: \n");
 		print_hexl((u32 *) (krb5_hdr + 16), KRB5_CKSUM_LENGTH, 0);
 		break;
 	default:
diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
index c604baf..2f0b112 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
@@ -70,7 +70,7 @@ krb5_get_seq_num(struct crypto_blkcipher
 	s32 code;
 	unsigned char plain[8];
 
-	dprintk("RPC:      krb5_get_seq_num:\n");
+	dprintk("RPC:       krb5_get_seq_num:\n");
 
 	if ((code = krb5_decrypt(key, cksum, buf, plain, 8)))
 		return code;
diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c b/net/sunrpc/auth_gss/gss_krb5_unseal.c
index 0828cf6..d9fce2b 100644
--- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
@@ -88,7 +88,7 @@ gss_verify_mic_kerberos(struct gss_ctx *
 	int			bodysize;
 	u32			ret = GSS_S_DEFECTIVE_TOKEN;
 
-	dprintk("RPC:      krb5_read_token\n");
+	dprintk("RPC:       krb5_read_token\n");
 
 	if (g_verify_token_header(&ctx->mech_used, &bodysize, &ptr,
 					read_token->len))
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index cc45c16..0b29a87 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -130,7 +130,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, i
 	struct page		**tmp_pages;
 	u32			seq_send;
 
-	dprintk("RPC:     gss_wrap_kerberos\n");
+	dprintk("RPC:       gss_wrap_kerberos\n");
 
 	now = get_seconds();
 
@@ -139,12 +139,12 @@ gss_wrap_kerberos(struct gss_ctx *ctx, i
 			checksum_type = CKSUMTYPE_RSA_MD5;
 			break;
 		default:
-			dprintk("RPC:      gss_krb5_seal: kctx->signalg %d not"
+			dprintk("RPC:       gss_krb5_seal: kctx->signalg %d not"
 				" supported\n", kctx->signalg);
 			goto out_err;
 	}
 	if (kctx->sealalg != SEAL_ALG_NONE && kctx->sealalg != SEAL_ALG_DES) {
-		dprintk("RPC:      gss_krb5_seal: kctx->sealalg %d not supported\n",
+		dprintk("RPC:       gss_krb5_seal: kctx->sealalg %d not supported\n",
 			kctx->sealalg);
 		goto out_err;
 	}
@@ -200,7 +200,7 @@ gss_wrap_kerberos(struct gss_ctx *ctx, i
 		       md5cksum.data + md5cksum.len - KRB5_CKSUM_LENGTH,
 		       KRB5_CKSUM_LENGTH);
 
-		dprintk("RPC:      make_seal_token: cksum data: \n");
+		dprintk("RPC:       make_seal_token: cksum data: \n");
 		print_hexl((u32 *) (krb5_hdr + 16), KRB5_CKSUM_LENGTH, 0);
 		break;
 	default:
@@ -245,7 +245,7 @@ gss_unwrap_kerberos(struct gss_ctx *ctx,
 	int			data_len;
 	int			blocksize;
 
-	dprintk("RPC:      gss_unwrap_kerberos\n");
+	dprintk("RPC:       gss_unwrap_kerberos\n");
 
 	ptr = (u8 *)buf->head[0].iov_base + offset;
 	if (g_verify_token_header(&kctx->mech_used, &bodysize, &ptr,
diff --git a/net/sunrpc/auth_gss/gss_mech_switch.c b/net/sunrpc/auth_gss/gss_mech_switch.c
index 3db7453..c7681db 100644
--- a/net/sunrpc/auth_gss/gss_mech_switch.c
+++ b/net/sunrpc/auth_gss/gss_mech_switch.c
@@ -113,7 +113,7 @@ gss_mech_register(struct gss_api_mech *g
 	spin_lock(&registered_mechs_lock);
 	list_add(&gm->gm_list, &registered_mechs);
 	spin_unlock(&registered_mechs_lock);
-	dprintk("RPC:      registered gss mechanism %s\n", gm->gm_name);
+	dprintk("RPC:       registered gss mechanism %s\n", gm->gm_name);
 	return 0;
 }
 
@@ -125,7 +125,7 @@ gss_mech_unregister(struct gss_api_mech 
 	spin_lock(&registered_mechs_lock);
 	list_del(&gm->gm_list);
 	spin_unlock(&registered_mechs_lock);
-	dprintk("RPC:      unregistered gss mechanism %s\n", gm->gm_name);
+	dprintk("RPC:       unregistered gss mechanism %s\n", gm->gm_name);
 	gss_mech_free(gm);
 }
 
@@ -298,7 +298,7 @@ gss_unwrap(struct gss_ctx	*ctx_id,
 u32
 gss_delete_sec_context(struct gss_ctx	**context_handle)
 {
-	dprintk("RPC:      gss_delete_sec_context deleting %p\n",
+	dprintk("RPC:       gss_delete_sec_context deleting %p\n",
 			*context_handle);
 
 	if (!*context_handle)
diff --git a/net/sunrpc/auth_gss/gss_spkm3_mech.c b/net/sunrpc/auth_gss/gss_spkm3_mech.c
index bdedf45..84a8ed3 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_mech.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_mech.c
@@ -110,13 +110,13 @@ get_key(const void *p, const void *end, 
 			break;
 		case NID_md5:
 			if (key.len == 0) {
-				dprintk("RPC: SPKM3 get_key: NID_md5 zero Key length\n");
+				dprintk("RPC:       SPKM3 get_key: NID_md5 zero Key length\n");
 			}
 			alg_name = "md5";
 			setkey = 0;
 			break;
 		default:
-			dprintk("gss_spkm3_mech: unsupported algorithm %d\n", *resalg);
+			dprintk("RPC:       SPKM3 get_key: unsupported algorithm %d\n", *resalg);
 			goto out_err_free_key;
 	}
 	*res = crypto_alloc_blkcipher(alg_name, 0, CRYPTO_ALG_ASYNC);
@@ -201,7 +201,7 @@ gss_import_sec_context_spkm3(const void 
 
 	ctx_id->internal_ctx_id = ctx;
 
-	dprintk("Successfully imported new spkm context.\n");
+	dprintk("RPC:       Successfully imported new spkm context.\n");
 	return 0;
 
 out_err_free_key2:
@@ -239,10 +239,10 @@ gss_verify_mic_spkm3(struct gss_ctx		*ct
 	u32 maj_stat = 0;
 	struct spkm3_ctx *sctx = ctx->internal_ctx_id;
 
-	dprintk("RPC: gss_verify_mic_spkm3 calling spkm3_read_token\n");
+	dprintk("RPC:       gss_verify_mic_spkm3 calling spkm3_read_token\n");
 	maj_stat = spkm3_read_token(sctx, checksum, signbuf, SPKM_MIC_TOK);
 
-	dprintk("RPC: gss_verify_mic_spkm3 returning %d\n", maj_stat);
+	dprintk("RPC:       gss_verify_mic_spkm3 returning %d\n", maj_stat);
 	return maj_stat;
 }
 
@@ -254,7 +254,7 @@ gss_get_mic_spkm3(struct gss_ctx	*ctx,
 	u32 err = 0;
 	struct spkm3_ctx *sctx = ctx->internal_ctx_id;
 
-	dprintk("RPC: gss_get_mic_spkm3\n");
+	dprintk("RPC:       gss_get_mic_spkm3\n");
 
 	err = spkm3_make_token(sctx, message_buffer,
 			      message_token, SPKM_MIC_TOK);
diff --git a/net/sunrpc/auth_gss/gss_spkm3_seal.c b/net/sunrpc/auth_gss/gss_spkm3_seal.c
index 18c7862..08cb2c8 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_seal.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_seal.c
@@ -66,12 +66,12 @@ spkm3_make_token(struct spkm3_ctx *ctx,
 	int			ctxelen = 0, ctxzbit = 0;
 	int			md5elen = 0, md5zbit = 0;
 
-	dprintk("RPC: spkm3_make_token\n");
+	dprintk("RPC:       spkm3_make_token\n");
 
 	now = jiffies;
 
 	if (ctx->ctx_id.len != 16) {
-		dprintk("RPC: spkm3_make_token BAD ctx_id.len %d\n",
+		dprintk("RPC:       spkm3_make_token BAD ctx_id.len %d\n",
 			ctx->ctx_id.len);
 		goto out_err;
 	}
@@ -81,13 +81,13 @@ spkm3_make_token(struct spkm3_ctx *ctx,
 			checksum_type = CKSUMTYPE_RSA_MD5;
 			break;
 		default:
-			dprintk("RPC: gss_spkm3_seal: ctx->signalg %d not"
+			dprintk("RPC:       gss_spkm3_seal: ctx->signalg %d not"
 				" supported\n", ctx->intg_alg);
 			goto out_err;
 	}
 	/* XXX since we don't support WRAP, perhaps we don't care... */
 	if (ctx->conf_alg != NID_cast5_cbc) {
-		dprintk("RPC: gss_spkm3_seal: ctx->sealalg %d not supported\n",
+		dprintk("RPC:       gss_spkm3_seal: ctx->sealalg %d not supported\n",
 			ctx->conf_alg);
 		goto out_err;
 	}
@@ -113,7 +113,7 @@ spkm3_make_token(struct spkm3_ctx *ctx,
 
 		spkm3_make_mic_token(&ptr, tokenlen, &mic_hdr, &md5cksum, md5elen, md5zbit);
 	} else if (toktype == SPKM_WRAP_TOK) { /* Not Supported */
-		dprintk("RPC: gss_spkm3_seal: SPKM_WRAP_TOK not supported\n");
+		dprintk("RPC:       gss_spkm3_seal: SPKM_WRAP_TOK not supported\n");
 		goto out_err;
 	}
 
diff --git a/net/sunrpc/auth_gss/gss_spkm3_token.c b/net/sunrpc/auth_gss/gss_spkm3_token.c
index 854a983..1504f38 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_token.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_token.c
@@ -209,7 +209,7 @@ spkm3_verify_mic_token(unsigned char **t
 
 	/* spkm3 innercontext token preamble */
 	if ((ptr[0] != 0xa4) || (ptr[2] != 0x30)) {
-		dprintk("RPC: BAD SPKM ictoken preamble\n"); 
+		dprintk("RPC:       BAD SPKM ictoken preamble\n");
 		goto out;
 	}
 
@@ -217,25 +217,25 @@ spkm3_verify_mic_token(unsigned char **t
 
 	/* token type */
 	if ((ptr[4] != 0x02) || (ptr[5] != 0x02)) {
-		dprintk("RPC: BAD asn1 SPKM3 token type\n");
+		dprintk("RPC:       BAD asn1 SPKM3 token type\n");
 		goto out;
 	}
 
 	/* only support SPKM_MIC_TOK */
 	if((ptr[6] != 0x01) || (ptr[7] != 0x01)) {
-		dprintk("RPC: ERROR unsupported SPKM3 token \n");
+		dprintk("RPC:       ERROR unsupported SPKM3 token \n");
 		goto out;
 	}
 
 	/* contextid */
 	if (ptr[8] != 0x03) {
-		dprintk("RPC: BAD SPKM3 asn1 context-id type\n");
+		dprintk("RPC:       BAD SPKM3 asn1 context-id type\n");
 		goto out;
 	}
 
 	ctxelen = ptr[9];
 	if (ctxelen > 17) {  /* length includes asn1 zbit octet */
-		dprintk("RPC: BAD SPKM3 contextid len %d\n", ctxelen);
+		dprintk("RPC:       BAD SPKM3 contextid len %d\n", ctxelen);
 		goto out;
 	}
 
@@ -251,7 +251,7 @@ spkm3_verify_mic_token(unsigned char **t
 	*/
 
 	if (*mic_hdrlen != 6 + ctxelen) {
-		dprintk("RPC: BAD SPKM_ MIC_TOK header len %d: we only support default int-alg (should be absent) and do not support snd-seq\n", *mic_hdrlen);
+		dprintk("RPC:       BAD SPKM_ MIC_TOK header len %d: we only support default int-alg (should be absent) and do not support snd-seq\n", *mic_hdrlen);
 		goto out;
 	}
 	/* checksum */
diff --git a/net/sunrpc/auth_gss/gss_spkm3_unseal.c b/net/sunrpc/auth_gss/gss_spkm3_unseal.c
index 8537f58..ec9484f 100644
--- a/net/sunrpc/auth_gss/gss_spkm3_unseal.c
+++ b/net/sunrpc/auth_gss/gss_spkm3_unseal.c
@@ -64,7 +64,7 @@ spkm3_read_token(struct spkm3_ctx *ctx,
 	int			mic_hdrlen;
 	u32			ret = GSS_S_DEFECTIVE_TOKEN;
 
-	dprintk("RPC: spkm3_read_token read_token->len %d\n", read_token->len);
+	dprintk("RPC:       spkm3_read_token read_token->len %d\n", read_token->len);
 
 	if (g_verify_token_header((struct xdr_netobj *) &ctx->mech_used,
 					&bodysize, &ptr, read_token->len))
@@ -78,7 +78,7 @@ spkm3_read_token(struct spkm3_ctx *ctx,
 			goto out;
 
 		if (*cksum++ != 0x03) {
-			dprintk("RPC: spkm3_read_token BAD checksum type\n");
+			dprintk("RPC:       spkm3_read_token BAD checksum type\n");
 			goto out;
 		}
 		md5elen = *cksum++; 
@@ -101,11 +101,11 @@ spkm3_read_token(struct spkm3_ctx *ctx,
 		if (code)
 			goto out;
 
-		dprintk("RPC: spkm3_read_token: digest wire_cksum.len %d:\n", 
+		dprintk("RPC:       spkm3_read_token: digest wire_cksum.len %d:\n",
 			wire_cksum.len);
-		dprintk("          md5cksum.data\n");
+		dprintk("           md5cksum.data\n");
 		print_hexl((u32 *) md5cksum.data, 16, 0);
-		dprintk("          cksum.data:\n");
+		dprintk("           cksum.data:\n");
 		print_hexl((u32 *) wire_cksum.data, wire_cksum.len, 0);
 
 		ret = GSS_S_BAD_SIG;
@@ -114,7 +114,7 @@ spkm3_read_token(struct spkm3_ctx *ctx,
 			goto out;
 
 	} else { 
-		dprintk("RPC: BAD or UNSUPPORTED SPKM3 token type: %d\n",toktype);
+		dprintk("RPC:       BAD or UNSUPPORTED SPKM3 token type: %d\n",toktype);
 		goto out;
 	}
 
diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index 1f0f079..a2cea13 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -671,13 +671,13 @@ gss_verify_header(struct svc_rqst *rqstp
 	}
 
 	if (gc->gc_seq > MAXSEQ) {
-		dprintk("RPC:      svcauth_gss: discarding request with large sequence number %d\n",
+		dprintk("RPC:       svcauth_gss: discarding request with large sequence number %d\n",
 				gc->gc_seq);
 		*authp = rpcsec_gsserr_ctxproblem;
 		return SVC_DENIED;
 	}
 	if (!gss_check_seq_num(rsci, gc->gc_seq)) {
-		dprintk("RPC:      svcauth_gss: discarding request with old sequence number %d\n",
+		dprintk("RPC:       svcauth_gss: discarding request with old sequence number %d\n",
 				gc->gc_seq);
 		return SVC_DROP;
 	}
@@ -960,7 +960,7 @@ svcauth_gss_accept(struct svc_rqst *rqst
 	__be32		*reject_stat = resv->iov_base + resv->iov_len;
 	int		ret;
 
-	dprintk("RPC:      svcauth_gss: argv->iov_len = %zd\n",argv->iov_len);
+	dprintk("RPC:       svcauth_gss: argv->iov_len = %zd\n",argv->iov_len);
 
 	*authp = rpc_autherr_badcred;
 	if (!svcdata)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
