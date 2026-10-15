Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AD3351AFF8
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 20:58:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792097898; cv=none; b=HzvKDWUAQU+QJB0giCccDF2XABPjKB9+1hKZ8flHGiRsHRPQAY994AF/WCwegnSsJWq3MmNni9RBspITPYgWh5qsuKuWff4e6wfn7YORPKRdrGbNI93A97cXxhB/rUjhhZ7jzf3xeOsyRUFzUOtfw7oFO3E+Fg7td3UesxrTPLg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792097898; c=relaxed/simple;
	bh=MJ8Qqco3gXgSKKB5ftH5gHSRU2OcsBWhXrEtclk1G0I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FSCaVdC5U94F9dgaFHr3ED+jNFsQBgwh6figS55Xngx6Eyp7FcnzPLaqhFMpFdmXX2wK4gkkjZQPO5eLH0op/+wonQ687wm/eNnxrAmB+EIPgLVqn5YWI+gw0ZIsnlLoFr9ku9wmIJoPVg9Faj++1td8PBfDmzUnhpwGlGRWW54=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=iO6ld1jK; arc=none smtp.client-ip=209.85.167.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="iO6ld1jK"
Received: by mail-oi1-f174.google.com with SMTP id 5614622812f47-4f55a53898cso3004756b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 13:58:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792097893; x=1792702693; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ygsaoCXwocs1UawNGUSlu18oh0KhrI7AlO/nxA6DhJY=;
        b=iO6ld1jKHUYa41XQJ0eng4XdryWAeT0DmvYugEkZ65RJIvDwGFZn7M5zy28hkRGTJJ
         QU1TZ+QR+A4/BzfRwqcUbEF04B7WEIMz3NIK+0ZHPeRjgo5PuEVSl4AX1NxcGoXrGyZK
         yjnD35HewG7ouC2dcpoSy9YnB5bC3IEpjjMs+ENNYl/w1cFlhjn64T6g0ROJM6+miI2N
         NR24F9oGcrV7pCGB5MWAVtNn0q78IWbcy8aB3HRD3j6PIrtp32ZWRd6+YWiBlHW8MfDA
         u+rOXqPwDWyf+jrOGiTfhejg8notmKM7NW3neVTuJfIpjIcF9IIL/ed92NbH6Ig1SJnK
         B7Lw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792097893; x=1792702693;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ygsaoCXwocs1UawNGUSlu18oh0KhrI7AlO/nxA6DhJY=;
        b=IE9zFF4qlRNN/U0pSecEUkWWRE/KKGJcpZafBqpgvQm+Il/x93z/kv0U6OFk9iiS0q
         bAYjYghMJbPmpasFzrDtwRja8DvZNO/ZrdviZfkD85sF6ZMG7HKMKXi7HccOx3Be1kTw
         Hv0og9aixI0wSHx0WWVuKRR7hPMZceG2zwaPbtmluNrtR3S56fmrEFXEH6LNloSrDo3V
         wMzwGermyE20eio7qZMsc67qTZBh4Li5FqH9hvYptmPvSdNv+InGNlanPwz80Z59cLcX
         bcelZSFlMuCC0gTikGYgF9SjsRTcGs34YQEnKOaWlhwLf4k1lz+BS8fyMhu3f0B/4Ov4
         BbrA==
X-Gm-Message-State: AFq9FYIyU1n1oCpx8LmVTHbBLgFDlrLlXTP3GDn/rhGNspwOifZPekic
	mxSaFInQ8bUIleAc6NmmkcOucDlO8ydsEvbaau28daduLFp+9+RRWU7Kvs2ZNyidHoY00d8mvqE
	0fquC
X-Gm-Gg: AYBFou3OX1GUPhTz0srPYBIhs41GMPIofafUDPKiXHm8tnVVSzb4L9w0B7te3/9R1vf
	Ble6oLp+fsbJqNC+kkNIdFWh/vQcYfUhwJqRP3VJyKOuJZA2xYPFPAzn+9DKxOYyiK5RupPr9OY
	u1lq7a2KDV0qW6G6V7Jp/d5DSY0uJuac3Rj1DvxclISSwANgNMbo4do7sb5V/r6V77RsDXZ3jSU
	Adlj529T5+/em48Cc7lhSUuUoKA2GnE9GtVBJHIjBlWnpeb3cg8ODX5DwWNJH3yq+bdVxPSDHf8
	218NDiqd9Zqi3PW78I5qqzhrj221bUg9v5dIS9oVFQjHXQd1SheMUNPXjllYFY0N3+J0TMrGPFb
	0dzi4/gekjsGZ6CuS/3nLTCGbwSoCZcJX9S+TaztGERi1G9x51KsnwvdgJ3wEpUfV8UqTvq41Md
	YG9OjPYmPlf4igWtMZz0DLQj8743lDzzufwap5HF+aZKBVuLk5moko4GdDOD9K0Q+JqtOMKpdqw
	LjHveu+U7F12WuTvzDeBfYlZStfdxjLxqNvy/nMWJ0Yceno+1Ux
X-Received: by 2002:a05:6808:10d3:b0:4e7:a404:92e3 with SMTP id 5614622812f47-50c532f4788mr18535923b6e.17.1792097893197;
        Thu, 15 Oct 2026 13:58:13 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388c1654e9sm25514b6e.8.2026.10.15.13.58.11
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 13:58:12 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFS: Resend unsent mirror requests when an O_DIRECT write hits -EAGAIN
Date: Thu, 15 Oct 2026 16:58:08 -0400
Message-ID: <0235209fab33cef50ae589bad9baf4bbcdb3efa2.1792097624.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792097624.git.bcodding@hammerspace.com>
References: <cover.1792097624.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

