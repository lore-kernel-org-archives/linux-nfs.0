Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794067774;
	b=XGzv6e/mDV8ruIA79HGIwAsrbtzFnakkItp/+PYDhcBhz8LrXfxq9x7p4BAC6nQPN0QS
	 4zbrTvejTBB8JpsLlOQWkGDTluF0rWuerORmxi7ty1tgTHxB5qI7Ux/3GSV1DMSFu1D/g
	 4pf6B3+DU8h1nt60hrRBhZ9wFsyN2XNnvp/rAm1nCP2bb/AlslzigQQ1Ji9zVbvd8gFS2
	 27ECuNmvIArmcxskz7KF2mcxHgvGKvO08i1HUfYhh13wrdFz95Na2IaLBVtcZ7KeKuBdw
	 F6Xg9w8FXsrd/y6HzIRSxwF1K8mJuXMjwUAQq7n2lCBbCdCVg16LnrSDP6YaMUdVfkg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794067774;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=ZpFzsxVEQvWtIOxAqVEIMN/ft++f1rjW7tVVrkxbWYU=;
	b=4NIr8zrboCbpCtGA1rYHC8ogMySdwsAxFgvfa7TFR95uZdzRUkh/aJHCHJKZleYNg2Gk
	 p/b7HUK0xRy9v6+qolnd4+zxjj2pglnAoW30i7zwNuDc14ALw1IHU55E50IygucQr07DZ
	 z6G5SF9r/HIlK4qKR0HKXPYNLamKCAwUpSOe2Nvzd4wikRPjgUYmo7udBVU7U+wM1OU/M
	 3vXMrmJjWGOhD2MTjR3F+aCKfVq4PQ4ajDgxJ7hGOPli5vymVaYRq+eHPe0envQRJcSZM
	 NfnZMuyaGls2FgTPeFWCMRNNXwj8JFU8sVyCgu+83x4BU52ZkexPbgrdZMkfk5oaNwg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=dPpG4VPi;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DACFD60A5BD4
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 16:09:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DACFD60A5BD4
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=dPpG4VPi
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794067773;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=ZpFzsxVEQvWtIOxAqVEIMN/ft++f1rjW7tVVrkxbWYU=;
	b=dPpG4VPiob+k3CydJJFDRqzx6zImJoRVEeaKgO2gBv/EO27zWWxHo943YUShaXpAMYPuBD
	5ZxCgP/apXHYoRHuLG3WpioiIovGnLFXJsgy/yDpzHHHkgkYIM0qE5T2Yc7FZ9+wOPQiVy
	PJVQbcabgBOGALRamTDG5++a3r208pU=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-561-_ABmAehkO76TJRVWeb-oeg-1; Sat,
 07 Nov 2026 11:09:29 -0500
X-MC-Unique: _ABmAehkO76TJRVWeb-oeg-1
X-Mimecast-MFC-AGG-ID: _ABmAehkO76TJRVWeb-oeg_1794067767
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 5B2AA19560B4;
	Sat,  7 Nov 2026 16:09:27 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id A1607195608B;
	Sat,  7 Nov 2026 16:09:23 +0000 (UTC)
From: David Howells <dhowells@redhat.com>
To: Christian Brauner <christian@brauner.io>
Cc: David Howells <dhowells@redhat.com>,
	Paulo Alcantara <pc@manguebit.org>,
	Matthew Wilcox <willy@infradead.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Marc Dionne <marc.dionne@auristor.com>,
	Stefan Metzmacher <metze@samba.org>,
	Eric Van Hensbergen <ericvh@kernel.org>,
	Dominique Martinet <asmadeus@codewreck.org>,
	Ilya Dryomov <idryomov@gmail.com>,
	netfs@lists.linux.dev,
	linux-afs@lists.infradead.org,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	v9fs@lists.linux.dev,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>
Subject: [PATCH v16 10/15] cifs: Use a bvecq for buffering instead of a folioq
Date: Sat,  7 Nov 2026 16:08:13 +0000
Message-ID: <20261107160823.1465553-11-dhowells@redhat.com>
In-Reply-To: <20261107160823.1465553-1-dhowells@redhat.com>
References: <20261107160823.1465553-1-dhowells@redhat.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.12

Use a bvecq for internal buffering for crypto purposes instead of a folioq
so that the latter can be phased out.

Signed-off-by: David Howells <dhowells@redhat.com>
Reviewed-by: Paulo Alcantara <pc@manguebit.org>
cc: Namjae Jeon <linkinjeon@kernel.org>
cc: Matthew Wilcox <willy@infradead.org>
cc: Christoph Hellwig <hch@infradead.org>
cc: linux-cifs@vger.kernel.org
cc: netfs@lists.linux.dev
cc: linux-fsdevel@vger.kernel.org
---
 fs/smb/client/cifsglob.h |  2 +-
 fs/smb/client/smb2ops.c  | 78 +++++++++++++++++++---------------------
 2 files changed, 38 insertions(+), 42 deletions(-)

