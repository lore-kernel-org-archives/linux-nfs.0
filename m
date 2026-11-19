Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795120054;
	b=O++Tm5fcC5oVhNR+qmUcsgmvL/8dW+FczeLWFoHNQq/0maZivgfOEzP6pVB5kfG32riw
	 PXryk54mKk2F7Fj8upGNiEIZL7P+r2NTBRrEVjrG5OwleAbn2qOs9vx2EvvWhKysgfl/U
	 u4SePqa4QDUzl1MCljJDSG+/WO9l1mkPlBO5yA7SYQeB3DvxxvGUnEfg3SUh+hgg6jSNM
	 Zr7kg5lHHKyHsbsM69XKTxe/SaBLIrBw3rFY6njiTBcoZcp6y+1YczRz6513EVRbmgCEW
	 hBlSNpvLphLvyu4yOgj9GxJW7SFOkudLvWULI9dziQjUDEnQv+TmuFvaLgu8FXAPbHw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795120054;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
	b=gDEarENPLt1I2UtcHWJ9vRb3LRWxHizYfKb82ZOb36V1SxfyBLaQkU5vF4hjtLXdit+e
	 X4r1pd0LdPVbClZXfZAplU5jcQ2AJ9rT0fqXp1TmcFoi6ApAQJHOvvIUFHGRqPfhF5Sq3
	 FiGRBFkLZ01p2gHe0hRyFSH1ZUhMPqWpJdb58WlzT9/aF9mCS+rM+RM2B7b5qPxPv1SxD
	 9c19z5FNFJh9p6yh6RMuTONFrz5YKPLkrSqMz4vf2WGvbzVEnuXd5ElPAJFqnuXGVGP9j
	 +xyY4aNxVM7yFrm+NpCso5I+1vfeComsHr1qxqZYd1HPjUmrbm/spgt3Lm6ujrkS9cw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=cb1Qmjv0;
	arc=none smtp.remote-ip=209.85.210.45
