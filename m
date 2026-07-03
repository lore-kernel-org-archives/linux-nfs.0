Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 570F131960B;
	Fri,  3 Jul 2026 03:39:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783050009; cv=none; b=sBIDsqRnslmrytRhkIENHhs9wCp8MDVADiHdjGiLKxOnE09sQ4ydycobHhbbqHvpZNzQ466mF3FvjAlOs2C1jwvRz6zThq4DlExHfWffmX/0Y+f2Nr2ZtW8/9rnp/MU7hGXHiz7oZm6QpmsMxtFYDWGLXoR7py6A1KHkVTJpBOw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783050009; c=relaxed/simple;
	bh=VINqarf7hOIseguRgK+ggb/uw32Diisf1elEGJDEhq0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hgGRqMEs+kSNvi/00Mh8NjEmocCRLJsggwIasVl4QyFL5xKmSaJ5mAlGhQavtsqbykw+4kkC1M8VK+8eSlTqaT+BJWIvjaZyn05oQgttNMkT3lf0PMGx/oklsvPMKOQjQrZjKnZocmUGeh8ZZcAPI41OnsRIOw8cihPul3aQNds=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=UTz99996; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="UTz99996"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7F1331F000E9;
	Fri,  3 Jul 2026 03:39:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783049996;
	bh=UNLcNnOxl71CB0YGFzVQszjVzHIH+/7q2lDPqivIgHk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=UTz99996E82+REkpDIqygstU2ayBAY9Hw2OanbJR/DY+6VIWT/0aAO2OqG9CZKT8u
	 uz89NGaX1YEZNKdMxxYk74OEuIkYn8X+QjHn/WUVPw07AP9tBdrGACM/qxtD+qkb6o
	 ql9Hq5L+A42MPbFo62Heg1hnDH/jSNX23Tc09/qWImEbjiUW1EJmNnNMKGYo9ob1Lr
	 N9kAGBqutEpvwGuPOftRX1i+b7AHOiVrnKvvc8ag6cex6N/v5lD8zgfp1mxBogvFZe
	 dEdZ9VO534xk0ckUlL4e9V2mDOXGN5/kAhSJ7Up70WX0TljFU9ChNIcR5i5HSXUiya
	 5ZLpEAGXrKULQ==
From: Chuck Lever <cel@kernel.org>
To: <stable@vger.kernel.org>
Cc: <linux-nfs@vger.kernel.org>,
	Chris Mason <clm@meta.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 5.10.y] nfsd: release layout stid on setlease failure
Date: Thu,  2 Jul 2026 23:39:54 -0400
Message-ID: <20260703033954.1602126-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <2026070228-repeater-synthesis-1c1b@gregkh>
References: <2026070228-repeater-synthesis-1c1b@gregkh>
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
[ cel: no ls_fence_work in 5.10.y; dropped INIT_DELAYED_WORK hunk ]
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

