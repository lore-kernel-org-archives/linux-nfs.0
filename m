Received: from mail-qk1-f181.google.com (mail-qk1-f181.google.com [209.85.222.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5473C486B86
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540825; cv=none; b=f3W6f2z+XFNTi31K/rfNYUTzgO9W8Fv9si0hA90DHWCEMeCdVcVGnNfc9/pRdjPL7OvTj9Ejx5B6EPObQ8hgm5S3g+4+mRGabU4GbHrvM3qzoyfopDOiFYdVZ1vexoPWomUw5FI5oNFf5TCqLUKrZ8H0R0Bv9c3Y8sXzJCJovA4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540825; c=relaxed/simple;
	bh=C3O0MFF7TKmLE/o+2+WO3u/2tWTZ9Hz3bJuv6kUSa6I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=FADvvJc3Z43dlnkMnURRYdjxaAYHSoic13GgJjaUCUAiwh9pwdoBz1jzgzLCLvGPW1wHlF8e4dEIcBbmPCUJ3e5rc9uudGtMWTRmNm/xPgYEWTOZkBuixt9hjgs2YXnj+Qb9IwC1ItCuQe+nsnfR+mo/v1GsOFFLIxD9xYi+stA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XsM3iXpV; arc=none smtp.client-ip=209.85.222.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XsM3iXpV"
Received: by mail-qk1-f181.google.com with SMTP id af79cd13be357-93903d81a82so106355885a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540822; x=1789145622; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=NgxyBvFT8VoZVt+8f5R7jUMZNOLCROid4aZgQjIXM+c=;
        b=XsM3iXpV6MdWjBcllt/TrfS1RWAaXLaBiCxft4o7QsKa4ERsDhzZZ+gk/OgUaaQ2XP
         +oG9P7e88QxnwluSnqiF3jLrKvDS+cnR+mAytuxWbYgi0a5tuW+NG8llrC3x9G2y6wDw
         RAvJzUUt8svJPfjKzz/0HvbevQIn3umCmxN0lYO4l7/430rDzvmzVFU4sLovrSmHIkKQ
         V6gboYXeOyjwvlo+f9YcdoJ8CmhApBkzxA7XXPC02x+CtEIMHFQmPSpByXaZd3stJ3Up
         dnlErzUi1knVJNnHGo2L8KMgbIgzrNE99BhqK9lc5pXzDNaSdPfGcRVs1LFiOzY6CXjc
         RxLw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540822; x=1789145622;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=NgxyBvFT8VoZVt+8f5R7jUMZNOLCROid4aZgQjIXM+c=;
        b=U3j8MJJ5Fx2FvCuI6mPzTKHo/ERdn6wUHAVJSKion3RNod/akJn6JzX2Iy06bLbkef
         /YFKuZfAGzkgrayiKaigqi7FkjenuREwn01fjZayaLq/s7vohXqQgaWT1km/V0NXcw7z
         oMslN+KF/Y6FWb4oYWoNjQ4byoTj90jukIzcuMoMe6OsZaNA29M6WKwHI6DKUixz8Dpa
         njnTKHtihOev4pTKbQ1cRd6wV4yZBIV6aG2p2/5f2DAL9xAabJLyo3Fbk+ODJqv8rlDv
         7YgkzsbwVkHkyYkS3L3w2jau1LdLMljMfn/K3V5VpUHeffUpfgsdIY0OLPSlteiUi995
         XOgw==
X-Gm-Message-State: AFuF++mhA7Iib45jsM+2OosTMgP5UPBpoyf1BDRMywbETnXDdaI/NCfN
	FROC8x8WBaQPKd0Z2n8RSF1c0AigWw04Y7UgL9alkk2McZ9hpv5BBF0RVLxtsc2/B2c=
X-Gm-Gg: AYBFou0yPH7tgWuzO7iJ/D9MPtokRhbrL6jenpJUp+MEPKPIJE9n/GbKzEMemic1RHC
	YHviuC8fUzH72ypMXw4q/mBD5M94FA5ELKguWYcaQUoSzdjvA2ftgxhhlyhGWn1FkiQrijjccps
	eAq3VI/O6ioZqNplndQhrgVDei8cd6Y/FBBsZ04obb4lSmfHyBfZ+o00NYQ22FGSaSbkQQZCBdw
	yYK8KXvEU2m19etnTGHGvBDaNKS/SrF1YWFpITs9IrEBj2A9TPFMUco4Up+K35Wzw10kFJ8zoj7
	nFmQOP2IdbhCFldX2UNEbtjtYK0n4cEearOB/D/XpTTw4NfRJ1WJRWz19OscY0QG8WQ5mOU/oBD
	SoihN9wEkgMFpTSUb6DF3sIc1G3uf1/PGNSXDrO9GXZH6muImwOUx31n6Ym6xuLmrPNYilysMpp
	8Bg7GkCAA7WLWhlS2ZEcNOZE2bIMKG3ZakfnaJ5//ecitOzkOwWiap+lRD7vJ8E//r5Gce9WaYR
	ldIZ6XqhRo5AeggdjQCsenY
X-Received: by 2002:a05:620a:4802:b0:939:1498:cd55 with SMTP id af79cd13be357-9398044b5c7mr735710285a.36.1788540817101;
        Fri, 04 Sep 2026 09:53:37 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.36
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:36 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 14/24] NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
Date: Fri,  4 Sep 2026 12:53:13 -0400
Message-ID: <6ee3180dfd5cd07075a0eb58f39e0811a5f807ca.1788530385.git.bcodding@hammerspace.com>
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

