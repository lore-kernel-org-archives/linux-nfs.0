Received: from mail-qk1-f170.google.com (mail-qk1-f170.google.com [209.85.222.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A3EF8477291
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540820; cv=none; b=F8M4ANasVscF9u56+Dqlbpzrxci5UpICTb3bu4Umm7s281FFflXXw1nB3kq5Ei+ThkjnjESjX9e5AJHqfOwHQGAgvIPdso/1ByWspX8ysPZTAy8KS572WcyHq2Cyjp0NOMaIia+FbZPmWpFFykvjGf7TIgp6G3j/sk05UAYrWsY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540820; c=relaxed/simple;
	bh=9lKEsN0Yv29O80ET7xR6K/BPp8zAC/tpybI43dgT6so=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eL5SO5Xva42s8J3wCYV717RdZ5jFrYM9k7zFO8w60JAXcfbyqtcWdW81o0Z5nfJ7mQ0g65P2eRdkKhXV0YiGboPtVnRqmJtk/q98LhsAdIqXfBSzVbVvIpjKyoVVPd/fS6zb2u0UO0zpz/iu5b3k5XM37ueEiAuDqUx0wvXTn60=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=Cnc0qG4U; arc=none smtp.client-ip=209.85.222.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="Cnc0qG4U"
Received: by mail-qk1-f170.google.com with SMTP id af79cd13be357-93905b1dc65so92714985a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540816; x=1789145616; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=e1HAQpEFVFuGxrtpysATc8xN1pv4Bf/Fmcn/QcCIfAE=;
        b=Cnc0qG4Uj2TNCOaO1l9hKWmytfwj53FEuJ2QVsCm9fg6eH/entAex/LI28LcEetPmJ
         FLxICMbnGZQS3PW644LlDUGWnNPH5jgskLa3lQD4zVHv3foH5TzaDLW8p0or1+L2y9c+
         IGkk7yWeBNiJzFHoiMb8YPdzkSPft+XlBNSp2gm7kLsLQ12ELJMRdWOlYeswPY4eTr2k
         jhqZVtBnNIr0P6N8O3vJvYJfFgafNfh2HM5GA8IhwwHsZhC30qyqsQs2RS4gcbM8aoMP
         4X+lfXomLdBBn075GzVWTZBDyFnPyAue15U/1BhGM7X9v8VlqY0hTifQUF68sIu49Dcf
         0rXw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540816; x=1789145616;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=e1HAQpEFVFuGxrtpysATc8xN1pv4Bf/Fmcn/QcCIfAE=;
        b=Wwem9NaUyBom75N0CKbb0BNOCMcBh797yiTwTqcNl/2O1X0hj143nE8XoRQQOPDhVP
         RocD/mxE1nqdXEl1hID/7EITgLLwzvDG5UbUrnEt4/1wDKjHHfD5L1AkStnk/d3wBhX+
         prk304tdsMuRcDOF/6dN8qYckuHVd8saFeTFKB89S7r27nJ8AnVpwQqFQkQ+a4LpW4GW
         dr9sCDjeMdDGdstFndEU5Dlxw90n3pvUmIOPH7ymtKfpR1JdXJnEhj0hSvCXntG3IafU
         LHw/PEXE2ZIxobMy5CWItXSjtpuK+00hIjBio1hbCvdQ8DRQ173fCVKIIdAQCGsxZ2r1
         UC2Q==
X-Gm-Message-State: AFuF++nDsGL4Ke4YRKrow/9XgbUwwDVSZWYDd0o6DI69i0knFZF1vGEU
	MsUQ+A3VmEdStB1gs5Rjz6HJRG0Ug6iX8jzQmALtXAzJmjVV/7DcYre2QzMxy3wj2pA=
X-Gm-Gg: AYBFou0DvAt4OdvYn8N0JW785zun3rjqqAMAFO7vcKRRPZPz7MkglyqXW/ajRJSXDMU
	N6CLMWj7Sd9sbnZuPtCVioZwNpDnxyqhz7+HqH2ueGlytvSKqEm7Th1V1L0yA4UKA2dCK9tjrBm
	q04k0fLw0cNG4qNVTvtHIjU+5oO/qcSfhcDYeMBMAwfKCDhkfiM8Bl2pnCUK2DvPUWVedjsF/Vy
	FvvwHBIC0l57ultx6npEMx9GBxSCGrVipXbstQzCuTCDoIyiKifJ8ctStHaICdK++KiOVGd3CCt
	KdGQNqklh6GCj7nh6vBWiAFO2LqO9QLXe4QJrTuYhu8TW1naOfOHwt2nsXM9YNYJgAIezeL4j7h
	uyj7cmy75viLR4p+73Yo2osbcVWOOT0oPx9a7mdJ7DxLtkuwYFbx4RLxDRgptzVprxLr/b0p8yU
	U+om+dL/Cm1zaPE7s6De43KNsj0xs40MweYBT/bAsbGndJHqskof9rTnvEWtsndSWTEynIIgXmU
	8e2XlLRFfwrIWx6yF7EIpCI
X-Received: by 2002:a05:620a:5642:b0:939:34c6:a333 with SMTP id af79cd13be357-939804a4609mr591747085a.40.1788540816225;
        Fri, 04 Sep 2026 09:53:36 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.35
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:35 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 13/24] NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
Date: Fri,  4 Sep 2026 12:53:12 -0400
Message-ID: <0d72d79f045f97f3655c7789d8b1fb37f9e802e1.1788530385.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788530385.git.bcodding@hammerspace.com>
References: <cover.1788530385.git.bcodding@hammerspace.com>
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

