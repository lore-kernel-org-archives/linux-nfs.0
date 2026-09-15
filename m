Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1F01B3B9D81
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474972; cv=none; b=YMBVIYRHOLad0zscXGmpHjoOSKRuv/xJ/BGqvKu0oVjVW6QnC4rhv9NFdkqoYgSlaCH+GuDH7t1ebWaVt6u3tjOAwdERARfrEk9TpxXH0kv2F4wyN19KqZ1M7/0orNxZ3+27ObDXNSRBERKYrUcqH6CeSsp5fXilw8KUt4/Imew=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474972; c=relaxed/simple;
	bh=SyhWCzsP3W7bfhU+kxia3JkBjE1oJlJJJ5N+j3F1Sz4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=AyFNWsecklAeqOtXRqQcdmqFJZE+2sXSEruISLl+xlRm1Jf+Be0+yl2FJkTDQfc5pTgaielyxrifSt7wAHaHXM5zk/6UpddxktRUosEYAI1NMM+wOzKUWdhjbpOAgraxxFqYWp9DE4/7J9MW8qGcvkBKKiYRxUEq6JlDmH2GoDg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=kJfKbHKB; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="kJfKbHKB"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c6b4783778so1245120b6e.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474970; x=1790079770; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=FwJ9sb8AOqIZJaaXMpbLU9WibTHsBZR1xXB0af4MU2s=;
        b=kJfKbHKBSGx5fmctMDtpsuyQI70Q09shGbaeovaTYRSId/Np/4H4aMxH3i+BvBVT7k
         cOdP0jgvLomNCPOzpPucf7IhsyyBNNRlKDayxBhVlEmrgGBPnVqSlq5VuY6jo5SYLnIW
         q016TjE8TTw6y2QaNJ6eKSk8HA1rH23QjJOheNpbLE7llgNvCuKf6QlVaTuuCy55jCGP
         B0u79FKOioYKnD4ByZDGsbvdl4CJfA+wPRxL2M5qbRy+91pIAjnEj9skUOqrJzwtFFg8
         EfXm2QmkukBbK14YQdlFu87TSbPXKGCtM/kbjegbwMYXmEWfK7dR33C7XxNoHx/mb9oR
         npPw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474970; x=1790079770;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=FwJ9sb8AOqIZJaaXMpbLU9WibTHsBZR1xXB0af4MU2s=;
        b=2SVUPVFiW+Qn+HaZVYL7OjHpeAu2+BAtvAi9rhvvm8ANpHyQJrbjOX4FKv1ibZcPO3
         tovjBoQi5nBuNaXy95EfzOTmhh8fozwu+PhnWAxwqxJul1fOhJqSGZpkI+ZSdekXkeGi
         8FdQYhUnviPyRe9y5/r6bJo+bP4HZeh3DNC3lx8EUHDdX7yqVlCLPm9lrLB6ZS2mvRku
         iKttisM5w+DBrR1NUPJbmfczATn6fRqZ3bDlgmDKbXRL1OUwwN/9enz5/weWlEKTwNri
         ySZayPn93THmZb07iXkRfwOeyiNMUU//E2dICtdL/VI8ot6ShbaU60gMlXfF9nRnjXie
         uqPw==
X-Gm-Message-State: AFuF++kocbEn+8ZGHWIqX9Fsw9dOdXjzD3nIHyp2hdaGTnokeZXM5uiG
	HiNgb/EdN/bGIwo6Ky6q7AVYN6lTsZniL/NESF3cXRKMoRkgy62LnFJgSS00RObQkvI=
X-Gm-Gg: AYBFou1n7EMYB9xGEGCxkVOp2VqJhjeCGQpteIKATBr8sEHwDGvja+RM2iSkIp4mD5c
	0bd/KNkF8La2G3w4FCjkffeYXGmtw87PphpJE9/q8zVghba3LkW8YxWGpFvafqMFpBKt9dlwT4I
	ctkBU9/IM3PL7dXRbYOA6Ink1+8YxhwpIaeEp3h3//Z8+Zo5N7STXSdWCF0nOU8miCRTdFX5AF7
	o3iTUJhwMys4j+bDf9ij31uOuDu5S4zlWxsoBqOfs6XgwzBXBAxHU0+ZVBwGhfKOD+L1gwKQgoW
	BdLYLkrDvKeW9xKKrlTjHDvkLVH8m3I+XNjZiywSjKP4uww5DCyAncf8I0AKx4J7hVvVLgpKrtC
	Shjb5H9brgW01q6XCIFyHhcdHsThwmzC0QppxflfdB/1NJvkm2U+7JFWRL0uTQp4OXmjwsZwalQ
	d43nilwEwEBq84OFbo9X3RJUDXyO5pgKsk1WpYOEYD2MKL9zEp0DAPrvrtFD2mgvwy00+SxDepT
	P5OBKx6E145jftbaYDGXICFyn0nWMEKIqI=
X-Received: by 2002:a05:6808:10d6:b0:4c3:95d:91f1 with SMTP id 5614622812f47-4c7b35e3164mr7399935b6e.1.1789474969741;
        Tue, 15 Sep 2026 05:22:49 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 16/24] pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
Date: Tue, 15 Sep 2026 08:22:18 -0400
Message-ID: <1948fdc9c5c36ee8e183bd52f1bb275409b15106.1789474702.git.bcodding@hammerspace.com>
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

