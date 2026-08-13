Received: from mail-oa1-f52.google.com (mail-oa1-f52.google.com [209.85.160.52])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E44E538E8B9
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:07:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.52
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786644445; cv=none; b=IznaiCHUxpnqp974IWWkBrSNJGUHz8AizfLgqK+vYYI0FsGJmld7UvoPedikHQ6qJGuS6MsmOpMpKqGA1N63ypGyp7dIxTgHqn7WxSUyNkjRKz4nDiNSawvoISPAJY4CBmh4UQ5iGtU3Xok1uJHy1PZ+8C+cQCOGHK27J+HoDN0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786644445; c=relaxed/simple;
	bh=FWV5a2AM0TNofkdSdcm+IbMw0Wqoq2ULqOveCKkbsEg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cjYP+FSlWuYyWLFHNFex3HKzz8/8eW+3UatbGHt4jNSqKl6esVxTXy/SzfBfuvjmknRBIRAo1Ut9Yl9wZfu0Y4wqQrtLpVN3ipIzcA3gIXU9npnAInBBnuycwLPOYoXVKxTRSBteoWUMBRqJoam16c3GFO/jZKurDk24g0fnnZQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=gHM6tP9q; arc=none smtp.client-ip=209.85.160.52
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="gHM6tP9q"
Received: by mail-oa1-f52.google.com with SMTP id 586e51a60fabf-43bf9548df4so143494fac.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 11:07:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786644441; x=1787249241; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=jcpuE6yNahPJy9OiB83UF3LqCubdNGvKp3GM0iSYrL0=;
        b=gHM6tP9qKj5d0GBhq6OuQtzRo/GqITPbNGP1qBgPablPPzHIvpD90SeIVnhn9eo0r9
         MTBhgnQwmAHsM5P+TJ3zbUfbS1q2UNuvM+b9rkKO1n+FiNIIwXeuD4Z8SDbDgx3jbAmd
         CdtXeLt4BiZqiUqo8XohVkQIU/2rJXDWXWyjynOyhWtu0QvGXM2xy+iE03QE5tuofrJb
         Q0Lqo5gWB6fom8wVc3y+8IhXlrkEyAcshAdbeqCs78gcWab1Go0ewbco/9cVSFc+rbpP
         mPTANBuy6ciRuZyFGa1rHwKgfEEM5z9BqqOnZYBVK3f8n4gjWL9so6+lZ41fjJdrEfSZ
         xqSg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786644441; x=1787249241;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=jcpuE6yNahPJy9OiB83UF3LqCubdNGvKp3GM0iSYrL0=;
        b=P9XUItjoZgiycyxfJricmZQeQ1Y1WEoWFXj9n3mCwc9FiD57g94SoCtL0sONRF1aPq
         IE1HmOH6V1Z79HqM9buXUTFE5837VNAloxgo8wl5pNeNuroFab+QxRWlcEzPPbsLAQAC
         s3doony+RrVLHr9rpNPiS+D9VP+UXRmJzQfZgRQmbnUDn3M++I/X66Mmwgozs7yQfSoN
         aEus9VBzFhel2CzcuGGtptw9Mti7/5L1XBpbgqiE0sOfGFPpPuRABvDoT6cxRCjzO/h+
         Nfi8/hX84fQlF6nMbeZvtI3+L98VAIG1VWAR1iZsczPsV7q4Y6PmayAE05b/kUY59PQZ
         F1Eg==
X-Gm-Message-State: AOJu0Yy6uytVeJoKaqoMV3jOVoreywIleV+NrBURwen+lyixerdlE439
	yIY0Jg0niokM8YW9LHrRmhgnBdhy2wvAtlFLPyUXKQ9rs7SrYO4oiUbK6nJa6f5i/5M=
