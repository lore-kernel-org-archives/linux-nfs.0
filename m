Received: from mail-oi1-f174.google.com (mail-oi1-f174.google.com [209.85.167.174])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 87AAD40F72F
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.174
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653822; cv=none; b=W89PkcNZnEwMd2EPnl9vRBTylffOIbodTqnHM+a62iq0n1Rf/FJEEUx9CK9lgdoXnTKz9FLCXogfMK/lbr7JTdHabxHDhpqi0xtsF83rtSlWstvFGe6UajdpaZ5Kx4PDGzdskUNFHXubRtLokVMqBuNamMDOkkl0cNCDDzMusms=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653822; c=relaxed/simple;
	bh=TMEUEi2SIinQ7E7fh0R+hLdf5nqjIif4/O+7hFQ6AMc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rHSPIWEcJdcE0GoqCRYcjrJrTJYINrFgNdwoJB/jZyFO1KQ0fZpMrhKzLl46EorEGZkPNl8sWUhbghCzyVmHCyBk1PO0nLyVlfqUZL9ryXI65E2ZwYoE4GLYuQw+YLqE7VuGa2T2mJ7C478RyXgLo66PSSq1tvZDoV/vLZYEVYY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=lDnfu3ye; arc=none smtp.client-ip=209.85.167.174
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="lDnfu3ye"
Received: by mail-oi1-f174.google.com with SMTP id 5614622812f47-4a4cb36ae00so159039b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:40 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653819; x=1787258619; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=yREyMV78xqxcGtmAw4FUlQLiSz3G+9EyPP5ebGc1dDs=;
        b=lDnfu3ye9JeVKAVpLTF9SKpJJIKfNnYK3OIZflE62rrTMTsSPguI0X7xHkkARaMoPy
         t5F19fY22VvplbxcQyYtteX4iOTGZhHdzpX083EuYOuaHUWUMzl0tKO/qzAJw+MWoUg9
         slwU0CESeGn2KQHyJ3aeidz3GBRHiqkG4V1ynKxQPV+ps1g9tQDCLz92//YRnCfv2Xcy
         y1iby4P6jUY3iGiYrKFLPpIvqNLKyQ4r7Lhkd0hl/2jK0KMFUmZvJfKasr57wDDt7+jC
         PF0b5JqkT/QcP+sOgXthl4ZXfR0HitZjYf4XDx5U2uh+rz36YYePTOhI8TkN1XUen9E7
         c9tQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653819; x=1787258619;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=yREyMV78xqxcGtmAw4FUlQLiSz3G+9EyPP5ebGc1dDs=;
        b=lOvSKM2XjbOqt+x+y7a547ap+oi90Js0fUR7cZT9DmCfRgejQjO1uUrUfMfHXkRkfH
         TO/vvihZWHaakyZixuEi3MphqGWs1y9zN1D0TIAZ/Zojzw/lS5fogdz1WNkKsNuAmvUe
         Tb9QbufT135YdZkJOIIPqx7UxHdLilyP8g38KS2GPJ7eFdhAQxsHvsDr90yWWHeTSZdX
         Nr6Z8sLwwwgUbOR4IGIBYVgbzTEPXfe9RQ/LD0GS1GTtdhiHI0z+6FOMLyx9oV5JY8A2
         j0N+2zMhzXpXQjmFvMKpbl7z699Sx/UEpQsWh13/+IWkI0CPgDTmbce6QEhZ8yXM/dmt
         KO6A==
X-Gm-Message-State: AOJu0Yy/Kuk2K2YphlwpizNXRBoHrIZqVVwCjTZLO5oJONyaAdLZeY/K
	W+KI0JRqEqtgpMK+uoWIza5R3I8Hi7Zc10cM8/7vkBmxMMcrCaVvW2b72udvNaBZea0=
X-Gm-Gg: AR+sD13YatfV6thzivxJjGaWnFoaC6C1J+fG8meRIV0n5B5pJE4fJpczQISPl6Lzkat
	+fMJXfi70Mztfc1CALrcD57DhKNrKwlGch+BB4ub8JK0NzuIv31bIJ6WYy2BtQ0t5gNFxPryfJN
	H+PPWN/Czfr2kaAwnTigBTeHVzTllMFWyPgTXJofSsgZT/rPlorwGQRuDeTS5bgDQah9azxzb8r
	MWmI1TnBxUaIGpg7NHD10g4Fg8tz5aCmffgJrn0iedzmdGNNVMkIW/QCFMpPHT7Mei3HCIvJFqh
	JgcoLyFu3z9IAsgeMtesKJ5LudqNJyJA3aSfl8wxqpMD3pQXair0M0ote8p0LTZDF4te7wOrIcR
	n2XEU5uXo99e2JLOiltxUq5VV4PT6m8J7T/2NPht9UC8XLPKmSx18vS9CCBrxAdA6zgVck2RzoG
	VZOX+2kf9wsgKC6uqA9zpf3C5tcBj46oI9v6ZU2uTXxYR++l4VwH9LjxOx6jEA82twKaCqcRpcX
	VWOg7LGpXvIvSDpph6isY9rEKwccyO2rp8=
