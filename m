Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 14B8135E1B0
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 17:11:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788973920; cv=none; b=PYZVB0AKM2kMm+Ni5dK4vNneVwL05DqmNwdeEF/QME/Bw+Hm7hg+daZ3aDnHlYbNfwKXRLovRY+cNFxxOqMRpHKLy9Jrl9QeQ9e8bPTKA7l2WzFOGPh5gvJgJQAGcLKzGP3yFzpofmB6nKVxSsZdIwq8sQD5X/+K3R5/BcaKI2E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788973920; c=relaxed/simple;
	bh=2lJcNrqH2IzaY8ZVM2wMzgB9VkDqg51e66icHVuZli8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Px6Ywcd4HqW8IvUbIxlggRJEwdVawAdYUqKok3A8bOZ5IcXMquOvc4ZcQB2PTysOCsQ7rs72lLNU9gQIOjrmCD1R7yTtMHkzVzkjHFAHwSwDqsHjYmHYW6NYX9r6DczZ971zDj1/z50ZWf+0I9ZXtj0yEHWYNXHDkVzf2O0K6Zg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=cwIWu6M+; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="cwIWu6M+"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-4b381337e1fso5693422b6e.1
        for <linux-nfs@vger.kernel.org>; Wed, 09 Sep 2026 10:11:56 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788973915; x=1789578715; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=oyQbgQXW6pwSynA6+biAIhXJjrdyqLegOmnh3nSbzbI=;
        b=cwIWu6M+IiXatCB5sQhKRQuZQx03uGx3UhPJJ0IbDrCr3Ma62DMdexqJIsA443VQ3C
         51kyaGIKUYloAMvKHwmTwVoni8aXFKJgC0v0hh/oyENepRjPct5DzemJkfvpLsyzjoLw
         2sp2AdN/5aeoICd8swxIm9IMF+UaNVfzUvjy/9sdjFrA3BmXcDY9iFD1jaJN4BLyfU6G
         /wg7yvk8GxtSQ9F1xLoW8ho+7DkSWiy7V8TNzkNZz93FKM0qa2Vzoe24pJyl1DYCVCKk
         yengCLTI7qC+M/n2WPhZI9lcE4+TrVZ1hfnfs/jHN74qvdGhel7wTYF6J5Nt2INkjMMV
         SHkQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788973915; x=1789578715;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=oyQbgQXW6pwSynA6+biAIhXJjrdyqLegOmnh3nSbzbI=;
        b=IWfKoGzJwbvQroObhej2d1pTdztGHAY3nDAVfLh9mUXRELkV5vm6MrN04skkz30YAk
         xd0gkoipd2Alqy3ohdXRgCa48YyYYNCXDmUB2jIXZ36dHzuFaYjW/GVy3bwl4/VarEJF
         iLgmC8og6xzBkQ9kXmGkc32oxYnlcwa5LRJCLakxiuloRJegHz7N+v1Jp0Z4OU4UkLRm
         kVCYOLw+MFXPXzkpYmcE5cmDzBjL00pHmYUZZyqr/Ih0qpH5PB64ma2v6sgHIEDdLK7U
         SujHOEcAcJq0jUUo+xTpUX42cX6bH+2W7ZuRBu+8tWBGw06MP6+Oa4EEfjupSAjo5+xU
         2uVg==
X-Gm-Message-State: AFuF++l1pTRVUkUzF5K37f8Y+cBdxf5p7JY0wBALLjXH1vD7uRmbrhSp
	8L4A1KZczcJtAuEHdxKKuoBeMs/zCZqLnSPBORUJldGvH7Ul+HKCl8pUiyQx7udbuBg=
X-Gm-Gg: AYBFou2k67kaFv9wr0rCxy/YVYPOjpmHPTTaL3YTpdUZL7sogKiJVo3JEZ4tFYpSB6s
	uo49gaJeR52JKDvhPf1bQ8YHSSOGh6APu3VfpoMTnHnQ4nco2C/V4YTNceBHPthfSz3+KhpHlDN
	eGEtbxs5nyDnBnbMuqF+zqIYkwkktdTYlhrD5aSFzjPepZqt8swEKcr4qe8V7CN4Z0qNBDPo3xg
	eCTX7ljfQMe/d9up5T2F6g8ATtfLflBJ1HFbUmEBQ11U9llr5pdyjEs9l91f3UjINdLm2pAk51Q
	xYGHJAqzOeeD4h3MyDqK/VdG3G3cHe4sRb4smg6Ir15HuB3JWeIXa/W5OuVQbG1aJ2LiVPTwS8Q
	FVw1IHhP5+HH3IW4fiOWfGgjUUKMGgHmuqcCGo4Q6SkGuMIvQfZqkfVNFON9YisQQosv+BAY5VZ
	oDt0bRQ1hBNzz58waxzxc2EpTiLPHTgW5uGV1Csh4xr/9nVIkqzfDPiZN6Ppdqvc5WNV5CiUkQV
	fD3WRoh8VsSPX5nf5GW9UWfJMHAtLYw2SA=
X-Received: by 2002:a05:6820:339a:20b0:6b7:83c5:fe00 with SMTP id 006d021491bc7-6b783c603eemr13569801eaf.65.1788973915557;
        Wed, 09 Sep 2026 10:11:55 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-6b6dd57198esm20616428eaf.11.2026.09.09.10.11.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 09 Sep 2026 10:11:55 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Subject: [PATCH v2 3/3] NFSv4/flexfiles: only cancel I/O to a failed mirror instance
Date: Wed,  9 Sep 2026 13:11:49 -0400
Message-ID: <a9188af37d11b1cba9a46c7c968acc5c9b6746d3.1788973535.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1788973535.git.bcodding@hammerspace.com>
References: <cover.1788973535.git.bcodding@hammerspace.com>
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
Reviewed-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 9 ++++++---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 3 ++-
 2 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index fb7222a04559..3e51e9640819 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1594,7 +1594,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 		fallthrough;
 	default:
 		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-						  lseg, NULL);
+						  lseg,
+						  &mirror->dss[dss_id].devid);
 	}
 
 out:
@@ -2256,7 +2257,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		 * FF_FLAGS_NO_IO_THRU_MDS: force fresh LAYOUTGET,
 		 * never fall through to MDS I/O.
 		 */
-		pnfs_error_mark_layout_for_return(hdr->inode, lseg, NULL);
+		pnfs_error_mark_layout_for_return(hdr->inode, lseg,
+						  &mirror->dss[dss_id].devid);
 		return PNFS_TRY_AGAIN;
 	}
 	trace_pnfs_mds_fallback_read_pagelist(hdr->inode,
@@ -2359,7 +2361,8 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
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
index 7bb0f2094e9d..6165c41fcf62 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -453,7 +453,8 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
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

