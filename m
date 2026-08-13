Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6FF836C0DC
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653805; cv=none; b=POaUl7RScaub0a8d/TWDkrQA5KKql3AhDcr4YbMD9VyDV7IL4zDMgd7vF5dU5CqOT6oJwEqczIkTeDkl+/xeN4WugHiGDIbzNTkcTcl9+qD0og1jV/YQdRbAUd9R3YeOloYhbn1CsPWnyeSMRzvm2wesihzTE7zcq3rs852HKDI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653805; c=relaxed/simple;
	bh=08ZGkmFAqXdj33tjvacImra3NRf1E1reP2RT82fuTl4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Dg2B7MBJDLHIqfChrWzBj3u1VfnCYQ0G5qTnFLNpcBiMEctoKU45mBRjn4Lk82GiOiJdHAYpzh9W6iboPSY+ji5qJ6z0BjZq5ZN3psXtJHIQ0bvGJr8pSDHygOUq1CCt1ShqazoW8Peu1SBJaYPAV6TaGA8RbG4y4SYt8zgL5sQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=L7csOhgz; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="L7csOhgz"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4a4c6081f9fso86776b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653803; x=1787258603; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sK9c+ymc7r3cBeH55luik8dcwLgRAVkfdd+L+Urgcag=;
        b=L7csOhgz7nsD0swrbCq2FEpFvrV5xPXnd4CKB0YgpRVGFEj7WE23DymRLPgSYe8z9E
         QLgE+0YCibETBy3QEtO+KXegeZyw1kqcDdCSE5uQuQrOXKyaYMm7PxpWxk5ukeODNXKQ
         4iPRra4PFcb4aX0MAKBrycWWgQASPXDl+cqjC3Am+Wzp9/unkKtB8r7R7RN2DE5tjGIG
         QLfrKDdNFpKWmNXZQVC3I1KCPoCGlML19Ij2GFpiFgSNLla3oytQmpoI4wNZNRU6b5Zg
         mY2oBNbqTyzGxqMAnNonVpJvjqK3P7Zu3/ugCghs02t+P2tB6yC86nnpg/dFkyBPnXSq
         eoNg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653803; x=1787258603;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sK9c+ymc7r3cBeH55luik8dcwLgRAVkfdd+L+Urgcag=;
        b=Pz5OGK2wUIRxtsK9dK89JR6KyDlARYqLrAWzkApIDsuO8XgVEQlG8XaoBFb7jnUSRv
         lhX0wGYZLBu/XTDhsVHRmdOReh4S0ooaOzA9KU9HP9C+2D5eU8n9qfexAhFjC+oNo8sZ
         5kdr07aPJNKa2ZhjZCDukZZEgn6GGWM18as9QJOsWXjJ/NyoFp/mL4i2/CCgFzEX+Ppd
         iwE1oXmzuvv2SYkBfeIAGj0D7a6FK62vUs9nH5p8jpJHMeH/5pR4skwyJa7G1gqyjFk4
         Db+oOF6uze54ed9iGuCb3pk0Vbz9dgoCAaFyyMvenVee4QbcCuVaHW3uB4q91itULgdP
         jNRg==
X-Gm-Message-State: AOJu0Yw4rkBf1m/L2sPNmeXO3I38cXc2HA67DiSiZGavy3JcZqrRjYq9
	cnqdP4UQOCdMHJAfXVVbXtNcW5V5Txw60og+KuwUoESCOFuLQOHDFBTmcI5gBQKmuXA=
X-Gm-Gg: AR+sD10E43diwNKfvWDGJliizfrCwM80pm8yM3cDTUm5L8TeXteSfElaF1qkxjQUZhV
	TvKHrfceC/zafIGVyvWWdLZ7L9mQYE+OYJbF/VRCNXygmy+Z0ixYBMUXipwYtwW4H0+/GhDmTBJ
	kMosk/6DH2K/fLCuVp8dK7IPVkShE5lldQe83+H7J9LMazhR3vVqg0M5nDU3/kCZ8Z6xzYY9VNN
	0EGKdh+ELKcL+Kk8WnK/dJCZYipzf+dyb3onJXieV7IANyCT7ciK2Rl3oT9FzqR4pv6/Jjrgr7H
	oItaaYS3WKc+v268WAobFdB6tjhyBODuEtHYFqnKFqa0gvQZwzZJZsMFan78U1ET9bm2oZBFQJ6
	C2CVDEWJj9SN/Pdi2jMEhoyPxVN55mghde1pncT4cOQDAnIXWPck+Fnvr5g+BEeoPcQAZMiEU46
	7DW0nLBkVSurZRMNEpTvzOVbqbNJTFcQJMNic4qVuf8mXKemMm95MXJX0fCdPwOJFTbtwDYpD12
	ry/1bVww8zdqKQf6nuWWquZ
X-Received: by 2002:a05:6808:1305:b0:495:d7ec:b6be with SMTP id 5614622812f47-4b241e72187mr680159b6e.18.1786653802641;
        Thu, 13 Aug 2026 13:43:22 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:21 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 02/21] NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
Date: Thu, 13 Aug 2026 16:42:58 -0400
Message-ID: <ed7900410a357aed1d2f81c8e2a64b37a47603f7.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The read data-server selection helpers declared their offset parameter
as u32, truncating the file offset before nfs4_ff_layout_calc_dss_id()
computes the stripe index.  For striped reads at offsets >= 4 GiB this
probes DS availability and sizes coalescing against the wrong stripe's
data server; the read itself recomputes dss_id from the full offset, so
data is not corrupted.  The write path already uses the full offset.

Widen the offset parameter to u64 in the five read-selection helpers.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c4aa995026f6..cce56faa8b70 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -878,7 +878,7 @@ ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, u32 idx, u32 dss_i
 static struct nfs4_pnfs_ds *
 ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 			     u32 start_idx, u32 *best_idx,
-			     u32 offset, u32 *dss_id,
+			     u64 offset, u32 *dss_id,
 			     bool check_device)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
@@ -914,7 +914,7 @@ ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 				 u32 start_idx, u32 *best_idx,
-				 u32 offset, u32 *dss_id)
+				 u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, false);
@@ -923,7 +923,7 @@ ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 				   u32 start_idx, u32 *best_idx,
-				   u32 offset, u32 *dss_id)
+				   u64 offset, u32 *dss_id)
 {
 	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx,
 					    offset, dss_id, true);
@@ -932,7 +932,7 @@ ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 				  u32 start_idx, u32 *best_idx,
-				  u32 offset, u32 *dss_id)
+				  u64 offset, u32 *dss_id)
 {
 	struct nfs4_pnfs_ds *ds;
 
@@ -947,7 +947,7 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 static struct nfs4_pnfs_ds *
 ff_layout_get_ds_for_read(struct nfs_pageio_descriptor *pgio,
 			  u32 *best_idx,
-			  u32 offset,
+			  u64 offset,
 			  u32 *dss_id)
 {
 	struct pnfs_layout_segment *lseg = pgio->pg_lseg;
-- 
2.53.0