X-Received: by 2002:a05:6808:238d:b0:4b1:b037:da8b with SMTP id 5614622812f47-4b241b9d07fmr630773b6e.11.1786653819230;
        Thu, 13 Aug 2026 13:43:39 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.37
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:37 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 13/21] pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
Date: Thu, 13 Aug 2026 16:43:09 -0400
Message-ID: <c5fb003dffc63416370fbfa25b98e4226acf13b2.1786653063.git.bcodding@hammerspace.com>
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

RFC 8881 Section 18.40.4: a GETDEVICEINFO reply in flight while the
server changes the device mapping may carry the pre-change mapping; if
it is inserted into the cache after the CHANGE notification unhashed
the stale entry, the client re-caches stale data.

Track a change epoch, bumped when a CHANGE notification is processed
before the stale entry is unhashed.  nfs4_find_get_deviceid() snapshots
the epoch before issuing GETDEVICEINFO and, serialized against the
unhash by nfs4_deviceid_lock at insert time, discards the reply and
refetches if the epoch moved.  A stale insert that instead precedes the
unhash is removed by the unhash itself, so both orderings end with the
post-change mapping.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c |  4 ++++
 fs/nfs/pnfs.h          |  1 +
 fs/nfs/pnfs_dev.c      | 25 +++++++++++++++++++++++++
 3 files changed, 30 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 64c994790d3f..1721c6dd2250 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -394,7 +394,11 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 		 * Unhash the cached device first so re-resolution cannot
 		 * re-pin the stale node, then re-point any references
 		 * pinned under live layouts (RFC 8881 Section 12.2.10).
+		 * The epoch bump lets an in-flight GETDEVICEINFO detect
+		 * that its reply may predate the change.
 		 */
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			nfs4_deviceid_bump_change_epoch();
 		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9ec0ffebe3c4..f3c55c86c256 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -399,6 +399,7 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 		const struct nfs4_deviceid *id, const struct cred *cred,
 		gfp_t gfp_mask);
 void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_deviceid_bump_change_epoch(void);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
 			     const struct nfs4_deviceid *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 274abdd6d5f3..0c39ae8325b3 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -181,6 +181,22 @@ __nfs4_find_get_deviceid(struct nfs_server *server,
 	return d;
 }
 
+/*
+ * Bumped when a CB_NOTIFY_DEVICEID CHANGE is processed.  A GETDEVICEINFO
+ * reply fetched across a change may carry the pre-change mapping; the
+ * epoch lets nfs4_find_get_deviceid() detect that and refetch.  The
+ * counter is ordered by nfs4_deviceid_lock: the notification handler
+ * bumps it before unhashing the stale entry under the lock, so an
+ * insert serialized after the unhash observes the new epoch.
+ */
+static atomic_t nfs4_deviceid_change_epoch = ATOMIC_INIT(0);
+
+void
+nfs4_deviceid_bump_change_epoch(void)
+{
+	atomic_inc(&nfs4_deviceid_change_epoch);
+}
+
 struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(struct nfs_server *server,
 		const struct nfs4_deviceid *id, const struct cred *cred,
@@ -188,11 +204,14 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 {
 	long hash = nfs4_deviceid_hash(id);
 	struct nfs4_deviceid_node *d, *new;
+	int epoch;
 
+retry:
 	d = __nfs4_find_get_deviceid(server, id, hash);
 	if (d)
 		goto found;
 
+	epoch = atomic_read(&nfs4_deviceid_change_epoch);
 	new = nfs4_get_device_info(server, id, cred, gfp_mask);
 	if (!new) {
 		trace_nfs4_find_deviceid(server, id, -ENOENT);
@@ -200,6 +219,12 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 	}
 
 	spin_lock(&nfs4_deviceid_lock);
+	if (atomic_read(&nfs4_deviceid_change_epoch) != epoch) {
+		/* a mapping changed while we fetched; ours may be stale */
+		spin_unlock(&nfs4_deviceid_lock);
+		server->pnfs_curr_ld->free_deviceid_node(new);
+		goto retry;
+	}
 	d = __nfs4_find_get_deviceid(server, id, hash);
 	if (d) {
 		spin_unlock(&nfs4_deviceid_lock);
-- 
2.53.0

