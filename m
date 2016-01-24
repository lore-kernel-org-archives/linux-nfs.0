Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:38728 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755281AbcAXNTh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:19:37 -0500
Subject: [PATCH 18/26] rxrpc: Use skcipher
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
Message-Id: <E1aNKZJ-0008Ee-0B@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:01 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of blkcipher with skcipher.
   
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/rxrpc/ar-internal.h |    2 
 net/rxrpc/ar-key.c      |   12 +--
 net/rxrpc/rxkad.c       |  172 +++++++++++++++++++++++++++++-------------------
 3 files changed, 114 insertions(+), 72 deletions(-)

diff --git a/net/rxrpc/ar-internal.h b/net/rxrpc/ar-internal.h
index 2934a73..71598f5 100644
--- a/net/rxrpc/ar-internal.h
+++ b/net/rxrpc/ar-internal.h
@@ -252,7 +252,7 @@ struct rxrpc_connection {
 	struct rxrpc_security	*security;	/* applied security module */
 	struct key		*key;		/* security for this connection (client) */
 	struct key		*server_key;	/* security for this service */
-	struct crypto_blkcipher	*cipher;	/* encryption handle */
+	struct crypto_skcipher	*cipher;	/* encryption handle */
 	struct rxrpc_crypt	csum_iv;	/* packet checksum base */
 	unsigned long		events;
 #define RXRPC_CONN_CHALLENGE	0		/* send challenge packet */
diff --git a/net/rxrpc/ar-key.c b/net/rxrpc/ar-key.c
index 3f65716..3fb492e 100644
--- a/net/rxrpc/ar-key.c
+++ b/net/rxrpc/ar-key.c
@@ -12,11 +12,11 @@
  *	"afs@CAMBRIDGE.REDHAT.COM>
  */
 
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <linux/key-type.h>
-#include <linux/crypto.h>
 #include <linux/ctype.h>
 #include <linux/slab.h>
 #include <net/sock.h>
@@ -824,7 +824,7 @@ static void rxrpc_free_preparse(struct key_preparsed_payload *prep)
  */
 static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 {
-	struct crypto_blkcipher *ci;
+	struct crypto_skcipher *ci;
 
 	_enter("%zu", prep->datalen);
 
@@ -833,13 +833,13 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 
 	memcpy(&prep->payload.data[2], prep->data, 8);
 
-	ci = crypto_alloc_blkcipher("pcbc(des)", 0, CRYPTO_ALG_ASYNC);
+	ci = crypto_alloc_skcipher("pcbc(des)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ci)) {
 		_leave(" = %ld", PTR_ERR(ci));
 		return PTR_ERR(ci);
 	}
 
-	if (crypto_blkcipher_setkey(ci, prep->data, 8) < 0)
+	if (crypto_skcipher_setkey(ci, prep->data, 8) < 0)
 		BUG();
 
 	prep->payload.data[0] = ci;
@@ -853,7 +853,7 @@ static int rxrpc_preparse_s(struct key_preparsed_payload *prep)
 static void rxrpc_free_preparse_s(struct key_preparsed_payload *prep)
 {
 	if (prep->payload.data[0])
-		crypto_free_blkcipher(prep->payload.data[0]);
+		crypto_free_skcipher(prep->payload.data[0]);
 }
 
 /*
@@ -870,7 +870,7 @@ static void rxrpc_destroy(struct key *key)
 static void rxrpc_destroy_s(struct key *key)
 {
 	if (key->payload.data[0]) {
-		crypto_free_blkcipher(key->payload.data[0]);
+		crypto_free_skcipher(key->payload.data[0]);
 		key->payload.data[0] = NULL;
 	}
 }
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index d7a9ab5..0d96b48 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -9,11 +9,11 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#include <crypto/skcipher.h>
 #include <linux/module.h>
 #include <linux/net.h>
 #include <linux/skbuff.h>
 #include <linux/udp.h>
-#include <linux/crypto.h>
 #include <linux/scatterlist.h>
 #include <linux/ctype.h>
 #include <linux/slab.h>
@@ -53,7 +53,7 @@ MODULE_LICENSE("GPL");
  * alloc routine, but since we have it to hand, we use it to decrypt RESPONSE
  * packets
  */
-static struct crypto_blkcipher *rxkad_ci;
+static struct crypto_skcipher *rxkad_ci;
 static DEFINE_MUTEX(rxkad_ci_mutex);
 
 /*
@@ -61,7 +61,7 @@ static DEFINE_MUTEX(rxkad_ci_mutex);
  */
 static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 {
-	struct crypto_blkcipher *ci;
+	struct crypto_skcipher *ci;
 	struct rxrpc_key_token *token;
 	int ret;
 
@@ -70,15 +70,15 @@ static int rxkad_init_connection_security(struct rxrpc_connection *conn)
 	token = conn->key->payload.data[0];
 	conn->security_ix = token->security_index;
 
-	ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
+	ci = crypto_alloc_skcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(ci)) {
 		_debug("no cipher");
 		ret = PTR_ERR(ci);
 		goto error;
 	}
 
-	if (crypto_blkcipher_setkey(ci, token->kad->session_key,
-				    sizeof(token->kad->session_key)) < 0)
+	if (crypto_skcipher_setkey(ci, token->kad->session_key,
+				   sizeof(token->kad->session_key)) < 0)
 		BUG();
 
 	switch (conn->security_level) {
@@ -113,7 +113,7 @@ error:
 static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 {
 	struct rxrpc_key_token *token;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
 	struct scatterlist sg[2];
 	struct rxrpc_crypt iv;
 	struct {
@@ -128,10 +128,6 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 	token = conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
 
-	desc.tfm = conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
-
 	tmpbuf.x[0] = conn->epoch;
 	tmpbuf.x[1] = conn->cid;
 	tmpbuf.x[2] = 0;
@@ -139,7 +135,13 @@ static void rxkad_prime_packet_security(struct rxrpc_connection *conn)
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
-	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	skcipher_request_set_tfm(req, conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+
+	crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 
 	memcpy(&conn->csum_iv, &tmpbuf.x[2], sizeof(conn->csum_iv));
 	ASSERTCMP(conn->csum_iv.n[0], ==, tmpbuf.x[2]);
@@ -156,7 +158,7 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 				    void *sechdr)
 {
 	struct rxrpc_skb_priv *sp;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[2];
 	struct {
@@ -177,13 +179,16 @@ static int rxkad_secure_packet_auth(const struct rxrpc_call *call,
 
 	/* start the encryption afresh */
 	memset(&iv, 0, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
-	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+
+	crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 
 	memcpy(sechdr, &tmpbuf, sizeof(tmpbuf));
 
@@ -203,13 +208,14 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	struct rxkad_level2_hdr rxkhdr
 		__attribute__((aligned(8))); /* must be all on one page */
 	struct rxrpc_skb_priv *sp;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[16];
 	struct sk_buff *trailer;
 	unsigned int len;
 	u16 check;
 	int nsg;
+	int err;
 
 	sp = rxrpc_skb(skb);
 
@@ -223,28 +229,38 @@ static int rxkad_secure_packet_encrypt(const struct rxrpc_call *call,
 	/* encrypt from the session key */
 	token = call->conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	sg_init_one(&sg[0], sechdr, sizeof(rxkhdr));
 	sg_init_one(&sg[1], &rxkhdr, sizeof(rxkhdr));
-	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(rxkhdr));
+
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(rxkhdr), iv.x);
+
+	crypto_skcipher_encrypt(req);
 
 	/* we want to encrypt the skbuff in-place */
 	nsg = skb_cow_data(skb, 0, &trailer);
+	err = -ENOMEM;
 	if (nsg < 0 || nsg > 16)
-		return -ENOMEM;
+		goto out;
 
 	len = data_size + call->conn->size_align - 1;
 	len &= ~(call->conn->size_align - 1);
 
 	sg_init_table(sg, nsg);
 	skb_to_sgvec(skb, sg, 0, len);
-	crypto_blkcipher_encrypt_iv(&desc, sg, sg, len);
+
+	skcipher_request_set_crypt(req, sg, sg, len, iv.x);
+
+	crypto_skcipher_encrypt(req);
 
 	_leave(" = 0");
-	return 0;
+	err = 0;
+
+out:
+	skcipher_request_zero(req);
+	return err;
 }
 
 /*
@@ -256,7 +272,7 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 				void *sechdr)
 {
 	struct rxrpc_skb_priv *sp;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[2];
 	struct {
@@ -281,9 +297,6 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	/* calculate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
@@ -293,7 +306,13 @@ static int rxkad_secure_packet(const struct rxrpc_call *call,
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
-	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+
+	crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 
 	y = ntohl(tmpbuf.x[1]);
 	y = (y >> 16) & 0xffff;
@@ -330,7 +349,7 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 {
 	struct rxkad_level1_hdr sechdr;
 	struct rxrpc_skb_priv *sp;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[16];
 	struct sk_buff *trailer;
@@ -352,11 +371,13 @@ static int rxkad_verify_packet_auth(const struct rxrpc_call *call,
 
 	/* start the decryption afresh */
 	memset(&iv, 0, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
-	crypto_blkcipher_decrypt_iv(&desc, sg, sg, 8);
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, 8, iv.x);
+
+	crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
 
 	/* remove the decrypted packet length */
 	if (skb_copy_bits(skb, 0, &sechdr, sizeof(sechdr)) < 0)
@@ -405,7 +426,7 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	const struct rxrpc_key_token *token;
 	struct rxkad_level2_hdr sechdr;
 	struct rxrpc_skb_priv *sp;
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist _sg[4], *sg;
 	struct sk_buff *trailer;
@@ -435,11 +456,13 @@ static int rxkad_verify_packet_encrypt(const struct rxrpc_call *call,
 	/* decrypt from the session key */
 	token = call->conn->key->payload.data[0];
 	memcpy(&iv, token->kad->session_key, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
-	crypto_blkcipher_decrypt_iv(&desc, sg, sg, skb->len);
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, skb->len, iv.x);
+
+	crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
 	if (sg != _sg)
 		kfree(sg);
 
@@ -487,7 +510,7 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 			       struct sk_buff *skb,
 			       u32 *_abort_code)
 {
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, call->conn->cipher);
 	struct rxrpc_skb_priv *sp;
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[2];
@@ -516,9 +539,6 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, call->conn->csum_iv.x, sizeof(iv));
-	desc.tfm = call->conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	/* validate the security checksum */
 	x = htonl(call->channel << (32 - RXRPC_CIDSHIFT));
@@ -528,7 +548,13 @@ static int rxkad_verify_packet(const struct rxrpc_call *call,
 
 	sg_init_one(&sg[0], &tmpbuf, sizeof(tmpbuf));
 	sg_init_one(&sg[1], &tmpbuf, sizeof(tmpbuf));
-	crypto_blkcipher_encrypt_iv(&desc, &sg[0], &sg[1], sizeof(tmpbuf));
+
+	skcipher_request_set_tfm(req, call->conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, &sg[1], &sg[0], sizeof(tmpbuf), iv.x);
+
+	crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 
 	y = ntohl(tmpbuf.x[1]);
 	y = (y >> 16) & 0xffff;
@@ -718,18 +744,21 @@ static void rxkad_encrypt_response(struct rxrpc_connection *conn,
 				   struct rxkad_response *resp,
 				   const struct rxkad_key *s2)
 {
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, conn->cipher);
 	struct rxrpc_crypt iv;
 	struct scatterlist sg[2];
 
 	/* continue encrypting from where we left off */
 	memcpy(&iv, s2->session_key, sizeof(iv));
-	desc.tfm = conn->cipher;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
-	crypto_blkcipher_encrypt_iv(&desc, sg, sg, sizeof(resp->encrypted));
+
+	skcipher_request_set_tfm(req, conn->cipher);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, sizeof(resp->encrypted), iv.x);
+
+	crypto_skcipher_encrypt(req);
+	skcipher_request_zero(req);
 }
 
 /*
@@ -822,7 +851,7 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 				time_t *_expiry,
 				u32 *_abort_code)
 {
-	struct blkcipher_desc desc;
+	struct skcipher_request *req;
 	struct rxrpc_crypt iv, key;
 	struct scatterlist sg[1];
 	struct in_addr addr;
@@ -853,12 +882,21 @@ static int rxkad_decrypt_ticket(struct rxrpc_connection *conn,
 
 	memcpy(&iv, &conn->server_key->payload.data[2], sizeof(iv));
 
-	desc.tfm = conn->server_key->payload.data[0];
-	desc.info = iv.x;
-	desc.flags = 0;
+	req = skcipher_request_alloc(conn->server_key->payload.data[0],
+				     GFP_NOFS);
+	if (!req) {
+		*_abort_code = RXKADNOAUTH;
+		ret = -ENOMEM;
+		goto error;
+	}
 
 	sg_init_one(&sg[0], ticket, ticket_len);
-	crypto_blkcipher_decrypt_iv(&desc, sg, sg, ticket_len);
+
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, ticket_len, iv.x);
+
+	crypto_skcipher_decrypt(req);
+	skcipher_request_free(req);
 
 	p = ticket;
 	end = p + ticket_len;
@@ -966,7 +1004,7 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 				   struct rxkad_response *resp,
 				   const struct rxrpc_crypt *session_key)
 {
-	struct blkcipher_desc desc;
+	SKCIPHER_REQUEST_ON_STACK(req, rxkad_ci);
 	struct scatterlist sg[2];
 	struct rxrpc_crypt iv;
 
@@ -976,17 +1014,21 @@ static void rxkad_decrypt_response(struct rxrpc_connection *conn,
 	ASSERT(rxkad_ci != NULL);
 
 	mutex_lock(&rxkad_ci_mutex);
-	if (crypto_blkcipher_setkey(rxkad_ci, session_key->x,
-				    sizeof(*session_key)) < 0)
+	if (crypto_skcipher_setkey(rxkad_ci, session_key->x,
+				   sizeof(*session_key)) < 0)
 		BUG();
 
 	memcpy(&iv, session_key, sizeof(iv));
-	desc.tfm = rxkad_ci;
-	desc.info = iv.x;
-	desc.flags = 0;
 
 	rxkad_sg_set_buf2(sg, &resp->encrypted, sizeof(resp->encrypted));
-	crypto_blkcipher_decrypt_iv(&desc, sg, sg, sizeof(resp->encrypted));
+
+	skcipher_request_set_tfm(req, rxkad_ci);
+	skcipher_request_set_callback(req, 0, NULL, NULL);
+	skcipher_request_set_crypt(req, sg, sg, sizeof(resp->encrypted), iv.x);
+
+	crypto_skcipher_decrypt(req);
+	skcipher_request_zero(req);
+
 	mutex_unlock(&rxkad_ci_mutex);
 
 	_leave("");
@@ -1115,7 +1157,7 @@ static void rxkad_clear(struct rxrpc_connection *conn)
 	_enter("");
 
 	if (conn->cipher)
-		crypto_free_blkcipher(conn->cipher);
+		crypto_free_skcipher(conn->cipher);
 }
 
 /*
@@ -1141,7 +1183,7 @@ static __init int rxkad_init(void)
 
 	/* pin the cipher we need so that the crypto layer doesn't invoke
 	 * keventd to go get it */
-	rxkad_ci = crypto_alloc_blkcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
+	rxkad_ci = crypto_alloc_skcipher("pcbc(fcrypt)", 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(rxkad_ci))
 		return PTR_ERR(rxkad_ci);
 
@@ -1155,7 +1197,7 @@ static __exit void rxkad_exit(void)
 	_enter("");
 
 	rxrpc_unregister_security(&rxkad);
-	crypto_free_blkcipher(rxkad_ci);
+	crypto_free_skcipher(rxkad_ci);
 }
 
 module_exit(rxkad_exit);
