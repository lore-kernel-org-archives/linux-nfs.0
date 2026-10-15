Received: from mail-ot1-f43.google.com (mail-ot1-f43.google.com [209.85.210.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 78A3B4A2E1F
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 20:58:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792097897; cv=none; b=SCK+IsgjULY/b5BKB3T+hF7PeoXHKvWze8UkBO+ZI34G8m5QOjrpUK3/PH1LYLO6LStWXQ0o8tIL9Tz5ta5AV10dOy2Hup+WdvrmQLOue1xuSTJVbv+SxhHWGqsZrf01z5uJzDtVisJOlYxGodcS2x7T1MUKLjSQ3Zi7/4l7r1o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792097897; c=relaxed/simple;
	bh=Ake7Zrpb4hk/Dgsuys8QDPi/nKdsfxv0vFAun3zZsYQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Bh+FoNZSJwUvK0i9+FXPmErvBmSE0mbYyJBvpHUSQY3FjfoZOzvrvKKUhO1Aq2hyAj2iI0g6BN/nHPTkTWuC0iUOAAE+giJ8A/ZVWRAT4wHMwyD0V+7ZIM+v4AL2AYUleebroEdQTdUb0AEWF0ntK3gTLcv07rjh+orzLINeEX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=O39N5xjS; arc=none smtp.client-ip=209.85.210.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="O39N5xjS"
Received: by mail-ot1-f43.google.com with SMTP id 46e09a7af769-7fccba9c675so576887a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 13:58:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792097894; x=1792702694; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=2FvtLCFEdz6DNSHbq6E9KmvWXVftP435cWnF6imBkIg=;
        b=O39N5xjSrq9ylrffVBAtLRL6Khcb7Ro1UXtHItcPsIckePg8UHR53OzuyaMGt/xslB
         axmKDayudn7jkQgiFLuD/LsHPQIV6KAtn93bWdV66IkJ1uKWa4+fb6AArjS5TRT9SASS
         PcOhq66hVxyI1NrTWUHEcOlaO2lqjHNc4DMsOlwwqfydD0rXVxaxp+r0RDybmPzK+X17
         +Us5lDS3Cydlkdo3FX9GDMhWoHdcvUWGqmukgwXuMVNPEi/8xumefvRGCWzPkWGYvNIe
         2RbDGgyEdOSdxoW7ZzXMP+CAZflwO4YHZSZ2M9OxXiJABfv+HPHFgwdNcE7mYQF0BI/A
         l4lw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792097894; x=1792702694;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=2FvtLCFEdz6DNSHbq6E9KmvWXVftP435cWnF6imBkIg=;
        b=HyAFsr44gSAf9vXR/rlN44B24glnPEW/qWKNFiNuenTXv8c1sEsuwPgeGUMvzQ3OAK
         jpkvMEMCa48H0i7ujykaYnDcRYMI8cFZeerozqXdw10c+OXQyFZW8nx/Soa2FLP/jclw
         bsqUYFNt8Zw+fR6Y9tXoy3iTB91gvObi9MYIi6srH3bFGT9fvWuegO6eSkXtvjw+lLlh
         hUUBiLLu564hfb0UX+r4fkreSH+jdc3sAcrEAwjI0QN8nSk4rHKfdfbjiGY71sGHUHBK
         uPoGXrjfA+STN5UmEce2hXWMNUOj4IcBtYkGaAVwPyUmwz4iE+bsu6NMYxLP4dk+iq+A
         IyPg==
X-Gm-Message-State: AFq9FYLW9ZRf2mQhyzfCzvRSGYXjGui/RaPgOsxLgwvu/HU7eDK3yTFH
	Ch26fCGUQTJMtCKFodXwpOFVoyDwGsyc2CNQ6Ry190SF9ysHXSgnDp7j4kxU6UT3sGA=
X-Gm-Gg: AYBFou3N7MmQGKaWjvRezRYwGuEECln1jCJcJ+v7rutJ6+P6dJXKiLha3BEeJieQqlD
	eHqJxg+0ez7hSVOI+GnZjtIRr0gET9RXClrZeuAIJqG24XZ4EOgMm3aaRWOL62JFTmcgGbbvyrW
	LF0Jh8skIzHbgNXTLtEtaSDW02SEgvsipHe5Cs/jWiDkv1jSLqIiVtsANoeYl5mP9Tp9s+2Zv6n
	348uHMawDH/1vlug9ih+l53henylJI2dIQ/XLLnF1uR6ZOZkFrxFF3NryTmEaDM+Ckt1pFyyzLT
	RzZKh4ecgYL1Es57QiNI1qjgvKY1TyHu8ny/ZCqXdOUqckKpqbH1Psmck3vQ5pQ+euv58F/Dx3v
	pkhV/YQdP2MFPS1PCfvKE457+V3CK5JGlhOAe25vpCL+yjB3X2lkPRZQntP71vn4KNoYHuoPxb2
	UbO6ghobuEE/JllOTnq8Sku5r8nBfJk10Nf9gxrujd1ogBwOvrbVGVdw7NU2YcTJ+wswaN/hD3w
	XOdL1tDt/CWmtizbjQ781/+e/gJybfrSWzxMx56lw==
X-Received: by 2002:a05:6808:4fe7:b0:4d6:9133:cfdf with SMTP id 5614622812f47-537005173dfmr962098b6e.36.1792097894093;
        Thu, 15 Oct 2026 13:58:14 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388c1654e9sm25514b6e.8.2026.10.15.13.58.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 13:58:13 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Don't warn when a changed layout refuses a split subrequest
Date: Thu, 15 Oct 2026 16:58:09 -0400
Message-ID: <878637a4a9a6c18303172435fe9ca512332c82dc.1792097624.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1792097624.git.bcodding@hammerspace.com>
References: <cover.1792097624.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

When __nfs_pageio_add_request() splits a request, it sizes the
subrequest with pg_test and then adds it.  The current mirror's list
is still empty at that point, because sizing added nothing, so
nfs_pageio_do_add_request() runs pg_init a second time.  For pNFS,
pg_init re-checks the layout segment.  A layout recalled between the
two calls can make the second pg_init fail the descriptor, for
example with -EAGAIN from ff_layout_pg_init_write() when the mirror
count changed, or leave a smaller pg_bsize, and the subrequest is
then not accepted in full.

That trips WARN_ON_ONCE(subreq != req), which was meant to catch
pg_test changing its answer for an unchanged descriptor.  The cleanup
in that branch already handles a refused subrequest correctly.

Warn only when the descriptor has no error and still has the layout
segment and bsize the subrequest was sized against.

Fixes: 44a65a0c2783 ("NFS: Reverse the submission order of requests in __nfs_pageio_add_request()")
Cc: stable@vger.kernel.org
Assisted-by: Claude:claude-opus-5-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/pagelist.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 06e301c8c291..cbcf19d5f61e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -1181,8 +1181,10 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			   struct nfs_page *req)
 {
 	struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(desc);
+	struct pnfs_layout_segment *lseg = NULL;
 	struct nfs_page *subreq;
 	unsigned int size, subreq_size;
+	size_t bsize = 0;
 
 	nfs_page_group_lock(req);
 
@@ -1204,7 +1206,15 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 			subreq = req;
 			continue;
 		}
-		if (WARN_ON_ONCE(subreq != req)) {
+		if (subreq != req) {
+			/*
+			 * An empty mirror runs pg_init again for the subrequest,
+			 * and a layout that changed since it was sized can refuse
+			 * it.  Anything else means pg_test changed its answer.
+			 */
+			WARN_ON_ONCE(desc->pg_error >= 0 &&
+				     desc->pg_lseg == lseg &&
+				     mirror->pg_bsize == bsize);
 			nfs_page_group_unlock(req);
 			nfs_pageio_cleanup_request(desc, subreq);
 			subreq = req;
@@ -1227,6 +1237,8 @@ static int __nfs_pageio_add_request(struct nfs_pageio_descriptor *desc,
 		if (IS_ERR(subreq))
 			goto err_ptr;
 		subreq_size = size;
+		lseg = desc->pg_lseg;
+		bsize = mirror->pg_bsize;
 	}
 
 	nfs_page_group_unlock(req);
-- 
2.53.0

