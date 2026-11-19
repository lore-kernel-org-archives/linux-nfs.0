Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795077613;
	b=zG4TbCwx10HW6FzC3IcpiBriQ6ZSzZP1w69i9u5cVOB5sRGKzzkUUN29nHhpv575dTKV
	 8d09D4jIjLBciBB8gQkVlMEbK03dvqn6dTA6K8KvVFsQZ2S/ghkncpob4dEa7B8wXPrAb
	 xbaJOr7c7XQfWyg1xfSBph8YtHc5nVHcjZFU2Urol5zwJLeG4UZpuQEpI5z/qbnkS4wAK
	 5FDjEjTRqWEgO68oWpM3VKveDsXLE3gR1gIc2uVewOfo2XzChLfYis9IvB+bMZlXmRix7
	 vVQlniCWnJoE0qksLJhvkK7QAaDsDQbeko6OruxvzSDKLMyveb6nGdBqHJw0BHLUpjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795077613;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=lurnHQou1JqdVPQJSrV+MSMuIzT6ocxvUPGpDR+yuTQ=;
	b=h6MKx3bQVH6ZrLgUr6euVm0S7VTZTcQyFC3Lso1Kcs0qDCjVMzkmHrA3KfIqjOd9Zhkn
	 Pua2uUXIsLIrRlEdtWzrUKB7bkv18SbWdFVgeRO5FU2Un4RQPUwzxEQzHF0ZvaVXn3oXL
	 PNjNTah0v+1U0i3UukNjslW1MiHyWKU/NIQiWfiWKmkjeLrQT9nFxOYHAtDh0wOCM0HAt
	 t4E1Gq++pnRKX9sf3COV7NwIKcJqozdnpJ6t0+2aEF3eMsJJCqtstK0Jp3DcxYXPp1ngW
	 yew/gtKgiDyn54+wUW5TG6c9vWmWVnxhkJ6S7At4vrVMTkx1A4F4mBDvHirfkBU3o/w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b="Nwp+yJx/";
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3275860A261D
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 08:40:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3275860A261D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=Nwp+yJx/
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795077612;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=lurnHQou1JqdVPQJSrV+MSMuIzT6ocxvUPGpDR+yuTQ=;
	b=Nwp+yJx/HdOzv1+RV/p4N2vrJKs/QZPa+SEpzeV+hfr60V2foAfghAXne3Y/E8zikrb8px
	Z2kMqwlEPh2Ehv1enFxFDkIUxfuT8TP+c/kpuhuJANHatch7EKrQD10d9E4Ae4TZ/1QHC4
	f1fXW0HNqeiiryjsrL7oF8Fsh+x3Txo=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-99-94JKUqSkO-ieoDeKZjnhZw-1; Thu,
 19 Nov 2026 03:40:08 -0500
X-MC-Unique: 94JKUqSkO-ieoDeKZjnhZw-1
X-Mimecast-MFC-AGG-ID: 94JKUqSkO-ieoDeKZjnhZw_1795077606
Received: from mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.12])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2FF4818005A6;
	Thu, 19 Nov 2026 08:40:06 +0000 (UTC)
Received: from dhowells-thinkpadp1gen8.rmtgb.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 83D8E1956088;
	Thu, 19 Nov 2026 08:40:02 +0000 (UTC)
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
Subject: [PATCH v19 12/17] cifs: Use a bvecq for buffering instead of a folioq
Date: Thu, 19 Nov 2026 08:38:43 +0000
Message-ID: <20261119083851.3306418-13-dhowells@redhat.com>
In-Reply-To: <20261119083851.3306418-1-dhowells@redhat.com>
References: <20261119083851.3306418-1-dhowells@redhat.com>
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
 fs/smb/client/smb2ops.c  | 97 ++++++++++++++++++++++------------------
 2 files changed, 54 insertions(+), 45 deletions(-)

