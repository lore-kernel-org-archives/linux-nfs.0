Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.41
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795136519;
	b=JqHeIwBz3SuUT9VVHRErSr7Ha6eAZ7+0R2jyyPQ80IEsteq87vFAEPplprnDso8BGorC
	 Je44k9zUeO06bB7eelRALo9x23lNje0V6NYxBb1D2lZVikNp7AniHwv+GAYqT4/2OW7cx
	 QndcE7eQS5lpoduBuxhasWlFlbRVIn42UyXRd6Q/5nNs44EvqlMtun3nNth61IoZmoj3E
	 FEWbiV9OGV76dV7yxR9v3aorIJDE+bYEa8mf1tG7v1kqy3KC4/1iyFMFhb8XYFf2W5TcB
	 KSpTszOgI6j+2WwWz4JEkaNjkZjDOp13lrNq6T3Ya/XdKWFjNxgOhCeMfgA1PBw7nSg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795136519;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=w5d0hOkm67mYdHCAEsmMGzKbwRsLjIjoR1T050D1zsc=;
	b=OiTmjB/PSa0h2gws6Oy6LfM7ZuD8Ir2FG0NhyUgK2EOJ8daRIVhrWpfrRwNNjSqqgDPz
	 Sl7aoLIys6TbDRj4ZWjGXRhr/JaV3yN6Y/++ZPhE19/Ueca/AE8suPoB+UbsYw6mUbOPu
	 2KzFkb3CyteumPFwknvopGcmz9K8B6u0N5TZ//J2g5QS8yvegYo790DPgC0VA1SNeE2de
	 /SDz5mwWHRB1C5MBHcv6ybAf8j0McHqECfZwaiVCM0t/r7INqomOaHm7VRSEXj/kHzdP+
	 nNNItPrLPYnsKa/3ka535yAh/mC6Jlave3PpDQuq3EVIvQ4GrNLeQZqIngacnHMngUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=kY4Dx8u5;
	arc=none smtp.remote-ip=209.85.161.41
Received: from mail-oo1-f41.google.com (mail-oo1-f41.google.com [209.85.161.41])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E25F2606A326
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 01:01:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E25F2606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=kY4Dx8u5
Received: by mail-oo1-f41.google.com with SMTP id 006d021491bc7-6e560e00a86so242762eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 17:01:58 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795136518; x=1795741318; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=w5d0hOkm67mYdHCAEsmMGzKbwRsLjIjoR1T050D1zsc=;
        b=kY4Dx8u587U9gJEegDx6ZiX/dd3AiRpasJjMQ2vorXdkSrbO0MHzSVYBvRb0adleku
         tu/EeYplEa5iZMgwuZ59GtgnKyvoYT0wcA0p4h5cOgIpnrAB2pPd3mPaxaRUqRDFPg5+
         cFhh8uAwXmwKKw0SwXf+HeWWQ+oLmfARE5wY7giyOW2TfdyjMCSZh81IimpfPowQpRWz
         NmunPN6tn7xLa8CthSfDLxeRavZIPnl3xMM+dFsQXjbfBGHLKcz79qElCGYYtJJx1ylD
         QJBLuTnZ3197er+OqXbuyWIZBqmpYEEOVe5oGB/ySEZttfFsoQk/vxCxQP1hu0IsPtKm
         Meag==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795136518; x=1795741318;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=w5d0hOkm67mYdHCAEsmMGzKbwRsLjIjoR1T050D1zsc=;
        b=jFVE9tluTrCyZ4ofFL6itRoojv9nVwm5qO2sDK+JpBi9NQVsg/R9kroZaLtdV0Nmqz
         CySJe8Q75/o7U2UXWQBjB1o8GL0CNhdqjSpRBlRU2HmBSaOXggAfpxCRql8Vq5443lTe
         BO3tqt70xJij/W5INShtGMiIsDQkKbKNnBshzUrP9xvabZ14/NUGjnPBM5wE+GqEWEcs
         yRZdmDJp7ay/4Eta6b86nwbdiNHQVdHmo/xOBprenqJq/Vzx3TCB1ycdnPhTX20mgXpv
         3fKcyCkPJKzBK12xcfOXt9OvaLpsc405J+wkN5lOi9JH606rok9bKnwu4e4LU7Rb84HI
         F3TA==
X-Gm-Message-State: APuU4Z9el08C0kJ+DJGrpu+FMPrIG2ipx/XPrXhLR0Tr9deYoN5MKuzu
	l2IaEmOV0xgrFQizVEGyOraef1YlJE7YvM8sFeyCRb3DY5ccR8ht5K20Bw+nTw+pDlkchQDU6vO
	z0uUM
