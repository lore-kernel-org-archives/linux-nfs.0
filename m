Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795191070;
	b=5skHb5apBSqAkOpvzG/q4YkhQ340SqhLJOXv1ErXThA2AsQ/OII7uawbr800u6sHK89C
	 wk7XqQLmzfJ/A2f8XG5TwjIleTy3oQp59KqyfAVSc+MnLU1nmKH4VD2VTecsiaangCopI
	 IXKfajwuyfb+l5sN5jlJClFk8BhcUO9yDlnm3WfKtpaSZCkckzUyytBW+O3teOsKHNe54
	 ZE+0Etfn7HT80dFW1tI6ArSyg4st9qfXZjL26t1f4OMldqpi5knXziz1LBbhKxdYBmVmQ
	 Gc+hhxL8WwtSaSfnZbog3QOOh5L8l5ZRvSBBBQqK4SSqfx6+p+OYqHlO7QnvXK5awbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795191070;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=LVJ2eom0GrgX9QPpQ1SRymkjjKT3vsNTuPiJ8337ZTI=;
	b=MDn3iqAI9JxVKqKzCfGovNzv3qeEr+pf/2Ce/UetExFUGlz2nGv+xcT70n3D0ig8VM27
	 9vvWnrWH6N4W97frH/p0Ln0DKQF5y0XIFn0o5cznqkr+RYS1PxdrAjz/yOdbmyJSLpd6O
	 nZlVkMfiJ/M359BXu+zVLpXgnp+r5GPLwHGcmLWHZ7eXs0eH3cw/6mxA2HwzsVF3pGCiu
	 mFHby4ahyzFLFpIKq/PMYFXFwwFke/s9KpBIIjNZJ+xfPlCMcw6OJdjjH6krQ1GGACSuL
	 +/9GvPfOPLM7R9uS3ntLW4TqmBMT2dzXByUXBIFsivTPrEKjgq9hReM0RDD6TbCjxFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=JmXrvsrb;
	arc=none smtp.remote-ip=209.85.210.53
Received: from mail-ot1-f53.google.com (mail-ot1-f53.google.com [209.85.210.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DD155606A320
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 16:11:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DD155606A320
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=JmXrvsrb
Received: by mail-ot1-f53.google.com with SMTP id 46e09a7af769-844a8bf7e25so624448a34.1
        for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 08:11:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795191068; x=1795795868; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=LVJ2eom0GrgX9QPpQ1SRymkjjKT3vsNTuPiJ8337ZTI=;
        b=JmXrvsrbkl91W3vL7Uspiiq/LL0rrLFBX23A6FWpPE+5RQCKnca4VR1sKl+EwXJmBi
         mRDk7qFFRIS5J/qTRo/ABXV/VKhyb7qIit/fYd116DiR7pWcERHIuLT0coIURat/LRRZ
         hMQWH8G2PtCu9Vpanh9c04+g9Mtket9au1X7HMirlgWjNHG3qK9Fwde7U5oyysmcGOY5
         fr0fYQp/o7fEnG25azLeUGv7MiHiIdj5tvNoz/6SlToRs/zc+549nnb5tRPudNoUHF3c
         XuQPLjZjzehiXDhb4gF5H6Rla1W5Nb84LL2TTbnrDhoBdeUHIE0cM6oTFnwahqlv4SyW
         Xi3w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795191068; x=1795795868;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=LVJ2eom0GrgX9QPpQ1SRymkjjKT3vsNTuPiJ8337ZTI=;
        b=ghsN3yxhB/M5MtfwDweRBaL+TX7RZQjW+oPcuk/09z01zJHg/laCgVZ+rpJVFngMcm
         FaOEF59bMJHkGq3vpiBfLf4DG8d6gso9iAjsnjR+SQofyCf7q7h5FQe2tEVrfFWVrr2b
         m6ftTAcnLj8XwH3DssA8855a5GEHsjYkpW/tGX8fpcGcNobxTl6b8/XS9omoJi98eQ8R
         0gnx5LnrMRXIY8DAhZvuqNffwkqrzafbOq5LZCfkFT6RgHTcsj2Jxuc51nTvh9icPRlQ
         M5ANegPq3gVHUmXy2DviFPtjVAzd7ir9RaNq9Il8Jeos7cbb2bODUtbJR6DYi1B9NvZ6
         RFBQ==
X-Gm-Message-State: APuU4Z+BhDEQ5f2IcMEoVWsDkyG3Jxlc6SODBfzLmf+NGphsiMLzP9vO
	sh01HkEdAWiCOEOHZsS84/+s0b1JlGa0zEf8t6rS8jXYNGB/LiswDNssvPX8k2f8sTyY2WcXEiD
	MNG4A
X-Gm-Gg: AYBFou31NrsBie+0wNqVrBtKJxv68lVtc483TLhDiXtfHla7v4A6a4gddz07JZSFnaY
	g8KeRNDiO32p8M8Cmcp9+Y9kO5XI9sk0zpCe77YJkzoJtndS6+j9HcQzBCxylKknA/RnY8KgKZe
	C3H87kgVtUjY/fXgUiVY+/fsbgzcbja/NeZdL18z9WLeVT0Kt9BmDO6KFxyzWb5N6KpPjnNdbwB
	Qpybs8IJtOf77clJlx4wpVPtG4awu/R/S5W8RuCUZvpxWK2tyHTkkfWCuF1vp6Robfk5dEhpyjg
	m9M7nw9UaL5FvMCUU1aY9QBxqT5shETqSozCvVhNMaqGYc9ByZlcZNEwm+CcJnvmUZTWTK3AC8s
	xRKJW9uHW/2xyCJAUhpLoIYJE8q1VOvrajnO2Pag0eGvDvV2Q98bZESEr2+mabdz5V94tRzQD3j
	5rop5QqklDVVHc3VtgXlcH/gCwTr90eNIBdobknPsR9DZsnUsrwUHGWiBfoTAhTBU2rVwYaKiij
	CrdLcsl9IDZkXh+BJ/Gl6aOOtonAn+MoQnjjWULCYa+ZKITPHRcHJ5I4yMHtauzEiMJSL3szCBv
	aVN2CX5rCfAaSpBjzBM2pkwrYy1eOd0hwDtC/cOi6BQ4//EAMdXGriM0E3iW6FbYVcJ1Z9B4dDc
	2cywmQVzHxxwc626I/q1MT3Gah0WPljvALQTu2IaBdIrGrtChDx9Y
X-Received: by 2002:a05:6830:438f:b0:862:aa2b:eae4 with SMTP id 46e09a7af769-863159e9bd9mr3990813a34.24.1795191068376;
        Fri, 20 Nov 2026 08:11:08 -0800 (PST)
Received: from bcodding.csb.hammerspace.com (196.sub-174-201-28.myvzw.com. [174.201.28.196])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631690fd36sm2441034a34.20.2026.11.20.08.11.05
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 20 Nov 2026 08:11:08 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/4] NFS: resend O_DIRECT write requests that error cleanup gets with -EAGAIN
Date: Fri, 20 Nov 2026 11:10:47 -0500
Message-ID: <819562dfc1402865aa0e140e9e89ca89df698bf7.1795148523.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795148523.git.bcodding@hammerspace.com>
References: <cover.1795148523.git.bcodding@hammerspace.com>
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

This also changes the other -EAGAIN cleanups of O_DIRECT write requests:
the requests queued in nfs_direct_write_reschedule()'s descriptor, a
mirror copy cleaned up by nfs_pageio_cleanup_request(), and the pages
left over when nfs_pageio_resend() fails with -EAGAIN are all requeued
rather than released.

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

