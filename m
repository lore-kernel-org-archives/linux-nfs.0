Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 159AB4E780D
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 12:21:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789734076; cv=none; b=K6iurGRIrm2qVHlfJxZETw+pvmf0k+U1cvkFYyJam4T07EW7qrpudoJPiiP2+uSl8vMxeEyTuSZgJLerMm6eSuBberrqj+pCYbynLME6FWNkQGQIeqpdF0fd/KR2v/Jv/zn/gbB0GKQn5yUGMR5lTCr55T05dARHtobszdDZdlI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789734076; c=relaxed/simple;
	bh=zuoLF5W+uDY0qQutkD3bwYk3HcfNK/EiZIQg2b0jnE8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=g7INSiz5zpXi2fzOTotHQD04H8tRyIIfZOqsr/H5hA3QgAvBUvIN6B+HyWvT6PnZXyf/l07gR59SYWBQuev541LuJIIZMyB+3Ft0HNkx2rTZfUaIOdszuk3t+fxyeSp2qjpyTeW/7k1ejz1e31hFcusTBjSyf5ae+UQDj7PXsl0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=lcqj/GOH; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lcqj/GOH"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4bf948737e1so496447b6e.2
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 05:21:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789734066; x=1790338866; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iwKuCWDKd3wCYqVqgifkMtn0UvxWWU9Zbm+F4N6DVJQ=;
        b=lcqj/GOHmAwx2zVMWB3ZW3zWXqks5U+KQsscEUecoT9RA00q8WMAmdr1/5seXDmghF
         Z+FraZ8D7MYoJ04/uKWLWlgHBTj+CM/lifKTK5kE18ePbG0xgXo5XPwx0HC+TpETFDN+
         ChC1pDJ+LKRHvLkuyesD2RdGeuQFgEezr5XPQc+an/ePiX2IQ3mWXDYPxHK/3LMRYntQ
         GN26QoHzyS2EV/Wb3ogoLRR35Eeq5aAHEAyGp3LkcSQGrwGvywvsBp0XO+7t0WJB2Njl
         3fSGW/sxYCMF+xv4DjdGmmMCJAL/oJ5AdwZ9Sactays91hT1PS5ASlZHiNVr66cMKI+E
         CKMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789734066; x=1790338866;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=iwKuCWDKd3wCYqVqgifkMtn0UvxWWU9Zbm+F4N6DVJQ=;
        b=Jx8dTB5jSQGE9ifNnPkzml32U6UjUiHflejqkCcX26ePTWlSyIm532IDXWAQW7J5oE
         paWceVyU5KH/lQiuKhBI31k7WFlgSmZRAvJqann8TLtuPT5OrwIbBl/TNBwxEE28ACtK
         b+0F/aLmSjdNMLA9XmZ8XW5wws3oDP87FuOqK5klEdKUQ5iyeYUN558lezh7EuvUAMAp
         7eghyKXKBwnsNhAusn9ZUviEGYk92zoNPAFB/xbPwuuAFA39nkhvxSUFLJxYK7w3AOSQ
         iFyCKTrZQ/rGaoXQbEuE6g66o2V4XzvSM9G3ZE/ac7IGMCqU7QOElfyLzf1jgrugOYcz
         H1xw==
X-Gm-Message-State: AFuF++nokZd015x5Yr8p+sO1RS6AFXAz/n5cSDcmimHz+1gURazM3blB
	or9wcRcmR488mfkZf8axq6JD/LU72zNegtavl1VrsedV4LMSnl4UmqhPwApI3oE++sA=
X-Gm-Gg: AYBFou3j6EXncOLrguAW9o7yPo50EYyFimWQWLmMZOaQqmWUyMWq9EK874Fn3IcbjDN
	2nQAzIhvg8WiwTbIiBUAe344G3RU1hASQ7DuvZzX1N+CzAAEpNq1+gALy0OC4QNZPgCCKun15Eq
	MZCBo9Iy4zynKt8gMCOFaUv7zrZj6PmsphslnNa6PjI4DezL4APyvD91HnYH+DS+Dmo4tq1QbHQ
	DhcxQdCIQDHsk5mT/pWCuIizqNbGHX3Js8K4HQeUPbw1tMCSenP1GXN+GN0CzN5F2Y4+xKOs5aE
	HXpHO7ZO0Zd3Z/X7mKWOTXb8qN3c8yDm9OHmzZqYJ+tffgf9E9CPHFUFcHrET8An9lYLb+RO3v3
	fj8AVlDM2loPGSKvjmqsWaN7YrHf/B0XHmGPEifBSAuD8Ufcc2Ayu7ocFUz/j8m8jx/7ghTvjeo
	uPo+GB/Mlu1eyPA4iWZ4S0ZKZ3wVroM3YovuovN0MIS0Krw4ZiyWQ95gn8WekvanDh3jBzRGKSr
	YNxlC2bvTS6ThXAszx/C3AmMMk8/6iZUlA=
X-Received: by 2002:a05:6808:350b:b0:4c3:e608:ade6 with SMTP id 5614622812f47-4ccf71a4d99mr2229512b6e.18.1789734066043;
        Fri, 18 Sep 2026 05:21:06 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4cd6ab7d9d3sm883331b6e.18.2026.09.18.05.21.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Sep 2026 05:21:05 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@kernel.org>
Subject: [PATCH 1/2] NFSv4/pnfs: Give the data server cache its own reference
Date: Fri, 18 Sep 2026 08:21:01 -0400
Message-ID: <037fabd833135d24ca8498e5fa8d6ff25a1c0383.1789733774.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789733774.git.bcodding@hammerspace.com>
References: <cover.1789733774.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Prepare the DS cache to allow data servers to outlive their layout
references.  Take a reference for the cache itself.  An entry is created
with a count of two, one for the caller and one for the cache, so a count
of one now means it is still hashed with no users left.

Entries are still torn down at exactly the same point as before; only
the bookkeeping changes.

Assisted-by: Claude:claude-opus-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 7adb6f941cf2..6d6a4d05d13e 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -713,11 +713,18 @@ void nfs4_pnfs_ds_put(struct nfs4_pnfs_ds *ds)
 {
 	struct nfs_net *nn = net_generic(ds->ds_net, nfs_net_id);
 
-	if (refcount_dec_and_lock(&ds->ds_count, &nn->nfs4_data_server_lock)) {
-		hlist_del_init(&ds->ds_node);
+	spin_lock(&nn->nfs4_data_server_lock);
+	refcount_dec(&ds->ds_count);
+	if (refcount_read(&ds->ds_count) > 1) {
 		spin_unlock(&nn->nfs4_data_server_lock);
-		destroy_ds(ds);
+		return;
 	}
+	hlist_del_init(&ds->ds_node);
+	spin_unlock(&nn->nfs4_data_server_lock);
+
+	/* The cache's reference is the last one */
+	if (refcount_dec_and_test(&ds->ds_count))
+		destroy_ds(ds);
 }
 EXPORT_SYMBOL_GPL(nfs4_pnfs_ds_put);
 
@@ -803,7 +810,7 @@ nfs4_pnfs_ds_add(const struct net *net, struct list_head *dsaddrs, u32 version,
 		INIT_LIST_HEAD(&ds->ds_addrs);
 		list_splice_init(dsaddrs, &ds->ds_addrs);
 		ds->ds_remotestr = remotestr;
-		refcount_set(&ds->ds_count, 1);
+		refcount_set(&ds->ds_count, 2);
 		INIT_HLIST_NODE(&ds->ds_node);
 		ds->ds_net = net;
 		ds->ds_clp = NULL;
-- 
2.53.0

