Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:50870 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932100AbcAXNUC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:20:02 -0500
Subject: [PATCH 20/26] drbd: Use shash and ahash
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
Message-Id: <E1aNKZd-0008FD-HQ@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:21 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
either shash (for non-SG users) or ahash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/block/drbd/drbd_int.h      |   16 +++++-----
 drivers/block/drbd/drbd_main.c     |   16 +++++-----
 drivers/block/drbd/drbd_nl.c       |   59 +++++++++++++++++++++++--------------
 drivers/block/drbd/drbd_receiver.c |   56 ++++++++++++++++-------------------
 drivers/block/drbd/drbd_worker.c   |   43 +++++++++++++++-----------
 5 files changed, 103 insertions(+), 87 deletions(-)

diff --git a/drivers/block/drbd/drbd_int.h b/drivers/block/drbd/drbd_int.h
index e66d453..686d955 100644
--- a/drivers/block/drbd/drbd_int.h
+++ b/drivers/block/drbd/drbd_int.h
@@ -26,13 +26,13 @@
 #ifndef _DRBD_INT_H
 #define _DRBD_INT_H
 
+#include <crypto/hash.h>
 #include <linux/compiler.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/sched.h>
 #include <linux/bitops.h>
 #include <linux/slab.h>
-#include <linux/crypto.h>
 #include <linux/ratelimit.h>
 #include <linux/tcp.h>
 #include <linux/mutex.h>
@@ -737,11 +737,11 @@ struct drbd_connection {
 
 	struct list_head transfer_log;	/* all requests not yet fully processed */
 
-	struct crypto_hash *cram_hmac_tfm;
-	struct crypto_hash *integrity_tfm;  /* checksums we compute, updates protected by connection->data->mutex */
-	struct crypto_hash *peer_integrity_tfm;  /* checksums we verify, only accessed from receiver thread  */
-	struct crypto_hash *csums_tfm;
-	struct crypto_hash *verify_tfm;
+	struct crypto_shash *cram_hmac_tfm;
+	struct crypto_ahash *integrity_tfm;  /* checksums we compute, updates protected by connection->data->mutex */
+	struct crypto_ahash *peer_integrity_tfm;  /* checksums we verify, only accessed from receiver thread  */
+	struct crypto_ahash *csums_tfm;
+	struct crypto_ahash *verify_tfm;
 	void *int_dig_in;
 	void *int_dig_vv;
 
@@ -1511,8 +1511,8 @@ static inline void ov_out_of_sync_print(struct drbd_device *device)
 }
 
 
-extern void drbd_csum_bio(struct crypto_hash *, struct bio *, void *);
-extern void drbd_csum_ee(struct crypto_hash *, struct drbd_peer_request *, void *);
+extern void drbd_csum_bio(struct crypto_ahash *, struct bio *, void *);
+extern void drbd_csum_ee(struct crypto_ahash *, struct drbd_peer_request *, void *);
 /* worker callbacks */
 extern int w_e_end_data_req(struct drbd_work *, int);
 extern int w_e_end_rsdata_req(struct drbd_work *, int);
diff --git a/drivers/block/drbd/drbd_main.c b/drivers/block/drbd/drbd_main.c
index 74d97f4..69ee808 100644
--- a/drivers/block/drbd/drbd_main.c
+++ b/drivers/block/drbd/drbd_main.c
@@ -1339,7 +1339,7 @@ void drbd_send_ack_dp(struct drbd_peer_device *peer_device, enum drbd_packet cmd
 		      struct p_data *dp, int data_size)
 {
 	if (peer_device->connection->peer_integrity_tfm)
-		data_size -= crypto_hash_digestsize(peer_device->connection->peer_integrity_tfm);
+		data_size -= crypto_ahash_digestsize(peer_device->connection->peer_integrity_tfm);
 	_drbd_send_ack(peer_device, cmd, dp->sector, cpu_to_be32(data_size),
 		       dp->block_id);
 }
