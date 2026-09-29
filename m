Received: from mail-qv2-f41.google.com (mail-qv2-f41.google.com [74.125.230.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42C53556B91
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 17:34:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.230.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790703275; cv=none; b=rL/Sp7OjiMxHs6hIJKFVH/vYfuf3ntAZVf4xMR+GIBJ8JXJksAbTYt9tedKgsrgJbXya0p/eYqTznV+POjGZfFK2TzO0XX2gHwh3ZHLju5XgaEQfBxRyxLZX9aSNxl/iKfL3pvOmlziywvx92+mDm26AfptohJ6OoAIJPi3RIDM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790703275; c=relaxed/simple;
	bh=YPmaVkaVbZEQXJYJ++HHdrhiiTev1Og/Gtt9iEYK9vc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CGt4U1GNj/JDYM/9H0dpwk++but6pXHrjpH1JpF7hoUpypjm8KmoOKADuHXE1aNgb2vF18Cb693uwH2aZWcqtTCBpRQtpGBB8d9tjOe5KaDXjuNmrlb2RAjbuARwzLUm9++BjfEtjnZr1hZ6BvMVHJARUmGOBi0SDhUxwhzqCQU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=FMQrGXNE; arc=none smtp.client-ip=74.125.230.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FMQrGXNE"
Received: by mail-qv2-f41.google.com with SMTP id 6a1803df08f44-917858a0019so11906586d6.2
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 10:34:34 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1790703273; x=1791308073; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iC16thcb3BG4vOnw+Ss5xDB8R4C9yo9t2bvS7Al26o0=;
        b=FMQrGXNEZ7oSiWTX17VJvg3V1Tepa9ZJRwc6uFPIogwPUBSmGMAC9LbnMsjGeHeh6A
         ZQ+Rjwg6gS7GoJIwWhkQjxgDpruZE1HttttSLv0ufvD/709WYroDibELCUbxs68r5W/G
         To37M1RFzJDKgpnl20kRoMjlAZPlDqoWjI7XmV4ebvAfX5iGjBnVFy9REe5jbzdbvDa9
         HBe6Bk7LIBnFX93pDts6DYK26Q9hbm+b9Gaqr2V3NCmkrFEAF8kx7w9ndw6mOiZMyUuB
         PRlzgX98IkvULvh+kfPztaITa3Nheih9jnrQmGMAzSVFnacjh901MS8s3wmFqgaCl/O5
         muiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790703273; x=1791308073;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:sender:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iC16thcb3BG4vOnw+Ss5xDB8R4C9yo9t2bvS7Al26o0=;
        b=nGkZIJlpeaWcXzDL0UroV3cbIDMMz0LcVwZ10uAYGUHfPdNAc9IA4a2ZrfeIVuqehi
         DT7XJTtFtIvueHnW/y7C4C1TnGmRaL+3U8ljFHei7P2Hnnp6KxAntKXbgE69s8wdV4WY
         m1SFR09fwKV5qmvBRmsvBySbTKWGAHHz4XdQA1+94TQUYWqesVT5bwL8ggdXKwl5aGYF
         /SfEg860KjgM8+2/3av2ok5pK5NjxitIj3Z6lZSnNrdu00BpbbV28Nkrx28veLOquGrM
         WOoC3PnQvMQO1C5zRG1Eo7D8K+ZeE95s7IbR/ldAOvXpfQt8IgHtP7ghqpGZY4a+iXA7
         LK9Q==
X-Gm-Message-State: AFuF++mUg4e+qRpB9KSj3kmGJawhgX/WK04BicARl871sIZTKdUkel9R
	Ug99PuLCe/hvZRNI2Jb0iZTYo2iNBSBWwCwD+TciMqPUwK0GqzcRjxHpAORM0/dLLVI=
X-Gm-Gg: AYBFou0QyOU9nQxYaYxVcvUHgG/+BqgbWUaBhN+Vz7zjkYWy4bzEYqVtOLS87W7PkCr
	nZnT6rbTGO8hUa818BTAhPNbL3t1mRgKxTsF2SIXQX1k1HW7cV9hg7i8v27SEq3QVofsne3FNdT
	wt3xH69orQFQ6vS0MVCHwQ7NmaBQWv4Q265GYgL7v5ntB2WSvlZ5901XP7X6GEpQosCa1VbTFmj
	T0QL8wuz1vidyCLbyAJUmFJQA1ZO+b0IqzI/3BLcrRJrRmVTvnmkvMgI4Sh0DyCI/9PDVMnMVSd
	QE29BwmTDehnTpslz/x3tHALEkudzUfgQ8mzXfKfXSYcnfzhSimVvNZ/BqWOi2q0f34KHDYRfjB
	GEn8R4czQVAvi0QGlKzFqwqH0MCxh49VnvXkBOGbSxCRjd6smU7KYlLWwQf6kuFc05v516bVQMO
	xKnxRkBfuGH7gy/f3h2vURPUhQ276uKPzLBDO7ILayuEl3ZYqyMBYC5WgLsppi6BcL+xaIwGb77
	GAGoVxNG76lZhlcZdw85AzXeEnEtArMoIYMG2UVttBxV4hbxSsiFYLz4+IGf0HMHOUOX8cEZf/C
	PmxNjGd2FA==
X-Received: by 2002:ad4:5aa9:0:b0:917:8c52:f52a with SMTP id 6a1803df08f44-9178c52f5d2mr41830686d6.34.1790703273004;
        Tue, 29 Sep 2026 10:34:33 -0700 (PDT)
Received: from localhost (pool-68-160-167-46.bstnma.fios.verizon.net. [68.160.167.46])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-9179892de77sm382636d6.39.2026.09.29.10.34.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 10:34:32 -0700 (PDT)
Sender: Mike Snitzer <mike.snitzer@hammerspace.com>
From: Mike Snitzer <snitzer@hammerspace.com>
X-Google-Original-From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 07/10] NFSD: persist a synchronous direct-mode WRITE once, after all of its segments
Date: Tue, 29 Sep 2026 13:34:20 -0400
Message-ID: <20260929173423.16149-8-snitzer@kernel.org>
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

nfsd_direct_write() may issue a WRITE as up to three segments: a
buffered prefix, a direct middle and a buffered suffix.  For a
FILE_SYNC or DATA_SYNC WRITE (from the client, or as the floor imposed
by NFSD_IO_DIRECT_WRITE_{DATA,FILE}_SYNC) the kiocb carries IOCB_DSYNC
and every segment inherits it, so generic_write_sync() runs a range
fsync after each segment: up to three cache flushes and log forces per
WRITE, and each one writes back and drops the boundary page it just
touched.

Strip IOCB_DSYNC and IOCB_SYNC from the per-segment flags and persist
the WRITE once with vfs_fsync_range() over the bytes actually written,
after the last segment.  Durability is unchanged: the reply is not sent
until the fsync completes, and datasync mirrors the previous per-segment
choice (IOCB_SYNC present means metadata too).  An fsync failure is
returned like a write failure.

Besides the fewer flushes, this puts the sync under NFSD's control,
which the next change uses to keep the boundary pages of a split WRITE
cached until the partner WRITE completes them.

Assisted-by: Claude:claude-fable-5-1
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/vfs.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 924c5992dc32e..827dfe0b5dac7 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1423,6 +1423,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	struct nfsd_write_dio_seg segments[3];
 	int floor_iocb_flags = 0;
 	struct file *file = nf->nf_file;
+	loff_t start = kiocb->ki_pos;
+	bool sync, datasync;
 	unsigned int nsegs, i;
 	ssize_t host_err;
 	size_t expected;
@@ -1435,12 +1437,21 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		nfsd_write_raise_stability(floor_iocb_flags, kiocb,
 					   iocb_flags);
 
+	/*
+	 * A synchronous WRITE (client FILE_SYNC/DATA_SYNC, or a floor set by
+	 * the IO mode) is persisted once, after all of its segments, rather
+	 * than by generic_write_sync() after each segment: one cache flush
+	 * and log force instead of up to three.
+	 */
+	sync = kiocb->ki_flags & IOCB_DSYNC;
+	datasync = !(kiocb->ki_flags & IOCB_SYNC);
+
 	nsegs = nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
 					  kiocb, *cnt, segments);
 
 	*cnt = 0;
 	for (i = 0; i < nsegs; i++) {
-		kiocb->ki_flags = segments[i].flags;
+		kiocb->ki_flags = segments[i].flags & ~(IOCB_DSYNC | IOCB_SYNC);
 		if (kiocb->ki_flags & IOCB_DIRECT)
 			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
 						segments[i].iter.count);
@@ -1458,6 +1469,13 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 			break;	/* partial write */
 	}
 
+	if (sync && *cnt) {
+		host_err = vfs_fsync_range(file, start, start + *cnt - 1,
+					   datasync);
+		if (host_err < 0)
+			return host_err;
+	}
+
 	return 0;
 }
 
-- 
2.52.0

