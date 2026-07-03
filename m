Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F32B30C178;
	Fri,  3 Jul 2026 03:38:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783049910; cv=none; b=SoPeKwHHcvaf41SByWr9h8Cbo6+JrXwEdUnC3HnMWkAzVfSJ5pTC0Umo9c7sMj03VUELCSmddhkkRAgSPMYI7JUbKDXxD2HGtWOIMrWYFR5sUkHCBTd11RR8yXMsKWKBARiqozzfe8y8gWXB0q7rwwubpLNkgjttodFUBwcEva8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783049910; c=relaxed/simple;
	bh=d2mTwY3vPT9q0uXQW/glaf5ntHryN0h6VHMEFjf3WwA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=IfTomzuGqG9Uv4LProLYxz4OP0dUOlHU9ob+yADFOF4tLAtiWETVPq99xnLVln1tZSc7OvwgigGGdJVNBZYmy0aYbd2+CkL/6u5IIjpnLcuq2GW6LHxcJpxW909MbBAiK1cniawcpH6kvKyh+/XVMVPnuvh4I66fxLe022DgP4g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Tr0PU0fY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Tr0PU0fY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C132C1F000E9;
	Fri,  3 Jul 2026 03:38:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783049898;
	bh=gJfTVIipOLwRm/OjXccUYhVkVz3G5zg319vn9f3homQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Tr0PU0fYrDbSVgGHcuAKevcU+SkSDr60xo2UdZp/EzZxYS8wES9zNJawmuyWmVByb
	 fUfdqtpO7REWJYp/r6+YpfHp3odrRsSfpIE74Mnnr41wZ/nnfasJT7acPDfRaWY/ec
	 ZD4UAZiVpU3cYZbq+m6DH1y0i7CRSRauZpKJujK+t9ihweAMX96xlNsx4QlqWgJhH4
	 14q3+ZoqN9tObm60M4KRCJNnkS6oFIbF9odjxTi4NMOsDW3cYeQZU1nruAgxLVkYhi
	 ssBj1aHSQcQHErI9Yr3VGyj2wEDoBaLZaJFBLSmTxg0oEdzNYJPvYgxmXmqbplbZ55
	 gqO8FWsXa5zZQ==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 5.15.y] nfsd: release layout stid on setlease failure
Date: Thu,  2 Jul 2026 23:38:15 -0400
Message-ID: <20260703033815.1573400-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <2026070228-deny-tattered-d0df@gregkh>
References: <2026070228-deny-tattered-d0df@gregkh>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chris Mason <clm@meta.com>

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

A second issue blocks that switch: nfsd4_free_layout_stateid()
unconditionally inspects ls->ls_fence_work via
delayed_work_pending() under ls_lock, but
INIT_DELAYED_WORK(&ls->ls_fence_work, ...) currently runs only
after the setlease call. On the setlease-failure path the
destructor would touch an uninitialized delayed_work.

    nfsd4_alloc_layout_stateid()
      nfs4_alloc_stid()           /* idr_alloc_cyclic under cl_lock */
      nfsd4_layout_setlease()     /* fails */
        nfs4_put_stid()
          nfsd4_free_layout_stateid()
            delayed_work_pending(&ls->ls_fence_work)  /* needs INIT */
            nfsd4_close_layout()  /* nfsd_file_put(ls->ls_file) */
          put_nfs4_file()

Fix by hoisting the ls_fenced / ls_fence_delay / INIT_DELAYED_WORK
initialization above the nfsd4_layout_setlease() call, and replace
the manual nfsd_file_put + put_nfs4_file + kmem_cache_free cleanup
with a single nfs4_put_stid(stp).

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Cc: stable@vger.kernel.org
Assisted-by: kres (claude-opus-4-7)
Signed-off-by: Chris Mason <clm@meta.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
[ cel: no ls_fence_work in 5.15.y; dropped INIT_DELAYED_WORK hunk ]
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index d0fbbd34db68..bcf16dd07d48 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -241,9 +241,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
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

