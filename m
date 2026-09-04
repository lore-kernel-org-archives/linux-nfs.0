Received: from mail-qk1-f176.google.com (mail-qk1-f176.google.com [209.85.222.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E05314FC8D5
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540824; cv=none; b=n28MLW5hfeBpC71WhqKA1iXF2g2kIvlPnp6LQWc68qPhx/cnw5yFeI2sv6QkeKmjPsIjZ6Q1zscliu9YjTzjoZm03UAa3VE31DBNAqujb57sb5wrx6RTIY6ZQq6WOFsavZ+CEQ8Cqd+XwfQVOnpI3Wr/6ONFS+ZP/rjWW+bC+jc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540824; c=relaxed/simple;
	bh=q44DsGR75xbeoUEhLZmW6W77Th4UYHtWiOgg0DyI8DM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Egiv1BmHd0QMKqbWKXEn2G/bQDVGfILUEyzUtpxyDPFdcGTOAExbDVcUaAfl9EoGWoRqOgYeQANinzLO1mm/CjLzHzjHOOTmv1LUDdZWlzY5IJ3V0Wjlw9ObxIiWAMtyoMSc1nmXvuZGVrPt2hK3HYBUXOfNbZnPjdR2qC47Fgk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=jSrMwM7a; arc=none smtp.client-ip=209.85.222.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="jSrMwM7a"
Received: by mail-qk1-f176.google.com with SMTP id af79cd13be357-93900ed2925so105829885a.0
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540822; x=1789145622; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iHHZe83R3XmB0WtI+frrm3XyScFEkBqGdrTvrAvVhoQ=;
        b=jSrMwM7avnbIx6MzBbja4VYtqJlXuy8wL/bcCMe36xxbzT5jPpkq4JK8e0G97i29WO
         wbfFgo6jHpindcWdoyO/Vu57vTo2IbCunYjG5Z3jpjee5rKcBzgdSGctwoI/I5KjlvS8
         PiU6nnTvwtacCj64/r2tWqa2N4mNR61lqgeHPzZZRvadKfCKvXGtAYOvVWtxATOgGN2N
         0H87LSkWTVwJeKHQ6qzI3m0SEj4fqpJ82ymctx2Ojq4Q7d9TAI/E4Dz86RTLBD0PYX+6
         1s8lhoSP/Uzln4RC/sY9TyssVtaus7xKKBxRHXhsjDkcZQsg2jAU13mw0r0iO6V+ZdAj
         MjVQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540822; x=1789145622;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=iHHZe83R3XmB0WtI+frrm3XyScFEkBqGdrTvrAvVhoQ=;
        b=aCCZgotBjF7HCkt9IEKr1UHCaQ0sU4zAcI1GvapPhiUhteg0sKz3l5Qef02SX4XUaz
         /nKrPp2MsuFH7/Z+QcYu//CaoxtSa80PwWSuTqwjU0ysAHI7fpiXDC9MV9JEj1ph5PAl
         Ay6vicTQ1aI9AWzUzAfIkiMfspQC0CR1m9OrqvKHY8i0UO85PmIjAL2sxsnQ9UnFpC+N
         4sb3PMTNd+C4hjVHRNjm/UnV7wPgGbvxLSh1R3hJoGQWj0yVd7i9TDOkQ6RpFhLSc2/2
         mQOVeH+7VXIP2nWBZ4lXHubfzlbSRFezb1Mcbg9ou/mmwRtmoGKEkAPkkBW0NJBDmQjQ
         CoHA==
X-Gm-Message-State: AFuF++kLeyZSK4sX80GTOsrn3I59jVTgtt8SIQv0r4edTCwCDtXDsgF5
	WrENFgoRfVTRpcrQ5Goxj8uzuSeQYBaJQJKIE65xDzBiKjfCkkj6d5WPKgSen5UrHKU=
X-Gm-Gg: AYBFou0UabX5S9vqxzt3yUm3exAR+l3Zu0PMFURFbl53cb0fl+QCpwW2w2vt02U6akI
	C594F2sABQKuUzFCPENWyJdJt7K6egChupRyfDk81k1SVz7d6XPUmT8hyjqgBhCPeg0NpfVPxrf
	NPYEID80aXDb5UzFkxRZLvKqtlzYoCYeodtBSIurIpAzmS5jibkUD4talcgKTQOhn1CVwppXn0Z
	xZTI0tLrzY8DxUbLhG8Bn0bRxaO8PtsATCUGeZwDUDu//IKB8djmw6Y9MbGJchDpDJkj8Rb27cg
	+XeuarldbasowhMg4LT3ltubqQLjzNYNFmwfAvspl4Z2DI2OPL41JmUCPEarYluRt0vqYh/0jN+
	HHXMYM38WTDjVC++2MijrZcX3XO1UE120Jq3F+urbc8fpsCP8rkM3yoE2tR4qiyVX5BBfohJ7qU
	l6uYD/cW/hCzW0CXDf+xe6XYuinb6oFWFXgwUfbxwFxuot5v5IXohNYwM+okAW1VZTkOL0GWcuA
	8BFpsW/FUr26hY07ewBP2xLhLbiT3wG0F0=
X-Received: by 2002:a05:620a:4392:b0:930:987d:9cd7 with SMTP id af79cd13be357-939802efaf3mr819823385a.11.1788540821704;
        Fri, 04 Sep 2026 09:53:41 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:41 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 19/24] NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
Date: Fri,  4 Sep 2026 12:53:18 -0400
Message-ID: <e4a7aab208c4d18699da049d9a9954c803748edb.1788530385.git.bcodding@hammerspace.com>
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

