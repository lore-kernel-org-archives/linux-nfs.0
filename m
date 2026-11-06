Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793989284;
	b=Pc/IVp9KgRHukO0owOwCwY+c1gG101v1ekwkUMvzw0krOo/Q3VdL0MbuCcSaLzcAzfHE
	 MZ8YzqRNw1GO8HA6EDVv74WwkUE33CfAQal0gExhSJLn1KDX555T9UW8qxJlzuSzFr3xS
	 ev+1WfPA2fbrqpJtUZYDiRc/3sfrAQkGMdQGR/mQ2Oiq48XmmU1uOpRqyb51jfnNBtH37
	 YnAxn6modtqs/OkbW+B8xYUvJQ/I33RQQjUuMRW0RUe5ydC59ReVzrQQsmZAV7/QedYr7
	 j406nx4vDCoYeLL/MEJ9jddkJV6HK30bZe0LGXNr1S5U5K1JIzoBrFvf07FqMTJEQcQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793989284;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=oS5SkjD+2sVMd8HTwcVp4YzUgo3hMjFk+KSTLizU/O4=;
	b=eaFDHTK84ypsRck2w/p5Eyj6cgHLDivukU31neYaG8Vx206IthdSUDktGymAP/hVGkjK
	 4XTot/CtIJ+Myqs7s5GVGjm+159pUv31B0O3fGyIfjTTBsZ0CUhStlPW+SN2cM1vSUpoG
	 h8MsTLLNF1tlMjmliUZIqyczW1xX3FupSoQ0aRogxN5kUBHDNO4RTfZrktyCYk3g30+1z
	 Pd1RKL5xty0q5Hw4JmStJYMWZmQ9ii5BVsetfI2PNeyx2KrGCVqsC4ze11HsFaEnbO7sm
	 jdKT2+XxDXYv0KT6fSh1/isNZNqE/teRdUk0XR0zS2n1nks7j7rnszX9j45CrWI4Jxw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nLto73IW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00497606A32D
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 18:21:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nLto73IW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 87A651F008BD;
	Fri,  6 Nov 2026 18:21:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793989283;
	bh=oS5SkjD+2sVMd8HTwcVp4YzUgo3hMjFk+KSTLizU/O4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nLto73IW6eRu3E9Nx2D3oWRIKjSZThAPtRhdgjSpzzrkF6f8r+JNs6BG5tKHLbGGq
	 ROFeum4Y0o/mD2dOU/UJK9M0xnuWrl1MrE7gTsoPtelm8scxr9Ss/M85j2nq+PVYuH
	 YP1wJ3XnQokg6+euOy/1zWnV8KVGOZCQFiHOQ6q/eRtZ7GG8yC2t8p0weQHOrXDuvw
	 biHquv3WvLqJlDuC0miedSLZf9mbhTFi4h0Ux5pHIsL8K7/IaVa9/JxWigAw1wq9Jc
	 6/ZJw0ObPnBKA0dKJ4aC858nL2uJsliUPh3v8NDRqIepibg5EKLbwMBCrmW/i2Stux
	 Bjlvqq5CfbOUQ==
From: Mike Snitzer <snitzer@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>
Cc: Mike Snitzer <snitzer@hammerspace.com>,
	linux-nfs@vger.kernel.org,
	Jonathan Flynn <jonathan.flynn@hammerspace.com>
Subject: [PATCH v3 12/12] NFSv4/flexfiles: share one helper for the start of a read and a write
Date: Fri,  6 Nov 2026 13:21:00 -0500
Message-ID: <20261106182105.78611-13-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20261106182105.78611-1-snitzer@kernel.org>
References: <20261106182105.78611-1-snitzer@kernel.org>
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

From: Mike Snitzer <snitzer@hammerspace.com>

nfs4_ff_layout_stat_io_start_read() and
nfs4_ff_layout_stat_io_start_write() differ only in the statistics they
update.  Replace them with nfs4_ff_layout_stat_io_start(), which takes
the direction of the I/O.

No functional change.

Suggested-by: Anna Schumaker <anna@kernel.org>
Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 62 +++++++-------------------
 1 file changed, 17 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 31d5dbd4debcc..000fddeaeb2a9 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -803,21 +803,21 @@ nfs4_ff_layoutstat_end_io(struct nfs4_ff_layoutstat *layoutstat,
 }
 
 static void
