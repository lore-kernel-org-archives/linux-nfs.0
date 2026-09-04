Received: from mail-qk1-f176.google.com (mail-qk1-f176.google.com [209.85.222.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CE4150EC0B
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 16:53:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788540830; cv=none; b=sOqxOWJIQScJhc5UcAJd/g+alGTeIr2YkuotNAH/JY2TlFMXbXFg8e3ykMeNOC+e3PWwvgJB//0sWs8Ul1hkozT3vLxMpBDK1cVjZQHnMK/Qqloo2QJMNB0uHnVho6qyF0fisSVCOV3+ay1+FhTdtENnmH4cnOrJEZGMNQ8IwO0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788540830; c=relaxed/simple;
	bh=EsH8Peom1tAOgtjdjLHuzJZHSNQOS6hni8nl8rr4zAk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pHdc2B6Hsnu7Z+x6izveAEQIz+4XolQv6i5tmin9y0R0PRzuoYJRqptWFMprNZXZFezyDrAYZeqb/gOXTeHZIUARXidejkb94T2UVWdF4Rly4/JONezwUD4jyq+qzHxCCay3A2Bznw5f98AzWFagxbfIDs0oj0/7eAlgMgfuQoU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=XyYW1QpL; arc=none smtp.client-ip=209.85.222.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="XyYW1QpL"
Received: by mail-qk1-f176.google.com with SMTP id af79cd13be357-936c02e58dfso123877585a.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 09:53:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788540827; x=1789145627; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4k9eVkI4A12rmuGKAgoZZekbl21MNnPeg4s4iebeUnY=;
        b=XyYW1QpLxqn3fHTXx35zIGZF6VkJnc5jS1hKkeKcIEw8PJNbIiyPHm1S1sjBHjw9Oc
         5UXvebNTXxmQwMOlA7DHdepoR6Zy5EYqz7UWwpiwW33zdlZ4kUQ3FQjpX1ywy63D33sO
         YZC2SGs2HLDaMOQdRSNdb3Xl4i4s3lBTt3kAqqKctBfqgGt4VQZjQL6G5hTDibDxMp0f
         VM7ntkd/SLdQtmpmSpuivbpxEloLQoUSppT1b46+lrTRb4GJ1xZ12y0NQNokDk7VtBpv
         akzJVpU5NsyDI+oiY78ZRKDtOM6N9AU1JIDoe829avzFknvt6xSkPUEwrQm6syRt+QtC
         hb9Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788540827; x=1789145627;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4k9eVkI4A12rmuGKAgoZZekbl21MNnPeg4s4iebeUnY=;
        b=dGg3mCt8O6OtAhY3PPm/tE33YdBM/5mFIDWgQLZNrXLOFbB9Ksv+o9I58B7gVi2XKl
         7afdPSp/M9rI/8LoTohL6o9Wvr2obXhpnwTCYPGNFIMd71RMx+S5WwQgqNy8dyGIBJdj
         Hwp4NZ63RGle9KBa+RVuJh+9zF2ER6uSX6q7E4CdOdE86CrkZKSHB5R/tPFGUKIozHnr
         pjjoEy/gUGjMsR25yJGHWPG+PuuOhKjl2H6H4hVENXz4rx/fx+Y65g8yc+fwtYEqlU+/
         bZtHLzXxGHQaUanpaKSwU5yj4V9HbXQFV+KB//7MJ82dr3wE+AtyWnuw7Ac7170e9JTT
         aRag==
X-Gm-Message-State: AFuF++lGI3l1cirm2PVXYInJMKE2ECSz7UUg2Nb7Z2SzB17g5MjXohr5
	7yRxFI31rstFm2YAm66UIRxZxJGDPNiYCcxJG5XfsfIZLxjVPDEFpUHbAgpZHA+UalU=
X-Gm-Gg: AYBFou1KfKH9ZFDicchbflT9MsnBc6MigE4eGKjaszX5+puPxulIipAxszxB6h5Ck4Y
	7b0X3903oTmCN6wBIuuM+tAvC3YDdh3KF+IfP5+PQ/0zsRRFhAjwAhlTziqP0Ab3jw0fCSrwJB+
	FNZt4PpYQJDsG/9P51e4SSDti1IZJ29eBPFPxpC5SQYgpw6kXSA6IW5ouJETHCQx+HMbhE3sOxl
	9jcXikm7Yty6zkUyY0VRflxejoKjIKtZK2+TGUKfm7QDx+nOxSwbq/DMSuTx+ZMJSh2+Sb32m2U
	/Mj3mMTQPcoHdsBpo11tUifn84tHsZlln2rejGXAjt6TJabCS8OBjgg2rp/OrJuc33lO81Ui6dd
	tMtWzh+8wGhwPM+wqTBfRvfK6B+NCWKCqTvCgTavKxGWPtUdNKVa5kdyLqowXgts6g6QoDA9zjW
	rhLQEYMykIt8O0Yi7q9VW7BM3PJbiwR/KYHPyV3k0DgDN1Wl9IvweN7JUiW6+yl/r9gs1JO/pzd
	nXD7nh8DUz6QyOJcTWoBP8a
X-Received: by 2002:a05:620a:2805:b0:939:49f1:f972 with SMTP id af79cd13be357-93980377d24mr733361785a.23.1788540822612;
        Fri, 04 Sep 2026 09:53:42 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fbf7c78sm248145485a.47.2026.09.04.09.53.41
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 09:53:42 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v3 20/24] NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
Date: Fri,  4 Sep 2026 12:53:19 -0400
Message-ID: <81e30687fcbd99ae41813742afcd5667de42e735.1788530385.git.bcodding@hammerspace.com>
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

Re-arm the state manager afterwards, as the delegation return above it
does.  The recovery issues synchronous RPCs, and a manager thread that
starts and exits while it runs clears NFS4CLNT_RUN_MANAGER on its way
out.

Bump the deviceid change epoch for both notification types rather
than only for CHANGE.  A GETDEVICEINFO whose reply is already in
flight can otherwise re-cache a device the notification has just
invalidated; that is as true of a delete as of a change, and Section
18.40.4 opens by describing the race for the delete case.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 24 +++++++++++++++---------
 fs/nfs/nfs4state.c     |  4 +++-
 2 files changed, 18 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index ea8c558b07b6..c9b71dbae9ea 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -392,19 +392,25 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
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
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 4c085c00abb1..b5d6daa2c416 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2670,8 +2670,10 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			}
 			nfs4_layoutreturn_any_run(clp);
 			if (test_and_clear_bit(NFS4CLNT_DEVICEID_DELETE,
-					       &clp->cl_state))
+					       &clp->cl_state)) {
 				nfs4_deviceid_delete_recover_run(clp);
+				set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
+			}
 			clear_bit(NFS4CLNT_RECALL_RUNNING, &clp->cl_state);
 		}
 
-- 
2.53.0

