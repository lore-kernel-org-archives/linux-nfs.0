Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com [209.85.167.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0A24F45C700
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:36:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792150607; cv=none; b=I/QdW4tC8RoqG8udpbbgpjtLhM+O13cy1Yr+2fhw30UJKmSLrN+98lap3T+6LUsufzfP6aJqekqgvo+249zrI6O5khLad358YLSwRxX7M2Zr52/g8NhplkX6UdLqGQCXRv3EJyXjlJ3Hh8ALtHYxvfH/2O+eJUzI94UGh20EwbE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792150607; c=relaxed/simple;
	bh=ZjMGbipjQ7PvtjHshvflwQ66C5c2lfFtK/t8iTY4GYo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nmgv+phTJVDyCZ1ltrMgtwAGbanK/GuiGdbPSsQc5tVD/liS9/FXdESEeYHJIQ7qLMKlNuY4KeCTyyyIKNVTIyWlgFeRV2MRFIjnfAY1ZD9kf8pSpxG7y4wBiHVw3x8wv0qSJITkex0fc/seIFmZda1T+sIqEqeBNjBYhBAGJFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Vlfh7Wsw; arc=none smtp.client-ip=209.85.167.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Vlfh7Wsw"
Received: by mail-oi1-f170.google.com with SMTP id 5614622812f47-4b28d7c729fso1416379b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 04:36:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792150605; x=1792755405; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=IUZeQP6zWoDBevTGz755Qp6CZmqiuevebAzjTg0ZcXg=;
        b=Vlfh7WswYU021MyxSUUk6zxWIzPcYvjGUJSh3IC1ERnxWTda9BpcmpbstqFZVcUTZM
         ICSC+7+8ppu1m48Mnp0W0gSDJetN+MtnHgN7ySuHgCtPb4kHbU/kpZ/RynM1hXYyoQkU
         r7wIC3mNajINTsTggY415XNspNW49KaIhkBsWoBw5hGw657XcoC1LbvGD5MilwC+dzev
         usc/mkFYOD3WM9FB8p9Oc+YH6LvkgORKDaw8XzjgyP9vPIf8GgMjef+R58vPcDHIXY+O
         RMJ3jiHQy71dgTeZpZdQH5tCHdyJMWEA25jMZqgTCVfnPkeZFjRkoBGGt1D1feOEHL0A
         PEHw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792150605; x=1792755405;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=IUZeQP6zWoDBevTGz755Qp6CZmqiuevebAzjTg0ZcXg=;
        b=z03Jnb38sBAG4eXVgIy8iCwYunhmBJ1d9Ke1kV4Xj0hcQtksZk44QPFbVuvp8DanSp
         Lyrp/NZE8A5K9COnmPhISp5tcxxClA89dqzJRE8KfqDdZb2vcoJAnsh3iV6RGpCKGLDm
         ggARgP5koog8osgOmIFLbpf6rdYDNujKNif12VLkxFu9rSvX3V8PZ57fvI8yOh+Pguek
         +0wZ3gKgw+ImfhLQtth7sUKAwIMZr46ldAYN+M7IXi7LEY6bArr0/IAUnFz1EwFNtwEs
         4loRmDqerzFm4+HezWC10NH7EylRN8feoZSBRzc2vT/ryZKeH4UiToZ4HIdrvgBsH42Q
         Bmow==
X-Gm-Message-State: AFq9FYKJN5ksAwRWGddYmxs0lNavQDe0GPIMXcExgVGN7Z2rH2CjTEBU
	4w2xuSrb8kvkUlk8wX1Kp36opHE0Yk5lqh5nQxZTKZTUy6fnTIS9HMU5+ES9OktqSysDpeSTv8Y
	qavWr
X-Gm-Gg: AYBFou0iaDxcmyKQhnXISwU4n1piRnbIIFBnxFq7Vm6DDxdbrROLZ/o6eIflYYe4IHq
	YcaMu4Wig83sZhN3qhYzESHPPlYsHIOyVu7cHANF8/rRlLDySbyAsu4latbtW58aJISj/qjTBEf
	31MiwGmvidNDvCAXlXLbpjazCsH+t4nczxO5F45KInDzGNSGPmkelztj2sEIa2qsd5N23iYTln3
	EBcuXuaY2hye0PRcQ8RQfAAhCynaMQPgEdV0/vO+I7T8x54q3KfLxipiF3Kdrxf77lqGi10iVpM
	I5ZWE9xrINY5Ex4aTn1EUHDBl1zByjpP+fdx9OPdbKAEyDaF+jpP7DMniFiTzRjxiGpkmILZGoC
	N0Bg7JjRkf9X7IUZ7rFZmeacbh93D/nbM4lGC+qy11EFP1C7nbNFhnYLVZ8ijwpugGc/KBiDml9
	9wi145JfzyMpNi5SOScP58blh87E0FyUBlIB2qM90t2e8h70alz6Fd1TiEf7MiQUCfF5lxwDa53
	ui/6JazZXqjYfZjp+C75wsC0eWgLEUKyllIQ6KmqiXfFNzDSaM4
X-Received: by 2002:a05:6808:6716:b0:4c3:4e34:c69e with SMTP id 5614622812f47-50c45c674eamr17774830b6e.8.1792150604712;
        Fri, 16 Oct 2026 04:36:44 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388f3eb6c1sm1269694b6e.15.2026.10.16.04.36.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 04:36:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Daejun Park <daejun7.park@samsung.com>,
	Christoph Hellwig <hch@lst.de>
Subject: [PATCH 1/2] pnfs/blocklayout: don't mark extents committed after a failed LAYOUTCOMMIT
Date: Fri, 16 Oct 2026 07:36:38 -0400
Message-ID: <8b5b2e8ecc7e1150c9b4505d1094da893db2e1a6.1792097970.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792097970.git.bcodding@hammerspace.com>
References: <cover.1792097970.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

bl_cleanup_layoutcommit() decides whether the server converted the
extents from res.status, which only decode_layoutcommit() sets.  When the
compound fails before the LAYOUTCOMMIT op is decoded, as with a soft
timeout or an error on PUTFH, res.status is still zero and
ext_tree_mark_committed() turns the extents into
PNFS_BLOCK_READWRITE_DATA, although the server may not have converted
them.

Fall back to the task status when res.status is zero.

Fixes: b2be7811dd94 ("pnfsblock: cleanup_layoutcommit")
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/blocklayout/blocklayout.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index d54a141a89b3..aafcb8e30057 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -794,7 +794,8 @@ bl_prepare_layoutcommit(struct nfs4_layoutcommit_args *arg)
 static void
 bl_cleanup_layoutcommit(struct nfs4_layoutcommit_data *lcdata)
 {
-	ext_tree_mark_committed(&lcdata->args, lcdata->res.status);
+	ext_tree_mark_committed(&lcdata->args,
+				lcdata->res.status ?: lcdata->task.tk_status);
 }
 
 static int
-- 
2.53.0

