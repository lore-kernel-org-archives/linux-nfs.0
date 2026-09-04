Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E539050EBF2
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540826; cv=none; b=MwDQ8FP4tgN/uOmdJz6EIx5ZTMJ6l137NGBQ5zuEf8KzUAvRiMtB/nqWr4pynjei7V72ZLawF5U3boxIDV7WFNOde6c7No/EdjtJu7TrvZkTaR3YjUKx8N7SnkpY12jfAq9p0tD5n65hBigIqrqKvolskmNg4SmzmcplydBQr6U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540826; c=relaxed/simple;
	bh=uj/zGxkDbmTxrFBHmuq9zG5vdOEa7SoOzyO36TAtLzc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=DaVcKDI67MgQ7BfRNwkLf9BfXsUz5uXJwKc7FQ2amCJ7BLJEtO1EVYV2upxz/voLmlZ75CZeYkg7JuTMExtZ7gPdYWvJCxglwTmulnGClVjlG0Z909sn73KLwLvcMJ8PxLG5tDCrSRixyDlWEFbXSy5K14blK7IEGg7v+uYOFB4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=DOR2YK+a; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="DOR2YK+a"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-9397e2994dcso107655985a.2
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540824; x=1789145624; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=1mplCqmjoY4a2uGjeJEne4DTJ6aM7zbXUN5EphHZbk4=;
        b=DOR2YK+azK0AsF/FMsojahgmdayLUoEOiUJnQ4Yc6Nn9EHwgfiorgoNDbRfoj5ZXXe
         UN08XCx5YunSHxgCkztplDnpsgNQMugj8HnYagzS/0DCaHSEZa2spqXNQa8HZ6U1cTF9
         vMEQeKxmhBPtqAcizqEbIUbXGmK6M/OOmWhge50Ja4hZcHuRIODvZbSWLhxvBNqDCV1D
         om9L5kaXaMllMVcG3fAi63gxgT40OeOMe1rwoXN6Tjcn0dJYHo00HPpQo16HFgW3k7rR
         wuJ/uH1wgEXmlYyNmu8+NJndgwrZOya9yCwwH+Gev39231CB/0zy83lnetcjSM2LX9yv
         +h3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540824; x=1789145624;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=1mplCqmjoY4a2uGjeJEne4DTJ6aM7zbXUN5EphHZbk4=;
        b=QfzNzkE/mpnyJfsXVQrMsssTZnh2R08LV3lQ2aYQF96ciuZ+Yh+X3WXzI8Sf4Bnhy7
         X7sWsZF4lQ2dFuqybtoPTgNJ//+9ob2ZsRYR+GiUvzPkzbdP/lI4VFWyMzFAPlEQfCbh
         dqu1stmtVzBplyqBOOEG2NACOrDCRgLUtY3V+R/FrxmN01oe5h4wKTAYPHkWL52lCTZQ
         2W0Mt+pUbguhRnJMaUzRf7vvTMln3jngIcPo0Xl/tnQ+kXdjDGR7lEGBt4iKpBmz37jP
         +Fs+E0M+/g1lfMsD9FoTw53Iisg8cBT0DxGQgtma4BSbp31tNWZVZKvwl20w0M9o1nPf
         XGjg==
X-Gm-Message-State: AFuF++m0fHveJEFIfZmlLSSeJlWA/xjz1xm8j0JCToEj7WmydxtNaimM
	py5DAeMl4vFPL0eNusWBBBF8NY0S7UW7PWvA64NKjDQ51nzAVpvPmtha7FPWzuu5CMY=
X-Gm-Gg: AYBFou3MHwRwGmXANF9fch0joF9hqlarn2bhyuu9SNQG2HLOukbSxSSsLQbAA7YsxRc
	dMD18aSnvjSyEGkRnOMFrocUbJDWWi7aJ741Cp9rk6aL/0IY3jkLTmS2EV8qRmgiLo35wbA38gm
	6V5V8HtmHaj4xzW1mEwV7vmMeSro3HDd7iMMNXuuJhIsMcJir4qEoTzb3WKNvgVBW8AmcxLFgiT
	E01TXg32su+RnqCzEQeLcOf/qpGeyCsPMx4OOpktUA5nl8YHh3N6/ZORH9cTgvmNN/7JyVGOky1
	D2Ga8Qy5rbOQ7HjYRqmzGhXFUxTxVkpiWrT2HxsdIryXmY/x2XLQRJLvxWKRSjKwxodxC99VOYE
	26d2BYefH8YjBzDhrWDqak9R16EaKLK0iRkSj1aq9LiQGJ+irP+zjVTLp8IFCVB7tFlteRRWCt2
	P7K5gIBIJ93Vz7/OnuSjuXs2HV3iLNOYjjBoDiF2gzzTfdx4XiFHc8rK3LYzI5MO3UmwCvOMmpn
	oCrdrGxp9eBZpZ4IkaJzoIL
X-Received: by 2002:a05:620a:ac14:b0:937:27fb:96f8 with SMTP id af79cd13be357-9398048b0e8mr636198485a.41.1788540818881;
        Fri, 04 Sep 2026 09:53:38 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.38
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:38 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 16/24] pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
Date: Fri,  4 Sep 2026 12:53:15 -0400
Message-ID: <20def7b8718b72b96d7741d253c62bc041611a47.1788530385.git.bcodding@hammerspace.com>
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
index 08bea2c4186e..2c0f5d4d38ab 100644
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