RFC 8881 Section 18.40.4: a GETDEVICEINFO reply in flight while the
server changes the device mapping may carry the pre-change mapping; if
it is inserted into the cache after the CHANGE notification unhashed
the stale entry, the client re-caches stale data.

Track a change epoch, bumped when a CHANGE notification is processed
before the stale entry is unhashed.  nfs4_find_get_deviceid() snapshots
the epoch before issuing GETDEVICEINFO and, serialized against the
unhash by nfs4_deviceid_lock at insert time, discards the reply and
refetches if the epoch moved.  A stale insert that instead precedes the
unhash is removed by the unhash itself, so the cache does not retain the
pre-change entry either way; a reference already handed to a caller in
that ordering is dropped by the re-resolve walk instead.

The refetch is bounded.  The epoch is bumped once per CHANGE entry --
that is, at a rate the server chooses -- so an unbounded retry would let
a server drive GETDEVICEINFO traffic without limit, and each discarded
node can carry a DS client teardown and reconnect with it.  After
NFS4_DEVICEID_FETCH_RETRIES attempts the reply is accepted.  That is
safe because discarding is an optimisation rather than a correctness
requirement: it avoids caching a mapping already known to be superseded,
but before this patch the client cached whatever the reply carried, so
the bounded case is no worse than the previous behaviour and a mapping
that really is stale is corrected by the notification that follows.

The epoch lives on the nfs_client, so a CHANGE delivered on one server's
callback channel does not force an unrelated server's in-flight lookup
to discard its reply and refetch.  Mounts that share an nfs_client do
share the counter; the deviceid cache is keyed per client ID, so that is
the granularity the race is defined at.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c    |  4 ++++
 fs/nfs/pnfs.h             |  1 +
 fs/nfs/pnfs_dev.c         | 25 +++++++++++++++++++++++++
 include/linux/nfs_fs_sb.h |  2 ++
 4 files changed, 32 insertions(+)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 01372d8548e1..ea8c558b07b6 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -395,7 +395,11 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 		 * Unhash the cached device first so re-resolution cannot
 		 * re-pin the stale node, then re-point any references
 		 * pinned under live layouts (RFC 8881 Section 12.2.10).
+		 * The epoch bump lets an in-flight GETDEVICEINFO detect
+		 * that its reply may predate the change.
 		 */
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			nfs4_deviceid_bump_change_epoch(cps->clp);
 		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index bb1ca7ba0221..9a5b8070f595 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -406,6 +406,7 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 		const struct nfs4_deviceid *id, const struct cred *cred,
 		gfp_t gfp_mask);
 void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nfs_client *, const struct nfs4_deviceid *);
+void nfs4_deviceid_bump_change_epoch(struct nfs_client *clp);
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
 			     const struct nfs4_deviceid *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index 274abdd6d5f3..a3b28409539a 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -181,6 +181,21 @@ __nfs4_find_get_deviceid(struct nfs_server *server,
 	return d;
 }
 
+/*
+ * Bumped before the stale entry is unhashed, so an insert serialised
+ * after the unhash by nfs4_deviceid_lock observes the new epoch.
+ */
+void
+nfs4_deviceid_bump_change_epoch(struct nfs_client *clp)
+{
+	atomic_inc(&clp->cl_deviceid_change_epoch);
+}
+
+/* Discarding a raced reply is an optimisation, not a correctness
+ * requirement, and the epoch moves at the server's rate: bound it.
+ */
+#define NFS4_DEVICEID_FETCH_RETRIES	3
+
 struct nfs4_deviceid_node *
 nfs4_find_get_deviceid(struct nfs_server *server,
 		const struct nfs4_deviceid *id, const struct cred *cred,
@@ -188,11 +203,14 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 {
 	long hash = nfs4_deviceid_hash(id);
 	struct nfs4_deviceid_node *d, *new;
+	int epoch, tries = 0;
 
+retry:
 	d = __nfs4_find_get_deviceid(server, id, hash);
 	if (d)
 		goto found;
 
+	epoch = atomic_read(&server->nfs_client->cl_deviceid_change_epoch);
 	new = nfs4_get_device_info(server, id, cred, gfp_mask);
 	if (!new) {
 		trace_nfs4_find_deviceid(server, id, -ENOENT);
@@ -200,6 +218,13 @@ nfs4_find_get_deviceid(struct nfs_server *server,
 	}
 
 	spin_lock(&nfs4_deviceid_lock);
+	if (atomic_read(&server->nfs_client->cl_deviceid_change_epoch) != epoch &&
+	    ++tries <= NFS4_DEVICEID_FETCH_RETRIES) {
+		/* a mapping changed while we fetched; ours may be stale */
+		spin_unlock(&nfs4_deviceid_lock);
+		server->pnfs_curr_ld->free_deviceid_node(new);
+		goto retry;
+	}
 	d = __nfs4_find_get_deviceid(server, id, hash);
 	if (d) {
 		spin_unlock(&nfs4_deviceid_lock);
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index 34d294774f8c..cd3ebca61dd1 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -74,6 +74,8 @@ struct nfs_client {
 	u64			cl_clientid;	/* constant */
 	nfs4_verifier		cl_confirm;	/* Clientid verifier */
 	unsigned long		cl_state;
+	/* bumped on each CB_NOTIFY_DEVICEID CHANGE for this client */
+	atomic_t		cl_deviceid_change_epoch;
 
 	spinlock_t		cl_lock;
 
-- 
2.53.0

