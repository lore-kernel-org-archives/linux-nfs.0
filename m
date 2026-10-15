Received: from proxmox-new.maurer-it.com (proxmox-new.maurer-it.com [94.136.29.106])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3F64C25B0A4;
	Thu, 15 Oct 2026 00:54:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=94.136.29.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792025698; cv=none; b=PdI4Sg/2803/nrjP5jfb6U7ItU5GNgG2ncq4ykuVAmNRrFNR3yor2jyO2g9TktvUQtuDXdquzVmfzq3HGhSLazNjTvJ3NZZjtL3c439XHjyzkCHbye73APZMeuXVHPM+oWrpZFeX5mIX9kat0Wk734p6Cbt7o1DtvWmMvwowfmQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792025698; c=relaxed/simple;
	bh=UcXfq2s8RBg/mdMLs5Sze1N6LCsFPoK+hasLw7OL0Iw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=gUGDqdMpOuJh+e+0XrlVMRSiPA+IOqxmL54a9OWZjm8f4mGpclPPoCxe8zMF8h4OsqEriqPNkGh3YGXmSGboW0Mk6aVFsg9iOOdxSqk9gDFZoHpwOCzt7v+qzkLlqYy1SBKKaAUhTtTYr0hk0n9oUgkfZHg3H9nJNp9ELNWBOUU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com; spf=pass smtp.mailfrom=proxmox.com; arc=none smtp.client-ip=94.136.29.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proxmox.com
Received: from proxmox-new.maurer-it.com (localhost.localdomain [127.0.0.1])
	by proxmox-new.maurer-it.com (Proxmox) with ESMTP id 5958242301;
	Thu, 15 Oct 2026 02:54:48 +0200 (CEST)
From: Lubos Rendek <l.rendek@proxmox.com>
To: stable@vger.kernel.org
Cc: Jeff Layton <jlayton@kernel.org>,
	Sasha Levin <sashal@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	linux-nfs@vger.kernel.org,
	regressions@lists.linux.dev,
	linux-kernel@vger.kernel.org,
	=?UTF-8?q?Fabian=20Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>
Subject: [PATCH 7.2.y] nfsd: fix all-zero stateid in CB_OFFLOAD for async COPY
Date: Thu, 15 Oct 2026 11:53:40 +1100
Message-ID: <20261015005340.550134-1-l.rendek@proxmox.com>
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
X-Bm-Transport-Timestamp: 1792025687393

[ There is no upstream commit: this fixes the 7.2.y backport of
  d0beaee498e1. Mainline fixed the problem as part of the async COPY
  rework in commit f307b4f7ed17 ("nfsd: split nfsd4_copy into transient
  and durable async copy objects"), which is too risky to backport. ]

Since commit 14b978e8d05c ("nfsd: fix stale s2s_cp_stateids IDR entry
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

Tested on 7.2.10 with an NFSv4.2 server-side COPY between two
exports: with this change the copy completes and CB_OFFLOAD carries
the same stateid as the COPY reply. Without it, cp(1) hangs on 7.2.4
and 7.2.9; the affected code in nfsd4_copy() is the same in 7.2.10.

Fixes: 14b978e8d05c ("nfsd: fix stale s2s_cp_stateids IDR entry for async COPY")
Closes: https://lore.kernel.org/stable/7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com/
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Lubos Rendek <l.rendek@proxmox.com>
---
 fs/nfsd/nfs4proc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 939749709..7c2955796 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2243,6 +2243,8 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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