diff --git a/fs/smb/client/cifsglob.h b/fs/smb/client/cifsglob.h
index d3ca688b6aba..806242d9cce0 100644
--- a/fs/smb/client/cifsglob.h
+++ b/fs/smb/client/cifsglob.h
@@ -290,7 +290,7 @@ struct smb_rqst {
 	struct kvec	*rq_iov;	/* array of kvecs */
 	unsigned int	rq_nvec;	/* number of kvecs in array */
 	struct iov_iter	rq_iter;	/* Data iterator */
-	struct folio_queue *rq_buffer;	/* Buffer for encryption */
+	struct bvecq	*rq_buffer;	/* Buffer for encryption */
 };
 
 struct mid_q_entry;
diff --git a/fs/smb/client/smb2ops.c b/fs/smb/client/smb2ops.c
index dc55cd512616..9d462f6e896c 100644
--- a/fs/smb/client/smb2ops.c
+++ b/fs/smb/client/smb2ops.c
@@ -13,7 +13,7 @@
 #include <linux/sort.h>
 #include <crypto/aead.h>
 #include <linux/fiemap.h>
-#include <linux/folio_queue.h>
+#include <linux/bvecq.h>
 #include <uapi/linux/magic.h>
 #include "cifsfs.h"
 #include "cifsglob.h"
@@ -4918,19 +4918,18 @@ crypt_message(struct TCP_Server_Info *server, int num_rqst,
 }
 
 /*
- * Copy data from an iterator to the folios in a folio queue buffer.
+ * Copy data from an iterator to the pages in a bvec queue buffer.
  */
