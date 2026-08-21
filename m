Received: from mail-oa1-f42.google.com (mail-oa1-f42.google.com [209.85.160.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F97B49363C
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.42
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329796; cv=none; b=hIOdH2ekcBpUpUGFLxVRjANYsax44saz7GFD4LRssmX+RKTQ/whL5qDejl3zn7cgf0qZEixFMtGv4qO/S08ebTr5+m2yXQdHf9a1s98SPT6KwlV5nAyeMLV5bCQ0PXrnMFNWGsKtrpA7ReQEgphWa1DYIVOJVB5t+vOVpkmNmX4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329796; c=relaxed/simple;
	bh=VnWYdU83ZuCc+qJp9on16IX4DQqezg2KwAAwUTiNpVM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eJX54hxsScASsu6YbtYuYjEyxWJ8q55EAtkQDLZiwdHvBqzS6Xqs01nEcz65Mnm9UPumlMR8e6eQCUpV3p3fuS94qRCPziFqPOo3Kc+f6ifZCFw/PuXbtqS5fQ5fDceCKgtLtY+lHkuALHCaTbq/CAFqDwwJo5S0IHO/Kq0KXdE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=fzRXPL1l; arc=none smtp.client-ip=209.85.160.42
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="fzRXPL1l"
Received: by mail-oa1-f42.google.com with SMTP id 586e51a60fabf-455ca262ccbso981236fac.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329794; x=1787934594; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=E6A7S6ZOBYp3SBoumrLoV6/dwyCw+xLsaOAWmFCPkK8=;
        b=fzRXPL1lfxdwCyzbc2RXL+3QotE+Zsa4xh6PqQJJCIEwB+e77fS7xyB5ZT3mb7P7Bm
         v4eQxdIqoaI9oVidpuFNJllI+Bb0qKdXWFIb/wMbVztXF23LaGAdSgculFOIuW9aQ5Eu
         Gq0AyA3/ZGhGYxyX01j6VnAESLQHy5RbitPMtSV3wqmIIx2vTvMSNPgVToiL6wMe9ENb
         ePIBHycVfusj+NG6TMBM7XYMvfRv8R+GvBlYtJ4Jb5AT6TyYWerwOuK8X/H+tJuKs3nT
         SIVAgtCLlyNZjjqJbVn+fLySdirEmh5zwHKJeBsdmUQ4uU3hG8qkMBtERY+sNV+Nv68C
         EJig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329794; x=1787934594;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=E6A7S6ZOBYp3SBoumrLoV6/dwyCw+xLsaOAWmFCPkK8=;
        b=qKpRPRYN8o6rxOWHG4CJ05EGoEfQuBgVaY5cwEPL3zpCIgjpEzCo3Si4dLjiFCNzO7
         g9ShQTLJ0wTG4yilz+mNQ83Bpbrxja/6NdXN3dYk5/uY8OT1gmqD+esjZQ6q9ATnmKJr
         JTWcCAq1mV2rou8FImGz2c9TAf8fWUuhCKmgjdQz1XEwSPNq5mns4ry//gF0TTDT8LkC
         tOo57UeoLeh9q3nBUkXKydvYrnSREKFmIXF7otfmM3onogQ3G9rJBYJCCGLRpTcWYHV5
         Tesr1LfYo0zOuo4nRF1CtFJidIwh9ci5P3R2Ethyijo+aJ0uWQinefAwJeh4MPfmu1Pm
         6X1A==
X-Gm-Message-State: AOJu0Yya/rIB0XhvyriAwsQSOv0Vcx6lAN7PRLfU0O7Npj30gwg5FjGB
	RG6ls+wc7aGNP03c0MZ8EXc1/9dvar88ZHZxXIGsGVMK/1y9IfyjUgl3YmdiXpyIGDG7C4yudgY
	dpUVY
X-Gm-Gg: AR+sD11D+GUfNCgsT3VCX1QR6AqIsO+btg1c5X/LpLIhnok07NxBVqf3yyIgLTb15T0
	Avc78M8gvB+llJiV4GFHAFQ8ecqItgpTZRUOQPfmbtqEQlSWOduX4TaZd1L9CxT26Az8ry/7v/t
	B52+BILGxVx7aJ02ykWbJ4ii12fA8Jrvfj3pALs+0YrYyOZJHM01eUNqoQnnkRToxf9tKVV/XzH
	UXA+u+tKNw9KFO7YpNOfyIzi1Wv1SFtLmLH+eCzfTt05fr9zT0cluF210Tq5IiIfSDPGI0f7QNn
	6d4YYQgz1kRGWGMkJNQhRqlD9QVmOVjw1M8e2ydMWt5zO87uMNGcbH2U+G6r0rFn5Fi1cQV1bfQ
	ZXfhfnNysf2l1PeFXYTNPP2VB0zji91wHxb4CQRbXkKeH69Wggq4HFEVTCFywUtUcW5ugDXt7uH
	3lqLF/Z8bfrCsoOgdVPD2DIQyGE4RlLVvNZsqLyPwrsMqk5kGpHaYKYXczNhK1925VcopKTMKc+
	LV/E1wZGrjXOFLWrdzatsnsWLFo+t7TbaY=
X-Received: by 2002:a05:6808:198e:b0:495:feaa:9e39 with SMTP id 5614622812f47-4b2ef11ee6emr8829488b6e.6.1787329793733;
        Fri, 21 Aug 2026 09:29:53 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:53 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 19/23] NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
Date: Fri, 21 Aug 2026 12:29:23 -0400
Message-ID: <b431a1e7a21ea8612d6a82ac0b29cb4a6e656d7e.1787327939.git.bcodding@hammerspace.com>
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

Turn on the RFC 8881 Section 18.40.4 DELETE handling: a DELETE for a
deviceID that no live layout references keeps today's cheap behavior
(drop the cached device, no state-manager wake).  A DELETE for a
deviceID that live layouts still reference is deferred to the state
manager, which TEST_STATEIDs the referring layouts, recovers revoked
ones, and confirms or refutes the delete with GETDEVICEINFO.

The deferred case no longer unhashes the device immediately: if the
recovery concludes the DELETE was erroneous (the deviceID still
exists and a referring layout is still valid), the client keeps
using the cached device.

Bump the deviceid change epoch for both notification types rather
than only for CHANGE.  A GETDEVICEINFO whose reply is already in
flight can otherwise re-cache a device the notification has just
invalidated; that is as true of a delete as of a change, and Section
18.40.4 opens by describing the race for the delete case.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 24 +++++++++++++++---------
 1 file changed, 15 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0d760749f481..0e606b63320e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -391,19 +391,25 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 				continue;
 		}
 		/*
-		 * Unhash the cached device first so re-resolution cannot
-		 * re-pin the stale node, then re-point any references
-		 * pinned under live layouts (RFC 8881 Section 12.2.10).
-		 * The epoch bump lets an in-flight GETDEVICEINFO detect
-		 * that its reply may predate the change.
+		 * Bump the epoch before touching the cache so a
+		 * GETDEVICEINFO already in flight can detect that it
+		 * predates the notification.  A referenced DELETE may be
+		 * racing revocation, so defer it to the state manager --
+		 * this thread cannot issue fore-channel RPCs.
 		 */
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
-			nfs4_deviceid_bump_change_epoch(cps->clp);
-		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+		nfs4_deviceid_bump_change_epoch(cps->clp);
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
+			nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
 			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
 							&dev->cbd_dev_id,
 							dev->cbd_immediate);
+		} else if (pnfs_layout_deviceid_referenced_byclid(cps->clp,
+						ld, &dev->cbd_dev_id)) {
+			pnfs_deviceid_delete_mark(cps->clp, ld,
+						  &dev->cbd_dev_id);
+		} else {
+			nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
+		}
 	}
 	pnfs_put_layoutdriver(ld);
 out:
-- 
2.53.0

