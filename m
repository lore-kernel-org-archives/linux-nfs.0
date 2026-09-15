Received: from mail-oi1-f169.google.com (mail-oi1-f169.google.com [209.85.167.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 285823B95FA
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474977; cv=none; b=WFxXbQTTGJl9vm1VbendN5UfhS+NOv4aRdLxxjTPtQfu0VHjBFqzrrt72GGS+P4gWmYu2LfpOGbic9D+uDpUaGoCXlUy/BRwvmfCGA910Seh1mawgAK7+O8LAuZdX1LxGehyQscearofsM7pgrZ1MbXMw1PBqk+V3ye32pEWr24=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474977; c=relaxed/simple;
	bh=EsH8Peom1tAOgtjdjLHuzJZHSNQOS6hni8nl8rr4zAk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=lBiPoSZaIMEAMWzRmzpOvl4eLw9Z+1otV52U8nWWd6chu9dxOWvGCSTF0oQ0LfC4M9zUxBV8OVoYoC5iYxnKmXuNuzPNfG2kPHGRIO5h/JiHb8WO+o+vmEdGxgrlfFLj51Jqml4RDc4UEXGCDxqVTfmC7sAXH9Q40kDvrABgmts=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=JZwrUrnW; arc=none smtp.client-ip=209.85.167.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="JZwrUrnW"
Received: by mail-oi1-f169.google.com with SMTP id 5614622812f47-4b28d9537bcso606921b6e.0
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474975; x=1790079775; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4k9eVkI4A12rmuGKAgoZZekbl21MNnPeg4s4iebeUnY=;
        b=JZwrUrnWHPSd8sA04htU8HO/J2gr5JLyAG9WxOuAm32s8cI2lfMnBVn+XMpk/hl8qo
         2AwdGYARVOZj8s26oJXA7AgMAlWyw/T8dHPjT0JtfDaudsYZdAKyeOeg40Q0uWMPFQCW
         HYtp7O8BP/9uv35Bq7rbogy72sqMXfyVO5mw0jcQ6EoaGa+86W6cTbG0Ckc7jsSRHPoY
         OmWHAANeyxIRBnvchL2WaIN1vBpdPH9wfwgTbaH7jh7WvmDeVqJGgyZwfhaE/OCDyQgi
         ZJC0tnpo48A7LJFyHdziFj+mEHCxj/afs1yHGYGUXQiLw9kWUDU4+eCVUpomgaFjc4ZN
         lSwA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474975; x=1790079775;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4k9eVkI4A12rmuGKAgoZZekbl21MNnPeg4s4iebeUnY=;
        b=spY9bU15T0KtFYLpMeeJpekspibhw2WEQsJb+x3iVUfYfaa09FtY4SoROg2Sbu2Rqe
         OG/EEmUYJsHvlj+MZkWwPNfn0/r6tW3n+nhALsCLe6VsIER9Isx1KJfjsmyr5rcvUz44
         bYIFy+7ts6kUY+BOgwIKUPFPhro0AZ2MoWvkMoe0H5k9YqztF7o1lxMLKOD8Ysfwf9/A
         AX9WNnLM+rQofdQ1cXRbj3DXqKge8zHxwue8kOf3+8i0R2K/Xkg8kOqSMAw88Nk4JVxV
         zXDDHk4vstraaG0iXzL4c4T27XzUnZoA2VA2owIB0lRg+/Lp+6gifHc/E7o6O7ECncrT
         5wPA==
X-Gm-Message-State: AFuF++nc3AylXUDkURmDOJ7/Vfxrr4ezzv3tm3oImehN4Ov/PwEhXHbn
	ijytC2T9bJJ7u7C56GHb3bqoj3wuaB1Bf0kZGd9BYuex8juTJDMNUEGNDxpDIYxYukQ=
X-Gm-Gg: AYBFou30EJ3Izp9HK+g57taT426fzHcwn6MntE/Lpo8uom9R9Rx52rggqmNEUvMq1TB
	xtCXN3wCYKhNQq9qAgOiN6V0Hn7GV+F5sAqjAYkpYFFjR5PArOSUgFQZCkIJzHZEY1IkXlHWCHb
	UuX+B8MSXFmcOcIyjIrIMLR3anGDgQ8eSKrWHf45VtRAvJaBi71MJa5pi+X0q86aBsnfP3Aefib
	o5PQowRhZD0nWqsngo6paFyxDPMqthS1klBka0s5RJ3YEVA7uR9FW/Q8fAippcVm9urBDRystII
	4/OkY6K+Zuwt1GUYH2JkXSSIXfttGp1kXdNeOMI5e8XsVjaiQyEypkQ7cdPNiA2nn9SwmphcRYi
	guJDpGNR+S1PGDy53NYo51eBw/7S0FprehqkrWVSx2BQQp/43qseIZ+fX5WeGPuAOM6aEZbrAEi
	XISY10rrnYglgWdvM8H+2E6q6rgjVL94GpaArqvVL2JSTR8Ho9oxIk+jm9rcpfT24HhQIEaGcvq
	jWwPDMaZyFhK12Gzd5yScFvf5hpJIlIlpeK9rYpmmwtjw==
X-Received: by 2002:a05:6808:1482:b0:4af:9364:b5a9 with SMTP id 5614622812f47-4c89ef83e00mr1744157b6e.6.1789474974802;
        Tue, 15 Sep 2026 05:22:54 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:54 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 20/24] NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
Date: Tue, 15 Sep 2026 08:22:22 -0400
Message-ID: <f91ff1777d0c320f00607ab7e3dee1b049f56067.1789474702.git.bcodding@hammerspace.com>
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