X-Gm-Gg: AR+sD10V0B6dPD2WneMKxSr/hu3BFH/Ie7TyfjLJmgS0OhjPph23WCeF3IzXy1SD9Ih
	auC5QpAyzxU3ni0JNK0/HeC3e7+7bj31pYNvfp6yfZ5Kn3o+LBk0dNVJAp+pZSvCrYl4rwXEiPo
	viGXF+o//x8YoMd2WjoJ0pUhWa2FfYFe1I8CiGE0u7GJRwf7XrNm4XWcWcJI5OBYd0LhTRAp0iY
	e4IPyetaHhg099onmwVx9RRGXtOgR8McjNOYpS+68BVcejjC7efExMloP5K4WnlralyYJZuwWjJ
	rLokfnvc+u1C03eel3cpMRBkMMtStEo0RvSnmWXH8R12qgE20Jx+t4R+LxSsd6wB2jo8U1fGWj0
	DC6wZ7i7WbN4IYAwt5nJeJ+BCfNPAsky/JAHjlXIWzSqdJw7pUPZOMbUlriw2ZbHX/6F7JBy+/I
	E5VFxdrFjP0p1TgukgO365KWgJg8O6ydUm84ZcBE5UFo6ynsMWxozfeUIzA4CqRHZt2kuGjRzEa
	oqmXWmllJdHtWcwdFvV9UaT
X-Received: by 2002:a05:6871:706:b0:456:b3d9:336d with SMTP id 586e51a60fabf-45e9239c776mr17500fac.20.1786644441334;
        Thu, 13 Aug 2026 11:07:21 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-45e8f96010fsm211730fac.7.2026.08.13.11.07.20
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 11:07:20 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 3/3] NFSv4/flexfiles: only cancel I/O to a failed mirror instance
Date: Thu, 13 Aug 2026 14:07:15 -0400
Message-ID: <d5a90f5d570648792789f815cec7a62084fe2401.1786636529.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786636529.git.bcodding@hammerspace.com>
References: <cover.1786636529.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

When an error causes the flexfiles driver to return a layout,
ff_layout_cancel_io() kills every in-flight RPC for the layout
segment, across all mirror instances.  Cancelled requests that had
already been transmitted to a healthy data server cannot be un-sent:
they complete on the data server after the client has sent its
LAYOUTRETURN, and the metadata server then observes writes to a file
for which no write layout is outstanding.

RFC 8881 Section 20.3.4 recommends that the client wait for the
response from in-process or in-flight READ, WRITE, or COMMIT
operations before returning the layout, and the machinery for that
wait already exists: the LAYOUTRETURN is deferred until every request
drops its layout segment reference, and requests that have not yet
been transmitted exit at RPC prepare time once the segment has been
invalidated.  Cancellation is only needed to avoid waiting forever on
a device that will never answer.

Pass the failed instance's device ID when marking the layout for
return, so that ff_layout_cancel_io() cancels only I/O directed at
the device we have given up on.  In-flight I/O to the remaining
healthy instances drains normally -- typically within a round trip --
before the LAYOUTRETURN is sent.  If a spared instance turns out to
be unresponsive, its requests fail with their own device error, and
the resulting layout return cancels its I/O in turn.

Layout recalls with clora_changed set, bulk returns, and layout
revocations continue to cancel I/O to every device, as do error
paths where no single failed device can be identified.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 9 ++++++---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index b0c90e6cdccb..b976c922cb62 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1590,7 +1590,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		fallthrough;
 	default:
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-						  lseg, NULL);
+						  lseg,
+						  &mirror->dss[dss_id].devid);
 	}
 
 out:
@@ -2244,7 +2245,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg,
+						  &mirror->dss[dss_id].devid);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_read_pagelist(hdr->inode,
@@ -2337,7 +2339,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg,
+						  &mirror->dss[dss_id].devid);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_write_pagelist(hdr->inode,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 33ee3ed1f546..16868645cd15 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -428,7 +428,8 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 				 opnum, GFP_NOIO);
 	ff_layout_send_layouterror(lseg);
 	if (opnum != OP_READ || !ff_layout_has_available_ds(lseg))
-		pnfs_error_mark_layout_for_return(ino, lseg, NULL);
+		pnfs_error_mark_layout_for_return(ino, lseg,
+						  &mirror->dss[dss_id].devid);
 	ds = ERR_PTR(status);
 out:
 	return ds;
-- 
2.53.0