nfs_pageio_add_request() adds each page to mirrors 1..n before mirror
0.  When ff_layout_pg_init_write() finds that a recalled layout came
back with a different mirror count, it fails the descriptor with
-EAGAIN, and nfs_pageio_error_cleanup() runs the error_cleanup of every
mirror's queue.  For O_DIRECT that is nfs_write_sync_pgio_error(),
which releases the requests.  Mirrors flush at their own wsize, so the
released requests can be one mirror's share of bytes another mirror
has already written.  nfs_direct_write_schedule_iovec() treats -EAGAIN
as soft and reschedules only the current page and those after it, and
the bytes the other mirror wrote are counted: the write succeeds while
one mirror never receives that part of it.
nfs_direct_write_reschedule() loses requests the same way when the
layout changes during a resend.

Pass the descriptor to error_cleanup, and on -EAGAIN have
nfs_write_sync_pgio_error() mark the queued requests for rescheduling,
as nfs_direct_write_reschedule_io() does for a failed header, instead
of releasing them.  nfs_pageio_resend() passes no descriptor and keeps
its current behaviour.

Fixes: 8b0401373734 ("pNFS/flexfiles: Fix list corruption if the mirror count changes")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c         | 28 ++++++++++++++++++++++++++--
 fs/nfs/pagelist.c       |  6 +++---
 fs/nfs/read.c           |  3 ++-
 fs/nfs/write.c          |  5 +++--
 include/linux/nfs_xdr.h |  5 ++++-
 5 files changed, 38 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index ccafdc1ce64d..a5e5fd4b1812 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -286,7 +286,8 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_read_sync_pgio_error(struct list_head *head, int error)
+static void nfs_read_sync_pgio_error(struct list_head *head, int error,
+				     struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_page *req;
 
@@ -796,10 +797,33 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_write_sync_pgio_error(struct list_head *head, int error)
+static void nfs_write_sync_pgio_error(struct list_head *head, int error,
+				      struct nfs_pageio_descriptor *desc)
 {
+	struct nfs_direct_req *dreq = desc ? desc->pg_dreq : NULL;
+	struct nfs_commit_info cinfo;
 	struct nfs_page *req;
 
+	/*
+	 * The layout changed under the descriptor: the queued requests were
+	 * never sent, and may be another mirror's share of a write that has
+	 * already completed elsewhere.  Resend them with the rest.
+	 */
+	if (error == -EAGAIN && dreq) {
+		nfs_init_cinfo_from_dreq(&cinfo, dreq);
+		spin_lock(&dreq->lock);
+		if (dreq->error == 0)
+			dreq->flags = NFS_ODIRECT_RESCHED_WRITES;
+		spin_unlock(&dreq->lock);
+		while (!list_empty(head)) {
+			req = nfs_list_entry(head->next);
+			nfs_list_remove_request(req);
+			nfs_unlock_request(req);
+			nfs_mark_request_commit(req, NULL, &cinfo, 0);
+		}
+		return;
+	}
+
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 7dd478ffc2fa..06e301c8c291 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1162,7 +1162,7 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 	LIST_HEAD(head);
 
 	nfs_list_move_request(req, &head);
-	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error);
+	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error, desc);
 }
 
 /**
@@ -1291,7 +1291,7 @@ static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
 	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 		mirror = nfs_pgio_get_mirror(desc, midx);
 		desc->pg_completion_ops->error_cleanup(&mirror->pg_list,
-				desc->pg_error);
+				desc->pg_error, desc);
 	}
 }
 
@@ -1394,7 +1394,7 @@ int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
 	nfs_pageio_complete(desc);
 	if (!list_empty(&pages)) {
 		int err = desc->pg_error < 0 ? desc->pg_error : -EIO;
-		hdr->completion_ops->error_cleanup(&pages, err);
+		hdr->completion_ops->error_cleanup(&pages, err, NULL);
 		nfs_set_pgio_error(hdr, err, hdr->io_start);
 		return err;
 	}
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 2b70bd2b934b..1e6a88d5ea7c 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -220,7 +220,8 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
 }
 
 static void
-nfs_async_read_error(struct list_head *head, int error)
+nfs_async_read_error(struct list_head *head, int error,
+		     struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_page	*req;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 623e7ef1f73d..50f381b19fab 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1375,7 +1375,8 @@ static void nfs_redirty_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-static void nfs_async_write_error(struct list_head *head, int error)
+static void nfs_async_write_error(struct list_head *head, int error,
+				  struct nfs_pageio_descriptor *desc)
 {
 	struct nfs_page	*req;
 
@@ -1391,7 +1392,7 @@ static void nfs_async_write_error(struct list_head *head, int error)
 
 static void nfs_async_write_reschedule_io(struct nfs_pgio_header *hdr)
 {
-	nfs_async_write_error(&hdr->pages, 0);
+	nfs_async_write_error(&hdr->pages, 0, NULL);
 }
 
 static const struct nfs_pgio_completion_ops nfs_async_write_completion_ops = {
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 7ed8fdb930d6..858d2bba8003 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1739,8 +1739,11 @@ struct nfs_commit_data {
 	unsigned long		flags;
 };
 
+struct nfs_pageio_descriptor;
+
 struct nfs_pgio_completion_ops {
-	void	(*error_cleanup)(struct list_head *head, int);
+	void	(*error_cleanup)(struct list_head *head, int error,
+				 struct nfs_pageio_descriptor *desc);
 	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
 	void	(*reschedule_io)(struct nfs_pgio_header *hdr);
-- 
2.53.0