Received: from mail-ot1-f45.google.com (mail-ot1-f45.google.com [209.85.210.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A28B260A2606
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 20:27:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A28B260A2606
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=cb1Qmjv0
Received: by mail-ot1-f45.google.com with SMTP id 46e09a7af769-8629ef8613aso77210a34.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 12:27:33 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795120052; x=1795724852; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
        b=cb1Qmjv0npYnWXIPQ/RNqU1gmkM3Ud3rNxkMPUhHok5nbJZrypbhYbxN4GwApumzNM
         ThMRCU27tzVjVNGxqU29bADn6vs3RS2q26NlRLGp3QyI6jn2bkXWvqH+McNyKj7IKn6P
         nxAqgcPtv+4QmoZB36k+xTRUY2YLs22kGJ3tvMqzzqYHL1UvoHYaLOODHFC0ez+a8dkw
         g+M5LbBc2EXR2M02KiVctQEEjLDu2aKEt9OSBQv0LiaQhX8rZ5z9t00qyiJ8SXLEhtzY
         yxkpTiLzKS3OPLRjd2n08v/ltwLgjnEOYD83wELmeaY0rEovT2rRuEd2jngZswPCrunX
         g1Cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795120052; x=1795724852;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ujNgoMLnJDtDzMYO/y2w/XnCWUTJsdcV468X64++wWc=;
        b=pc9jMO86o0CgR930Ei6MVuFLla2LfG1hcHUgLxux9ZWsBd9vZOiGlsM2EQNA2ZGpjK
         fpJLXlsa4iBQJLEyBYRJuDsQSR13oqwZQHSteP2Dc+R/4IC6vliHgnDH7alJWI0azKXI
         Jf7ANTZt58lpD6/W4q294JO17mCrDIWbqhsbuQmFJWMBUXIPtciMnbVuCdlEWSw0qKsn
         0YIo+kpkrjKe474IF2b9nMZoz2IvtszO5MoxPaloFUP4GLV/L4NFwL6MAZaRY1y+AVmn
         vAGr30BOjlo1fBS3MxSud3ZcmIks+8pM2EnlJHtjO9nZps7e1csYQq1KGA1LvyV+wB8d
         aO+w==
X-Gm-Message-State: APuU4Z/5VYgFva5aNkXSbRG+4J7Jws7Hrt/wxMAbm0rdDxT+/rrKsiZH
	cEeDL6b0nSNEt6g6D3RlK9/q4wUVvrC5hdTrDe5RUO5+Q9R4iGivOv1kkAztwXFUNhG9SfieDEH
	J5vXw
X-Gm-Gg: AYBFou1RzxBVUE59AocvGWoM1Bjyu/Vd4a6p6FheO+URwlSv3QSrYAiRnD/+Os9Mqz4
	RV2ACKnm92USkrOvqtCZcCLDvWkizZCrY+BPc+nRrPPg7k4gQ5SrOVeIBPXDGJ4NllkhEja7UN4
	aWkxkr6PNjvBOKyJTVRTUyNzwrrN969c3Xxvp7yTzMykkQeybKw90bcom0l4vcnkGT1W6JCEikB
	WYki8P3Ycd8RBxqCXjcIyJNG0zLXMZ8DaOhFryleZC+tGKg69vUtO+3WehnqcyGpQdeoRND9tPF
	ewKTm2cWD8gwKBwR4UathYW5ReXUa6SEatK012peGoDhuy7XzptxwRv4BWQblcft+MQyzhkUdc8
	9v+bX6d8nne2yXqbuhJRktBaDNsdwK4W9SXGrGxlOY4abRMs0v+s8LVUw0XYtQjejdo7j9UIzxu
	O4FWtJso4VAVSl8axj2VZsbv0VJQigDVA6tPiyAyOZF5pD/pwd0mTis7jNOx6Q2/fyuqAruKI6Z
	ibBCKrxhl9ztu/8GKUYKOCWcN/CXcQ4Vd/g4yEl7z9Ov6AUQY+QjPUgXVCjdP1VV9g8z6iHn6lX
	yznEBSv18yqmHGozkHV9lHU53JNc53InQg/ht68mqmgLabPz4imNAorsJHiXCTbeyfUpwip5JIc
	+
X-Received: by 2002:a05:6830:448d:b0:85f:1601:d3 with SMTP id 46e09a7af769-863157af868mr1142612a34.23.1795120052541;
        Thu, 19 Nov 2026 12:27:32 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-863168dde05sm506933a34.13.2026.11.19.12.27.31
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 12:27:32 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/5] NFS: make the O_DIRECT write work a delayed_work
Date: Thu, 19 Nov 2026 15:27:25 -0500
Message-ID: <f3decfbd07b417383b170eb2bafc1000cd849578.1795117974.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1795117974.git.bcodding@hammerspace.com>
References: <cover.1795117974.git.bcodding@hammerspace.com>
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

nfs_direct_write_complete() queues dreq->work on nfsiod_workqueue to
commit, reschedule or complete an O_DIRECT write.  Make it a
delayed_work, queued with no delay, so that a reschedule can be paced
without sleeping in the worker.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/direct.c   | 8 +++++---
 fs/nfs/internal.h | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index a3c6e8f4ea06..9ef8031a68ad 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -219,7 +219,7 @@ static inline struct nfs_direct_req *nfs_direct_req_alloc(void)
 	init_completion(&dreq->completion);
 	INIT_LIST_HEAD(&dreq->mds_cinfo.list);
 	pnfs_init_ds_commit_info(&dreq->ds_cinfo);
-	INIT_WORK(&dreq->work, nfs_direct_write_schedule_work);
+	INIT_DELAYED_WORK(&dreq->work, nfs_direct_write_schedule_work);
 	spin_lock_init(&dreq->lock);
 
 	return dreq;
@@ -739,7 +739,8 @@ static void nfs_direct_write_clear_reqs(struct nfs_direct_req *dreq)
 
 static void nfs_direct_write_schedule_work(struct work_struct *work)
 {
-	struct nfs_direct_req *dreq = container_of(work, struct nfs_direct_req, work);
+	struct nfs_direct_req *dreq = container_of(to_delayed_work(work),
+						   struct nfs_direct_req, work);
 	int flags = dreq->flags;
 
 	dreq->flags = 0;
@@ -760,7 +761,8 @@ static void nfs_direct_write_schedule_work(struct work_struct *work)
 static void nfs_direct_write_complete(struct nfs_direct_req *dreq)
 {
 	trace_nfs_direct_write_complete(dreq);
-	queue_work(nfsiod_workqueue, &dreq->work); /* Calls nfs_direct_write_schedule_work */
+	/* Calls nfs_direct_write_schedule_work */
+	queue_delayed_work(nfsiod_workqueue, &dreq->work, 0);
 }
 
 static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 5af6a032f145..8f1361397f8f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -1035,7 +1035,7 @@ struct nfs_direct_req {
 	/* commit state */
 	struct nfs_mds_commit_info mds_cinfo;	/* Storage for cinfo */
 	struct pnfs_ds_commit_info ds_cinfo;	/* Storage for cinfo */
-	struct work_struct	work;
+	struct delayed_work	work;
 	int			flags;
 	/* for write */
 #define NFS_ODIRECT_DO_COMMIT		(1)	/* an unstable reply was received */
-- 
2.53.0