X-Gm-Gg: AYBFou1QKY4EPo/DMndb9TwPnhRikFcwE3KfahYvIdFEl34GNTFbcmVNItydQQHqkb9
	5QjzAr13SNerXmfY85mRcNir40xDd6kQAbf/8rlCeV9C4/MTZko//uZ+weqexkbT91sps3eZ6OV
	x8O16ErfRnSQnYyYtsgbdagUBPnxx3cRj13T/3knQm1AUL7l9cMfimlCWcPRzXTcE/djqRHh2mr
	KIAGhjU4kLyn7P3iSkFiNR+H5K0sSumpizct6EEQJmAclY3WkNrZ6tW1KMun1wXH9gyaHlxo3Mm
	C9FUpR13nlW4oWv1S2OKFhL99uHIk6uf4P3AEO3F1s/szO9+faL0k1GL2TLJ0KRqWsPJlC8VVkb
	3xgx1W74u9jQ5MfIt3bmlRan4Cft6ArgKeq86Ea1qVnzLEQ5Std+g8Vfwb/iKcov3jrG8n6xD+V
	qdYQL2bszj9LpMEx5Kk4j0grtHW/rtsJGSnElsfMYEmaLkJvixQRqgXbfiJ6pnMMpBFj5VF2D1y
	2J5tjCgjgUrba/TO8GMz+BdIIt/1KwJDuQS+dEYf5EdoI8uY9z57XK08IoRRe0KhDUb0kDnM5P2
	INukQML9OgSgUfEsXpXpOyFXlVLd0OGW2zR6nOb+jEZ0+fPhi+bovlv20BKAQQq7Liz/SG6p8js
	+DzG7ElMnlbW9srZMsL2b3Q==
X-Received: by 2002:a05:6820:3397:10b0:71a:f6ba:5f3b with SMTP id 006d021491bc7-71b3929459amr1144548eaf.5.1795136517837;
        Thu, 19 Nov 2026 17:01:57 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-71b37ea818bsm1101995eaf.1.2026.11.19.17.01.57
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 17:01:57 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/3] NFS: resend O_DIRECT write requests that error cleanup gets with -EAGAIN
Date: Thu, 19 Nov 2026 20:01:52 -0500
Message-ID: <95ac680997bbb3efc145c492ae9a817e9639cb05.1795136323.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795136323.git.bcodding@hammerspace.com>
References: <cover.1795136323.git.bcodding@hammerspace.com>
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

From: Benjamin Coddington <bcodding@hammerspace.com>

A layout driver's pg_init can fail a descriptor with -EAGAIN while it
still holds queued requests; flexfiles does this when the mirror count
changes.  nfs_pageio_error_cleanup() hands those requests to
error_cleanup, and for O_DIRECT writes nfs_write_sync_pgio_error() just
unlocks and releases them.  nfs_direct_write_schedule_iovec() treats
-EAGAIN as soft and defers only the request it was adding, so the queued
requests, already counted in requested_bytes, are never written and no
error is reported.

Pass the descriptor's nfs_direct_req to error_cleanup.  On -EAGAIN, put
the O_DIRECT write requests on the commit list and set
NFS_ODIRECT_RESCHED_WRITES so the write completion resends them.  Move
that code out of nfs_direct_write_reschedule_io() into
nfs_direct_write_requeue() and use it in both places.

Fixes: 954998b60caa ("NFS: Fix error handling for O_DIRECT write scheduling")
Cc: stable@vger.kernel.org # v6.6+
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c         | 48 +++++++++++++++++++++++++----------------
 fs/nfs/pagelist.c       |  7 +++---
 fs/nfs/read.c           |  3 ++-
 fs/nfs/write.c          |  5 +++--
 include/linux/nfs_xdr.h |  3 ++-
 5 files changed, 41 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a3c6e8f4ea06..c771bb1b0730 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -330,7 +330,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_read_sync_pgio_error(struct list_head *head, int error)
+static void nfs_read_sync_pgio_error(struct list_head *head, int error,
+				     struct nfs_direct_req *dreq)
 {
 	nfs_release_request_list(head);
 }
@@ -818,39 +819,50 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_write_sync_pgio_error(struct list_head *head, int error)
+static void nfs_direct_write_requeue(struct nfs_direct_req *dreq,
+				     struct list_head *head)
 {
+	struct nfs_commit_info cinfo;
 	struct nfs_page *req;
 
+	nfs_init_cinfo_from_dreq(&cinfo, dreq);
+	spin_lock(&dreq->lock);
+	if (dreq->error == 0)
+		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+	spin_unlock(&dreq->lock);
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_unlock_and_release_request(req);
+		nfs_unlock_request(req);
+		nfs_mark_request_commit(req, NULL, &cinfo, 0);
 	}
 }
 
