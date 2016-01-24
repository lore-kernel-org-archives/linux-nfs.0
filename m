Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:34112 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932230AbcAXNUv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:20:51 -0500
Subject: [PATCH 25/26] sctp: Use shash
References: <20160124131021.GA31153@gondor.apana.org.au>
To: Linux Crypto Mailing List <linux-crypto@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@vger.kernel.org, devel@driverdev.osuosl.org,
        dm-devel@redhat.com, linux-wireless@vger.kernel.org,
        linux-cifs@vger.kernel.org, ecryptfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
        linux-bluetooth@vger.kernel.org, ceph-devel@vger.kernel.org,
        linux-wpan@vger.kernel.org, linux-afs@lists.infradead.org,
        drbd-dev@lists.linbit.com, open-iscsi@googlegroups.com
Message-Id: <E1aNKaS-0008Gn-Rz@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:20:12 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
shash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/sctp/auth.h    |    4 +--
 include/net/sctp/structs.h |    6 ++---
 net/sctp/auth.c            |   36 ++++++++++++++++---------------
 net/sctp/endpointola.c     |    1 
 net/sctp/sm_make_chunk.c   |   51 +++++++++++++++++++++++++--------------------
 net/sctp/socket.c          |    8 +++----
 6 files changed, 57 insertions(+), 49 deletions(-)

diff --git a/include/net/sctp/auth.h b/include/net/sctp/auth.h
index f2d58aa..9b9fb12 100644
--- a/include/net/sctp/auth.h
+++ b/include/net/sctp/auth.h
@@ -31,12 +31,12 @@
 #define __sctp_auth_h__
 
 #include <linux/list.h>
-#include <linux/crypto.h>
 
 struct sctp_endpoint;
 struct sctp_association;
 struct sctp_authkey;
 struct sctp_hmacalgo;
+struct crypto_shash;
 
 /*
  * Define a generic struct that will hold all the info
@@ -90,7 +90,7 @@ int sctp_auth_asoc_copy_shkeys(const struct sctp_endpoint *ep,
 				struct sctp_association *asoc,
 				gfp_t gfp);
 int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp);
-void sctp_auth_destroy_hmacs(struct crypto_hash *auth_hmacs[]);
+void sctp_auth_destroy_hmacs(struct crypto_shash *auth_hmacs[]);
 struct sctp_hmac *sctp_auth_get_hmac(__u16 hmac_id);
 struct sctp_hmac *sctp_auth_asoc_get_hmac(const struct sctp_association *asoc);
 void sctp_auth_asoc_set_default_hmac(struct sctp_association *asoc,
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index 20e7212..6b1e383 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -82,7 +82,7 @@ struct sctp_bind_addr;
 struct sctp_ulpq;
 struct sctp_ep_common;
 struct sctp_ssnmap;
-struct crypto_hash;
+struct crypto_shash;
 
 
 #include <net/sctp/tsnmap.h>
@@ -166,7 +166,7 @@ struct sctp_sock {
 	struct sctp_pf *pf;
 
 	/* Access to HMAC transform. */
-	struct crypto_hash *hmac;
+	struct crypto_shash *hmac;
 	char *sctp_hmac_alg;
 
 	/* What is our base endpointer? */