-static bool cifs_copy_iter_to_folioq(struct iov_iter *iter, size_t size,
-				     struct folio_queue *buffer)
+static bool cifs_copy_iter_to_bvecq(struct iov_iter *iter, size_t size,
+				    struct bvecq *buffer)
 {
 	for (; buffer; buffer = buffer->next) {
-		for (int s = 0; s < folioq_count(buffer); s++) {
-			struct folio *folio = folioq_folio(buffer, s);
-			size_t part = folioq_folio_size(buffer, s);
+		for (int s = 0; s < bvecq_nr_slots_acquire(buffer); s++) {
+			struct bio_vec *bv = &buffer->bv[s];
+			size_t part = umin(bv->bv_len, size);
 
-			part = umin(part, size);
-
-			if (copy_folio_from_iter(folio, 0, part, iter) != part)
+			if (copy_page_from_iter(bv->bv_page, bv->bv_offset,
+						part, iter) != part)
 				return false;
 			size -= part;
 		}
@@ -4942,7 +4941,7 @@ void
 smb3_free_compound_rqst(int num_rqst, struct smb_rqst *rqst)
 {
 	for (int i = 0; i < num_rqst; i++)
-		netfs_free_folioq_buffer(rqst[i].rq_buffer);
+		bvecq_put(rqst[i].rq_buffer);
 }
 
 /*
@@ -4969,7 +4968,7 @@ smb3_init_transform_rq(struct TCP_Server_Info *server, int num_rqst,
 	for (int i = 1; i < num_rqst; i++) {
 		struct smb_rqst *old = &old_rq[i - 1];
 		struct smb_rqst *new = &new_rq[i];
-		struct folio_queue *buffer = NULL;
+		struct bvecq *buffer = NULL;
 		size_t size = iov_iter_count(&old->rq_iter);
 
 		orig_len += smb_rqst_len(server, old);
@@ -4977,17 +4976,16 @@ smb3_init_transform_rq(struct TCP_Server_Info *server, int num_rqst,
 		new->rq_nvec = old->rq_nvec;
 
 		if (size > 0) {
-			size_t cur_size = 0;
-			rc = netfs_alloc_folioq_buffer(NULL, &buffer, &cur_size,
-						       size, GFP_NOFS);
-			new->rq_buffer = buffer;
-			if (rc < 0)
+			rc = -ENOMEM;
+			buffer = bvecq_alloc_buffer(size, GFP_NOFS, true);
+			if (!buffer)
 				goto err_free;
 
-			iov_iter_folio_queue(&new->rq_iter, ITER_SOURCE,
-					     buffer, 0, 0, size);
+			new->rq_buffer = buffer;
+			iov_iter_bvec_queue(&new->rq_iter, ITER_SOURCE,
+					    buffer, 0, 0, size);
 
-			if (!cifs_copy_iter_to_folioq(&old->rq_iter, size, buffer)) {
+			if (!cifs_copy_iter_to_bvecq(&old->rq_iter, size, buffer)) {
 				rc = smb_EIO1(smb_eio_trace_tx_copy_iter_to_buf, size);
 				goto err_free;
 			}
@@ -5077,22 +5075,20 @@ decrypt_raw_data(struct TCP_Server_Info *server, char *buf,
 }
 
 static int
-cifs_copy_folioq_to_iter(struct folio_queue *folioq, size_t data_size,
-			 size_t skip, struct iov_iter *iter)
+cifs_copy_bvecq_to_iter(struct bvecq *bq, size_t data_size,
+			size_t skip, struct iov_iter *iter)
 {
-	for (; folioq; folioq = folioq->next) {
-		for (int s = 0; s < folioq_count(folioq); s++) {
-			struct folio *folio;
-			size_t fsize, n, len;
+	for (; bq; bq = bq->next) {
+		for (int s = 0; s < bvecq_nr_slots_acquire(bq); s++) {
+			struct bio_vec *bv = &bq->bv[s];
+			size_t n, len;
 
 			if (data_size == 0)
 				return 0;
 
-			folio = folioq_folio(folioq, s);
-			fsize = folio_size(folio);
-			len = umin(fsize - skip, data_size);
+			len = umin(bv->bv_len - skip, data_size);
 
-			n = copy_folio_to_iter(folio, skip, len, iter);
+			n = copy_page_to_iter(bv->bv_page, bv->bv_offset + skip, len, iter);
 			if (n != len) {
 				cifs_dbg(VFS, "%s: something went wrong\n", __func__);
 				return smb_EIO2(smb_eio_trace_rx_copy_to_iter,
@@ -5114,7 +5110,7 @@ cifs_copy_folioq_to_iter(struct folio_queue *folioq, size_t data_size,
 
 static int
 handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
-		 char *buf, unsigned int buf_len, struct folio_queue *buffer,
+		 char *buf, unsigned int buf_len, struct bvecq *buffer,
 		 unsigned int buffer_len, bool is_offloaded)
 {
 	unsigned int data_offset;
@@ -5224,8 +5220,8 @@ handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
 		}
 
 		/* Copy the data to the output I/O iterator. */
-		rdata->result = cifs_copy_folioq_to_iter(buffer, data_len,
-							 cur_off, &rdata->subreq.io_iter);
+		rdata->result = cifs_copy_bvecq_to_iter(buffer, data_len,
+							cur_off, &rdata->subreq.io_iter);
 		if (rdata->result != 0) {
 			if (is_offloaded)
 				mid->mid_state = MID_RESPONSE_MALFORMED;
@@ -5264,7 +5260,7 @@ handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
 struct smb2_decrypt_work {
 	struct work_struct decrypt;
 	struct TCP_Server_Info *server;
-	struct folio_queue *buffer;
+	struct bvecq *buffer;
 	char *buf;
 	unsigned int len;
 };
@@ -5278,7 +5274,7 @@ static void smb2_decrypt_offload(struct work_struct *work)
 	struct mid_q_entry *mid;
 	struct iov_iter iter;
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dw->buffer, 0, 0, dw->len);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dw->buffer, 0, 0, dw->len);
 	rc = decrypt_raw_data(dw->server, dw->buf, dw->server->vals->read_rsp_size,
 			      &iter, true);
 	if (rc) {
@@ -5328,7 +5324,7 @@ static void smb2_decrypt_offload(struct work_struct *work)
 	}
 
 free_pages:
-	netfs_free_folioq_buffer(dw->buffer);
+	bvecq_put(dw->buffer);
 	cifs_small_buf_release(dw->buf);
 	kfree(dw);
 }
@@ -5374,12 +5370,12 @@ receive_encrypted_read(struct TCP_Server_Info *server, struct mid_q_entry **mid,
 	dw->len = len;
 	len = round_up(dw->len, PAGE_SIZE);
 
-	size_t cur_size = 0;
-	rc = netfs_alloc_folioq_buffer(NULL, &dw->buffer, &cur_size, len, GFP_NOFS);
-	if (rc < 0)
+	rc = -ENOMEM;
+	dw->buffer = bvecq_alloc_buffer(len, GFP_NOFS, false);
+	if (!dw->buffer)
 		goto discard_data;
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dw->buffer, 0, 0, len);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dw->buffer, 0, 0, len);
 
 	/* Read the data into the buffer and clear excess bufferage. */
 	rc = cifs_read_iter_from_socket(server, &iter, dw->len);
@@ -5439,7 +5435,7 @@ receive_encrypted_read(struct TCP_Server_Info *server, struct mid_q_entry **mid,
 	}
 
 free_pages:
-	netfs_free_folioq_buffer(dw->buffer);
+	bvecq_put(dw->buffer);
 free_dw:
 	kfree(dw);
 	return rc;