-static void nfs_direct_write_reschedule_io(struct nfs_pgio_header *hdr)
+static void nfs_write_sync_pgio_error(struct list_head *head, int error,
+				      struct nfs_direct_req *dreq)
 {
-	struct nfs_direct_req *dreq = hdr->dreq;
 	struct nfs_page *req;
-	struct nfs_commit_info cinfo;
-
-	trace_nfs_direct_write_reschedule_io(dreq);
 
-	nfs_init_cinfo_from_dreq(&cinfo, dreq);
-	spin_lock(&dreq->lock);
-	if (dreq->error == 0)
-		dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
-	set_bit(NFS_IOHDR_REDO, &hdr->flags);
-	spin_unlock(&dreq->lock);
-	while (!list_empty(&hdr->pages)) {
-		req = nfs_list_entry(hdr->pages.next);
+	/* -EAGAIN: requests already counted by the caller must be resent */
+	if (error == -EAGAIN) {
+		nfs_direct_write_requeue(dreq, head);
+		return;
+	}
+	while (!list_empty(head)) {
+		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
-		nfs_unlock_request(req);
-		nfs_mark_request_commit(req, NULL, &cinfo, 0);
+		nfs_unlock_and_release_request(req);
 	}
 }
 
+static void nfs_direct_write_reschedule_io(struct nfs_pgio_header *hdr)
+{
+	trace_nfs_direct_write_reschedule_io(hdr->dreq);
+
+	set_bit(NFS_IOHDR_REDO, &hdr->flags);
+	nfs_direct_write_requeue(hdr->dreq, &hdr->pages);
+}
+
 static const struct nfs_pgio_completion_ops nfs_direct_write_completion_ops = {
 	.error_cleanup = nfs_write_sync_pgio_error,
 	.init_hdr = nfs_direct_pgio_init,
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 71f0ce2bc4ea..bdf8b7305e61 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1208,7 +1208,8 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 	LIST_HEAD(head);
 
 	nfs_list_move_request(req, &head);
-	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error);
+	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error,
+					       desc->pg_dreq);
 }
 
 /**
@@ -1337,7 +1338,7 @@ static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
 	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 		mirror = nfs_pgio_get_mirror(desc, midx);
 		desc->pg_completion_ops->error_cleanup(&mirror->pg_list,
-				desc->pg_error);
+				desc->pg_error, desc->pg_dreq);
 	}
 }
 
@@ -1440,7 +1441,7 @@ int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
 	nfs_pageio_complete(desc);
 	if (!list_empty(&pages)) {
 		int err = desc->pg_error < 0 ? desc->pg_error : -EIO;
-		hdr->completion_ops->error_cleanup(&pages, err);
+		hdr->completion_ops->error_cleanup(&pages, err, hdr->dreq);
 		nfs_set_pgio_error(hdr, err, hdr->io_start);
 		return err;
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index e7497b029d6c..7047883ddb6b 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -220,7 +220,8 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
 }
 
 static void
-nfs_async_read_error(struct list_head *head, int error)
+nfs_async_read_error(struct list_head *head, int error,
+		     struct nfs_direct_req *dreq)
 {
 	struct nfs_page	*req;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 0b42d31f7a75..ab94b8a833f3 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1373,7 +1373,8 @@ static void nfs_redirty_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-static void nfs_async_write_error(struct list_head *head, int error)
+static void nfs_async_write_error(struct list_head *head, int error,
+				  struct nfs_direct_req *dreq)
 {
 	struct nfs_page	*req;
 
@@ -1389,7 +1390,7 @@ static void nfs_async_write_error(struct list_head *head, int error)
 
 static void nfs_async_write_reschedule_io(struct nfs_pgio_header *hdr)
 {
-	nfs_async_write_error(&hdr->pages, 0);
+	nfs_async_write_error(&hdr->pages, 0, NULL);
 }
 
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index c0e29b4dfa62..fce0e773bd7b 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1742,7 +1742,8 @@ struct nfs_commit_data {
 };
 
 struct nfs_pgio_completion_ops {
-	void	(*error_cleanup)(struct list_head *head, int);
+	void	(*error_cleanup)(struct list_head *head, int error,
+				 struct nfs_direct_req *dreq);
 	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
 	void	(*reschedule_io)(struct nfs_pgio_header *hdr);
-- 
2.53.0

