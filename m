Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9E7B3B95FA
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474968; cv=none; b=Mc4Td9XY4EbNsAzHgzjyZ2tBQAp0HmVGYGm7LVJxvkoxU9xSfZohfZqvgYYwg6tu2mQColh6vfs3uZd6xlpexvU5VSVLgBCa0ZWZSy2b6uWSUR00WfqHmY2gy0PtPaZYcwyUUa5cdfJpbBfpiS2Xcq1LbjlL7RVUF950kw6R1uM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474968; c=relaxed/simple;
	bh=9lKEsN0Yv29O80ET7xR6K/BPp8zAC/tpybI43dgT6so=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=odlb+WIa5AhOiPYjzlZInjJEQX86RyRSlL1KltSWs35JCRJJnNrZwL6EhgKjcB27FxaQUC08o0rHHg3QyGzknY7sMxrncaNF2XrL2HtiZahL/VOVmx2mbggGJHxoQpS87DMy2BrYeIsbmODDsXwHeNA+YByYBrBc9fAuxACLH5A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=eIq5nc0b; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="eIq5nc0b"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a3ed715so2265729b6e.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:46 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474966; x=1790079766; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=e1HAQpEFVFuGxrtpysATc8xN1pv4Bf/Fmcn/QcCIfAE=;
        b=eIq5nc0b7QpXBtyf6VkauljAnUXGvK/Lmcfn1q0PMr950fyHBjlEHzPx3s/Q67J1oZ
         9XKl8fo/2FmtcLmWZZAXwkSorzGlfsW3Zmhcg7M632AW6We6Z4M7yWsZ+pcx6q2jFc/M
         xlyF/qfJj5U7CcOCJdCLXGhWs/NaLdDHiNNKWY682h+5SCcuoa5vtzSDeNQQCrjI2KSc
         Oeo2LPfFg+rVie396FHiVywtCdHEjsodg28cDJuHulLkN1+MHmPCoy/Fwlzc07ik7LA/
         G9QwZXSf3xeiNu6GmhREjzsxj8TlfX7xrZdLbZL24h0ENpGEEgyz4zfixhkMNYuIqOtK
         cBbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474966; x=1790079766;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=e1HAQpEFVFuGxrtpysATc8xN1pv4Bf/Fmcn/QcCIfAE=;
        b=kQKb+lPboXEKsm1OuOiz++bdPuExdMnqLJijLpVkQMEUH7rh5YdoSqjZ9ZgmUkK6W/
         FsbMLnOMO9Fnx0ua+Vk0YocB073pNtv6AIh3diG2f9cNwflml3nXu1Ps9dPIlrgQMl81
         LCze2aUbM2JS97tU6z4sratToHcm/5m6ggNoTQ71ZE964T9QbHDRl5LIiz+tIZ3hkar2
         C2/BIq3eh1tHDrzb+7noR6waAfBp4Pzi6gPH9pQvimwcO9pSjGj4rAwIBMsvFVq47zGe
         lbh6KIXhtNTOceIZz6ZdnyxdiDcIxAKUMH8R7vpM+XEipVDVcJZtw96PIKs0SMmBoHv1
         C/+w==
X-Gm-Message-State: AFuF++nGL5Bs8njPIc2g8Es6Ns9ANJ7DvAuChOKItS3MCjB7GCk68U3j
	CgouA39QWRf/SUBGwq2kHUEhtESfn6BaOA7DLFxmGpc8QSaxrpKq/MWdvuXsWDBVysE=
X-Gm-Gg: AYBFou2AvbCzwXmovrsMjd/lHC7C5y4HRY6xsM6cPpVofrtymtoJNcCtDoBuueqOEKh
	c+mv/ARb1BMVinJSVE6HRiZEulgb2F80rZLW61QGF1tkcb8VQGyVPavVCsjzgrRSxYXSFl5caD6
	i9RnJBJQT6zYpSLov/nIT1OZOjDLAmEj44PkkmijlA4T2UvmWG1rfACB7qUtwgvrUd9ZTaCXeW5
	Vczv7LCedwT05rwpgshvLCkmLmRQuSeEB6NxVeMj/ATm3BJqfOnGogKbQACYhy4wotRyHxs6KEU
	AtcA4Mex+C3zE7aUwVAyCZU+PutqThKaGXn02lmPRDbNZXyxm+wBmZtKq+9ShXcRPZgMC+Kw832
	7NPxD4deHpR51bgDPmAMX7DtP6inXY5mtFVkmd8a40c1rGZerZgsXHL9VW+Jh3LyG2greQ/vPFJ
	YTkvwKjm4g/ys/2JHOixx8NSAprLD/t0f1DhA66l38qNTU5boo447u1WCUnwpvP1l6LnC0w7R8k
	b4mn28NU/DQ73sffZllUYE2XIc7uN11y7sft2iWCLSUBA==
X-Received: by 2002:a05:6808:528e:b0:4b9:a829:f012 with SMTP id 5614622812f47-4c7b579df59mr4482298b6e.30.1789474965547;
        Tue, 15 Sep 2026 05:22:45 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:44 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 13/24] NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
Date: Tue, 15 Sep 2026 08:22:15 -0400
Message-ID: <a928b6405c249d1cf6eb200e23d053e482e73ebd.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
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
index eeda084d20dd..a7fda4422c5f 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2527,6 +2527,45 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg)
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
@@ -3108,6 +3147,7 @@ static struct pnfs_layoutdriver_type flexfilelayout_type = {
 	.pg_write_ops		= &ff_layout_pg_write_ops,
 	.get_ds_info		= ff_layout_get_ds_info,
 	.free_deviceid_node	= ff_layout_free_deviceid_node,
+	.reresolve_deviceid	= ff_layout_reresolve_deviceid,
 	.read_pagelist		= ff_layout_read_pagelist,
 	.write_pagelist		= ff_layout_write_pagelist,
 	.alloc_deviceid_node    = ff_layout_alloc_deviceid_node,
-- 
2.53.0

