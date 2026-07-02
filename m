Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C68993161BE;
	Thu,  2 Jul 2026 20:27:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783024073; cv=none; b=qpKa/tb8YKNNAnLISIMrsK/GMAZo2QQ5F8oibA6a9y0bI1AJ+22e2TVK3ErMJlxJjhzLmuNhOVdKLTj7GUq2LlZFtyM1du45auNPv5bYYUYAbmgguPPsUjbk5KVMoN1w4LSacIWL2tSnUtSZqwUXUgmgzVn27hslLApCbMW2LXg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783024073; c=relaxed/simple;
	bh=6dGBWGBBG59neW1v2gtxQOj7AniEMKFWX7nlz91cenw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=f8GCaAwAk3GpRdZr5k1vF8P73fEgk6Qjq/d31xbIcGUsegJi6wtKGeJf/d2IjYfroKjfewoAg+ZzcOgWWZ5l/LwEm1De0gjGmeKFxXwaaGvGIJOcsCHYfg9zBns7oaD8BRtuuC/7dVLkLUme/n/431Fl6VqEIcPP1aCkRGBRvOg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JbYtHuma; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JbYtHuma"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 586291F00A3A;
	Thu,  2 Jul 2026 20:27:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783024072;
	bh=Ps8j8F/Do3ZPa4QJfrmY+Qqk2x2W4g0PJ7nq6sK8Kz4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JbYtHumamw6qKmjB+Z0gx2PjcAuODLSh66eA/t13bpZHcr//LlLHwR4LdTswSpVgq
	 XcAJ5ieOuYFk1nLMV3NZ1FyopwPkXGbHyz+UQP77H3w10HmuNHbnLW9y7z1LPuUzEe
	 QDyKoTdfHNVYKze52kKkFaesqFydOLw36HF20rSR6xrHMSyr42uRhsR038CVYOADzN
	 sCUAa5i9FSEWmRrM8gIjgHRy387XD8w9YwiH0cN0jOusJcjem+rgvN6jA+7JvObHAl
	 zmGngcRcVBrxvpnxHi5LAId/bzRVsY2sv/ni5IF2hsB8vDgYABXX3SGddhp+vTdlQL
	 09O9xGoxBb0BA==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 6.12.y 2/2] nfsd: release layout stid on setlease failure
Date: Thu,  2 Jul 2026 16:27:49 -0400
Message-ID: <20260702202749.1618630-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260702202749.1618630-1-cel@kernel.org>
References: <20260702202749.1618630-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

commit 30d55c8aabb261bc3f427d6b9aae7ef6206063f9 upstream.

nfs4_alloc_stid() publishes the new stid into cl->cl_stateids via
idr_alloc_cyclic() under cl_lock before returning to
nfsd4_alloc_layout_stateid(). When nfsd4_layout_setlease() then
fails, the error path frees the layout stateid directly with
kmem_cache_free() without ever calling idr_remove(), leaving the
IDR slot pointing at freed slab memory. Any subsequent IDR walker
(states_show, client teardown) dereferences the dangling pointer.

The correct teardown for an IDR-published stid is nfs4_put_stid(),
which removes the IDR slot under cl_lock, dispatches sc_free
(nfsd4_free_layout_stateid) to release ls->ls_file via
nfsd4_close_layout(), and drops the nfs4_file reference in its
tail.

Replace the manual nfsd_file_put + put_nfs4_file + kmem_cache_free
cleanup with a single nfs4_put_stid(stp).

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Cc: stable@vger.kernel.org
Signed-off-by: Chris Mason <clm@meta.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
[ cel: no ls_fence_work in 6.12.y; dropped INIT_DELAYED_WORK hunk ]
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index fc5e82eddaa1..c08bc2d0d377 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -256,9 +256,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	BUG_ON(!ls->ls_file);
 
 	if (nfsd4_layout_setlease(ls)) {
-		nfsd_file_put(ls->ls_file);
-		put_nfs4_file(fp);
-		kmem_cache_free(nfs4_layout_stateid_cache, ls);
+		nfs4_put_stid(stp);
 		return NULL;
 	}
 
-- 
2.54.0

