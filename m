Received: from mail-qk2-f43.google.com (mail-qk2-f43.google.com [74.125.230.235])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 936ED544D60
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.235
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703273; cv=none; b=WK7vmQY6qHfQdwVWKgLZXvuz6n1jQJ3grznf4L9XHmS8ekjViVVDrdhvBqPJY5/Nr6GdygJcAxTnBpFwMuKVg1clf2SaZY/PJNFPbSaK6ZjGmwIJBGyGSsiQrLCfMWvVZlmyABpi9FIqXjUH9nVOtjrW9zFB18dh/YGmE6+tkj4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703273; c=relaxed/simple;
	bh=j3yrc4JNVmExveq2ISpmTD1mawOSjz2nBuziTj2tfNI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZJ3q0YOWORJT9yviPlZs2L43O+aKF85xox+X0pb6KrVpwYC3DFsProC7DEEektmjH09qCd8+y+LDpwvvaO/fi6CYE8mCYbX9LawWIv4zyGISSQGXHtXmIptey8B9fHH65vKSAVRNJSAJBiOdoMMj54DKhS4+wP84eHUOFp+YcOM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=SvX8G/Q+; arc=none smtp.client-ip=74.125.230.235
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="SvX8G/Q+"
Received: by mail-qk2-f43.google.com with SMTP id af79cd13be357-93a2a8c29c4so385466485a.3
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703270; x=1791308070; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Zms2GkKUCmsNV/yp2SGkyNT6n9oSD5kRwAmFi+/+8wo=;
        b=SvX8G/Q+l5FgzhQvo/PuIw3kj1hTGPrUGksc/skumYCmepBfEniF71HYwX3tO77wM/
         iSvsiuRqxJDuev38KOrkZgc+mDDyYlf+BYW4o27lpG47AsU1GEI0wssobkQfX2vRGBYj
         9gdEyQ0LR4rf3uM4ZU/qKyINIk7vJtreTaVeUfAaluSgyblpSyUh5u0hFccbY5zmoOXY
         L2rfEQE+4ZyuhnEM3E5rMbnenxiwY1vmHsACw/988vUuJrVsNH7RdPiTlJA4WYNMf3t7
         fNrhKL/s1hPc4zC1Fhy0wlkEA/eNIucxMlQ6nXZqCgQZF1VT5dU1gGBea4Fy2gFA2B7G
         NDxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703270; x=1791308070;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=Zms2GkKUCmsNV/yp2SGkyNT6n9oSD5kRwAmFi+/+8wo=;
        b=ASYyYhTePZ8nEUy6Ltm1EBICncWhb3e3h19PtbLfU1VfdCoLTg2rqnsQydoCBBlG/i
         zLOoQthPTtTZV0cLzyK4RstBny+8eZn31iH+/nNvSy7x0ejh9NjKCUeXa/FHf54gT9Od
         ioumSPB97YPZtTSSpt1U8u7/hoX7YRbFHOS4tXFVIRVDIl2/7UDZ8x0LuESESaOfBkz5
         n++7hyQlBSyN8+DbL45dAEYsqlFONiHm1N1u983GuSkRGioDz8KVoyVUfQRhBAiI5G6/
         EFvENOlx8hXIzz6YCrHIkf2rRjvq+UEl89fmLfF8y29UnBOLiJibm0Y2EIEC7ixcthsU
         hMnQ==
X-Gm-Message-State: AFuF++nFP/cnjOsvcHq0RU8H5smkH+4nCChAIqoiDeVF+L4reSGtSIOD
	WcDi1zIM3OWgkqBA2UeQM7o96Opu8MdObJNpd9DKfB5RbO0KzAlvFVoBCmHMFbjUCdgg6rL6Nes
	IlmZf
X-Gm-Gg: AYBFou1iqBl93WBOGkLc2sl21wSld0TN9WQCsub8g7slzN9ufb1g7oz208oH69XXYMT
	L2wIlqlUDPBBE+60Ljf+EZLqF1xXRmyY62X1+vJJTLPSZPPfX3/qadJ+UTA7C5mIpnlNF8k8ldU
	uVT/R1Dodk6cEah/Hut0HRYCDxCo4U5S0xhpxOweZjhZOSBOHhUPTssj9gMU3cv5X3FALurvTPy
	lHwYSRSW5j+UdsM7RvcQEuPjOA2KjWS7ENJ3KvFnwFVIkvFvV/QA12H41Ma8TWdat4wXLTNHPKC
	U9lOxryDKODzr+lG8c+twm3q4X0jfMI15TDrzu7jKj8CSGyBTugT6pvfWWGEmKKahzGJLhmbuc0
	KTJmCzrhIoKxkVYe8nd1bHF0rBSPO7J9739dFe4CTIdIFijFBhxiWRn40r7PDotl5H+uWND/uEg
	6DOlhMsTC/qsd0nsJXXMmqExpE5ut7zqvEwARX6VzCz+hiO9nJVs/0i8AXizBdeAVyv28TnNEaR
	VHYGReu5PQgjJdZtNKEkEmf+dav7jBcdMPAX/rZOs6QJWxM7TIJzKWfHopWKyEnMvyimozRmnw=
