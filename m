Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8583342FCAA
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653817; cv=none; b=nref4AVITLdfMjEROiskvWwNMHdFp+VEe90jX6ubf1JWWF9tsp0JmNNI6Zh3LsMorAcVlHGHVcqpBuWEzd5dYmT3zu/7LzHxjRYWuTibu3pWz9Mi/+f5BRNAFx6YKQpumG/W2id7EVqxmYTPWNRa2/may5E1JLawaseS8giI3jQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653817; c=relaxed/simple;
	bh=yVNbP3/d1maoIA07ASQMyMLBjr4Lswx1Yzu8FRALRCA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=l1W2PGK6YsCjKjhntK6obxomkyawZlaFnqX/EFDsGiytUYJ6KawU0HowxloadVl2GoC4jZMIE17odOKZXQFwSo9dEj8c2g0MZKJNZ3T9+eElk0qN1JJiAKI7awmvzZw/Uqf5iGqXNhYCNpZrEIpj0l/FMlXZR2eHdjKZ5EV7ruE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=e+CmdsYE; arc=none smtp.client-ip=209.85.167.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="e+CmdsYE"
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-4864ebb6268so142378b6e.3
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653814; x=1787258614; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=KsGVRaRe2bQbbDq/8ml8nWbXo3sZR9tPrsFs/VyaOAY=;
        b=e+CmdsYEZMiIi2FBVjg+XG673aRYo68iBqAXb7Tlsv/2bwHFGSR4Y+9CiN9lzqS7Ue
         l9Fd7eMyffU0mkIo/6lHFFCjzYoIHyYMdEwWgekClXsg9pkExA/RDvM3hiX6zAkHn8Hd
         AxmcIu0kw1eHt10qaTlZPcX8NBDZ7RCQBWPpw+0wjGUzN4DI6R9P3dELxXw+eSeAaOQu
         KS+1wcqZA6duZ6HHxUxUAA5Tr/SUMCScll+IOLe9Fr5PIGwYrp++HhxDXeqs83Xr5eEW
         v1aObnNs8s86+zTxtG8i9m+NvFYuotv7Z3RWnNN4xMa5//WvYX8E5kLTZxSCpHxkEt0b
         da9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653814; x=1787258614;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=KsGVRaRe2bQbbDq/8ml8nWbXo3sZR9tPrsFs/VyaOAY=;
        b=N0g/sdxP/Ij1e38aBwkPYCVxdrqKN7zB2L/XpXkg2i/d1Puy1g0JJtdjTv3srJ/gyy
         XHoNn1h7er0gln5TAiXBJmnpYWteCK/Tx+8HC+LSz+dagIBkzF06N1KibtWeAmPMoHy2
         LIAWlgOf1RXeeZrMPU1Uwfo7NpOEXqo2DL5cp3jMdkQuP7nHvgiBC7iTcWsU5xg0cR8t
         uu3G8fNf1C5buH85IHravj5JdG/rr6g+ufX1GPxOZKzUHhKp4xgdWfyWCqVR9hnEr0T+
         JSCEIo/oXVqxL43VDc/2oo6fYTl21AL7uEnV2gjhknXkOyPQPUoBE0+LvQi+gTKPdpFy
         fx0A==
X-Gm-Message-State: AOJu0YwGbSQ93Qjf4QKGa3HaMxmbtLDCElLX86VKtsxpFiT1ZQ3nDX5R
	75+S6M9V0Al0fVllad/eVSwx3OZoBx89fYn22Cnzm/NpykTf33FgkxNSHuQGdWsv3kM=
