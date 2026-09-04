Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BC1D1492520
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526584; cv=none; b=fDquSc9dYjkJOyLbmK3/dg0akNBx2Ye9jJNMDLsy6oLWdyzjwOYCq6O+lsC/BqvPLRkVUdJfSXEi31XfT4EoZG39Veb/wehxwBRtzLGo3djxIxAk9sYB/n01Cxdi95KYqHIC8Rk5YjBy2M86jyRaPRgvdJm6m0lfsAPWrKS1+S8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526584; c=relaxed/simple;
	bh=Z3lqBTYTn3B15uQDAWxFNdGQglZ8nU7Ynvvmcl2iDQc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Fzb3bbHH/gZRTf6IjCyPnx14rkd4QymOU4qn8l4R63B38Zi80LwBbxE4feGhQXbPv55fje3A7dxqpminzSP/bQuAz3TJWdUq5PFPMcn807WKRIN/uRoWpo623zLzsEj2G800zIXKRlirQOhsEQtS7hwbiWkUjESKW4QcH4lPzuc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=WWhkpxo7; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="WWhkpxo7"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-92e50a650a0so92850485a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526581; x=1789131381; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=/15bcXL3ue1lC0Hwag6x4qBJVINJNJV7MDGInxle4Lg=;
        b=WWhkpxo7IiurrTpuFTdzjbqHPpaaCZGHpnjf0/7CTjgm6IvlZWUq2p4/kMXLuu7V2z
         uVqe7u8EF/Z3Kv6r8qZdcESb9F1axhVvIF1NqzUUHTteSDvIn5nzDSnZOl4+mPSInpZp
         mfSxKIBYY4/vMh1mX8TeJ/+qfjNmkbNPmnVJCNpXzfBFxduS0FYiT9/t48HKI1DdpqYg
         ydxSysTCCFln0ZafhcXksu3viSZL6Us5L1/elihoeGMcWWkVPHGTcQ+41v6sAjb71qVy
         nbMxG4R9O+uo3qXj2OCz7ULqUb9+a1RTpBbAtZ6DQW5TL878kW3dActtmYQd/rJzQXML
         QoXg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526581; x=1789131381;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=/15bcXL3ue1lC0Hwag6x4qBJVINJNJV7MDGInxle4Lg=;
        b=JqH6i+nc/Z0TRCZz5SkDir9Nf1clxYcL4BBt7sKOUtnk2grDED7RgBGyHd+3mSSCUv
         emVvwRwiBDRoGIdFyy52Y4diHcjgxx5787o7uuuaU28hQIcq6EDxipSsBBuKgJCgsFf2
         /KPt+O/hNfY5sox2LeUq0gc3WCMulHOZrW1qXuWgxLKNUiGsHHn+g3Ybodrz6/zG4eox
         N+sfOScwhly73mtEUkpzPj/Jzy97v4k82+Ju0RckShq73u+fytKDXopWL7+Y65FV3FvH
         lKfXCzy0ZHtZP5sjQwgbAi2nrtqiG2qSLflxvjmQwVvGj10yPk/IRkd6ZZzsc2fwmO1b
         FuVQ==
X-Gm-Message-State: AFuF++mf2hiOJODQhO63bIMkG+lBbwg+ibfAyKrYSHNs2+Fao6mVWssZ
	xKlTqUlzQL4iPqoxYViZtdzqMM2sNOcYxLMkD2obhaNhRQg9vrBf8UG/TpGboIybl2s=
X-Gm-Gg: AYBFou2nnvLRZwo8Tb0zkH5Ic0jwdLmqhYCaPkM90T33AyTpzb1QLcR6IzdWmgduCdT
	mV7Omw0pSpopavD36ohVfRppT2I6FpVpeuIHTQ8mFc4BCIZRfVOlWa0i3fa2qh27s8d8rlJIitq
	WIC6dSrP0awE58i32sk6IdY6cGkf9JhZ/IOm4MEI7aNSNhmuVeerH9QPPsV9PUcMainO0qkUlQs
	k5Uu/cjMMY/akJW8wr6kL1zEZktnUtJyiTXro7odD8ogWRyse9f70z4PO+AEwobf4NUuEYfqBtN
	/RnXZ1kCCVEJbP5LVWq6DgBMocdL6G2f6MMk7JjfmTw8r2F4AT2Zx7oRjOUDsqo8PkeoFJKeLFS
	leLlXahld+7xudUuLZtzGDfablSzEXvSSBL1/CO3L3U85MAZonPCjYsvaET5Sqi45puN/ReObvT
	Tr+GIksMir4pS/NV3RUBG4oht5GQjX1WCiEz/Uym7S+I/STxqmBiavI5hUbBcqYCweAzrtaosAi
	1HVDGBpZvoBjtPTqpKqKY48Pt3Ld4Hh6Rw=
X-Received: by 2002:a05:620a:4807:b0:939:7162:911b with SMTP id af79cd13be357-93980400249mr505644785a.32.1788526581492;
        Fri, 04 Sep 2026 05:56:21 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 6/6] NFSv4/flexfiles: allocate the per-mirror stripe array with kvzalloc_objs
Date: Fri,  4 Sep 2026 08:56:07 -0400
Message-ID: <bfd8b685bec2beb0172d0a25e948078fd335e2d7.1788453839.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788453839.git.bcodding@hammerspace.com>
References: <cover.1788453839.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Each mirror's stripe array is a single contiguous allocation of
dss_count * sizeof(struct nfs4_ff_layout_ds_stripe) -- roughly 300
bytes per stripe.  With the LAYOUTGET reply buffer no longer capped at
a single page, a wide striped layout can push this well past the
high-order allocation comfort zone (a 2048-stripe mirror is a ~600KB
contiguous allocation) where it can fail under memory fragmentation.

Use kvzalloc_objs() so wide stripe arrays fall back to vmalloc.  Note
the vmalloc fallback is unavailable when the pageio path allocates
under memalloc_noio (swap over pNFS); that case simply behaves as
before.

Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..1267eab830fd 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -285,8 +285,8 @@ static struct nfs4_ff_layout_mirror *ff_layout_alloc_mirror(u32 dss_count,
 
 	mirror->dss_count = dss_count;
 	mirror->dss =
-		kzalloc_objs(struct nfs4_ff_layout_ds_stripe, dss_count,
-			     gfp_flags);
+		kvzalloc_objs(struct nfs4_ff_layout_ds_stripe, dss_count,
+			      gfp_flags);
 	if (mirror->dss == NULL) {
 		kfree(mirror);
 		return NULL;
@@ -315,7 +315,7 @@ static void ff_layout_free_mirror(struct nfs4_ff_layout_mirror *mirror)
 		nfs4_ff_layout_put_deviceid(mirror->dss[dss_id].mirror_ds);
 	}
 
-	kfree(mirror->dss);
+	kvfree(mirror->dss);
 	kfree(mirror);
 }
 
-- 
2.53.0

