Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E37423BADB1
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474976; cv=none; b=ofb+/YAyFr5NCg30wAbm8Hesyc/FHYQIF8RMKg2sEVi5CKozj6iGaQhLHaKro737URvM0ZHlRxS8YEk9p4pmd+nePuixd3uPYrFfCwMupMyf+HnwJIVPYoABxcSdWVcjR9/kCHvbtYo9EwMAjcGy7FmE2GcqJ5TPQbwIriruAQ8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474976; c=relaxed/simple;
	bh=q44DsGR75xbeoUEhLZmW6W77Th4UYHtWiOgg0DyI8DM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MQ2CeX5p9CPRH0i0EzN4LE9dLi3tGMn47BJyuhwdzwkOsVmGHZF0ToypM+PCU1EL9sm8NaWoE9z1kzj6n7SduL898BX6x9HC5tNm4Lb22w0pl2IaaTKDdfQ3TG6UrIIz65pCPwwDfU8RBXThoeftcvntdTtkQNrBS+GxROyjzgY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=YOWaIzYp; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="YOWaIzYp"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c0776592e3so95557b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474974; x=1790079774; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iHHZe83R3XmB0WtI+frrm3XyScFEkBqGdrTvrAvVhoQ=;
        b=YOWaIzYpwcKA0QOzmaGvkFEECqRBtGgn7v862H+RiJIehgfDM/TOmXwCopMOJiuBKI
         Q9v9ZHpYgulKaK29Go82tIN3MQqvBCZc8aGGJxMiF3trbZyfVqLjBwUsfMyj1F0Us9pu
         yPaPPlv4T8KQ7l6cDYEP66VM7O5cbhuCy6Jo70hJJz0e8x3w6tNIffxdcn6Y4Q36LnF8
         o2LP+B2MX9A7THES4MwLc0E+VxCs6xA8wRJEYIVhvLUkja0OdUqqV//2au/CfczBOHpx
         1SLgfYCqzQq+6/2e1xAMXsHlf2gHfg83NbGBCPFOz8kK5WQa5ZH+swajFxvxawgcii5s
         SKwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474974; x=1790079774;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=iHHZe83R3XmB0WtI+frrm3XyScFEkBqGdrTvrAvVhoQ=;
        b=ZLpBeYwaUPQvInB5jFs5wmqMRfh73ZORATN39vzmb1V7vHOT/aM5fDjIAnq+y9lh7s
         xQFI9Q2iFvFen82OJHN/tBLRpp7mLQP9CxxiTuczscg6MgMk7Buzwcn60bhEZUbzvrEK
         wQm+mxy1AnX/eQWTqQ4kon0/fH1UPBQ693Gz5blpu55pBx2sgXlNLl4j1u2jKxJ0ooWE
         Wv1zC9bDDd34SztrZKmeuGyicWORg3SGCRvQGNl0fvp0A84kwDdATy+NFWqS4yUPm+Mb
         nV78JqpZpsdG/BjbwxIfrE9y53Kzt36Q1+Tf55I/+jT+W22XXMgbDtnNy4tNBlLmItiV
         MdEQ==
X-Gm-Message-State: AFuF++l749YOrI1w8453sgrfA95rdZQEyEBxwHzz1fyIIKyCWa55q7Rn
	9JKA9g7Z7eTsrg+83qTKKAo4grTHQ+hIwZmlb/BTUjFJjB12jh1PjJyHnF0IwRVFiZI=
