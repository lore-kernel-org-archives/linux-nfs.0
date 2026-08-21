Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D42C3493636
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329791; cv=none; b=izVI7P6McnVhUBmwj3yudrLTbc6bgA9SztOQ/xF7Aul05U/mvjIITExO/Denbo2dx8qHa2xQ/uJfL4/npmGhgdcUXDcOktbVCP+5vE7sAx/zg3C3PdM3CKbdk8BLNDHNsn1tM+h+9UDpeyEezR1ELL0ty7rDrdC1AskuTHIS8XU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329791; c=relaxed/simple;
	bh=dtn7bYMHKP2WCuItdaKQ0NJoI3iuZPpGBYVYH1cJo5g=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=nPon2KC11X1/3kQehqpIecSNW8F9/HiaSMLyEoVYI8dSJbi6SkiJo4oHwe6WXa5741gBI8mVQJmvz2WARODuEm4MEvKiiPpHKyhHzvqrTU/E494mCok7nCXfCm+W/D4oiwbTv3caY930cj8A2gDG7njoBs6fJ1PipoVffYONUow=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=PeQtV1s6; arc=none smtp.client-ip=209.85.167.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="PeQtV1s6"
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-4b28d7c729fso777655b6e.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329789; x=1787934589; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=8j1yS8lex/iCTeJnI8cjdV3ny1+n+V8zANSeAeWU1EA=;
        b=PeQtV1s69mRbFiqLez+Yq+6fs3x288MpmZ1YoEPXejatJq5A3VS/DzH/cS6YsQqtsl
         MDV7cD9g3eKkiQeqiyu6Svsxn//fN8VUKFkaTCE7DwdaiWPCpg8sga25xoiG3+kU4YCI
         +vucIidzn5RRz+ICgtMfLshPZbR6rDx24OJOYQZ58Fc1NwDjxeAvjSN3I8knBNAd8cn0
         JzOu3BFUvM6wJ9GrDay33hurEkKxnjLSoSZagYkB8idFLQerYE+CcAhQOKgom/CVUT3L
         ++5gXgkzNWj04LZ9au40ZasL7iNiSPOBIg8+pRv6Mydy31HSrV87fEnkmSXAhEudKxaD
         W1TQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329789; x=1787934589;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=8j1yS8lex/iCTeJnI8cjdV3ny1+n+V8zANSeAeWU1EA=;
        b=L406wpag/emFdx6Qd0gWbJuJKxQ//9YqmkAh3078A/girkSNE1CyxmVxTgd8SM/9yh
         czpzYpm8JWdVvh2lRpOXZ/b6jnU0c3G/Rz9Ig+9bToq8PQrrs3NS84RxCHyVlLCc5tPb
         9Q3XF7EQ+oLBxx7b2018pDxTLdllrJQrWeCrSbmq9/kX1tYWiwo3uQo7UB3GqqKLR5RK
         pcXc+PJiuPtDGkYeXObAYnqVU2KH9fz704IjthsHz7psR2Hb+0po04SgJpRu5o1IsdcH
         aXBtShqMB3ZgLdIi3YmUE+P2y/XxKN4c9DISlZqHfKvuMC7Tdw1O/kcX9HrbJpesGklH
         z9cg==
X-Gm-Message-State: AOJu0YwYwUWM0DO29gFY0tzYzUULWfanbkGh+bSuZ+3VxAJNO92GeGTb
	qXEds737n9gE+HihN2hcaIsS2l8AwC6mokVxWweBZ/0wDZ+odtILN5TGcfMx4ghbTrM=
X-Gm-Gg: AR+sD12NgS4FJjnbM4BkJtU9Gpl/r8CxRRJdC7hk2ZvLikotzXyEbjqcvMzOR0Zpt3z
	6zqmx/A1VeBmbpDMnLw8T8UBQzsJ41ifryG830SrPf51Z5chFYHKct5YS+32tml54ihcLoxPVYc
	xBZp0b1yV88bSr0cMillPZ+pa6bq5rWJLfthA2UYeIO0LonpzJQoAsMKlZN62zmKzTyNZTYJyIn
	qBaBqBp6W6yXYpoHWmS6OxSXlxVf/1E3uv+4sczJGxsQ5XvXZ5kljjl2Dms/nr80gaVES9KyCR+
	B0vvVmLkNwEVfJy0tVSh94vGzpbyqQUIlbpvu8qHcslNKMx+cY5IjekQWQhU7+V8gIadHDg8O8t
	VeW0n6ESph28LQWZx7sKrkn38vrDLWjd+VipvqB1uZOx8/eNd2fNf1yvrN6WEJ9W6WharM4osYf
	gIEEewvdAwcXuVWuaL4Kun7XnsJHzzhAdTQxrsJIo3qJ0ACofV9g2nS84EX7prp7+K96OzujMe8
	EqxsTI+055RSrHsfxDT+w11
X-Received: by 2002:a05:6808:152a:b0:4b2:9aae:3f71 with SMTP id 5614622812f47-4b2ef378f40mr7906734b6e.15.1787329788562;
        Fri, 21 Aug 2026 09:29:48 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.47
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:47 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 15/23] pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
Date: Fri, 21 Aug 2026 12:29:19 -0400
Message-ID: <4daa6ca18d272e870e90ba827b2985de7bb2ce36.1787327939.git.bcodding@hammerspace.com>
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
index 64c994790d3f..0d760749f481 100644
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
+			nfs4_deviceid_bump_change_epoch(cps->clp);
 		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
 		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
 			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 9627da034d94..bf0b012a49a9 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -405,6 +405,7 @@ nfs4_find_get_deviceid(struct nfs_server *server,
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

