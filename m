Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0D5A8470EB3
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 15:00:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786546824; cv=none; b=Nu43nMEMrc9FYLScgfQlMDYYIlTgfnOhLMUKGjCG6hZuwR1oWUPvLpSM+p18Kojbujz19cHNRPHvQuUOnzTVjy8rI1bvX1TXpJXGE2sn66Vh6b4TSulVp53a25B2L2rXWBhNOKlTIdBGetFJOxo+TW8tQDzcR9SVdYQACefr350=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786546824; c=relaxed/simple;
	bh=nVz03LEZZcrMtkXp/Ok5Wrg3Jz8kFd498lBb+NjVnCU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=pnh8Z4oIhfJvI98BhmA0YXBc7MjkFAiA4mlJsYMxC/bvpmRnZpeKV7WFRW0jcjQUZDyGcxky4Pqn7M6AOS+5Uzn6SOrUlhVG38OEDczCPLLyb8wt02aPGYFpKcbhlIDjLHS2dEQylJt7vYWA0EKjUQUa6zUZX/CmhQncPOcGLas=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Zu5X6Fvi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Zu5X6Fvi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 416BC1F00A3E;
	Wed, 12 Aug 2026 15:00:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786546814;
	bh=KCBcfNnrFEaHFp51Y1Q5KqYs5ZSwcjosh6YxC311++E=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Zu5X6FviK/qozRt5m1VbHCrAVPu7lAvDnOQpFiwC0UWmgxWqC9n/9c2hOk0QRFWyD
	 xRemhf0eZe9FYLaBpwqPqVfMlHxAWaffqF8Ltz7C/Xxi0VlIt9ejgHxAc2sEULrhSu
	 2WXgTVbh+AIkrFf36vNS4H22QzzhJld8RaRVmjOPf2wkGbdDm2eNultaprfpnGCYI7
	 6tHvn4iNpqLdxzxJhibwPMKdlk9Xe8CqbPMTj7ejYVY6tTopDSenDurmLE9bSFrlVz
	 g/jJsVfLo5sup+qxbjTlpi2MIahfxGF9NFBB+pEx9U5lH22xEm3xyImPpPG8b3VRIq
	 OuIyF1SmhYnRg==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 12 Aug 2026 10:59:57 -0400
Subject: [PATCH v2 3/4] NFSD: Name directory delegations in the
 CB_RECALL_ANY type mask
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-recall-any-keep-count-v2-3-a82f4ca23812@kernel.org>
References: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
In-Reply-To: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1409; i=cel@kernel.org;
 h=from:subject:message-id; bh=nVz03LEZZcrMtkXp/Ok5Wrg3Jz8kFd498lBb+NjVnCU=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGp8inugxHEcrvNGFoaXn19kRunc2bkf30OWSR0t5VG4X9M2k
 okCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJqfIp7AAoJEDNqszNvZn+XCT0QAMBG
 HJEMXcWVw0/85oGnHif7iCBYKdM5eMMUuNZeO1ALeH4fJIiKM9YibWGbi91sF9ulDwSzNVm6Qoq
 Abeog5x5gyEzFGvWnwNXyWda7RCb7VpkAaEpLh6Nx4u2D3ZxT5tlZ/vh/1XgOcRfuTJBFYaofMq
 ttKTg+xArjgMTf1UjkHXzgu4J12Cw1wPR8viuuUlCmP9Vjary3icGW8/xFz33ZwGd4lBT0CXwGH
 e68SllBcYK1rDrmgz3iwFoqlzw1JL2x+YU48nUkN/t6pmndGDsmziDpcelWP85SXNcbXV0xhoSr
 YblWYNFJ5/aUUHkLQT46jQ7wU4OrZqFzLJ0BefarBOSxZDW272FDdi+TlJ5lnREo9MVRZkl0ukK
 PuFY96rArr5gyLngrGjgsVxRd5L9B5AV48mfbJQZBdh+1o3MumTWlfjz9rhn9gh8CE/pN68wh6g
 IjarltPlAvCXtKQVIei7Domtn6YMG0vmHeEGRjDKciS2sCjTvF3qfO1pXlWDjYt1SlVd5OPpGkj
 lytxqJBUR0UJDcVSdo1kb94EAn5/aFqyoTaWPwYUdaC8YD2kcxSbub2o/PAyaPfVW+oVupguscp
 lCLWGOt0rfsFo+NW9oXSeMoJUAyKjWalFnfgs+dtULLpMeZ8IpHkOizMxwtX7iyC1ckDWAR7uCh
 qfJW6
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

RFC 8881 Section 20.6.3 distinguishes an NFSv4.1 server
implementation that shares one pool among all classes of recallable
objects from one that keeps separate pools per class. NFSD falls
in the former category.

The CB_RECALL_ANY operation's craa_type_mask argument names the
types of objects in the recallable resource pool, but NFSD's
implementation does not name directory delegations, even though
they are allocated through __alloc_init_deleg(), they are counted
against the max_delegations budget, and the state shrinker reclaims
them.

Add RCA4_TYPE_MASK_DIR_DLG to craa_type_mask so clients that
implement directory delegations consider them when choosing which
delegations to return.

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

