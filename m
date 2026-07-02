Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04965396D2E;
	Thu,  2 Jul 2026 21:41:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783028499; cv=none; b=V8tA+D92R/WhheNORFgqR/vASUivlaJNxT4yjPdJOXH/3oXTUPSsZiCqdBr3ZqEz1vCojNjxYflQ2K5SCGxLaKNUGYzD98u2SRbnaY8TW6K7GGvX2YPxFq0Srx3PkxFx24vfPT0UUpXDof2VFX+EH6pYV54+LHOqABWF4C4DcS4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783028499; c=relaxed/simple;
	bh=ddZPTIQBXHN5/ukPBn3a/jjJl2IOQXjI970W5ZUffJc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fmHJLmnKZ1MMxHlk3pJ9WV9kv0QbVh5sTdlIMRKv0dOUNNgJ+KnI0hQ6RKpxHos1R7OMZpmRM0A50iEA0RVK4bvEsK37Be8C/OY3xlKgfehuQT/+5MF53debrl5Y/+zeD8o8TBv5B529V4ZTP28MdAstZCT7OCPWS4tUYHalwro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Rp+iCbz3; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Rp+iCbz3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 76FCD1F000E9;
	Thu,  2 Jul 2026 21:41:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783028497;
	bh=lraBce0bPA6Oz3ILSCazwgCxYsFFKeSpm0zKg9v8iJ8=;
	h=From:To:Cc:Subject:Date;
	b=Rp+iCbz3qdy9xg4iFGwqsJRfhYxwBVoYnpuSXFJ2tfuZD2gxzhpJLTsfvZb5MJRJr
	 1R8ZESyO+TYGZOIz8vVrPgboee9NNAWlEUg0vJ4g0ybfXDQvKujccVBipF+VotizE7
	 HoBk7mhvT57UtNqwwGlBpMB9Xy+3EhSoM4pFynbN6tjr34uOxQ2ZzsjkU3lT6h+k3n
	 p09hwyPHQlUxX0vOfGrhOno0Q3rssjK/WeLDk5q0NSlGcd46KO3q/oRJI9E+Xv7D+4
	 1qTWEQ0yg//GIuIKtvO/iXvqpfTN+XKUMFvKnGgiQkjm51mzey/8VZP1RFEq8yj4I/
	 JkliLBmwv7bJw==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 6.6.y 1/2] nfsd: release layout stid on setlease failure
Date: Thu,  2 Jul 2026 17:41:34 -0400
Message-ID: <20260702214135.533354-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
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
[ cel: no ls_fence_work in 6.6.y; dropped INIT_DELAYED_WORK hunk ]
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4layouts.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 308214378fd3..84bb200e24ad 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -242,9 +242,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
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