-nfs4_ff_layout_stat_io_start_read(struct inode *inode,
-		struct nfs4_ff_layout_mirror *mirror,
-		u32 dss_id,
-		__u64 requested, ktime_t now)
+nfs4_ff_layout_stat_io_start(struct inode *inode,
+			     struct nfs4_ff_layout_mirror *mirror,
+			     u32 dss_id, bool write,
+			     __u64 requested, ktime_t now)
 {
 	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
-	bool report;
+	struct nfs4_ff_layoutstat *layoutstat =
+		write ? &dss_info->write_stat : &dss_info->read_stat;
 
-	spin_lock(&dss_info->read_stat.lock);
-	nfs4_ff_layoutstat_start_io(&dss_info->read_stat, requested, now);
-	spin_unlock(&dss_info->read_stat.lock);
+	spin_lock(&layoutstat->lock);
+	nfs4_ff_layoutstat_start_io(layoutstat, requested, now);
+	spin_unlock(&layoutstat->lock);
 
 	nfs4_ff_layoutstat_set_start_time(dss_info, now);
-	report = nfs4_ff_layoutstat_report_due(dss_info, now);
-	if (report)
+	if (nfs4_ff_layoutstat_report_due(dss_info, now))
 		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
 }
 
@@ -837,25 +837,6 @@ nfs4_ff_layout_stat_io_end_read(struct rpc_task *task,
 	spin_unlock(&dss_info->read_stat.lock);
 }
 
-static void
-nfs4_ff_layout_stat_io_start_write(struct inode *inode,
-		struct nfs4_ff_layout_mirror *mirror,
-		u32 dss_id,
-		__u64 requested, ktime_t now)
-{
-	struct nfs4_ff_layout_ds_stripe *dss_info = &mirror->dss[dss_id];
-	bool report;
-
-	spin_lock(&dss_info->write_stat.lock);
-	nfs4_ff_layoutstat_start_io(&dss_info->write_stat, requested, now);
-	spin_unlock(&dss_info->write_stat.lock);
-
-	nfs4_ff_layoutstat_set_start_time(dss_info, now);
-	report = nfs4_ff_layoutstat_report_due(dss_info, now);
-	if (report)
-		pnfs_report_layoutstat(inode, nfs_io_gfp_mask());
-}
-
 static void
 nfs4_ff_layout_stat_io_end_write(struct rpc_task *task,
 		struct nfs4_ff_layout_mirror *mirror,
@@ -1772,12 +1753,8 @@ static void ff_layout_read_record_layoutstats_start(struct rpc_task *task,
 		mirror->dss_count,
 		hdr->args.offset);
 
-	nfs4_ff_layout_stat_io_start_read(
-		hdr->inode,
-		mirror,
-		dss_id,
-		hdr->args.count,
-		task->tk_start);
+	nfs4_ff_layout_stat_io_start(hdr->inode, mirror, dss_id, false,
+				     hdr->args.count, task->tk_start);
 }
 
 static void ff_layout_read_record_layoutstats_done(struct rpc_task *task,
@@ -2002,12 +1979,8 @@ static void ff_layout_write_record_layoutstats_start(struct rpc_task *task,
 		mirror->dss_count,
 		hdr->args.offset);
 
-	nfs4_ff_layout_stat_io_start_write(
-		hdr->inode,
-		mirror,
-		dss_id,
-		hdr->args.count,
-		task->tk_start);
+	nfs4_ff_layout_stat_io_start(hdr->inode, mirror, dss_id, true,
+				     hdr->args.count, task->tk_start);
 }
 
 static void ff_layout_write_record_layoutstats_done(struct rpc_task *task,
@@ -2121,10 +2094,9 @@ static void ff_layout_commit_record_layoutstats_start(struct rpc_task *task,
 
 	idx = calc_mirror_idx_from_commit(cdata->lseg, cdata->ds_commit_index);
 	dss_id = calc_dss_id_from_commit(cdata->lseg, cdata->ds_commit_index);
-	nfs4_ff_layout_stat_io_start_write(cdata->inode,
-			FF_LAYOUT_COMP(cdata->lseg, idx),
-			dss_id,
-			0, task->tk_start);
+	nfs4_ff_layout_stat_io_start(cdata->inode,
+				     FF_LAYOUT_COMP(cdata->lseg, idx),
+				     dss_id, true, 0, task->tk_start);
 }
 
 static void ff_layout_commit_record_layoutstats_done(struct rpc_task *task,
-- 
2.52.0

