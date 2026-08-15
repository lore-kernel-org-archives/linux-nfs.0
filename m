Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8AB6423EB7
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811942; cv=none; b=Wu5PeIqslVv+rQ1JrnVxZrlJTNKjTZQgFNv5atBkt0X8Rdhw/onVTAVvQwuGdfI9seD81Yq8CcQxoTGasu9cpksMkvB05zM66d2FXVGOO8hn/3l4s5pcsZqrdl4mtc0i0q1qWObTkN+iy6AdWyWMSvQ7u2QgBiIZ3RvJ4R83rgA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811942; c=relaxed/simple;
	bh=hjyOXY1iaXHyiyONmrxdckfkarREO/QB+c2QXeKqq5M=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=HYobQ1N5MMP4FVvJe5tE6O8Jfbtbnz0qleaP23cOYCB2D2NiOri3QK9aRtwaI0IIZjGqsIJCY/52u+ZoPYsdY/Oa9+X7lys5R+tygQYZaJSmmJritBt8GnjaT2yKqJ7XJwGW9G7b9xi7TIlCFbzQdbH07/BLCvtDg+ECmUHJqf0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ISBtwcr1; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ISBtwcr1"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E68A21F00A3A;
	Sat, 15 Aug 2026 16:38:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811940;
	bh=RdRWcaBu2AveqfSV3Ha9LbjLuI8aaubrGdqQvdRiaw4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ISBtwcr1tmounZ4Y/di51U4+p6KztNuaw/EZAZ1ptWf0NIIU4xcC8K9pQoSvgx9B5
	 aQZ3w+C13xlfS5rFanJcT4hpa5UJyJl0omXOwSAJE2piFTDmOxQTDvcx5xs3OOwEyY
	 rpEDAe02Mb7W6m5x9c/aPw3TYFnU368xVpsG3zfGpu+CtjoIeSIK3lkXpHv8jQ+ygn
	 rFAg4Uzz2alVl1BAMbMrPlPW18yR8ab2hkodubJfMEZDnimV0bos0J1cxCzeTkSv/l
	 h5x9GEA2qvFHfhY/pP1dNS3qxEevDL1uiSv3D5qmcS7qiqf9jgqyNhHNZTHIWs1MOX
	 5mp4h7wcl9xow==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:50 -0400
Subject: [PATCH v4 2/8] NFSD: Count the delegations held by each client
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-2-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2423; i=cel@kernel.org;
 h=from:subject:message-id; bh=hjyOXY1iaXHyiyONmrxdckfkarREO/QB+c2QXeKqq5M=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYhj4tkrvgPJhMF4mWjw0W5gJL5Ge7ZTvT3F
 FTRfRekfyKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIQAKCRAzarMzb2Z/
 l6KUD/9FaX5FDJ9/cHPZxrvfwinOCeSY3tc54NzX7GtPnGt4T7NcFbzQiZozx3xWMfKV66DGgp9
 OIMh66aY7RBXGXMNQNYLoXLsqyQAnJroH9DEWCQLdqAm3W3gcn0K2qZrC48h4F0xjINOBfKRCM7
 XQ+ls2nnBG1MMin2oCJCbGZjWxP8m1D4SAHWlRmFZVmkvZWD9Y8ie7FJbWH7XF3Kt6F/QToxG2+
 NiqLAchr9aNog4Jz4Cj3oy3KFOmreGU4R73ER2COeemsmXalhot0Ynmkv1QC17c0Q71fCGVqf+Z
 7q4QxvR8wRvWbBhxK8BoruRDM1xc8j726T0w9k5n7TUN+DPU0aKd/F/Ri6ZSRhAZ5W0jTqSzxOi
 sRdV89I5AhqTyMer6v0zam+r4S9598w3FPBhE0nPt1M9bZidOEpK3MpDHp65895ori3tb8b8zk1
 IRZwn9Nks+CkzrPp1w/PeP9BMEtGiZSikNnCl2BVO6YCa6+5QRGwiX0FivYEEzneOXgjS/JKlDP
 VrYP+ypvUX+u/M5KtNHGS+ePPj5uScX8JSKAZxXtn56t0siXerhcD+r2aPjy/xJRBREfpFK/dAh
 RVbj3dqGMmU69rLsqgk5SJYKpwlM3lUMHGakrorcX5zaEm6xLU6vnh0bplIMsT61ydCnwdkAIaY
 1pqMJKx42i0Qb2Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

struct nfs4_client records the delegations it holds on cl_delegations
but keeps no count of them. deleg_reaper() walks nn->client_lru under
nn->client_lock, but cl_delegations is serialized by nn->deleg_lock,
which nests outside nn->client_lock. A caller there cannot take
nn->deleg_lock to count the list. The cost tells against the walk as
well: an O(n) count per client, on a pass that already visits every
client.

Add cl_deleg_count, maintained at the two sites that mutate
cl_delegations. Both hold nn->deleg_lock, so the counter is already
serialized against itself and needs no atomic of its own. The decrement
sits below the delegation_hashed() test, next to the list_del_init it
pairs with, so it runs only when the delegation really leaves the list.

A reader that holds only nn->client_lock is not synchronized against
either update site, so it can see a count that does not match the
list. Such a reader marks the access with data_race() and may not
depend on the value for correctness.

No functional change.

Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 2 ++
 fs/nfsd/state.h     | 2 ++
 2 files changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9a3574b853ad..fbe073ee5225 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1527,6 +1527,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	dp->dl_stid.sc_type = SC_TYPE_DELEG;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &clp->cl_delegations);
+	clp->cl_deleg_count++;
 	return 0;
 }
 
@@ -1558,6 +1559,7 @@ unhash_delegation_locked(struct nfs4_delegation *dp, unsigned short statusmask)
 	++dp->dl_time;
 	spin_lock(&fp->fi_lock);
 	list_del_init(&dp->dl_perclnt);
+	dp->dl_stid.sc_client->cl_deleg_count--;
 	list_del_init(&dp->dl_recall_lru);
 	list_del_init(&dp->dl_perfile);
 	spin_unlock(&fp->fi_lock);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index c65b604e29f1..cd9294f024bb 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -633,6 +633,8 @@ struct nfs4_client {
 
 	unsigned int		cl_state;
 	atomic_t		cl_delegs_in_recall;
+	/* Length of cl_delegations, updated under nn->deleg_lock */
+	unsigned int		cl_deleg_count;
 
 	struct nfsd4_cb_recall_any	*cl_ra;
 	time64_t		cl_ra_time;

-- 
2.54.0

