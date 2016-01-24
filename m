Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:37884 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754266AbcAXNUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:20:31 -0500
Subject: [PATCH 23/26] iscsi-target: Use shash and ahash
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
Message-Id: <E1aNKa8-0008G2-88@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:52 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
either shash (for non-SG users) or ahash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/target/iscsi/iscsi_target.c       |   86 ++++++++++++++------------
 drivers/target/iscsi/iscsi_target_auth.c  |   98 +++++++++++-------------------
 drivers/target/iscsi/iscsi_target_login.c |   45 ++++++++-----
 include/target/iscsi/iscsi_target_core.h  |    4 -
 4 files changed, 113 insertions(+), 120 deletions(-)

diff --git a/drivers/target/iscsi/iscsi_target.c b/drivers/target/iscsi/iscsi_target.c
index 72204fb..866f3ad 100644
--- a/drivers/target/iscsi/iscsi_target.c
+++ b/drivers/target/iscsi/iscsi_target.c
@@ -16,9 +16,9 @@
  * GNU General Public License for more details.
  ******************************************************************************/
 
+#include <crypto/hash.h>
 #include <linux/string.h>
 #include <linux/kthread.h>
-#include <linux/crypto.h>
 #include <linux/completion.h>
 #include <linux/module.h>
 #include <linux/vmalloc.h>