X-Received: by 2002:a05:620a:700b:b0:93a:1ca:f14a with SMTP id af79cd13be357-93c9f7e4369mr51281585a.17.1790703269989;
        Tue, 29 Sep 2026 10:34:29 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-93c9f541cfasm20858685a.38.2026.09.29.10.34.29
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:29 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 04/10] NFSD: do not use direct I/O for a READ smaller than its alignment
Date: Tue, 29 Sep 2026 13:34:17 -0400
Message-ID: <20260929173423.16149-5-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260929173423.16149-1-snitzer@kernel.org>
References: <20260929173423.16149-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsd_direct_read() expands a misaligned READ out to DIO-aligned
boundaries: it reads from round_down(offset, dio_read_offset_align) to
round_up(offset + count, dio_read_offset_align) and returns only the
requested bytes from within that window.  When the READ is smaller than
the alignment, that window is always at least one full alignment unit,
and two when the READ straddles a boundary, so a few hundred bytes of
payload can cost a 4K or 64K device read.

Decline direct I/O for those.  A READ smaller than
dio_read_offset_align now falls through to the DONTCACHE path, which
issues DONTCACHE buffered I/O when the file system supports
FOP_DONTCACHE and normal buffered I/O otherwise.  This mirrors the
WRITE side, which already declines direct I/O for a WRITE smaller than
the larger of its offset and memory alignments.

Only dio_read_offset_align is consulted, because the READ path fills
page-aligned pages from rq_bvec and so has no memory alignment to
satisfy.  The threshold only bites when the file system advertises a
large alignment; where it reports 512 almost no READ is excluded.

Document it in the "Misaligned READ" section of nfsd-io-modes.rst.

Assisted-by: Claude:claude-opus-5[1m]
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 Documentation/filesystems/nfs/nfsd-io-modes.rst | 7 +++++++
 fs/nfsd/vfs.c                                   | 6 +++---
 2 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentation/filesystems/nfs/nfsd-io-modes.rst
index f4e7cee5ee159..bc1c0f1a7b7ca 100644
--- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
+++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
@@ -156,6 +156,13 @@ Misaligned READ:
     verified to have proper offset/len (logical_block_size) and
     dma_alignment checking.
 
+    A READ smaller than dio_read_offset_align is not issued as O_DIRECT
+    at all. Expanding it would read a whole alignment unit, or two when
+    the READ straddles a boundary, to return those few bytes. Such a
+    READ is issued as DONTCACHE buffered IO instead (normal buffered IO
+    if the filesystem lacks FOP_DONTCACHE), mirroring the WRITE that is
+    smaller than its own alignment.
+
 Misaligned WRITE:
     If NFSD_IO_DIRECT is used, split any misaligned WRITE into a start,
     middle and end as needed. The large middle segment is DIO-aligned
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index e3ce66bce00d4..1d2b03cb42963 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1186,7 +1186,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		      unsigned int base, u32 *eof)
 {
 	struct file *file = nf->nf_file;
-	unsigned long v, total;
+	unsigned long v, total = *count;
 	struct iov_iter iter;
 	struct kiocb kiocb;
 	ssize_t host_err;
@@ -1199,7 +1199,8 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		break;
 	case NFSD_IO_DIRECT:
 		/* When dio_read_offset_align is zero, dio is not supported */
-		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len)
+		if (nf->nf_dio_read_offset_align && !rqstp->rq_res.page_len &&
+		    total >= nf->nf_dio_read_offset_align)
 			return nfsd_direct_read(rqstp, fhp, nf, offset,
 						count, eof);
 		fallthrough;
@@ -1212,7 +1213,6 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	kiocb.ki_pos = offset;
 
 	v = 0;
-	total = *count;
 	while (total && v < rqstp->rq_maxpages &&
 	       rqstp->rq_next_page < rqstp->rq_page_end) {
 		len = min_t(size_t, total, PAGE_SIZE - base);
-- 
2.52.0

