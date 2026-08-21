Received: from mail-oi1-f171.google.com (mail-oi1-f171.google.com [209.85.167.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E615493640
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329790; cv=none; b=sIZF6elJqIcy9QWBQl3SFebcVXp+fVgGn2u1eggrZy356Rkn3EsH164S6hbqPe3OSvOVzk8d8tPBft0l+Cby6btMA7T0NbKEecmT+s4M08PUBW+Hrpac0yI09YeNENywoPf457ABbtPXrYKJo3OjXwmgU8rLHGVMdX5IKYf2QHY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329790; c=relaxed/simple;
	bh=kEzYg4bYkEi8xFmK4sPw/dXCJjf/kn8uVDHuz4jMaTA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bacA3iwVPIeptG99ILddCqIi4gLGN69dSTRq7dZuAdb5SM4SCi2209B30CELyAA2TwzvfmooUQoAf4XVa1r033MALyyh1sLAoan+pWdxjrOpcF+6y6ew4xWwz0Dat6maM+WxQ764+rOPhy5q2gy4uLC5ixFkCd5g/zIKdk+GqXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=eWla6UP3; arc=none smtp.client-ip=209.85.167.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="eWla6UP3"
Received: by mail-oi1-f171.google.com with SMTP id 5614622812f47-4a483a552efso610784b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329787; x=1787934587; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=zqNOewFq5Mlhm9rpJjA78PvHosAWZjgLCnqpkCDaOyk=;
        b=eWla6UP3KYYoObqqwd2UMFi3aMEUPAeweFK2TDtkWRJl4MkMZ6aWBtzgAfdogXHoEF
         jjeE2WrTcyT9f31o8Acqgo3Ua7jRLjZWojQABmZklBL5jbB057hxBnKyzuao6pSlGSb+
         lb5tWyyf2gVlfUTxOeClVO12aZ9iQOC3/CfMznlVHg5P+54JkJj4SWyXVc7C+5IqaOZk
         +mtXtybxubLPcUAegsAtWjOHYq7sInZYMVUMxd5gmrwJ21PsA2bycaR6szOGSwpPwosf
         pBV+I/5aDn3qPugLORSI5Dlu5rjE/ML2jZrw1bYVKOMcG6OuAnrWBD19nVSxznYUXqt4
         g8aA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329787; x=1787934587;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=zqNOewFq5Mlhm9rpJjA78PvHosAWZjgLCnqpkCDaOyk=;
        b=tIi8wWSxTXrlRH/zONECOHlXOhQkn1e5BqKZ4AvKsLyD5QrNmKLK2AF+Sb+1oEoOtb
         RZZY7MevsEmc7MRQFqwsl8XlBhej+n+4I/Pzxm2VKJgdHgEMgoDDp/0vb0OEV0LtMp6t
         QV7vZtoSUrW83odSZnM1BqFv7QZMXAJ8L9nC/BqaDq52c+YSbTeIX4jy2X1Zxht19URX
         +3eXgfZ1OsYpwTATHj2qgNv9jWrMmh+Pa551NhpkSNjU/N5rR6ueqR4XTKt3PIqm8tZ4
         BCCMzqC47qAEBrnSnwKM4BmZUI3EZDTYqkc/Ik9EGngX+FvBjqzfY5sfFg59pPO3uZrE
         Sn/Q==
X-Gm-Message-State: AOJu0YyTdelyZGm8ipBB+UhYPHWRhFdDZKL71aTkCB5YWrD7oCwGQ4/2
	HaGXG4TV03Wz5GlIYsBgXJ3rWR4zUnt/wfXPjsVjGAfmA/XuugXlLd2hub9ylcE6D1E=
X-Gm-Gg: AR+sD10Ks1giSjFJ9EflwreqiHr4VAPdPmxBcFG+pAOKKhsEWslRICfUXbXdOgOpBly
	L9ZeGRqF3w6TLSr9a78P7SsqqZtiJzkMe2WojiQBRfztQKsv/p4gCQQPecGsT1TCyn7jnTWeDcG
	80no3XrZWbGkMKymO2/4Dm/HaxOSLoVrG7KxtP267xXgva02fQISA/qAk41PdsPcwIRkxwgirB4
	38/hRGHj8fHAcg430siXGpAmrkynZerzbphddF6hKGnSLGwZTgKa34i0sGTSXiJV/1BFczzQaua
	1lWEAe1PyTIO7kJZ5Hw9QggmvwHmwUre7t54F11nDa7RWJMh4fGhODquJAhjuzmaEXBjV+RNPNA
	prudctiJV2MUAGWghpli0RUFR4sCEPuLXHSuX9DUox0GHAj68kVHARkNBNrHIv8thO4Zf9Go0Pn
	dHc9U4RAAgeBm/vSMui6FHWpeTkB2twWKO+//+Hip6v8PZehpdislT4MXzIWu9p51yyURPkmJeg
	2LCevuSg2jjGS/mNNM6gIOL
X-Received: by 2002:a05:6808:1925:b0:4ae:f5be:fe29 with SMTP id 5614622812f47-4b2ef20ec5emr7681007b6e.5.1787329787272;
        Fri, 21 Aug 2026 09:29:47 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.46
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:46 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 14/23] NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
Date: Fri, 21 Aug 2026 12:29:18 -0400
Message-ID: <da98de51fe276a11faef6b42d469ed73dd4ff53f.1787327939.git.bcodding@hammerspace.com>
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

When a CHANGE notification carries ndc_immediate, RFC 8881 Section
20.12 says the change is enforced immediately and the client might not
be able to complete pending I/O.  In addition to un-pinning the stripe's
device node, mark the old node unavailable.

Marking does not recall the references already handed out.  A write
whose DS connection is already up keeps using the old node until that
I/O errors: nfs4_ff_layout_prepare_ds() returns early on a live
ds_clp, and the unavailable flag is only consulted when a connection
is being established.  What the mark does change is that a read skips
the node while another mirror is usable, and that an IOMODE_RW segment
still pinning it stops counting as fully available -- so I/O the
server rejects falls back to the MDS rather than being retried against
a mapping the server has already withdrawn.

The walk can also exchange out a node that already carries the new
mapping: a re-resolve that completed between the unhash and the walk
reaching the stripe, raced by this walk or by the walk of a later
CHANGE for the same deviceid.  Ripping such a node out is harmless (it
is still hashed, so the next I/O re-pins it from the cache), but it
must not be marked unavailable.  Stale vintages are distinguishable by
hashed-ness: every superseded node was unhashed before its walk began
and is never re-inserted, while a fresh node is inserted before it is
installed.  Only mark nodes that are no longer hashed.

That test is hlist_unhashed_lockless(): the hook runs under the layout
inode's i_lock and rcu_read_lock(), but not under nfs4_deviceid_lock,
which is what serializes the writers of node.pprev -- and __hlist_del()
stores a neighbour's pprev with WRITE_ONCE(), so removing any other
entry in the same bucket can write the field this test reads.

Without ndc_immediate, pending I/O drains on the old mapping and only
new I/O re-resolves, as before.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 46ca58e8e96b..ebb19a919f9d 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2541,6 +2541,14 @@ static void ff_layout_reresolve_deviceid(struct pnfs_layout_hdr *lo,
 				kfree(put);
 				continue;
 			}
+			/* Only mark stale vintages: a node still hashed was
+			 * fetched after the unhash and carries the new
+			 * mapping.  Lockless -- nfs4_deviceid_lock, which
+			 * serialises pprev, is not held here.
+			 */
+			if (immediate &&
+			    hlist_unhashed_lockless(&old->id_node.node))
+				nfs4_mark_deviceid_unavailable(&old->id_node);
 			put->dev = &old->id_node;
 			list_add(&put->node, head);
 		}
-- 
2.53.0

