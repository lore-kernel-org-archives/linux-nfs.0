Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 49708493642
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329787; cv=none; b=AvTrKLQI40tsPlEi3hASDlV37vP7oNp93MuAsvgdzHJx/VmQ4ht+EeZ5qeLcPHubofRz7c1EB36weIF5BUdt1lzUfe8tG97Ze7j+i9khtZnXEIv9VSZDaNhFnd60as3X6Wo1wDOMtb7vZmg8IFeadEShyKN2kTHwkCHpECgu6rU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329787; c=relaxed/simple;
	bh=WfYZ2r9E9SHhjrenMteVei1hvDWd8ntDm/2XQo07kVo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=W2Ss1KwlWzul2QFX269LdsjPZQL01/0j1Pcv8mf/R2jtUcXbW2uXXcTK1ag3xmq2s3qD8hlWthu9MzyJvL953ZiY6BQV8okdTySD4NRsSWZRJe7Q7uUrfPqOZ97+0ed+tUH3oXprPN0rNitXDfcD0xVk7s4ho5fBwSygXqvW1PY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=FpHVVQGV; arc=none smtp.client-ip=209.85.167.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FpHVVQGV"
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4ab70b882c5so961221b6e.2
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329785; x=1787934585; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=roHRmLUwIyPtwfLaS6+zs/NjVHLHne1axdY2H2UOv3w=;
        b=FpHVVQGVGoyC0irAho5ld5snm7usW1AR+dsovIStIav5VErA5HHnqqQUh729z8ebMj
         rdg7csfW8NMVsnlK/Ry+Xn4q+GpOMLvjSiJ8+fI9Rn2NlgNKVCsI7RF2wgDJX1TzqD3h
         h8Y1bRzxoNol7RTiS4iWbvfobe55V7tejLJR/E/Nbtg3MZF+vFe69Ov8rSwfCIVJy7kd
         ehYIEQlFGwroYfV+4NmZi3hPPxZmVdBUZsEcS4M5gqEWcjExx7KH0fe8d0B1xqjAcbIA
         fsLRPH6+koV5xzy7gNH9iZUINwr1Rg3hpAF219UIPR08OIdl/Ug3Fkoi3oPgQB869sLC
         QzDQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329785; x=1787934585;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=roHRmLUwIyPtwfLaS6+zs/NjVHLHne1axdY2H2UOv3w=;
        b=qEYCK3Xv6Tx23FC6d7dOjGXBorO0Y6ep6oyhV+90FiIru8gO89q51r9j/d2umb/6G7
         rUwfbbhwuhHWuRnmcTBBuDDGuopKfrkjtvCWQZp5zVpC3ThExuy/KP2ffY9erT6/bwil
         7xhJsQxOnKO42MIXwytIbhRp38Ny3CyU544U4BhvwlS5OK3d9VmtQQBGCufJzP9JE7uO
         rjy+sd8YCZwhG+eHVKnO4KEd8NAg8BBCbkkyZ29aUnD/QdheL6RY8ogNk/IgzwSeAZtT
         H9X57adJjOjqJAAKotFbkQqDBI+DvQSfHhsIMRXAfRWW0tt1x8YRLEUgC96PwCF8ksaL
         kIQA==
X-Gm-Message-State: AOJu0Yx0QlB6v5IwB5ROWlIDLDdHDSQQUye9hE+q90BtaIE6wSf7AHDG
	2wKnOwOvUbsjYs06RXElUQnn3RpqRTg1YzTb72IFYs/QC4YTGanKohYUfpxocqrVtlA=
X-Gm-Gg: AR+sD108SgqkAz/3B/5tiMn3pDu+keWpWavOENzRDE5MFRvXt5aV0rP48UrcROTnevp
	q8taL2awM1MOR5VQZdhjMJayug09PCxxUaUX4A/HKo35ohPznTC9a5d3oX8b37i7tH5n01What7
	AhTqTt9f8GLcVIxqre3WfbePVXa1H7QW4O4Ozm0Q/+jRirw9dXkdTJYeuzZZS08X6r5TIqBOmp0
	eNgD2RvTUwhEy605bd+Yz1ETNIudwLOPOmcL9e1WGQG/F0J/wCAkAyWhu2f0bPbV+e6D3S+sGT1
	ehMDRAKKlZKWx6a4Qv18vPjpXNRV5y6mKQKCc7SzTE/HoczWy5tSLgILxNrbUdXiuH059OLDEBr
	GFDsyzWvYFVi1HM94/KdoigDBC8sFWhRctouDEImxcbAznqgPTAFvrmmdPqAaT5DCB+gvyojUTT
	/f6DS5juV+L8uQvkbwt2LspG6q7UyiNeAvA8CyMatUMZm8Ny89AdlrJn698RQPK0yVAqGR4wy9y
	nXFtQWEI0+V4hbtkaFR7saT
X-Received: by 2002:a05:6808:124d:b0:489:a387:1e29 with SMTP id 5614622812f47-4b2ef4eeeb6mr6415146b6e.20.1787329785123;
        Fri, 21 Aug 2026 09:29:45 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:44 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 12/23] NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
Date: Fri, 21 Aug 2026 12:29:16 -0400
Message-ID: <631adecc29c60d90a0063c3dee342385d50dad0a.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Implement the reresolve_deviceid hook: walk the layout's mirrors and,
for every stripe whose raw deviceid matches the changed one, exchange
the pinned device node out for NULL.  In-flight I/O completes on the old
node through its own reference; the next I/O to the stripe re-resolves
via ff_layout_get_mirror_ds() and picks up the server's new mapping
with a fresh GETDEVICEINFO.  The un-pinned references are handed back
on the walker's list to be put outside the locks.

Matching uses the raw deviceid decoded from the layout (dss[].devid), so
a stripe that was never resolved, or already exchanged, is left alone.
A stripe whose resolution previously failed holds an ERR_PTR sentinel
rather than a node; that is cleared too, so the stripe retries
GETDEVICEINFO on its next I/O.  Nothing dispatches CHANGE to the walker
yet: no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 40 ++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 3572324630df..46ca58e8e96b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2508,6 +2508,45 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	}
 }
 
+/*
+ * Un-pin every stripe node resolved from @id: in-flight I/O drains on the
+ * old node through its own reference, the next I/O re-resolves.
+ */
+static void ff_layout_reresolve_deviceid(struct pnfs_layout_hdr *lo,
+					 const struct nfs4_deviceid *id,
+					 bool immediate,
+					 struct list_head *head)
+{
+	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *old;
+	struct nfs4_deviceid_put *put;
+	u32 dss_id;
+
+	list_for_each_entry(mirror, &flo->mirrors, mirrors) {
+		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
+			if (memcmp(&mirror->dss[dss_id].devid, id,
+				   sizeof(*id)) != 0)
+				continue;
+			/* Allocate before un-pinning: on failure the reference
+			 * stays put rather than being dropped here, where the
+			 * final put may not sleep.
+			 */
+			put = kzalloc_obj(*put, GFP_ATOMIC);
+			if (!put)
+				continue;
+			old = unrcu_pointer(
+				xchg(&mirror->dss[dss_id].mirror_ds, NULL));
+			if (IS_ERR_OR_NULL(old)) {
+				kfree(put);
+				continue;
+			}
+			put->dev = &old->id_node;
+			list_add(&put->node, head);
+		}
+	}
+}
+
 static struct pnfs_ds_commit_info *
 ff_layout_get_ds_info(struct inode *inode)
 {
@@ -3089,6 +3128,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
+	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
-- 
2.53.0