@@ -1235,7 +1235,7 @@ struct sctp_endpoint {
 	/* SCTP AUTH: array of the HMACs that will be allocated
 	 * we need this per association so that we don't serialize
 	 */
-	struct crypto_hash **auth_hmacs;
+	struct crypto_shash **auth_hmacs;
 
 	/* SCTP-AUTH: hmacs for the endpoint encoded into parameter */
 	 struct sctp_hmac_algo_param *auth_hmacs_list;
diff --git a/net/sctp/auth.c b/net/sctp/auth.c
index 1543e39..912eb16 100644
--- a/net/sctp/auth.c
+++ b/net/sctp/auth.c
@@ -27,9 +27,9 @@
  *   Vlad Yasevich     <vladislav.yasevich@hp.com>
  */
 
+#include <crypto/hash.h>
 #include <linux/slab.h>
 #include <linux/types.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <net/sctp/sctp.h>
 #include <net/sctp/auth.h>
@@ -448,7 +448,7 @@ struct sctp_shared_key *sctp_auth_get_shkey(
  */
 int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
 {
-	struct crypto_hash *tfm = NULL;
+	struct crypto_shash *tfm = NULL;
 	__u16   id;
 
 	/* If AUTH extension is disabled, we are done */
@@ -462,9 +462,8 @@ int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
 		return 0;
 
 	/* Allocated the array of pointers to transorms */
-	ep->auth_hmacs = kzalloc(
-			    sizeof(struct crypto_hash *) * SCTP_AUTH_NUM_HMACS,
-			    gfp);
+	ep->auth_hmacs = kzalloc(sizeof(struct crypto_shash *) *
+				 SCTP_AUTH_NUM_HMACS, gfp);
 	if (!ep->auth_hmacs)
 		return -ENOMEM;
 
@@ -483,8 +482,7 @@ int sctp_auth_init_hmacs(struct sctp_endpoint *ep, gfp_t gfp)
 			continue;
 
 		/* Allocate the ID */
-		tfm = crypto_alloc_hash(sctp_hmac_list[id].hmac_name, 0,
-					CRYPTO_ALG_ASYNC);
+		tfm = crypto_alloc_shash(sctp_hmac_list[id].hmac_name, 0, 0);
 		if (IS_ERR(tfm))
 			goto out_err;
 
@@ -500,7 +498,7 @@ out_err:
 }
 
 /* Destroy the hmac tfm array */
-void sctp_auth_destroy_hmacs(struct crypto_hash *auth_hmacs[])
+void sctp_auth_destroy_hmacs(struct crypto_shash *auth_hmacs[])
 {
 	int i;
 
@@ -508,8 +506,7 @@ void sctp_auth_destroy_hmacs(struct crypto_hash *auth_hmacs[])
 		return;
 
 	for (i = 0; i < SCTP_AUTH_NUM_HMACS; i++) {
-		if (auth_hmacs[i])
-			crypto_free_hash(auth_hmacs[i]);
+		crypto_free_shash(auth_hmacs[i]);
 	}
 	kfree(auth_hmacs);
 }
@@ -709,8 +706,7 @@ void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
 			      struct sctp_auth_chunk *auth,
 			      gfp_t gfp)
 {
-	struct scatterlist sg;
-	struct hash_desc desc;
+	struct crypto_shash *tfm;
 	struct sctp_auth_bytes *asoc_key;
 	__u16 key_id, hmac_id;
 	__u8 *digest;
@@ -742,16 +738,22 @@ void sctp_auth_calculate_hmac(const struct sctp_association *asoc,
 
 	/* set up scatter list */
 	end = skb_tail_pointer(skb);
-	sg_init_one(&sg, auth, end - (unsigned char *)auth);
 
-	desc.tfm = asoc->ep->auth_hmacs[hmac_id];
-	desc.flags = 0;
+	tfm = asoc->ep->auth_hmacs[hmac_id];
 
 	digest = auth->auth_hdr.hmac;
-	if (crypto_hash_setkey(desc.tfm, &asoc_key->data[0], asoc_key->len))
+	if (crypto_shash_setkey(tfm, &asoc_key->data[0], asoc_key->len))
 		goto free;
 
-	crypto_hash_digest(&desc, &sg, sg.length, digest);
+	{
+		SHASH_DESC_ON_STACK(desc, tfm);
+
+		desc->tfm = tfm;
+		desc->flags = 0;
+		crypto_shash_digest(desc, (u8 *)auth,
+				    end - (unsigned char *)auth, digest);
+		shash_desc_zero(desc);
+	}
 
 free:
 	if (free_key)
diff --git a/net/sctp/endpointola.c b/net/sctp/endpointola.c
index 2522a61..9d494e3 100644
--- a/net/sctp/endpointola.c
+++ b/net/sctp/endpointola.c
@@ -42,7 +42,6 @@
 #include <linux/slab.h>
 #include <linux/in.h>
 #include <linux/random.h>	/* get_random_bytes() */
-#include <linux/crypto.h>
 #include <net/sock.h>
 #include <net/ipv6.h>
 #include <net/sctp/sctp.h>
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 5d6a03f..1296e55 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -45,6 +45,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <crypto/hash.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/ip.h>
@@ -52,7 +53,6 @@
 #include <linux/net.h>
 #include <linux/inet.h>
 #include <linux/scatterlist.h>
-#include <linux/crypto.h>
 #include <linux/slab.h>
 #include <net/sock.h>
 
@@ -1606,7 +1606,6 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 {
 	sctp_cookie_param_t *retval;
 	struct sctp_signed_cookie *cookie;
-	struct scatterlist sg;
 	int headersize, bodysize;
 
 	/* Header size is static data prior to the actual cookie, including
@@ -1663,16 +1662,19 @@ static sctp_cookie_param_t *sctp_pack_cookie(const struct sctp_endpoint *ep,
 	       ntohs(init_chunk->chunk_hdr->length), raw_addrs, addrs_len);
 
 	if (sctp_sk(ep->base.sk)->hmac) {
-		struct hash_desc desc;
+		SHASH_DESC_ON_STACK(desc, sctp_sk(ep->base.sk)->hmac);
+		int err;
 
 		/* Sign the message.  */
-		sg_init_one(&sg, &cookie->c, bodysize);
-		desc.tfm = sctp_sk(ep->base.sk)->hmac;
-		desc.flags = 0;
-
-		if (crypto_hash_setkey(desc.tfm, ep->secret_key,
-				       sizeof(ep->secret_key)) ||
-		    crypto_hash_digest(&desc, &sg, bodysize, cookie->signature))
+		desc->tfm = sctp_sk(ep->base.sk)->hmac;
+		desc->flags = 0;
+
+		err = crypto_shash_setkey(desc->tfm, ep->secret_key,
+					  sizeof(ep->secret_key)) ?:
+		      crypto_shash_digest(desc, (u8 *)&cookie->c, bodysize,
+					  cookie->signature);
+		shash_desc_zero(desc);
+		if (err)
 			goto free_cookie;
 	}
 
@@ -1697,12 +1699,10 @@ struct sctp_association *sctp_unpack_cookie(
 	struct sctp_cookie *bear_cookie;
 	int headersize, bodysize, fixed_size;
 	__u8 *digest = ep->digest;
-	struct scatterlist sg;
 	unsigned int len;
 	sctp_scope_t scope;
 	struct sk_buff *skb = chunk->skb;
 	ktime_t kt;
-	struct hash_desc desc;
 
 	/* Header size is static data prior to the actual cookie, including
 	 * any padding.
@@ -1733,16 +1733,23 @@ struct sctp_association *sctp_unpack_cookie(
 		goto no_hmac;
 
 	/* Check the signature.  */
-	sg_init_one(&sg, bear_cookie, bodysize);
-	desc.tfm = sctp_sk(ep->base.sk)->hmac;
-	desc.flags = 0;
-
-	memset(digest, 0x00, SCTP_SIGNATURE_SIZE);
-	if (crypto_hash_setkey(desc.tfm, ep->secret_key,
-			       sizeof(ep->secret_key)) ||
-	    crypto_hash_digest(&desc, &sg, bodysize, digest)) {
-		*error = -SCTP_IERROR_NOMEM;
-		goto fail;
+	{
+		SHASH_DESC_ON_STACK(desc, sctp_sk(ep->base.sk)->hmac);
+		int err;
+
+		desc->tfm = sctp_sk(ep->base.sk)->hmac;
+		desc->flags = 0;
+
+		err = crypto_shash_setkey(desc->tfm, ep->secret_key,
+					  sizeof(ep->secret_key)) ?:
+		      crypto_shash_digest(desc, (u8 *)bear_cookie, bodysize,
+					  digest);
+		shash_desc_zero(desc);
+
+		if (err) {
+			*error = -SCTP_IERROR_NOMEM;
+			goto fail;
+		}
 	}
 
 	if (memcmp(digest, cookie->signature, SCTP_SIGNATURE_SIZE)) {
diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index 9bb80ec..4101c5b 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -52,6 +52,7 @@
 
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
+#include <crypto/hash.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/wait.h>
@@ -61,7 +62,6 @@
 #include <linux/fcntl.h>
 #include <linux/poll.h>
 #include <linux/init.h>
-#include <linux/crypto.h>
 #include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/compat.h>
@@ -4160,7 +4160,7 @@ static void sctp_destruct_sock(struct sock *sk)
 	struct sctp_sock *sp = sctp_sk(sk);
 
 	/* Free up the HMAC transform. */
-	crypto_free_hash(sp->hmac);
+	crypto_free_shash(sp->hmac);
 
 	inet_sock_destruct(sk);
 }
@@ -6299,13 +6299,13 @@ static int sctp_listen_start(struct sock *sk, int backlog)
 {
 	struct sctp_sock *sp = sctp_sk(sk);
 	struct sctp_endpoint *ep = sp->ep;
-	struct crypto_hash *tfm = NULL;
+	struct crypto_shash *tfm = NULL;
 	char alg[32];
 
 	/* Allocate HMAC for generating cookie. */
 	if (!sp->hmac && sp->sctp_hmac_alg) {
 		sprintf(alg, "hmac(%s)", sp->sctp_hmac_alg);
-		tfm = crypto_alloc_hash(alg, 0, CRYPTO_ALG_ASYNC);
+		tfm = crypto_alloc_shash(alg, 0, 0);
 		if (IS_ERR(tfm)) {
 			net_info_ratelimited("failed to load transform for %s: %ld\n",
 					     sp->sctp_hmac_alg, PTR_ERR(tfm));
