Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9C9633B6C1D
	for <linux-nfs@vger.kernel.org>; Tue, 11 Aug 2026 19:52:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786477937; cv=none; b=f2BJvRbs4JpXKz+1/WaconIUy28mlFOsF3nIu9IVW4Gpfaoy6YapYONa5DDrD5v6sQi2dVUWt7OZopp8Cf/cHx1i3bcXHyKd3d5HEFDEEtvgyFNynJ9mgUjiqrhv1NSxoZ+Ss4HeTtkFk8d13LKymZgFmZExOXshYkUmhnolDIk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786477937; c=relaxed/simple;
	bh=A582t8Vd6kYHt390nx5zOzDpK8nAWFCsPL4eP3UU5x4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CJbFtai490v6RkhtW2Rx4IuGIuIQMtWale7hqLldWT2FFjs3ZP1MSUmpPYdRXEqu1W+aiB3dtaFWH3cNuW9rED6LjtnK0fGg9Fqu5lkC9w67RyPp4BkOqaabOs0fUIHjF1N94GO+0g7MfHQHZpvqY5EuNX6joK+wujW+E7R0mDs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DSodQhmw; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DSodQhmw"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BBBD21F00AC4;
	Tue, 11 Aug 2026 19:52:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786477936;
	bh=5dPdFJXlf35mt1Kz8bmdH9L6v3+/QTwotrkmHagssGk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DSodQhmwAFEKyhyE6BA7klYZTV1NzGA87EFRO5FCQ7qiIyBB7/H6H4+3CW70Xz1iX
	 F8w3w9qZyA1rIWJy+0zpvq35h32Ok72gKy24Tv8miPBL4dOtZuJ6lYvqPN8uSgXzGL
	 q83Bs8lUcaJ5m2YrAkoW5uBWn6s/B00z2KiboarQ9L+IGOfFUVoSxLUND5PWacpO5l
	 KLIC+iEDBKfsZXh/yCvCNVjFOyoWJNM23CZ9PacOX+3W3rKbMw+A0/WVx022Hv8pLU
	 jtHylLeZbW+2meR52ZWgO3J1AF4+cCbKyF/v32UY/gu+yy9RzNW6/N9l9iO6xNCqhK
	 G7v5bMREc+lIg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 11 Aug 2026 15:52:04 -0400
Subject: [PATCH 3/4] NFSD: Name directory delegations in the CB_RECALL_ANY
 type mask
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260811-recall-any-keep-count-v1-3-de9ca00493b7@kernel.org>
References: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
In-Reply-To: <20260811-recall-any-keep-count-v1-0-de9ca00493b7@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1730; i=cel@kernel.org;
 h=from:subject:message-id; bh=A582t8Vd6kYHt390nx5zOzDpK8nAWFCsPL4eP3UU5x4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqe31tAnjP6kehNtjWsJ2H8gbUSXr6mlA3jcjW/
 1rT/dw98mCJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCant9bQAKCRAzarMzb2Z/
 lz7PD/4yFPP55vXOTPsamhPt2qtepTaMNQgQV9MtERr3I34iy/slvyn8vAkESL0TR1MBogxMqjg
 V1yDJGJiteAdndWsgeWTZcpPhbwsm1APjNsJDEaSYkJBwGu/apygW6LRZGII2r5zkfEAHMLzmSC
 hOg3Q6AuJ8XusoRjCm1uJDDqE+3xp8GclrtnaLW99w06vSJN7XBjh7hIQxuI1BSJ2QWCb4jarp0
 o9Q/MeU5vz0tZLSSc6yg6S8xmqlmWjCq73JtuvtIq1R0+kFJvhnPO8zxWvPQiPp26N/LBNCzBDH
 kRxigI5XQtFG58pIynJQLA7b79N5ubZPHGHTeX0vSV0IfBbeMjxwfbxzj22Qyeo1bdqLnG+v4XA
 hxRxQTvc1c3uBBk57aTtUfQy8JmOlHSLnyQXpSJrnxMQrzu323sQgXsPMaZonQAmGIfNE3Nzxfo
 glyjCqpy9z3N8bsMEauD1tqjTMtLPhMGCJH6Y0+5cmo6Rdr2U4dKvi6fknu/qjmPY+WiI/ubImV
 yVNQveTJyL7TezitKwTesMSCHx4PVqr8qPDtLSfCh8d1riB2+mpRhR2iC0mYjh+XY8Qi1Z5MuTg
 7XTFac83BnaG2EsYEXx2KF4xiMNsyI7hnJ35a+E+1KoWTkcPXMbEGTUXJNzTqF0QfWUcn8jxyKf
 xgrgSoAwvHGfXkw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 20.6.3 has craa_type_mask name the types of
recallable object in the resource pool that is over-utilized. The
section distinguishes a server that shares one pool among all
classes from one that keeps separate pools per class. NFSD shares
one. nfsd_get_dir_deleg() allocates through __alloc_init_deleg(), the
same helper the file delegation path uses. A directory delegation comes
from the same slab and is charged against the same num_delegations and
max_delegations budget. The state shrinker counts it.

deleg_reaper() nevertheless names only RCA4_TYPE_MASK_RDATA_DLG and
RCA4_TYPE_MASK_WDATA_DLG, describing a resource pool NFSD does not
have. Add RCA4_TYPE_MASK_DIR_DLG.

A client that implements directory delegations will start returning
them on a callback that never named them before. NFSD takes that
return on the path it already takes for any other: nfsd4_delegreturn()
resolves the stateid as SC_TYPE_DELEG and calls destroy_delegation()
with no branch on what the delegation covers.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2ddc77ac7312..3017a93261ff 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7969,7 +7969,8 @@ deleg_reaper(struct nfsd_net *nn)
 		clp->cl_ra_time = ktime_get_boottime_seconds();
 		clp->cl_ra->ra_keep = 0;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
-						BIT(RCA4_TYPE_MASK_WDATA_DLG);
+						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
+						BIT(RCA4_TYPE_MASK_DIR_DLG);
 		trace_nfsd_cb_recall_any(clp->cl_ra);
 		nfsd4_run_cb(&clp->cl_ra->ra_cb);
 	}

-- 
2.54.0