diff --git a/fs/smb/client/cifsglob.h b/fs/smb/client/cifsglob.h
index 4e16347886ed..e348834e5f38 100644
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
index 298f549bd7ed..d129e3130ddd 100644
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
@@ -4920,19 +4920,18 @@ crypt_message(struct TCP_Server_Info *server, int num_rqst,
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
@@ -4944,7 +4943,7 @@ void
 smb3_free_compound_rqst(int num_rqst, struct smb_rqst *rqst)
 {
 	for (int i = 0; i < num_rqst; i++)
-		netfs_free_folioq_buffer(rqst[i].rq_buffer);
+		bvecq_put(rqst[i].rq_buffer);
 }
 
 /*
@@ -4965,13 +4964,24 @@ smb3_init_transform_rq(struct TCP_Server_Info *server, int num_rqst,
 		       struct smb_rqst *new_rq, struct smb_rqst *old_rq)
 {
 	struct smb2_transform_hdr *tr_hdr = new_rq[0].rq_iov[0].iov_base;
-	unsigned int orig_len = 0;
+	unsigned int orig_len = 0, flags;
 	int rc = -ENOMEM;
 
+	/*
+	 * TODO: This sets flags to BVECQ_USE_SUBREQ_POOL, but should only do
+	 * so for writeback or reconnect or session renegotiation during
+	 * writeback, however this info is not currently easily available here.
+	 *
+	 * If BVECQ_HIT_OOM gets set in flags by bvecq_alloc_buffers(), then we
+	 * need to shorten the write operation - but that's not easy at this
+	 * point either.
+	 */
+	flags = BVECQ_USE_SUBREQ_POOL;
+
 	for (int i = 1; i < num_rqst; i++) {
 		struct smb_rqst *old = &old_rq[i - 1];
 		struct smb_rqst *new = &new_rq[i];
-		struct folio_queue *buffer = NULL;
+		struct bvecq *buffer = NULL;
 		size_t size = iov_iter_count(&old->rq_iter);
 
 		orig_len += smb_rqst_len(server, old);
@@ -4979,17 +4989,16 @@ smb3_init_transform_rq(struct TCP_Server_Info *server, int num_rqst,
 		new->rq_nvec = old->rq_nvec;
 
 		if (size > 0) {
-			size_t cur_size = 0;
-			rc = netfs_alloc_folioq_buffer(NULL, &buffer, &cur_size,
-						       size, GFP_NOFS);
-			new->rq_buffer = buffer;
-			if (rc < 0)
+			rc = -ENOMEM;
+			buffer = bvecq_alloc_buffer(size, GFP_NOFS, &flags);
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
@@ -5004,11 +5013,13 @@ smb3_init_transform_rq(struct TCP_Server_Info *server, int num_rqst,
 	if (rc)
 		goto err_free;
 
+out:
+	bvecq_pool_unlock(&flags);
 	return rc;
 
 err_free:
 	smb3_free_compound_rqst(num_rqst - 1, &new_rq[1]);
-	return rc;
+	goto out;
 }
 
 static int
@@ -5079,22 +5090,20 @@ decrypt_raw_data(struct TCP_Server_Info *server, char *buf,
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
@@ -5116,7 +5125,7 @@ cifs_copy_folioq_to_iter(struct folio_queue *folioq, size_t data_size,
 
 static int
 handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
-		 char *buf, unsigned int buf_len, struct folio_queue *buffer,
+		 char *buf, unsigned int buf_len, struct bvecq *buffer,
 		 unsigned int buffer_len, bool is_offloaded)
 {
 	unsigned int data_offset;
@@ -5226,8 +5235,8 @@ handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
 		}
 
 		/* Copy the data to the output I/O iterator. */
-		rdata->result = cifs_copy_folioq_to_iter(buffer, data_len,
-							 cur_off, &rdata->subreq.io_iter);
+		rdata->result = cifs_copy_bvecq_to_iter(buffer, data_len,
+							cur_off, &rdata->subreq.io_iter);
 		if (rdata->result != 0) {
 			if (is_offloaded)
 				mid->mid_state = MID_RESPONSE_MALFORMED;
@@ -5266,7 +5275,7 @@ handle_read_data(struct TCP_Server_Info *server, struct mid_q_entry *mid,
 struct smb2_decrypt_work {
 	struct work_struct decrypt;
 	struct TCP_Server_Info *server;
-	struct folio_queue *buffer;
+	struct bvecq *buffer;
 	char *buf;
 	unsigned int len;
 };
@@ -5280,7 +5289,7 @@ static void smb2_decrypt_offload(struct work_struct *work)
 	struct mid_q_entry *mid;
 	struct iov_iter iter;
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dw->buffer, 0, 0, dw->len);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dw->buffer, 0, 0, dw->len);
 	rc = decrypt_raw_data(dw->server, dw->buf, dw->server->vals->read_rsp_size,
 			      &iter, true);
 	if (rc) {
@@ -5330,7 +5339,7 @@ static void smb2_decrypt_offload(struct work_struct *work)
 	}
 
 free_pages:
-	netfs_free_folioq_buffer(dw->buffer);
+	bvecq_put(dw->buffer);
 	cifs_small_buf_release(dw->buf);
 	kfree(dw);
 }
@@ -5343,7 +5352,7 @@ receive_encrypted_read(struct TCP_Server_Info *server, struct mid_q_entry **mid,
 	char *buf = server->smallbuf;
 	struct smb2_transform_hdr *tr_hdr = (struct smb2_transform_hdr *)buf;
 	struct iov_iter iter;
-	unsigned int len;
+	unsigned int len, alloc_flags = 0;
 	unsigned int buflen = server->pdu_size;
 	int rc;
 	struct smb2_decrypt_work *dw;
@@ -5376,12 +5385,12 @@ receive_encrypted_read(struct TCP_Server_Info *server, struct mid_q_entry **mid,
 	dw->len = len;
 	len = round_up(dw->len, PAGE_SIZE);
 
-	size_t cur_size = 0;
-	rc = netfs_alloc_folioq_buffer(NULL, &dw->buffer, &cur_size, len, GFP_NOFS);
-	if (rc < 0)
+	rc = -ENOMEM;
+	dw->buffer = bvecq_alloc_buffer(len, GFP_NOFS, &alloc_flags);
+	if (!dw->buffer)
 		goto discard_data;
 
-	iov_iter_folio_queue(&iter, ITER_DEST, dw->buffer, 0, 0, len);
+	iov_iter_bvec_queue(&iter, ITER_DEST, dw->buffer, 0, 0, len);
 
 	/* Read the data into the buffer and clear excess bufferage. */
 	rc = cifs_read_iter_from_socket(server, &iter, dw->len);
@@ -5441,7 +5450,7 @@ receive_encrypted_read(struct TCP_Server_Info *server, struct mid_q_entry **mid,
 	}
 
 free_pages:
-	netfs_free_folioq_buffer(dw->buffer);
+	bvecq_put(dw->buffer);
 free_dw:
 	kfree(dw);
 	return rc;