X-Gm-Gg: AR+sD13+MhhP3hXaCkOWJpbYDl01xGYSjtor+EtL+mqVzmsp+8d39FY042QbR2G+LFZ
	jlsgI6y909t3jQGyozE0IBlEVK/9VyVvdzT3EEG1aW2u0WgcghQKmMmd80jBUmA/Ah/fnHovG8F
	YjW2/90/HdXYSoH6zEsMzAg5XMDyzQZfQZIwSpqz8Y+WLi9xjG+1cq51aEqWvr+m5hfsbKaq/bU
	M3d0Abf2l5MhHSSpqcFuTx+brW2QzYodQVzpf0Fnu7p6TWVrQNjSS+E4f1DKAg6L2AKL8LMWYB9
	cFutMqTy9SV6aC+9FJQCaRIWSWHp6xNK2bXc0iMdhKb8TSUpSkgnpcmJj5Y1NpEYXdIEZKf0jwM
	xtEy8xLhF4wqse1AQJDCtYrJar3669O6/FTszKuugQZ/TOpGN9AEfojrCqtkmPI+oj2nE1YIOED
	HSXw10Hl2tJO6Da17EjKXWFCh5k/YknZJji/NmKVyW7P3yN1RNcTDMcetE8gvbEZ49SVVL3YlA0
	KUP9DlR64XOJQUCttIikOvY
X-Received: by 2002:a05:6808:4f10:b0:4b1:b9f1:e893 with SMTP id 5614622812f47-4b2412f1004mr825317b6e.3.1786653814084;
        Thu, 13 Aug 2026 13:43:34 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.32
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:33 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 10/21] NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
Date: Thu, 13 Aug 2026 16:43:06 -0400
Message-ID: <aeb34a04237d832d3741f5b80e198639e3df9b14.1786653063.git.bcodding@hammerspace.com>
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

Implement the reresolve_deviceid hook: walk the layout's mirrors and,
for every stripe whose raw deviceid matches the changed one, exchange
the pinned device node out for NULL.  In-flight I/O completes on the old
node through its own reference; the next I/O to the stripe re-resolves
via ff_layout_get_mirror_ds() and picks up the server's new mapping
with a fresh GETDEVICEINFO.  The un-pinned references are handed back
on the walker's list to be put outside the locks.

Matching uses the raw deviceid decoded from the layout (dss[].devid), so
stripes whose node was never resolved, or already exchanged, are
untouched.  Nothing dispatches CHANGE to the walker yet: no behavior
change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 36 ++++++++++++++++++++++++++
 1 file changed, 36 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index dfc0c298ab4b..bb27bbea6c95 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2505,6 +2505,41 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
 	}
 }
 
+/*
+ * The server changed the mapping for deviceid @id (CB_NOTIFY_DEVICEID
+ * CHANGE).  Un-pin every stripe device node resolved from @id in @lo's
+ * mirrors: in-flight I/O completes on the old node via its own
+ * reference, and the next I/O to the stripe re-resolves, picking up the
+ * new mapping with a fresh GETDEVICEINFO (the stale cache entry has
+ * already been unhashed).
+ *
+ * Called under @lo's inode i_lock; the un-pinned references are handed
+ * to the caller on @head to put outside the lock.
+ */
+static void ff_layout_reresolve_deviceid(struct pnfs_layout_hdr *lo,
+					 const struct nfs4_deviceid *id,
+					 bool immediate,
+					 struct list_head *head)
+{
+	struct nfs4_flexfile_layout *flo = FF_LAYOUT_FROM_HDR(lo);
+	struct nfs4_ff_layout_mirror *mirror;
+	struct nfs4_ff_layout_ds *old;
+	u32 dss_id;
+
+	list_for_each_entry(mirror, &flo->mirrors, mirrors) {
+		for (dss_id = 0; dss_id < mirror->dss_count; dss_id++) {
+			if (memcmp(&mirror->dss[dss_id].devid, id,
+				   sizeof(*id)) != 0)
+				continue;
+			old = unrcu_pointer(
+				xchg(&mirror->dss[dss_id].mirror_ds, NULL));
+			if (IS_ERR_OR_NULL(old))
+				continue;
+			list_add(&old->id_node.put_list, head);
+		}
+	}
+}
+
 static struct pnfs_ds_commit_info *
 ff_layout_get_ds_info(struct inode *inode)
 {
@@ -3088,6 +3123,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
+	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
-- 
2.53.0

