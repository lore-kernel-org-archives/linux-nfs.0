Received: from mail-oa1-f45.google.com (mail-oa1-f45.google.com [209.85.160.45])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D154493638
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.45
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329788; cv=none; b=dtHAVzAmUl72FBnPgt5aAkeod6dcqapoEFPAJ+4CFmSi8qAqs+OgTam2RJjyu+XRCcMYwEKoo3k/GO3eXaS1soIhhLXVxf6A7pqJS3HRbkHr7sFS+DusX6QHTXoCGD9EjGiqKxDY2AF4smktpWoI6v1VZJYIlN+VrLSjWmZa2rs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329788; c=relaxed/simple;
	bh=mFoYwYIfmpUGwbbgND9FY/hrOpDd9bRmMBUAmVa2QzE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pjSWDRFJZPwVjnvnpBjJLptKah7gAyIzyeeSgDUiMxSmaGph6GN8pH5iVclSH5lSq/cJ1ytrugSnnYeIfTMndRAV1BF0pHh7AjxDm04/VdRXZTJIHDEuN7az/UMyde3bdcaMI/8NYRJnUQ+6py1de9Wla4uq86YQU3HeADQJziA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=RbGWlGf7; arc=none smtp.client-ip=209.85.160.45
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="RbGWlGf7"
Received: by mail-oa1-f45.google.com with SMTP id 586e51a60fabf-446f87b6de1so1777344fac.3
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329786; x=1787934586; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=GVg+XmonONGQOefT2/fB0fPfVVU94Ojdzu2JY1DIKdI=;
        b=RbGWlGf70BJRiFAtoBNZZnZFg4g6yn4hWgTpeWO8Utiu6OOr0KocOK3kq3f82fz1xN
         0bXLLb3BG9e0qHSvgRKCFM2GWpoz1fZ9/trRgKM0BRfPwxro3KAYYPg1+AZ3l6n8UgRm
         s7vdCkKKLH6e81WXPFmgVbrBA8gWdfRhcojanj34X3xk6Y3/tE9F3rR+NVHUMJIBiUn7
         Z33YiXg5G6MrzFnf8GFfzIRXuGn2TzAzBWI94aJw+Z0RltBu83sriz6Ys+YQc7FGp6GW
         DOIG2b64ulDgs4WgySUaTAKyOr9feseYCZ0IJQY8qUTmFbOIrn41i+DYilDNZG58XzMt
         vcWA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329786; x=1787934586;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=GVg+XmonONGQOefT2/fB0fPfVVU94Ojdzu2JY1DIKdI=;
        b=G9p39/fpoUiZ9TuEs2xIq11Yje6xg12c98DF9uXvGR7KuibKfeKkGhHJvnR9mHHUmO
         fI0C+IDO7QDl27NTFznyqqHXbA2Rfh9UiRgpNNeyIXXs5OevH9L/7jIbyT3YVksVKAla
         2tHcniKa6/pQNzQv38AiWfFpnfg7sxzUdNu02ixnJZ07UUFiM1WBbsEAz+tB5W/+Kf/7
         9zhAZgbXCzB3/m5FuN83Er7/7GIv2q5DbQIR1O1vq1sbX9gxG4pkeIMyKAI/AsOh1U1c
         GZWtglq+t/i6rhxAy/cvd3NJ6k2sWCgrjgxvM7lqM6hqd2ITwuhC7/3/8ajg4XdnWdEY
         R/Fw==
X-Gm-Message-State: AOJu0YzbD1dxHtX5cgQyCSH/l0rfkzT5JmdgvgSSmW+k2vF0BQZ+WBgO
	RKZdO9xjnETvkUwqc8/S8Bt5dx2pWb9f0v4YwuVKVHSmNlaBpSA8Wwx23GFPAAaa1MU=
X-Gm-Gg: AR+sD12MHW4IFzmljWh3imsCXbnBwVRelPS9Ca9ruNwX/NsP+D4b0vfWBYwzaD0l0uj
	eU8f6PxeMUUPCdYJPnmL8a3J8e7VU1jletOR5avsSz0b2IDYlBy4NGgRRnL6IDKM5calKbF5Ak5
	pzQhOZses+4HnIU+WGpirES+NM+VxciNs49uWGVT+WlbfcTpYVHBOwn9C41BHMB8d7f8keLuatb
	rgJ2Mezu6aXsHjmFJwZIxgdSTR0AcNPaEjqAiv06YG7LLExOIwy6NYCJsAcChAQtD9K7wawKhEj
	sO/7yjIwYielV+FIvZ2z9gynZH7QOUvS6sm3CcDefPS1y4M+8LEvadetbonOC4HzyG37noqCJSI
	N+m5PYT4pxdAMHgU4mEohyYuZc3bVPziByODhXi5TeCtgY3w2QFA0SHhrjzCN8wfcyldXBpfB4U
	sHgWp2guHCQPXCm9RXyaK4JSosneGO6v0WMit3R9RBBRDSV6m7NkCXmsvtaZn/japtx96nqrMpb
	z5OUmT/UdAVRQNW59VCVkqd
X-Received: by 2002:a05:6808:4482:b0:495:fb79:7712 with SMTP id 5614622812f47-4b2eef561demr8847634b6e.0.1787329786142;
        Fri, 21 Aug 2026 09:29:46 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:45 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 13/23] NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
Date: Fri, 21 Aug 2026 12:29:17 -0400
Message-ID: <596a4de4f3ff57c628b616623a8c01e730706090.1787327939.git.bcodding@hammerspace.com>
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

nfs4_callback_devicenotify() treated CHANGE identically to DELETE: both
only unhashed the cached device, so references pinned under live
layouts kept sending I/O to the old mapping until the layouts were
freed.  Per RFC 8881 Section 12.2.10, CHANGE exists precisely so a
server can change a mapping without recalling the layouts.

For CHANGE, after unhashing the stale cache entry (so re-resolution
cannot re-pin it), invoke the layout driver's re-resolve walker.  The
walker does not install the new mapping itself: it un-pins the stale
node so the next I/O to that stripe re-resolves and fetches the new
one, while I/O already in flight completes on the old node through its
own reference.  DELETE is unchanged, and drivers without a
reresolve_deviceid hook see no change.

Re-resolution is best effort.  A lookup that hit the cache just before
the unhash can still install that node after the walk has passed the
stripe, and the walk skips nothing else; such a stripe keeps the old
mapping until the next notification.  Nothing is left inconsistent by
that -- the old mapping is a valid address the server published -- so
the race is tolerated rather than serialised against.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 10f2354ba304..64c994790d3f 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -390,7 +390,16 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 			if (!ld)
 				continue;
 		}
+		/*
+		 * Unhash the cached device first so re-resolution cannot
+		 * re-pin the stale node, then re-point any references
+		 * pinned under live layouts (RFC 8881 Section 12.2.10).
+		 */
 		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
+							&dev->cbd_dev_id,
+							dev->cbd_immediate);
 	}
 	pnfs_put_layoutdriver(ld);
 out:
-- 
2.53.0