X-Gm-Gg: AYBFou3KSDgAoNzB52m9zOsRriesF2guDhZIh+x0MfRxgelHR3m20J+fIFS3b/fkVeG
	Ddo46tGk4rgVWZPMluoMaUo/k+j7rKG3WBjydObMMSVfrPJITMGNwhDTRp5DVfZ4B+1syHaB9Cr
	nNBz9Idw7Ano6ydpxTngMqJ+tMxO7bP5vniEtP/AqM/EMmjH5wswey6LYB2UJNp1fU9dZQwDx/m
	d6xd6z2iux+cqdxEGuhr+auGTGANdSIgI7WLSqpongeHzKKcfJkgpY4LJM46pJiFELraZ9iHazc
	Rtv7HZ8nvlJnvuXo4vYxHk2eqNDG96BsUQk6+dbWcoq07bd1qK5jtEo5G93418UqUKkVD6Pl1qL
	fV3A8vNIghcqViWAXL2wTJTzkQf4qbW0d841gjEau0nm5rETAsPG5PJNOdW9kQbeWvudKN7ZMVb
	rGKqOmAB+qUxlmfIrRiEdvItmAMKlaYLw0Q8nV2yEX+gTvKYeVrXm+iCg2Jy478nc2YbfWYhtPs
	6F7fmnHUgn00wB5f+rHze4xFsMEUgSchR4=
X-Received: by 2002:a05:6808:198a:b0:495:ff85:d33d with SMTP id 5614622812f47-4c9ab0af001mr544660b6e.12.1789474973683;
        Tue, 15 Sep 2026 05:22:53 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:53 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 19/24] NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
Date: Tue, 15 Sep 2026 08:22:21 -0400
Message-ID: <b8175d2844b5a305c6f5e0d65a8056e5d1646520.1789474702.git.bcodding@hammerspace.com>
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

RFC 8881 Section 18.40.4: if TEST_STATEID says at least one layout
referring to the deleted deviceID is still valid, the delete cannot
be trusted -- verify it with GETDEVICEINFO.  The device really being
gone while the server also considers a referring layout valid means
the server is faulty; recover by re-establishing the client ID and
drop the cached device.  Any other answer -- including the device
existing, i.e. an erroneous DELETE -- keeps the cached device and
the layout intact.

Re-establishing the client ID is nfs4_reset_all_state(), which sets
NFS4CLNT_PURGE_STATE so the state manager runs nfs4_purge_lease():
a fresh EXCHANGE_ID, then state reclaim with no grace period.  The
grace-less reclaim is the point -- the server has not rebooted, so
there is nothing to reclaim under CLAIM_PREVIOUS, and the new client
ID orphans the state held under the old one.  The obvious-looking
nfs4_schedule_lease_recovery() is not the right call here: it sets
NFS4CLNT_CHECK_LEASE, which the state manager turns into a lease
renewal, and on a healthy session -- which this one is, the server
having just answered TEST_STATEID and GETDEVICEINFO on it -- that
renewal succeeds and no EXCHANGE_ID is ever sent.

This is the only path on which a device notification can escalate to
a full client-ID reset, and every open, lock and delegation on the
client is reclaimed as a result.  From userspace that is
indistinguishable from a spontaneous lease expiry, so the escalation
is announced with a rate-limited warning naming the server.

The raw-status probe calls nfs4_proc_getdeviceinfo() directly
because nfs4_get_device_info() swallows the RPC status and cannot
distinguish NFS4ERR_NOENT from a transient failure.  A one-page
reply buffer is enough: a device too large for it fails with
something other than -ENOENT, which still proves existence.

Still nothing enqueues suspects; no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/nfs4_fs.h   |  1 +
 fs/nfs/nfs4proc.c  | 59 ++++++++++++++++++++++++++++++++++++++++------
 fs/nfs/nfs4state.c |  2 +-
 3 files changed, 54 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index d642aca0adc3..76dae699d4d7 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -511,6 +511,7 @@ extern void nfs_inode_find_state_and_recover(struct inode *inode,
 		const nfs4_stateid *stateid);
 extern int nfs4_state_mark_reclaim_nograce(struct nfs_client *, struct nfs4_state *);
 extern void nfs4_schedule_lease_recovery(struct nfs_client *);
+extern void nfs4_reset_all_state(struct nfs_client *);
 extern int nfs4_wait_clnt_recover(struct nfs_client *clp);
 extern int nfs4_client_recover_expired_lease(struct nfs_client *clp);
 extern void nfs4_schedule_state_manager(struct nfs_client *);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 02df5f4f5d84..75545294ebb1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10498,19 +10498,50 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	return ret;
 }
 
