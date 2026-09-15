Received: from mail-oi2-f12.google.com (mail-oi2-f12.google.com [74.125.231.204])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2094F3B8BA4
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.204
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474969; cv=none; b=o6SDmG1jl+ra3TZLM3xIwJRyIJ9MSb+krcihaF/EaEVLma2xVDOKyrzIRN96xKX83vIGmHR4n+0xMuLf2oXstFsB6HOKKWpEWhroyfZow5fLW2UM7+LIyzkfQPLayYBKwl0X+swCMSpsc+CUHZge2hIDsLlFAUD7NUWaouqukXw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474969; c=relaxed/simple;
	bh=C3O0MFF7TKmLE/o+2+WO3u/2tWTZ9Hz3bJuv6kUSa6I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=r6CqSy0vXKeB55ghLvtlIIJL+/MJCiLQ6jDJCQmuVpL1DmFxtDIqkdtdKKwXbsTNioUgGEe1OD2jICfhYz1iN3aDkGyauNOeQcGin2i4b6dwiOFv13qHYD336d9iLsOUGFungvOIUY+5hyd5DdQg4HE1rI2z8w7rUrs3LdpX/Bs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=i4n7tjhx; arc=none smtp.client-ip=74.125.231.204
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="i4n7tjhx"
Received: by mail-oi2-f12.google.com with SMTP id 5614622812f47-4b37a3ed715so2265753b6e.3
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474967; x=1790079767; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NgxyBvFT8VoZVt+8f5R7jUMZNOLCROid4aZgQjIXM+c=;
        b=i4n7tjhx0RIkYgH/7F0et/tQIv0G5ljnU7cVGIKhlsIA9k/m8qcdktEXtQTPezkw3U
         vjlVY+Vf6rjuKI8Oc30o5byIsp0E3X3uvxByrLsRqN+TmCXpDGrLqtdwpK+QXuobDPPg
         1ijZSA5js8A7VK81oyayUrMywIPOSM2EmxB0Q8hS0s0CWqLVKPwjDbsSSgLw0NcPWWsF
         8bxsJchNC3NlRuUD0QN6XmRYe1ckuds0uUOJfeYv0O8BNaDCjwCplNRv5yqoF5eloB50
         D+p12+Q85OslvPbeciZ5MR8VrxbN6QryWVjgRStKJ04Dp1B/uUYSg94crA02cTsX5ENY
         DbRA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474967; x=1790079767;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NgxyBvFT8VoZVt+8f5R7jUMZNOLCROid4aZgQjIXM+c=;
        b=qPKaAf/PeJvv1moWwtUZPWfknZmo/nlazhETCP7oiXXgZL919WtQrNGZFRKvHVkJr+
         oTNHIh2iUKw+mYqCN+Yrs3vQo+LpvHqxRQNMyenHJLYHb6v/1qpJwI6AZU8FB7V4gtO5
         ZI4satoLyRDehE/q04GkTbqiSpAZV4yzT+cuScu8mS7HbgV/c9xwHClwLyRW2yDBh5LV
         NK/82J1DsbQm45q7EJwNQSKWbx3f02X4sv6Ld3Xeff/qys/nJPmPCrJ21vJOS1CrpUzJ
         Hq/zJ20JWlncaegrIWBIJSH2BD4QlFSSDRty25eMy9KjES4qgVNzeg48p+kiNwdWJW+I
         mKnA==
X-Gm-Message-State: AFuF++kNh7m+6dgJGWgcMimDUEP3+/3xv/cpqABaj8R5oUWScPkwNXGL
	08+0VVAKK9WrpnnAAG72iW5IhMUjD9r+ByLRZKxUzqsy0Ut62BoW/Gq+eRrvVNOEnn4=
X-Gm-Gg: AYBFou1sPJCpcLKI811zIpuvExdSQsNM2WDZcKn7FQPu5z5l7h/F4dnIQHyHPcQmbmF
	NCXRAyajYArrgHpHAajGRoJPBkVZDEeIWDJfWVbAKLtiGkxdhXj5tlk1NOw+NOWU1heE/3o7N9D
	C2y38OncsJAn2VosziaeGwFGGtoPMA3jihiB6lj/x7RGSVdFMWbhbeQgJi5bvKXp6lb87CPNnDT
	JO1RpxcihclqxBiEKxnQFVRi4b/EdxQp6NITVyhFy70nGbMnlFOrm5Z0YZ/aJ2UU+VMvUu0tIOz
	1PyT2lAFat5AaEFBKpolW3cXI3SEes25xSRz1pgYoCfrt17lO7MixQgEazazKQmlbgO5dCSFGZq
	n/bgaOKULV02QiHTUPchy9DjWkHcXKK6tKwF0HU6t7wHnoHLvZPmybFmSbKYgIb0r7VVY8S9N9N
	eqXHtB79owaTQTYyXW7U9SUwGOjUKbaNcPOqj21ZsMkHJyQAgAP+/XmKAkLlzEVqdni8vH4HGVe
	d2rQWhjQWf3jTWhimJOP4CP/PQOIcOBhOYr
X-Received: by 2002:a05:6808:151e:b0:489:93ff:9ea0 with SMTP id 5614622812f47-4c7b2df8c0dmr4881142b6e.2.1789474966836;
        Tue, 15 Sep 2026 05:22:46 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:46 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 14/24] NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
Date: Tue, 15 Sep 2026 08:22:16 -0400
Message-ID: <739aef0590ca182a067535d93ea05dffea7e628d.1789474702.git.bcodding@hammerspace.com>
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
index 3fb10c8e4271..01372d8548e1 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -391,7 +391,16 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
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

