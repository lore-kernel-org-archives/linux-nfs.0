Received: from proxmox-new.maurer-it.com (proxmox-new.maurer-it.com [94.136.29.106])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17D292EC090;
	Thu, 15 Oct 2026 00:58:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=94.136.29.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792025884; cv=none; b=JJ26Pn+xMnCPxDcqLmfU+ZP1EyZkxlyJ+zEXQMvcrLnVtlwYOLopWa+6cuKfvkBAOaY3XufzVUnVU1+OtMrdw3Ka8Tg2lii7rqqCvo+pMlKMP1Pw6ipkWEDen1+E6GmPqygf5fQ/nq1E2Ms7ZHTrYT8FhKbkKkEoVfDU1BuOdpg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792025884; c=relaxed/simple;
	bh=BOUiJpFDSD9/2JBzgiFuKETS6BD5hFqNsWrC6W8j3GI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CJ1bGcQ8rKCUyptgP5PD6L29tQhizzSWlXgfv+zp1CjMNfSgrIX5KWNs+Nnw30QDqKDK4v+YqRLijMkMFBJuWB00XVdfsXHYkJZeLN249oYjevF/xc7BcJLp25RLzr8Clf/seMTnIri41rhTmWFyOOEcuoZMoWoP9+XjYhn4Th8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com; spf=pass smtp.mailfrom=proxmox.com; arc=none smtp.client-ip=94.136.29.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proxmox.com
Received: from proxmox-new.maurer-it.com (localhost.localdomain [127.0.0.1])
	by proxmox-new.maurer-it.com (Proxmox) with ESMTP id 235AB422D2;
	Thu, 15 Oct 2026 02:58:00 +0200 (CEST)
From: Lubos Rendek <l.rendek@proxmox.com>
To: stable@vger.kernel.org
Cc: Jeff Layton <jlayton@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org,
	regressions@lists.linux.dev,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Fabian=20Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>
Subject: [PATCH 6.18.y] nfsd: fix all-zero stateid in CB_OFFLOAD for async COPY
Date: Thu, 15 Oct 2026 11:57:25 +1100
Message-ID: <20261015005725.550511-1-l.rendek@proxmox.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <bb39cba3-c4a3-4fc4-b078-c92752cf483a@proxmox.com>
References: <bb39cba3-c4a3-4fc4-b078-c92752cf483a@proxmox.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bm-Milter-Handled: 55990f41-d878-4baa-be0a-ee34c49e34d2
X-Bm-Transport-Timestamp: 1792025879200

[ There is no upstream commit: this fixes the 6.18.y backport of
  d0beaee498e1. Mainline fixed the problem as part of the async COPY
  rework in commit f307b4f7ed17 ("nfsd: split nfsd4_copy into transient
  and durable async copy objects"), which is too risky to backport. ]

Since commit 9b4e5e9ba5ae ("nfsd: fix stale s2s_cp_stateids IDR entry
for async COPY"), nfsd4_copy() calls dup_copy_fields() before the copy
stateid is created and then writes the new stateid only into the COPY
result. The async copy's own cp_res.cb_stateid stays zero, so
nfsd4_send_cb_offload() sends CB_OFFLOAD with an all-zero stateid. The
client cannot match it to its pending COPY and waits forever in
nfs42_proc_copy().

Also copy the new stateid into async_copy->cp_res.cb_stateid. Calling
dup_copy_fields() after nfs4_init_copy_state() instead is not an
option, because dup_copy_fields() also copies cp_stateid and would
overwrite the stateid that the backport moved to the async copy.

Tested on 6.18.56 with an NFSv4.2 server-side COPY between two
exports: with this change the copy completes and CB_OFFLOAD carries
the same stateid as the COPY reply. Without it, cp(1) hangs on
6.18.55; the affected code in nfsd4_copy() is the same in 6.18.56.

Fixes: 9b4e5e9ba5ae ("nfsd: fix stale s2s_cp_stateids IDR entry for async COPY")
Closes: https://lore.kernel.org/stable/7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com/
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Lubos Rendek <l.rendek@proxmox.com>
---
 fs/nfsd/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index bc14c3939..aeab09dde 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2084,6 +2084,8 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 			goto out_dec_async_copy_err;
 		memcpy(&result->cb_stateid, &async_copy->cp_stateid.cs_stid,
 			sizeof(result->cb_stateid));
+		memcpy(&async_copy->cp_res.cb_stateid, &async_copy->cp_stateid.cs_stid,
+		       sizeof(async_copy->cp_res.cb_stateid));
 		if ((READ_ONCE(copy->nf_dst->nf_file->f_mode) &
 			       FMODE_NOCMTIME) != 0)
 			async_copy->attr_update = true;
-- 
2.47.3