+/*
+ * GETDEVICEINFO surfacing the raw status; nfs4_get_device_info()
+ * swallows it.  A device too large for one page fails with something
+ * other than -ENOENT, which still proves existence.
+ */
+static int nfs4_deviceid_validate(struct nfs_server *server,
+		const struct pnfs_layoutdriver_type *ld,
+		const struct nfs4_deviceid *id, const struct cred *cred)
+{
+	struct pnfs_device pdev;
+	struct page *page;
+	int status;
+
+	page = alloc_page(GFP_KERNEL);
+	if (!page)
+		return -ENOMEM;
+
+	memset(&pdev, 0, sizeof(pdev));
+	memcpy(&pdev.dev_id, id, sizeof(pdev.dev_id));
+	pdev.layout_type = ld->id;
+	pdev.pages = &page;
+	pdev.pglen = PAGE_SIZE;
+	pdev.maxcount = PAGE_SIZE - nfs41_maxgetdevinfo_overhead;
+
+	status = nfs4_proc_getdeviceinfo(server, &pdev, cred);
+	__free_page(page);
+	return status;
+}
+
 /*
  * A DELETE for a deviceID we still hold layouts on implies the server
- * revoked them: run the RFC 8881 Section 18.40.4 recovery.
+ * revoked them: run the RFC 8881 Section 18.40.4 recovery.  A layout the
+ * server still calls valid leaves the revocations unable to confirm the
+ * delete, so verify it with GETDEVICEINFO.
  */
 static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 		const struct pnfs_layoutdriver_type *ld,
 		const struct nfs4_deviceid *id)
 {
 	LIST_HEAD(layouts);
-	struct nfs4_deviceid_ref *ref;
+	struct nfs4_deviceid_ref *ref, *confirm = NULL;
 	bool revoked = false;
-	bool referenced = false;
 	bool inconclusive = false;
+	int status;
 
 	if (pnfs_layout_collect_deviceid_refs(clp, ld, id, &layouts)) {
 		/* Only a partial list -- an allocation failed, or an inode is
@@ -10531,14 +10562,14 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 		struct inode *inode = ref->inode;
 		bool invalidated = false;
 		LIST_HEAD(head);
-		int status;
 
 		status = nfs41_test_stateid(NFS_SERVER(inode), &ref->stateid,
 					    ref->cred);
 		switch (status) {
 		case NFS_OK:
 		case -NFS4ERR_OLD_STATEID:
-			referenced = true;
+			if (!confirm)
+				confirm = ref;
 			break;
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_DELEG_REVOKED:
@@ -10564,10 +10595,24 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
 			break;
 		}
 	}
-	pnfs_layout_put_deviceid_refs(&layouts);
 
-	if (revoked && !referenced && !inconclusive)
+	if (confirm) {
+		status = nfs4_deviceid_validate(NFS_SERVER(confirm->inode),
+						ld, id, confirm->cred);
+		if (status == -ENOENT) {
+			/* Section 18.40.4 prescribes EXCHANGE_ID here;
+			 * nfs4_schedule_lease_recovery() would only renew
+			 * the existing lease.
+			 */
+			pr_warn_ratelimited("NFS: server %s deleted a deviceID referred to by a layout it still considers valid; re-establishing the client ID\n",
+					    clp->cl_hostname);
+			nfs4_reset_all_state(clp);
+			nfs4_delete_deviceid(ld, clp, id);
+		}
+	} else if (revoked && !inconclusive) {
 		nfs4_delete_deviceid(ld, clp, id);
+	}
+	pnfs_layout_put_deviceid_refs(&layouts);
 }
 
 void nfs4_deviceid_delete_recover_run(struct nfs_client *clp)
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 1faf9dafd331..4c085c00abb1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2354,7 +2354,7 @@ void nfs41_notify_server(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
-static void nfs4_reset_all_state(struct nfs_client *clp)
+void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
 		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
-- 
2.53.0