@@ -1190,7 +1190,7 @@ iscsit_handle_scsi_cmd(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 }
 
 static u32 iscsit_do_crypto_hash_sg(
-	struct hash_desc *hash,
+	struct ahash_request *hash,
 	struct iscsi_cmd *cmd,
 	u32 data_offset,
 	u32 data_length,
@@ -1201,7 +1201,7 @@ static u32 iscsit_do_crypto_hash_sg(
 	struct scatterlist *sg;
 	unsigned int page_off;
 
-	crypto_hash_init(hash);
+	crypto_ahash_init(hash);
 
 	sg = cmd->first_data_sg;
 	page_off = cmd->first_data_sg_off;
@@ -1209,7 +1209,8 @@ static u32 iscsit_do_crypto_hash_sg(
 	while (data_length) {
 		u32 cur_len = min_t(u32, data_length, (sg->length - page_off));
 
-		crypto_hash_update(hash, sg, cur_len);
+		ahash_request_set_crypt(hash, sg, NULL, cur_len);
+		crypto_ahash_update(hash);
 
 		data_length -= cur_len;
 		page_off = 0;
@@ -1221,33 +1222,34 @@ static u32 iscsit_do_crypto_hash_sg(
 		struct scatterlist pad_sg;
 
 		sg_init_one(&pad_sg, pad_bytes, padding);
-		crypto_hash_update(hash, &pad_sg, padding);
+		ahash_request_set_crypt(hash, &pad_sg, (u8 *)&data_crc,
+					padding);
+		crypto_ahash_finup(hash);
+	} else {
+		ahash_request_set_crypt(hash, NULL, (u8 *)&data_crc, 0);
+		crypto_ahash_final(hash);
 	}
-	crypto_hash_final(hash, (u8 *) &data_crc);
 
 	return data_crc;
 }
 
 static void iscsit_do_crypto_hash_buf(
-	struct hash_desc *hash,
+	struct ahash_request *hash,
 	const void *buf,
 	u32 payload_length,
 	u32 padding,
 	u8 *pad_bytes,
 	u8 *data_crc)
 {
-	struct scatterlist sg;
+	struct scatterlist sg[2];
 
-	crypto_hash_init(hash);
+	sg_init_table(sg, ARRAY_SIZE(sg));
+	sg_set_buf(sg, buf, payload_length);
+	sg_set_buf(sg + 1, pad_bytes, padding);
 
-	sg_init_one(&sg, buf, payload_length);
-	crypto_hash_update(hash, &sg, payload_length);
+	ahash_request_set_crypt(hash, sg, data_crc, payload_length + padding);
 
-	if (padding) {
-		sg_init_one(&sg, pad_bytes, padding);
-		crypto_hash_update(hash, &sg, padding);
-	}
-	crypto_hash_final(hash, data_crc);
+	crypto_ahash_digest(hash);
 }
 
 int
@@ -1422,7 +1424,7 @@ iscsit_get_dataout(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 	if (conn->conn_ops->DataDigest) {
 		u32 data_crc;
 
-		data_crc = iscsit_do_crypto_hash_sg(&conn->conn_rx_hash, cmd,
+		data_crc = iscsit_do_crypto_hash_sg(conn->conn_rx_hash, cmd,
 						    be32_to_cpu(hdr->offset),
 						    payload_length, padding,
 						    cmd->pad_bytes);
@@ -1682,7 +1684,7 @@ static int iscsit_handle_nop_out(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 		}
 
 		if (conn->conn_ops->DataDigest) {
-			iscsit_do_crypto_hash_buf(&conn->conn_rx_hash,
+			iscsit_do_crypto_hash_buf(conn->conn_rx_hash,
 					ping_data, payload_length,
 					padding, cmd->pad_bytes,
 					(u8 *)&data_crc);
@@ -2101,7 +2103,7 @@ iscsit_handle_text_cmd(struct iscsi_conn *conn, struct iscsi_cmd *cmd,
 			goto reject;
 
 		if (conn->conn_ops->DataDigest) {
-			iscsit_do_crypto_hash_buf(&conn->conn_rx_hash,
+			iscsit_do_crypto_hash_buf(conn->conn_rx_hash,
 					text_in, payload_length,
 					padding, (u8 *)&pad_bytes,
 					(u8 *)&data_crc);
@@ -2440,7 +2442,7 @@ static int iscsit_handle_immediate_data(
 	if (conn->conn_ops->DataDigest) {
 		u32 data_crc;
 
-		data_crc = iscsit_do_crypto_hash_sg(&conn->conn_rx_hash, cmd,
+		data_crc = iscsit_do_crypto_hash_sg(conn->conn_rx_hash, cmd,
 						    cmd->write_data_done, length, padding,
 						    cmd->pad_bytes);
 
@@ -2553,7 +2555,7 @@ static int iscsit_send_conn_drop_async_message(
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		cmd->tx_size += ISCSI_CRC_LEN;
@@ -2683,7 +2685,7 @@ static int iscsit_send_datain(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, cmd->pdu,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, cmd->pdu,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -2711,7 +2713,7 @@ static int iscsit_send_datain(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 				cmd->padding);
 	}
 	if (conn->conn_ops->DataDigest) {
-		cmd->data_crc = iscsit_do_crypto_hash_sg(&conn->conn_tx_hash, cmd,
+		cmd->data_crc = iscsit_do_crypto_hash_sg(conn->conn_tx_hash, cmd,
 			 datain.offset, datain.length, cmd->padding, cmd->pad_bytes);
 
 		iov[iov_count].iov_base	= &cmd->data_crc;
@@ -2857,7 +2859,7 @@ iscsit_send_logout(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, &cmd->pdu[0],
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, &cmd->pdu[0],
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -2915,7 +2917,7 @@ static int iscsit_send_unsolicited_nopin(
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		tx_size += ISCSI_CRC_LEN;
@@ -2963,7 +2965,7 @@ iscsit_send_nopin(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -2993,7 +2995,7 @@ iscsit_send_nopin(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 				" padding bytes.\n", padding);
 		}
 		if (conn->conn_ops->DataDigest) {
-			iscsit_do_crypto_hash_buf(&conn->conn_tx_hash,
+			iscsit_do_crypto_hash_buf(conn->conn_tx_hash,
 				cmd->buf_ptr, cmd->buf_ptr_size,
 				padding, (u8 *)&cmd->pad_bytes,
 				(u8 *)&cmd->data_crc);
@@ -3049,7 +3051,7 @@ static int iscsit_send_r2t(
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		cmd->iov_misc[0].iov_len += ISCSI_CRC_LEN;
@@ -3239,7 +3241,7 @@ static int iscsit_send_response(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 		}
 
 		if (conn->conn_ops->DataDigest) {
-			iscsit_do_crypto_hash_buf(&conn->conn_tx_hash,
+			iscsit_do_crypto_hash_buf(conn->conn_tx_hash,
 				cmd->sense_buffer,
 				(cmd->se_cmd.scsi_sense_length + padding),
 				0, NULL, (u8 *)&cmd->data_crc);
@@ -3262,7 +3264,7 @@ static int iscsit_send_response(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, cmd->pdu,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, cmd->pdu,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -3332,7 +3334,7 @@ iscsit_send_task_mgt_rsp(struct iscsi_cmd *cmd, struct iscsi_conn *conn)
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		cmd->iov_misc[0].iov_len += ISCSI_CRC_LEN;
@@ -3601,7 +3603,7 @@ static int iscsit_send_text_rsp(
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -3611,7 +3613,7 @@ static int iscsit_send_text_rsp(
 	}
 
 	if (conn->conn_ops->DataDigest) {
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash,
 				cmd->buf_ptr, text_length,
 				0, NULL, (u8 *)&cmd->data_crc);
 
@@ -3668,7 +3670,7 @@ static int iscsit_send_reject(
 	if (conn->conn_ops->HeaderDigest) {
 		u32 *header_digest = (u32 *)&cmd->pdu[ISCSI_HDR_LEN];
 
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, hdr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, hdr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)header_digest);
 
 		iov[0].iov_len += ISCSI_CRC_LEN;
@@ -3678,7 +3680,7 @@ static int iscsit_send_reject(
 	}
 
 	if (conn->conn_ops->DataDigest) {
-		iscsit_do_crypto_hash_buf(&conn->conn_tx_hash, cmd->buf_ptr,
+		iscsit_do_crypto_hash_buf(conn->conn_tx_hash, cmd->buf_ptr,
 				ISCSI_HDR_LEN, 0, NULL, (u8 *)&cmd->data_crc);
 
 		iov[iov_count].iov_base = &cmd->data_crc;
@@ -4145,7 +4147,7 @@ int iscsi_target_rx_thread(void *arg)
 				goto transport_err;
 			}
 
-			iscsit_do_crypto_hash_buf(&conn->conn_rx_hash,
+			iscsit_do_crypto_hash_buf(conn->conn_rx_hash,
 					buffer, ISCSI_HDR_LEN,
 					0, NULL, (u8 *)&checksum);
 
@@ -4359,10 +4361,14 @@ int iscsit_close_connection(
 	 */
 	iscsit_check_conn_usage_count(conn);
 
-	if (conn->conn_rx_hash.tfm)
-		crypto_free_hash(conn->conn_rx_hash.tfm);
-	if (conn->conn_tx_hash.tfm)
-		crypto_free_hash(conn->conn_tx_hash.tfm);
+	ahash_request_free(conn->conn_tx_hash);
+	if (conn->conn_rx_hash) {
+		struct crypto_ahash *tfm;
+
+		tfm = crypto_ahash_reqtfm(conn->conn_rx_hash);
+		ahash_request_free(conn->conn_rx_hash);
+		crypto_free_ahash(tfm);
+	}
 
 	free_cpumask_var(conn->conn_cpumask);
 
diff --git a/drivers/target/iscsi/iscsi_target_auth.c b/drivers/target/iscsi/iscsi_target_auth.c
index 47e249d..667406f 100644
--- a/drivers/target/iscsi/iscsi_target_auth.c
+++ b/drivers/target/iscsi/iscsi_target_auth.c
@@ -16,9 +16,9 @@
  * GNU General Public License for more details.
  ******************************************************************************/
 
+#include <crypto/hash.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
-#include <linux/crypto.h>
 #include <linux/err.h>
 #include <linux/scatterlist.h>
 
@@ -185,9 +185,8 @@ static int chap_server_compute_md5(
 	unsigned char chap_n[MAX_CHAP_N_SIZE], chap_r[MAX_RESPONSE_LENGTH];
 	size_t compare_len;
 	struct iscsi_chap *chap = conn->auth_protocol;
-	struct crypto_hash *tfm;
-	struct hash_desc desc;
-	struct scatterlist sg;
+	struct crypto_shash *tfm = NULL;
+	struct shash_desc *desc = NULL;
 	int auth_ret = -1, ret, challenge_len;
 
 	memset(identifier, 0, 10);
@@ -245,52 +244,47 @@ static int chap_server_compute_md5(
 	pr_debug("[server] Got CHAP_R=%s\n", chap_r);
 	chap_string_to_hex(client_digest, chap_r, strlen(chap_r));
 
-	tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
+	tfm = crypto_alloc_shash("md5", 0, 0);
 	if (IS_ERR(tfm)) {
-		pr_err("Unable to allocate struct crypto_hash\n");
+		tfm = NULL;
+		pr_err("Unable to allocate struct crypto_shash\n");
 		goto out;
 	}
-	desc.tfm = tfm;
-	desc.flags = 0;
 
-	ret = crypto_hash_init(&desc);
-	if (ret < 0) {
-		pr_err("crypto_hash_init() failed\n");
-		crypto_free_hash(tfm);
+	desc = kmalloc(sizeof(*desc) + crypto_shash_descsize(tfm), GFP_KERNEL);
+	if (!desc) {
+		pr_err("Unable to allocate struct shash_desc\n");
 		goto out;
 	}
 
-	sg_init_one(&sg, &chap->id, 1);
-	ret = crypto_hash_update(&desc, &sg, 1);
+	desc->tfm = tfm;
+	desc->flags = 0;
+
+	ret = crypto_shash_init(desc);
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for id\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_init() failed\n");
 		goto out;
 	}
 
-	sg_init_one(&sg, &auth->password, strlen(auth->password));
-	ret = crypto_hash_update(&desc, &sg, strlen(auth->password));
+	ret = crypto_shash_update(desc, &chap->id, 1);
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for password\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_update() failed for id\n");
 		goto out;
 	}
 
-	sg_init_one(&sg, chap->challenge, CHAP_CHALLENGE_LENGTH);
-	ret = crypto_hash_update(&desc, &sg, CHAP_CHALLENGE_LENGTH);
+	ret = crypto_shash_update(desc, (char *)&auth->password,
+				  strlen(auth->password));
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for challenge\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_update() failed for password\n");
 		goto out;
 	}
 
-	ret = crypto_hash_final(&desc, server_digest);
+	ret = crypto_shash_finup(desc, chap->challenge,
+				 CHAP_CHALLENGE_LENGTH, server_digest);
 	if (ret < 0) {
-		pr_err("crypto_hash_final() failed for server digest\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_finup() failed for challenge\n");
 		goto out;
 	}
-	crypto_free_hash(tfm);
 
 	chap_binaryhex_to_asciihex(response, server_digest, MD5_SIGNATURE_SIZE);
 	pr_debug("[server] MD5 Server Digest: %s\n", response);
@@ -306,9 +300,8 @@ static int chap_server_compute_md5(
 	 * authentication is not enabled.
 	 */
 	if (!auth->authenticate_target) {
-		kfree(challenge);
-		kfree(challenge_binhex);
-		return 0;
+		auth_ret = 0;
+		goto out;
 	}
 	/*
 	 * Get CHAP_I.
@@ -372,58 +365,37 @@ static int chap_server_compute_md5(
 	/*
 	 * Generate CHAP_N and CHAP_R for mutual authentication.
 	 */
-	tfm = crypto_alloc_hash("md5", 0, CRYPTO_ALG_ASYNC);
-	if (IS_ERR(tfm)) {
-		pr_err("Unable to allocate struct crypto_hash\n");
-		goto out;
-	}
-	desc.tfm = tfm;
-	desc.flags = 0;
-
-	ret = crypto_hash_init(&desc);
+	ret = crypto_shash_init(desc);
 	if (ret < 0) {
-		pr_err("crypto_hash_init() failed\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_init() failed\n");
 		goto out;
 	}
 
 	/* To handle both endiannesses */
 	id_as_uchar = id;
-	sg_init_one(&sg, &id_as_uchar, 1);
-	ret = crypto_hash_update(&desc, &sg, 1);
+	ret = crypto_shash_update(desc, &id_as_uchar, 1);
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for id\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_update() failed for id\n");
 		goto out;
 	}
 
-	sg_init_one(&sg, auth->password_mutual,
-				strlen(auth->password_mutual));
-	ret = crypto_hash_update(&desc, &sg, strlen(auth->password_mutual));
+	ret = crypto_shash_update(desc, auth->password_mutual,
+				  strlen(auth->password_mutual));
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for"
+		pr_err("crypto_shash_update() failed for"
 				" password_mutual\n");
-		crypto_free_hash(tfm);
 		goto out;
 	}
 	/*
 	 * Convert received challenge to binary hex.
 	 */
-	sg_init_one(&sg, challenge_binhex, challenge_len);
-	ret = crypto_hash_update(&desc, &sg, challenge_len);
+	ret = crypto_shash_finup(desc, challenge_binhex, challenge_len,
+				 digest);
 	if (ret < 0) {
-		pr_err("crypto_hash_update() failed for ma challenge\n");
-		crypto_free_hash(tfm);
+		pr_err("crypto_shash_finup() failed for ma challenge\n");
 		goto out;
 	}
 
-	ret = crypto_hash_final(&desc, digest);
-	if (ret < 0) {
-		pr_err("crypto_hash_final() failed for ma digest\n");
-		crypto_free_hash(tfm);
-		goto out;
-	}
-	crypto_free_hash(tfm);
 	/*
 	 * Generate CHAP_N and CHAP_R.
 	 */
@@ -440,6 +412,8 @@ static int chap_server_compute_md5(
 	pr_debug("[server] Sending CHAP_R=0x%s\n", response);
 	auth_ret = 0;
 out:
+	kzfree(desc);
+	crypto_free_shash(tfm);
 	kfree(challenge);
 	kfree(challenge_binhex);
 	return auth_ret;
diff --git a/drivers/target/iscsi/iscsi_target_login.c b/drivers/target/iscsi/iscsi_target_login.c
index 96e78c8..8436d56 100644
--- a/drivers/target/iscsi/iscsi_target_login.c
+++ b/drivers/target/iscsi/iscsi_target_login.c
@@ -16,9 +16,9 @@
  * GNU General Public License for more details.
  ******************************************************************************/
 
+#include <crypto/hash.h>
 #include <linux/string.h>
 #include <linux/kthread.h>
-#include <linux/crypto.h>
 #include <linux/idr.h>
 #include <scsi/iscsi_proto.h>
 #include <target/target_core_base.h>
@@ -115,27 +115,36 @@ out_login:
  */
 int iscsi_login_setup_crypto(struct iscsi_conn *conn)
 {
+	struct crypto_ahash *tfm;
+
 	/*
 	 * Setup slicing by CRC32C algorithm for RX and TX libcrypto contexts
 	 * which will default to crc32c_intel.ko for cpu_has_xmm4_2, or fallback
 	 * to software 1x8 byte slicing from crc32c.ko
 	 */
-	conn->conn_rx_hash.flags = 0;
-	conn->conn_rx_hash.tfm = crypto_alloc_hash("crc32c", 0,
-						CRYPTO_ALG_ASYNC);
-	if (IS_ERR(conn->conn_rx_hash.tfm)) {
-		pr_err("crypto_alloc_hash() failed for conn_rx_tfm\n");
+	tfm = crypto_alloc_ahash("crc32c", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm)) {
+		pr_err("crypto_alloc_ahash() failed\n");
 		return -ENOMEM;
 	}
 
-	conn->conn_tx_hash.flags = 0;
-	conn->conn_tx_hash.tfm = crypto_alloc_hash("crc32c", 0,
-						CRYPTO_ALG_ASYNC);
-	if (IS_ERR(conn->conn_tx_hash.tfm)) {
-		pr_err("crypto_alloc_hash() failed for conn_tx_tfm\n");
-		crypto_free_hash(conn->conn_rx_hash.tfm);
+	conn->conn_rx_hash = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!conn->conn_rx_hash) {
+		pr_err("ahash_request_alloc() failed for conn_rx_hash\n");
+		crypto_free_ahash(tfm);
+		return -ENOMEM;
+	}
+	ahash_request_set_callback(conn->conn_rx_hash, 0, NULL, NULL);
+
+	conn->conn_tx_hash = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!conn->conn_tx_hash) {
+		pr_err("ahash_request_alloc() failed for conn_tx_hash\n");
+		ahash_request_free(conn->conn_rx_hash);
+		conn->conn_rx_hash = NULL;
+		crypto_free_ahash(tfm);
 		return -ENOMEM;
 	}
+	ahash_request_set_callback(conn->conn_tx_hash, 0, NULL, NULL);
 
 	return 0;
 }
@@ -1174,10 +1183,14 @@ old_sess_out:
 		iscsit_dec_session_usage_count(conn->sess);
 	}
 
-	if (!IS_ERR(conn->conn_rx_hash.tfm))
-		crypto_free_hash(conn->conn_rx_hash.tfm);
-	if (!IS_ERR(conn->conn_tx_hash.tfm))
-		crypto_free_hash(conn->conn_tx_hash.tfm);
+	ahash_request_free(conn->conn_tx_hash);
+	if (conn->conn_rx_hash) {
+		struct crypto_ahash *tfm;
+
+		tfm = crypto_ahash_reqtfm(conn->conn_rx_hash);
+		ahash_request_free(conn->conn_rx_hash);
+		crypto_free_ahash(tfm);
+	}
 
 	free_cpumask_var(conn->conn_cpumask);
 
diff --git a/include/target/iscsi/iscsi_target_core.h b/include/target/iscsi/iscsi_target_core.h
index 373d334..c3371fa 100644
--- a/include/target/iscsi/iscsi_target_core.h
+++ b/include/target/iscsi/iscsi_target_core.h
@@ -570,8 +570,8 @@ struct iscsi_conn {
 	spinlock_t		response_queue_lock;
 	spinlock_t		state_lock;
 	/* libcrypto RX and TX contexts for crc32c */
-	struct hash_desc	conn_rx_hash;
-	struct hash_desc	conn_tx_hash;
+	struct ahash_request	*conn_rx_hash;
+	struct ahash_request	*conn_tx_hash;
 	/* Used for scheduling TX and RX connection kthreads */
 	cpumask_var_t		conn_cpumask;
 	unsigned int		conn_rx_reset_cpumask:1;
