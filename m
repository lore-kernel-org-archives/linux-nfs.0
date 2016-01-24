Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from helcar.hengli.com.au ([209.40.204.226]:60696 "EHLO
	helcar.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbcAXNUV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Jan 2016 08:20:21 -0500
Subject: [PATCH 22/26] iscsi_tcp: Use ahash
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
Message-Id: <E1aNKZy-0008Fl-01@gondolin.me.apana.org.au>
From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 24 Jan 2016 21:19:41 +0800
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch replaces uses of the long obsolete hash interface with
ahash.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 drivers/scsi/iscsi_tcp.c    |   54 ++++++++++++++++++++++++++------------------
 drivers/scsi/iscsi_tcp.h    |    4 +--
 drivers/scsi/libiscsi_tcp.c |   29 +++++++++++++----------
 include/scsi/libiscsi_tcp.h |   13 +++++-----
 4 files changed, 58 insertions(+), 42 deletions(-)

diff --git a/drivers/scsi/iscsi_tcp.c b/drivers/scsi/iscsi_tcp.c
index 0b8af18..2e4c82f 100644
--- a/drivers/scsi/iscsi_tcp.c
+++ b/drivers/scsi/iscsi_tcp.c
@@ -26,12 +26,12 @@
  *	Zhenyu Wang
  */
 
+#include <crypto/hash.h>
 #include <linux/types.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/blkdev.h>
-#include <linux/crypto.h>
 #include <linux/delay.h>
 #include <linux/kfifo.h>
 #include <linux/scatterlist.h>
@@ -428,7 +428,7 @@ static void iscsi_sw_tcp_send_hdr_prep(struct iscsi_conn *conn, void *hdr,
 	 * sufficient room.
 	 */
 	if (conn->hdrdgst_en) {
-		iscsi_tcp_dgst_header(&tcp_sw_conn->tx_hash, hdr, hdrlen,
+		iscsi_tcp_dgst_header(tcp_sw_conn->tx_hash, hdr, hdrlen,
 				      hdr + hdrlen);
 		hdrlen += ISCSI_DIGEST_SIZE;
 	}
@@ -454,7 +454,7 @@ iscsi_sw_tcp_send_data_prep(struct iscsi_conn *conn, struct scatterlist *sg,
 {
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 	struct iscsi_sw_tcp_conn *tcp_sw_conn = tcp_conn->dd_data;
-	struct hash_desc *tx_hash = NULL;
+	struct ahash_request *tx_hash = NULL;
 	unsigned int hdr_spec_len;
 
 	ISCSI_SW_TCP_DBG(conn, "offset=%d, datalen=%d %s\n", offset, len,
@@ -467,7 +467,7 @@ iscsi_sw_tcp_send_data_prep(struct iscsi_conn *conn, struct scatterlist *sg,
 	WARN_ON(iscsi_padded(len) != iscsi_padded(hdr_spec_len));
 
 	if (conn->datadgst_en)
-		tx_hash = &tcp_sw_conn->tx_hash;
+		tx_hash = tcp_sw_conn->tx_hash;
 
 	return iscsi_segment_seek_sg(&tcp_sw_conn->out.data_segment,
 				     sg, count, offset, len,
@@ -480,7 +480,7 @@ iscsi_sw_tcp_send_linear_data_prep(struct iscsi_conn *conn, void *data,
 {
 	struct iscsi_tcp_conn *tcp_conn = conn->dd_data;
 	struct iscsi_sw_tcp_conn *tcp_sw_conn = tcp_conn->dd_data;
-	struct hash_desc *tx_hash = NULL;
+	struct ahash_request *tx_hash = NULL;
 	unsigned int hdr_spec_len;
 
 	ISCSI_SW_TCP_DBG(conn, "datalen=%zd %s\n", len, conn->datadgst_en ?
@@ -492,7 +492,7 @@ iscsi_sw_tcp_send_linear_data_prep(struct iscsi_conn *conn, void *data,
 	WARN_ON(iscsi_padded(len) != iscsi_padded(hdr_spec_len));
 
 	if (conn->datadgst_en)
-		tx_hash = &tcp_sw_conn->tx_hash;
+		tx_hash = tcp_sw_conn->tx_hash;
 
 	iscsi_segment_init_linear(&tcp_sw_conn->out.data_segment,
 				data, len, NULL, tx_hash);
@@ -543,6 +543,7 @@ iscsi_sw_tcp_conn_create(struct iscsi_cls_session *cls_session,
 	struct iscsi_cls_conn *cls_conn;
 	struct iscsi_tcp_conn *tcp_conn;
 	struct iscsi_sw_tcp_conn *tcp_sw_conn;
+	struct crypto_ahash *tfm;
 
 	cls_conn = iscsi_tcp_conn_setup(cls_session, sizeof(*tcp_sw_conn),
 					conn_idx);
@@ -552,23 +553,28 @@ iscsi_sw_tcp_conn_create(struct iscsi_cls_session *cls_session,
 	tcp_conn = conn->dd_data;
 	tcp_sw_conn = tcp_conn->dd_data;
 
-	tcp_sw_conn->tx_hash.tfm = crypto_alloc_hash("crc32c", 0,
-						     CRYPTO_ALG_ASYNC);
-	tcp_sw_conn->tx_hash.flags = 0;
-	if (IS_ERR(tcp_sw_conn->tx_hash.tfm))
+	tfm = crypto_alloc_ahash("crc32c", 0, CRYPTO_ALG_ASYNC);
+	if (IS_ERR(tfm))
 		goto free_conn;
 
-	tcp_sw_conn->rx_hash.tfm = crypto_alloc_hash("crc32c", 0,
-						     CRYPTO_ALG_ASYNC);
-	tcp_sw_conn->rx_hash.flags = 0;
-	if (IS_ERR(tcp_sw_conn->rx_hash.tfm))
-		goto free_tx_tfm;
-	tcp_conn->rx_hash = &tcp_sw_conn->rx_hash;
+	tcp_sw_conn->tx_hash = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!tcp_sw_conn->tx_hash)
+		goto free_tfm;
+	ahash_request_set_callback(tcp_sw_conn->tx_hash, 0, NULL, NULL);
+
+	tcp_sw_conn->rx_hash = ahash_request_alloc(tfm, GFP_KERNEL);
+	if (!tcp_sw_conn->rx_hash)
+		goto free_tx_hash;
+	ahash_request_set_callback(tcp_sw_conn->rx_hash, 0, NULL, NULL);
+
+	tcp_conn->rx_hash = tcp_sw_conn->rx_hash;
 
 	return cls_conn;
 
-free_tx_tfm:
-	crypto_free_hash(tcp_sw_conn->tx_hash.tfm);
+free_tx_hash:
+	ahash_request_free(tcp_sw_conn->tx_hash);
+free_tfm:
+	crypto_free_ahash(tfm);
 free_conn:
 	iscsi_conn_printk(KERN_ERR, conn,
 			  "Could not create connection due to crc32c "
@@ -607,10 +613,14 @@ static void iscsi_sw_tcp_conn_destroy(struct iscsi_cls_conn *cls_conn)
 
 	iscsi_sw_tcp_release_conn(conn);
 
-	if (tcp_sw_conn->tx_hash.tfm)
-		crypto_free_hash(tcp_sw_conn->tx_hash.tfm);
-	if (tcp_sw_conn->rx_hash.tfm)
-		crypto_free_hash(tcp_sw_conn->rx_hash.tfm);
+	ahash_request_free(tcp_sw_conn->rx_hash);
+	if (tcp_sw_conn->tx_hash) {
+		struct crypto_ahash *tfm;
+
+		tfm = crypto_ahash_reqtfm(tcp_sw_conn->tx_hash);
+		ahash_request_free(tcp_sw_conn->tx_hash);
+		crypto_free_ahash(tfm);
+	}
 
 	iscsi_tcp_conn_teardown(cls_conn);
 }
diff --git a/drivers/scsi/iscsi_tcp.h b/drivers/scsi/iscsi_tcp.h
index f42ecb23..06d42d0 100644
--- a/drivers/scsi/iscsi_tcp.h
+++ b/drivers/scsi/iscsi_tcp.h
@@ -45,8 +45,8 @@ struct iscsi_sw_tcp_conn {
 	void			(*old_write_space)(struct sock *);
 
 	/* data and header digests */
-	struct hash_desc	tx_hash;	/* CRC32C (Tx) */
-	struct hash_desc	rx_hash;	/* CRC32C (Rx) */
+	struct ahash_request	*tx_hash;	/* CRC32C (Tx) */
+	struct ahash_request	*rx_hash;	/* CRC32C (Rx) */
 
 	/* MIB custom statistics */
 	uint32_t		sendpage_failures_cnt;
diff --git a/drivers/scsi/libiscsi_tcp.c b/drivers/scsi/libiscsi_tcp.c
index 60cb6dc..63a1d69 100644
--- a/drivers/scsi/libiscsi_tcp.c
+++ b/drivers/scsi/libiscsi_tcp.c
@@ -26,13 +26,13 @@
  *	Zhenyu Wang
  */
 
+#include <crypto/hash.h>
 #include <linux/types.h>
 #include <linux/list.h>
 #include <linux/inet.h>
 #include <linux/slab.h>
 #include <linux/file.h>
 #include <linux/blkdev.h>
-#include <linux/crypto.h>
 #include <linux/delay.h>
 #include <linux/kfifo.h>
 #include <linux/scatterlist.h>
@@ -214,7 +214,8 @@ int iscsi_tcp_segment_done(struct iscsi_tcp_conn *tcp_conn,
 		} else
 			sg_init_one(&sg, segment->data + segment->copied,
 				    copied);
-		crypto_hash_update(segment->hash, &sg, copied);
+		ahash_request_set_crypt(segment->hash, &sg, NULL, copied);
+		crypto_ahash_update(segment->hash);
 	}
 
 	segment->copied += copied;
@@ -260,7 +261,9 @@ int iscsi_tcp_segment_done(struct iscsi_tcp_conn *tcp_conn,
 	 * is completely handled in hdr done function.
 	 */
 	if (segment->hash) {
-		crypto_hash_final(segment->hash, segment->digest);
+		ahash_request_set_crypt(segment->hash, NULL,
+					segment->digest, 0);
+		crypto_ahash_final(segment->hash);
 		iscsi_tcp_segment_splice_digest(segment,
 				 recv ? segment->recv_digest : segment->digest);
 		return 0;
@@ -310,13 +313,14 @@ iscsi_tcp_segment_recv(struct iscsi_tcp_conn *tcp_conn,
 }
 
 inline void
-iscsi_tcp_dgst_header(struct hash_desc *hash, const void *hdr, size_t hdrlen,
-		      unsigned char digest[ISCSI_DIGEST_SIZE])
+iscsi_tcp_dgst_header(struct ahash_request *hash, const void *hdr,
+		      size_t hdrlen, unsigned char digest[ISCSI_DIGEST_SIZE])
 {
 	struct scatterlist sg;
 
 	sg_init_one(&sg, hdr, hdrlen);
-	crypto_hash_digest(hash, &sg, hdrlen, digest);
+	ahash_request_set_crypt(hash, &sg, digest, hdrlen);
+	crypto_ahash_digest(hash);
 }
 EXPORT_SYMBOL_GPL(iscsi_tcp_dgst_header);
 
@@ -341,7 +345,7 @@ iscsi_tcp_dgst_verify(struct iscsi_tcp_conn *tcp_conn,
  */
 static inline void
 __iscsi_segment_init(struct iscsi_segment *segment, size_t size,
-		     iscsi_segment_done_fn_t *done, struct hash_desc *hash)
+		     iscsi_segment_done_fn_t *done, struct ahash_request *hash)
 {
 	memset(segment, 0, sizeof(*segment));
 	segment->total_size = size;
@@ -349,14 +353,14 @@ __iscsi_segment_init(struct iscsi_segment *segment, size_t size,
 
 	if (hash) {
 		segment->hash = hash;
-		crypto_hash_init(hash);
+		crypto_ahash_init(hash);
 	}
 }
 
 inline void
 iscsi_segment_init_linear(struct iscsi_segment *segment, void *data,
 			  size_t size, iscsi_segment_done_fn_t *done,
-			  struct hash_desc *hash)
+			  struct ahash_request *hash)
 {
 	__iscsi_segment_init(segment, size, done, hash);
 	segment->data = data;
@@ -368,7 +372,8 @@ inline int
 iscsi_segment_seek_sg(struct iscsi_segment *segment,
 		      struct scatterlist *sg_list, unsigned int sg_count,
 		      unsigned int offset, size_t size,
-		      iscsi_segment_done_fn_t *done, struct hash_desc *hash)
+		      iscsi_segment_done_fn_t *done,
+		      struct ahash_request *hash)
 {
 	struct scatterlist *sg;
 	unsigned int i;
@@ -431,7 +436,7 @@ static void
 iscsi_tcp_data_recv_prep(struct iscsi_tcp_conn *tcp_conn)
 {
 	struct iscsi_conn *conn = tcp_conn->iscsi_conn;
-	struct hash_desc *rx_hash = NULL;
+	struct ahash_request *rx_hash = NULL;
 
 	if (conn->datadgst_en &&
 	    !(conn->session->tt->caps & CAP_DIGEST_OFFLOAD))
@@ -686,7 +691,7 @@ iscsi_tcp_hdr_dissect(struct iscsi_conn *conn, struct iscsi_hdr *hdr)
 
 		if (tcp_conn->in.datalen) {
 			struct iscsi_tcp_task *tcp_task = task->dd_data;
-			struct hash_desc *rx_hash = NULL;
+			struct ahash_request *rx_hash = NULL;
 			struct scsi_data_buffer *sdb = scsi_in(task->sc);
 
 			/*
diff --git a/include/scsi/libiscsi_tcp.h b/include/scsi/libiscsi_tcp.h
index 2a7aa75..30520d5 100644
--- a/include/scsi/libiscsi_tcp.h
+++ b/include/scsi/libiscsi_tcp.h
@@ -26,7 +26,7 @@
 struct iscsi_tcp_conn;
 struct iscsi_segment;
 struct sk_buff;
-struct hash_desc;
+struct ahash_request;
 
 typedef int iscsi_segment_done_fn_t(struct iscsi_tcp_conn *,
 				    struct iscsi_segment *);
@@ -38,7 +38,7 @@ struct iscsi_segment {
 	unsigned int		total_size;
 	unsigned int		total_copied;
 
-	struct hash_desc	*hash;
+	struct ahash_request	*hash;
 	unsigned char		padbuf[ISCSI_PAD_LEN];
 	unsigned char		recv_digest[ISCSI_DIGEST_SIZE];
 	unsigned char		digest[ISCSI_DIGEST_SIZE];
@@ -73,7 +73,7 @@ struct iscsi_tcp_conn {
 	/* control data */
 	struct iscsi_tcp_recv	in;		/* TCP receive context */
 	/* CRC32C (Rx) LLD should set this is they do not offload */
-	struct hash_desc	*rx_hash;
+	struct ahash_request	*rx_hash;
 };
 
 struct iscsi_tcp_task {
@@ -111,15 +111,16 @@ extern void iscsi_tcp_segment_unmap(struct iscsi_segment *segment);
 extern void iscsi_segment_init_linear(struct iscsi_segment *segment,
 				      void *data, size_t size,
 				      iscsi_segment_done_fn_t *done,
-				      struct hash_desc *hash);
+				      struct ahash_request *hash);
 extern int
 iscsi_segment_seek_sg(struct iscsi_segment *segment,
 		      struct scatterlist *sg_list, unsigned int sg_count,
 		      unsigned int offset, size_t size,
-		      iscsi_segment_done_fn_t *done, struct hash_desc *hash);
+		      iscsi_segment_done_fn_t *done,
+		      struct ahash_request *hash);
 
 /* digest helpers */
-extern void iscsi_tcp_dgst_header(struct hash_desc *hash, const void *hdr,
+extern void iscsi_tcp_dgst_header(struct ahash_request *hash, const void *hdr,
 				  size_t hdrlen,
 				  unsigned char digest[ISCSI_DIGEST_SIZE]);
 extern struct iscsi_cls_conn *
