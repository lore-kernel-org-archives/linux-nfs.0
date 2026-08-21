Received: from mail-oi1-f173.google.com (mail-oi1-f173.google.com [209.85.167.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD3F649363A
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329795; cv=none; b=WBRpS+YiEr38DSOSrEVn8+d+CW6iuIIq9DHyrdWbaH1l9K5kmcJB5qSjSStu3wEdPmqYh61Ghl12NcY4rWmT5zE/8Y8uzXyHS58pKQHWABfwgbuVkUZrn1eSko+zAmRuHN/bZ+/SBX6Pc7c/xY3hi/v6/vFgxiEI0IgDUOnLCTQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329795; c=relaxed/simple;
	bh=+68WRFLOBJpJ/E7E5JabRxUvmix2Nw0IvotYCXwIXzI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ib6nqxfX/vs+TA43lI+QuXkSXJbkQ2zhecIrIbKYwq7CP0P2yKt31T79kQtk58zHLVMwxHZWpYKiuvCjONPb9nPYS9h0C6hbGSDCoKjuvPs/qaXtygv+xtgyMgqzfP9UKYa4H91kzn8ZVN32yHe0VJFWiiGB1rbxVu8E1aORZ0I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=dvOThbOv; arc=none smtp.client-ip=209.85.167.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="dvOThbOv"
Received: by mail-oi1-f173.google.com with SMTP id 5614622812f47-4a475409044so628605b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329792; x=1787934592; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bbI8LqjSVorzDkb9Iw9F9LmE8wyppbyBEYpjxJw4mNc=;
        b=dvOThbOvrAZSoTyy9/LQxW4vzkLdzlWhJRm7Lv2RZkSQ1fz6WF00+D2+7kF1M3/j7y
         ez0bfRpB6VyGlnAfuRb+XXHLcHu2pIZODon7egVNTVJlHiRNEfU1nIk/DTW0D+fKJvSD
         lZURkxxYzdjP/+Wq70bTFl7tPiNKzSxJm+FwJTILt8I9CiN+ckwdbNqHnZoPe98pgS76
         P7ZK9ZUOQu6mJCB3/HKmNgBKuT/Hl9wwA8ykqUQiLGfmnOb5S5MugotC4ew4CujtaAPe
         bsmQQL+eqI02LytoS7QA/DF+4g0YklQ79oysxVv/rNfHlcO3dCsHplC7hYtEmgeARiK7
         R7kg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329792; x=1787934592;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=bbI8LqjSVorzDkb9Iw9F9LmE8wyppbyBEYpjxJw4mNc=;
        b=m3RZiEbpi9Ml0OailOCxamCcmafFPc09Ds1F/Li4TS6J2eqDRo5vHld3ILM939askd
         jZfe1kQHIBfmU4pn51gmqnp1ThSbxq8mAt6rXqN+UQ/vNmDBwKiJxcYc/b220kUZtjzS
         xZ/hZJjPtpu/rjqhOwbDAGUFcon1RMIkGQqWxHU/M4E3qp4JX8IzwyzUqW+zTfQ5YeFQ
         rPR9sJXsPCnDz0wDXbTW7Cat1nnFmKuSXfDMQve0RreIGNFZWks/XoMExmyrYqf9iB2o
         hfsaetNG/G+KEtGu1+PnzmK32VXFVzzRqZ1gOlpjWpc9206w43bvjsI5WovE12hlA9mT
         2ICQ==
X-Gm-Message-State: AOJu0YwVWIjdmOie/OW5mpOl1rf3QZt7pF/bn0bpuaUzidrxnUsjca/6
	BZYr756VuK1+vrFkHfn+klUvNLFJWxBaSQ5Qs5GZcJX0PzRPlbkL6zrEQu4ffaTfwTE=
X-Gm-Gg: AR+sD11nrXoKZ9x70kHNrN+RJTRhl3yMyq+aDztKyoMUrSs8098AbiaWLo5Rfwmbs8K
	CkXPFbirzBTYI5eq+le8Sgu24PzgroP0qyVkiLDCdLzvhZenlXXhrhfZ2KdOGBuNVzES9CRnXMV
	429LLZWizDevZYusS5BXqfxnw2IsBaF2ReowjOpMljZlrCgVH4f6L9QQz20kJkIATQPxV7XIpYZ
	CV5WczXgmuAg1Rv+cqxZ3vlKXMA7BGe+hCabnT3i2K08Bx9RXjFb0JKolVE6F7p7AjeRGPedrZC
	SMIAwtLkh6NokVNXK8IQBhEzEwH/YtNZqPLkPKN7d7/4w6BxHHR8xWrw1ylW1nFiPdaWHEAAsJQ
	QwE8r915FiQpnMLpiKwthaem4xKfjMLTMf0HivTm3+FTp1NjYGWrRUap35CItF1LEB3iHTSmHFX
	NALb4dUDPwppqsVdm+G0AMj06AHsMXgQjhbc/RQ3QaLLoZt+fEm4AgjNHwFHrb9+0QIAeCoxhVb
	ODUZ7pMWvsaXGKebX2+YDjl
X-Received: by 2002:a05:6808:238a:b0:4b2:8d77:511 with SMTP id 5614622812f47-4b2ef34849amr7135943b6e.10.1787329792440;
        Fri, 21 Aug 2026 09:29:52 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:51 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 18/23] NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
Date: Fri, 21 Aug 2026 12:29:22 -0400
Message-ID: <4a08cc76472758fb1b7d3955260dcc47129f8500.1787327939.git.bcodding@hammerspace.com>
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
index d115ee1dd185..08572c6278be 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10441,19 +10441,50 @@ static int nfs41_free_stateid(struct nfs_server *server,
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
@@ -10474,14 +10505,14 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
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
@@ -10507,10 +10538,24 @@ static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
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
index fcdb4b55c98a..b2f932edc7e1 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2328,7 +2328,7 @@ void nfs41_notify_server(struct nfs_client *clp)
 	nfs4_schedule_state_manager(clp);
 }
 
-static void nfs4_reset_all_state(struct nfs_client *clp)
+void nfs4_reset_all_state(struct nfs_client *clp)
 {
 	if (test_and_set_bit(NFS4CLNT_LEASE_EXPIRED, &clp->cl_state) == 0) {
 		set_bit(NFS4CLNT_PURGE_STATE, &clp->cl_state);
-- 
2.53.0