@@ -1628,7 +1628,7 @@ int drbd_send_dblock(struct drbd_peer_device *peer_device, struct drbd_request *
 	sock = &peer_device->connection->data;
 	p = drbd_prepare_command(peer_device, sock);
 	digest_size = peer_device->connection->integrity_tfm ?
-		      crypto_hash_digestsize(peer_device->connection->integrity_tfm) : 0;
+		      crypto_ahash_digestsize(peer_device->connection->integrity_tfm) : 0;
 
 	if (!p)
 		return -EIO;
@@ -1717,7 +1717,7 @@ int drbd_send_block(struct drbd_peer_device *peer_device, enum drbd_packet cmd,
 	p = drbd_prepare_command(peer_device, sock);
 
 	digest_size = peer_device->connection->integrity_tfm ?
-		      crypto_hash_digestsize(peer_device->connection->integrity_tfm) : 0;
+		      crypto_ahash_digestsize(peer_device->connection->integrity_tfm) : 0;
 
 	if (!p)
 		return -EIO;
@@ -2506,11 +2506,11 @@ void conn_free_crypto(struct drbd_connection *connection)
 {
 	drbd_free_sock(connection);
 
-	crypto_free_hash(connection->csums_tfm);
-	crypto_free_hash(connection->verify_tfm);
-	crypto_free_hash(connection->cram_hmac_tfm);
-	crypto_free_hash(connection->integrity_tfm);
-	crypto_free_hash(connection->peer_integrity_tfm);
+	crypto_free_ahash(connection->csums_tfm);
+	crypto_free_ahash(connection->verify_tfm);
+	crypto_free_shash(connection->cram_hmac_tfm);
+	crypto_free_ahash(connection->integrity_tfm);
+	crypto_free_ahash(connection->peer_integrity_tfm);
 	kfree(connection->int_dig_in);
 	kfree(connection->int_dig_vv);
 
diff --git a/drivers/block/drbd/drbd_nl.c b/drivers/block/drbd/drbd_nl.c
index e80cbef..578f635 100644
--- a/drivers/block/drbd/drbd_nl.c
+++ b/drivers/block/drbd/drbd_nl.c
@@ -2065,19 +2065,34 @@ check_net_options(struct drbd_connection *connection, struct net_conf *new_net_c
 }
 
 struct crypto {
-	struct crypto_hash *verify_tfm;
-	struct crypto_hash *csums_tfm;
-	struct crypto_hash *cram_hmac_tfm;
-	struct crypto_hash *integrity_tfm;
+	struct crypto_ahash *verify_tfm;
+	struct crypto_ahash *csums_tfm;
+	struct crypto_shash *cram_hmac_tfm;
+	struct crypto_ahash *integrity_tfm;
 };
 
 static int
-alloc_hash(struct crypto_hash **tfm, char *tfm_name, int err_alg)
+alloc_shash(struct crypto_shash **tfm, char *tfm_name, int err_alg)
 {
 	if (!tfm_name[0])
 		return NO_ERROR;
 
-	*tfm = crypto_alloc_hash(tfm_name, 0, CRYPTO_ALG_ASYNC);
+	*tfm = crypto_alloc_shash(tfm_name, 0, 0);
+	if (IS_ERR(*tfm)) {
+		*tfm = NULL;
+		return err_alg;
+	}
+
+	return NO_ERROR;
+}
+
+static int
+alloc_ahash(struct crypto_ahash **tfm, char *tfm_name, int err_alg)
+{
+	if (!tfm_name[0])
+		return NO_ERROR;
+
+	*tfm = crypto_alloc_ahash(tfm_name, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(*tfm)) {
 		*tfm = NULL;
 		return err_alg;
@@ -2092,24 +2107,24 @@ alloc_crypto(struct crypto *crypto, struct net_conf *new_net_conf)
 	char hmac_name[CRYPTO_MAX_ALG_NAME];
 	enum drbd_ret_code rv;
 
-	rv = alloc_hash(&crypto->csums_tfm, new_net_conf->csums_alg,
-		       ERR_CSUMS_ALG);
+	rv = alloc_ahash(&crypto->csums_tfm, new_net_conf->csums_alg,
+			 ERR_CSUMS_ALG);
 	if (rv != NO_ERROR)
 		return rv;
-	rv = alloc_hash(&crypto->verify_tfm, new_net_conf->verify_alg,
-		       ERR_VERIFY_ALG);
+	rv = alloc_ahash(&crypto->verify_tfm, new_net_conf->verify_alg,
+			 ERR_VERIFY_ALG);
 	if (rv != NO_ERROR)
 		return rv;
-	rv = alloc_hash(&crypto->integrity_tfm, new_net_conf->integrity_alg,
-		       ERR_INTEGRITY_ALG);
+	rv = alloc_ahash(&crypto->integrity_tfm, new_net_conf->integrity_alg,
+			 ERR_INTEGRITY_ALG);
 	if (rv != NO_ERROR)
 		return rv;
 	if (new_net_conf->cram_hmac_alg[0] != 0) {
 		snprintf(hmac_name, CRYPTO_MAX_ALG_NAME, "hmac(%s)",
 			 new_net_conf->cram_hmac_alg);
 
-		rv = alloc_hash(&crypto->cram_hmac_tfm, hmac_name,
-			       ERR_AUTH_ALG);
+		rv = alloc_shash(&crypto->cram_hmac_tfm, hmac_name,
+				 ERR_AUTH_ALG);
 	}
 
 	return rv;
@@ -2117,10 +2132,10 @@ alloc_crypto(struct crypto *crypto, struct net_conf *new_net_conf)
 
 static void free_crypto(struct crypto *crypto)
 {
-	crypto_free_hash(crypto->cram_hmac_tfm);
-	crypto_free_hash(crypto->integrity_tfm);
-	crypto_free_hash(crypto->csums_tfm);
-	crypto_free_hash(crypto->verify_tfm);
+	crypto_free_shash(crypto->cram_hmac_tfm);
+	crypto_free_ahash(crypto->integrity_tfm);
+	crypto_free_ahash(crypto->csums_tfm);
+	crypto_free_ahash(crypto->verify_tfm);
 }
 
 int drbd_adm_net_opts(struct sk_buff *skb, struct genl_info *info)
@@ -2197,23 +2212,23 @@ int drbd_adm_net_opts(struct sk_buff *skb, struct genl_info *info)
 	rcu_assign_pointer(connection->net_conf, new_net_conf);
 
 	if (!rsr) {
-		crypto_free_hash(connection->csums_tfm);
+		crypto_free_ahash(connection->csums_tfm);
 		connection->csums_tfm = crypto.csums_tfm;
 		crypto.csums_tfm = NULL;
 	}
 	if (!ovr) {
-		crypto_free_hash(connection->verify_tfm);
+		crypto_free_ahash(connection->verify_tfm);
 		connection->verify_tfm = crypto.verify_tfm;
 		crypto.verify_tfm = NULL;
 	}
 
-	crypto_free_hash(connection->integrity_tfm);
+	crypto_free_ahash(connection->integrity_tfm);
 	connection->integrity_tfm = crypto.integrity_tfm;
 	if (connection->cstate >= C_WF_REPORT_PARAMS && connection->agreed_pro_version >= 100)
 		/* Do this without trying to take connection->data.mutex again.  */
 		__drbd_send_protocol(connection, P_PROTOCOL_UPDATE);
 
-	crypto_free_hash(connection->cram_hmac_tfm);
+	crypto_free_shash(connection->cram_hmac_tfm);
 	connection->cram_hmac_tfm = crypto.cram_hmac_tfm;
 
 	mutex_unlock(&connection->resource->conf_update);
diff --git a/drivers/block/drbd/drbd_receiver.c b/drivers/block/drbd/drbd_receiver.c
index b4b5680..d1f8559 100644
--- a/drivers/block/drbd/drbd_receiver.c
+++ b/drivers/block/drbd/drbd_receiver.c
@@ -1601,7 +1601,7 @@ read_in_block(struct drbd_peer_device *peer_device, u64 id, sector_t sector,
 
 	digest_size = 0;
 	if (!trim && peer_device->connection->peer_integrity_tfm) {
-		digest_size = crypto_hash_digestsize(peer_device->connection->peer_integrity_tfm);
+		digest_size = crypto_ahash_digestsize(peer_device->connection->peer_integrity_tfm);
 		/*
 		 * FIXME: Receive the incoming digest into the receive buffer
 		 *	  here, together with its struct p_data?
@@ -1715,7 +1715,7 @@ static int recv_dless_read(struct drbd_peer_device *peer_device, struct drbd_req
 
 	digest_size = 0;
 	if (peer_device->connection->peer_integrity_tfm) {
-		digest_size = crypto_hash_digestsize(peer_device->connection->peer_integrity_tfm);
+		digest_size = crypto_ahash_digestsize(peer_device->connection->peer_integrity_tfm);
 		err = drbd_recv_all_warn(peer_device->connection, dig_in, digest_size);
 		if (err)
 			return err;
@@ -3295,7 +3295,7 @@ static int receive_protocol(struct drbd_connection *connection, struct packet_in
 	int p_proto, p_discard_my_data, p_two_primaries, cf;
 	struct net_conf *nc, *old_net_conf, *new_net_conf = NULL;
 	char integrity_alg[SHARED_SECRET_MAX] = "";
-	struct crypto_hash *peer_integrity_tfm = NULL;
+	struct crypto_ahash *peer_integrity_tfm = NULL;
 	void *int_dig_in = NULL, *int_dig_vv = NULL;
 
 	p_proto		= be32_to_cpu(p->protocol);
@@ -3376,14 +3376,14 @@ static int receive_protocol(struct drbd_connection *connection, struct packet_in
 		 * change.
 		 */
 
-		peer_integrity_tfm = crypto_alloc_hash(integrity_alg, 0, CRYPTO_ALG_ASYNC);
+		peer_integrity_tfm = crypto_alloc_ahash(integrity_alg, 0, CRYPTO_ALG_ASYNC);
 		if (!peer_integrity_tfm) {
 			drbd_err(connection, "peer data-integrity-alg %s not supported\n",
 				 integrity_alg);
 			goto disconnect;
 		}
 
-		hash_size = crypto_hash_digestsize(peer_integrity_tfm);
+		hash_size = crypto_ahash_digestsize(peer_integrity_tfm);
 		int_dig_in = kmalloc(hash_size, GFP_KERNEL);
 		int_dig_vv = kmalloc(hash_size, GFP_KERNEL);
 		if (!(int_dig_in && int_dig_vv)) {
@@ -3413,7 +3413,7 @@ static int receive_protocol(struct drbd_connection *connection, struct packet_in
 	mutex_unlock(&connection->resource->conf_update);
 	mutex_unlock(&connection->data.mutex);
 
-	crypto_free_hash(connection->peer_integrity_tfm);
+	crypto_free_ahash(connection->peer_integrity_tfm);
 	kfree(connection->int_dig_in);
 	kfree(connection->int_dig_vv);
 	connection->peer_integrity_tfm = peer_integrity_tfm;
@@ -3431,7 +3431,7 @@ static int receive_protocol(struct drbd_connection *connection, struct packet_in
 disconnect_rcu_unlock:
 	rcu_read_unlock();
 disconnect:
-	crypto_free_hash(peer_integrity_tfm);
+	crypto_free_ahash(peer_integrity_tfm);
 	kfree(int_dig_in);
 	kfree(int_dig_vv);
 	conn_request_state(connection, NS(conn, C_DISCONNECTING), CS_HARD);
@@ -3443,15 +3443,15 @@ disconnect:
  * return: NULL (alg name was "")
  *         ERR_PTR(error) if something goes wrong
  *         or the crypto hash ptr, if it worked out ok. */
-static struct crypto_hash *drbd_crypto_alloc_digest_safe(const struct drbd_device *device,
+static struct crypto_ahash *drbd_crypto_alloc_digest_safe(const struct drbd_device *device,
 		const char *alg, const char *name)
 {
-	struct crypto_hash *tfm;
+	struct crypto_ahash *tfm;
 
 	if (!alg[0])
 		return NULL;
 
-	tfm = crypto_alloc_hash(alg, 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_ahash(alg, 0, CRYPTO_ALG_ASYNC);
 	if (IS_ERR(tfm)) {
 		drbd_err(device, "Can not allocate \"%s\" as %s (reason: %ld)\n",
 			alg, name, PTR_ERR(tfm));
@@ -3504,8 +3504,8 @@ static int receive_SyncParam(struct drbd_connection *connection, struct packet_i
 	struct drbd_device *device;
 	struct p_rs_param_95 *p;
 	unsigned int header_size, data_size, exp_max_sz;
-	struct crypto_hash *verify_tfm = NULL;
-	struct crypto_hash *csums_tfm = NULL;
+	struct crypto_ahash *verify_tfm = NULL;
+	struct crypto_ahash *csums_tfm = NULL;
 	struct net_conf *old_net_conf, *new_net_conf = NULL;
 	struct disk_conf *old_disk_conf = NULL, *new_disk_conf = NULL;
 	const int apv = connection->agreed_pro_version;
@@ -3652,14 +3652,14 @@ static int receive_SyncParam(struct drbd_connection *connection, struct packet_i
 			if (verify_tfm) {
 				strcpy(new_net_conf->verify_alg, p->verify_alg);
 				new_net_conf->verify_alg_len = strlen(p->verify_alg) + 1;
-				crypto_free_hash(peer_device->connection->verify_tfm);
+				crypto_free_ahash(peer_device->connection->verify_tfm);
 				peer_device->connection->verify_tfm = verify_tfm;
 				drbd_info(device, "using verify-alg: \"%s\"\n", p->verify_alg);
 			}
 			if (csums_tfm) {
 				strcpy(new_net_conf->csums_alg, p->csums_alg);
 				new_net_conf->csums_alg_len = strlen(p->csums_alg) + 1;
-				crypto_free_hash(peer_device->connection->csums_tfm);
+				crypto_free_ahash(peer_device->connection->csums_tfm);
 				peer_device->connection->csums_tfm = csums_tfm;
 				drbd_info(device, "using csums-alg: \"%s\"\n", p->csums_alg);
 			}
@@ -3703,9 +3703,9 @@ disconnect:
 	mutex_unlock(&connection->resource->conf_update);
 	/* just for completeness: actually not needed,
 	 * as this is not reached if csums_tfm was ok. */
-	crypto_free_hash(csums_tfm);
+	crypto_free_ahash(csums_tfm);
 	/* but free the verify_tfm again, if csums_tfm did not work out */
-	crypto_free_hash(verify_tfm);
+	crypto_free_ahash(verify_tfm);
 	conn_request_state(peer_device->connection, NS(conn, C_DISCONNECTING), CS_HARD);
 	return -EIO;
 }
@@ -4895,14 +4895,13 @@ static int drbd_do_auth(struct drbd_connection *connection)
 {
 	struct drbd_socket *sock;
 	char my_challenge[CHALLENGE_LEN];  /* 64 Bytes... */
-	struct scatterlist sg;
 	char *response = NULL;
 	char *right_response = NULL;
 	char *peers_ch = NULL;
 	unsigned int key_len;
 	char secret[SHARED_SECRET_MAX]; /* 64 byte */
 	unsigned int resp_size;
-	struct hash_desc desc;
+	SHASH_DESC_ON_STACK(desc, connection->cram_hmac_tfm);
 	struct packet_info pi;
 	struct net_conf *nc;
 	int err, rv;
@@ -4915,12 +4914,12 @@ static int drbd_do_auth(struct drbd_connection *connection)
 	memcpy(secret, nc->shared_secret, key_len);
 	rcu_read_unlock();
 
-	desc.tfm = connection->cram_hmac_tfm;
-	desc.flags = 0;
+	desc->tfm = connection->cram_hmac_tfm;
+	desc->flags = 0;
 
-	rv = crypto_hash_setkey(connection->cram_hmac_tfm, (u8 *)secret, key_len);
+	rv = crypto_shash_setkey(connection->cram_hmac_tfm, (u8 *)secret, key_len);
 	if (rv) {
-		drbd_err(connection, "crypto_hash_setkey() failed with %d\n", rv);
+		drbd_err(connection, "crypto_shash_setkey() failed with %d\n", rv);
 		rv = -1;
 		goto fail;
 	}
@@ -4981,7 +4980,7 @@ static int drbd_do_auth(struct drbd_connection *connection)
 		goto fail;
 	}
 
-	resp_size = crypto_hash_digestsize(connection->cram_hmac_tfm);
+	resp_size = crypto_shash_digestsize(connection->cram_hmac_tfm);
 	response = kmalloc(resp_size, GFP_NOIO);
 	if (response == NULL) {
 		drbd_err(connection, "kmalloc of response failed\n");
@@ -4989,10 +4988,7 @@ static int drbd_do_auth(struct drbd_connection *connection)
 		goto fail;
 	}
 
-	sg_init_table(&sg, 1);
-	sg_set_buf(&sg, peers_ch, pi.size);
-
-	rv = crypto_hash_digest(&desc, &sg, sg.length, response);
+	rv = crypto_shash_digest(desc, peers_ch, pi.size, response);
 	if (rv) {
 		drbd_err(connection, "crypto_hash_digest() failed with %d\n", rv);
 		rv = -1;
@@ -5040,9 +5036,8 @@ static int drbd_do_auth(struct drbd_connection *connection)
 		goto fail;
 	}
 
-	sg_set_buf(&sg, my_challenge, CHALLENGE_LEN);
-
-	rv = crypto_hash_digest(&desc, &sg, sg.length, right_response);
+	rv = crypto_shash_digest(desc, my_challenge, CHALLENGE_LEN,
+				 right_response);
 	if (rv) {
 		drbd_err(connection, "crypto_hash_digest() failed with %d\n", rv);
 		rv = -1;
@@ -5061,6 +5056,7 @@ static int drbd_do_auth(struct drbd_connection *connection)
 	kfree(peers_ch);
 	kfree(response);
 	kfree(right_response);
+	shash_desc_zero(desc);
 
 	return rv;
 }
diff --git a/drivers/block/drbd/drbd_worker.c b/drivers/block/drbd/drbd_worker.c
index 5578c14..426d4fc 100644
--- a/drivers/block/drbd/drbd_worker.c
+++ b/drivers/block/drbd/drbd_worker.c
@@ -269,51 +269,56 @@ void drbd_request_endio(struct bio *bio)
 		complete_master_bio(device, &m);
 }
 
-void drbd_csum_ee(struct crypto_hash *tfm, struct drbd_peer_request *peer_req, void *digest)
+void drbd_csum_ee(struct crypto_ahash *tfm, struct drbd_peer_request *peer_req, void *digest)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, tfm);
 	struct scatterlist sg;
 	struct page *page = peer_req->pages;
 	struct page *tmp;
 	unsigned len;
 
-	desc.tfm = tfm;
-	desc.flags = 0;
+	ahash_request_set_tfm(req, tfm);
+	ahash_request_set_callback(req, 0, NULL, NULL);
 
 	sg_init_table(&sg, 1);
-	crypto_hash_init(&desc);
+	crypto_ahash_init(req);
 
 	while ((tmp = page_chain_next(page))) {
 		/* all but the last page will be fully used */
 		sg_set_page(&sg, page, PAGE_SIZE, 0);
-		crypto_hash_update(&desc, &sg, sg.length);
+		ahash_request_set_crypt(req, &sg, NULL, sg.length);
+		crypto_ahash_update(req);
 		page = tmp;
 	}
 	/* and now the last, possibly only partially used page */
 	len = peer_req->i.size & (PAGE_SIZE - 1);
 	sg_set_page(&sg, page, len ?: PAGE_SIZE, 0);
-	crypto_hash_update(&desc, &sg, sg.length);
-	crypto_hash_final(&desc, digest);
+	ahash_request_set_crypt(req, &sg, digest, sg.length);
+	crypto_ahash_finup(req);
+	ahash_request_zero(req);
 }
 
-void drbd_csum_bio(struct crypto_hash *tfm, struct bio *bio, void *digest)
+void drbd_csum_bio(struct crypto_ahash *tfm, struct bio *bio, void *digest)
 {
-	struct hash_desc desc;
+	AHASH_REQUEST_ON_STACK(req, tfm);
 	struct scatterlist sg;
 	struct bio_vec bvec;
 	struct bvec_iter iter;
 
-	desc.tfm = tfm;
-	desc.flags = 0;
+	ahash_request_set_tfm(req, tfm);
+	ahash_request_set_callback(req, 0, NULL, NULL);
 
 	sg_init_table(&sg, 1);
-	crypto_hash_init(&desc);
+	crypto_ahash_init(req);
 
 	bio_for_each_segment(bvec, bio, iter) {
 		sg_set_page(&sg, bvec.bv_page, bvec.bv_len, bvec.bv_offset);
-		crypto_hash_update(&desc, &sg, sg.length);
+		ahash_request_set_crypt(req, &sg, NULL, sg.length);
+		crypto_ahash_update(req);
 	}
-	crypto_hash_final(&desc, digest);
+	ahash_request_set_crypt(req, NULL, digest, 0);
+	crypto_ahash_final(req);
+	ahash_request_zero(req);
 }
 
 /* MAYBE merge common code with w_e_end_ov_req */
@@ -332,7 +337,7 @@ static int w_e_send_csum(struct drbd_work *w, int cancel)
 	if (unlikely((peer_req->flags & EE_WAS_ERROR) != 0))
 		goto out;
 
-	digest_size = crypto_hash_digestsize(peer_device->connection->csums_tfm);
+	digest_size = crypto_ahash_digestsize(peer_device->connection->csums_tfm);
 	digest = kmalloc(digest_size, GFP_NOIO);
 	if (digest) {
 		sector_t sector = peer_req->i.sector;
@@ -1108,7 +1113,7 @@ int w_e_end_csum_rs_req(struct drbd_work *w, int cancel)
 		 * a real fix would be much more involved,
 		 * introducing more locking mechanisms */
 		if (peer_device->connection->csums_tfm) {
-			digest_size = crypto_hash_digestsize(peer_device->connection->csums_tfm);
+			digest_size = crypto_ahash_digestsize(peer_device->connection->csums_tfm);
 			D_ASSERT(device, digest_size == di->digest_size);
 			digest = kmalloc(digest_size, GFP_NOIO);
 		}
@@ -1158,7 +1163,7 @@ int w_e_end_ov_req(struct drbd_work *w, int cancel)
 	if (unlikely(cancel))
 		goto out;
 
-	digest_size = crypto_hash_digestsize(peer_device->connection->verify_tfm);
+	digest_size = crypto_ahash_digestsize(peer_device->connection->verify_tfm);
 	digest = kmalloc(digest_size, GFP_NOIO);
 	if (!digest) {
 		err = 1;	/* terminate the connection in case the allocation failed */
@@ -1230,7 +1235,7 @@ int w_e_end_ov_reply(struct drbd_work *w, int cancel)
 	di = peer_req->digest;
 
 	if (likely((peer_req->flags & EE_WAS_ERROR) == 0)) {
-		digest_size = crypto_hash_digestsize(peer_device->connection->verify_tfm);
+		digest_size = crypto_ahash_digestsize(peer_device->connection->verify_tfm);
 		digest = kmalloc(digest_size, GFP_NOIO);
 		if (digest) {
 			drbd_csum_ee(peer_device->connection->verify_tfm, peer_req, digest);
