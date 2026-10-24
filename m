Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792850898;
	b=dyYZGe3215YvOASoX9xRWeD6tADIcXaHb4otLgMIKqmafSGyj5xUGdEZ/hRaZBCbUhw/
	 Ko2394SLmv00BLKO6dnviC7jqQBqtHtft4/U+RUhQw060Sb6umzLADlLn9UsnuLDG6UgG
	 zZlqnb6eTzllUzUUKG06UP1dvDhJdQZjx4bTK6nZjS3mB+3x25ukBG9n+1mc157uRx4+w
	 sjnRWQLv72ZmTLmhOixxToMIdhM4zqahoNKhFmcDL6REesjEkI3VyIncVXvka4sr9l8Xh
	 uPiPJyLQ3b9edgBaoqx7iYOm7hDhPORT/xw1s+OnEjMJpOTHI2p+5+PGRJan9joLnEQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792850898;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:
	 X-Google-Original-From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=c6wCqzN3EsgOG2nKU2sQEo++USut2OFxcLcZCZIPEk8=;
	b=mzFnHJcCUj4fBJyDaIWlC7pdxn5dwqBJ41OpD08BV5vTeu28WxuFsZ3DhX7QuKEmjtge
	 ugBg8NH6Pjl9Zh/YotuYqFGyV99xcG/TuuZBsT6RCKLcDPytYxALURQCDJyL0xFZNp1Ke
	 Jx/P9Z1A7/h/m5R+vuP7J9Wfdk6Iyfx+0+IdoNolSA+InKQS1jP7+zOQ76pnZuIldix7Q
	 HI03vaCbH+eSgq43oHotLDeMb+calX6q+uGu5dkSpJoiAi/zpgQuP7lp/KvASwBTX5XQT
	 asy6fMQpROt+aEFhxsxaYc2kf4Pgwt/4BQyVGCD6sY3EDQeto4qc/v3klC+FuJ0wMLw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=fmELto2s;
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E3D9A606A31A
	for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 14:08:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E3D9A606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20251104 header.b=fmELto2s
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-82380b0f55dso729966a34.1
        for <linux-nfs@vger.kernel.org>; Sat, 24 Oct 2026 07:08:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792850897; x=1793455697; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=c6wCqzN3EsgOG2nKU2sQEo++USut2OFxcLcZCZIPEk8=;
        b=fmELto2sW+shfblnzDuYfwZ9wIi8AteVWMjvWMH821z590KSZYDMpx6klDq7weZjOH
         wVm4+agpIqYSM9Osv81ACJTh7zqZBrKmQXcYYdR285yOItrgcgEytCziRDj3sFC4fEs7
         iWcmoUxyaTPXIDWQfNixJy7XTPCwhVvzitaVyrDiEaY6S39EaoZ6Sw8pSGrwXT4zOUO8
         4jQ6155oYSMLgOE6fKObewvUnZjT9osNKVD+il9PiqW89zBv5shD1qWzkO0Xufhuh2Cy
         Zpy7mzQXwVIY2N+VyzPdc4RKuNQzief++N2NxaN+ZRYv6PgkvyqqXgWEk6dS1x073Ag5
         qXMw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792850897; x=1793455697;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=c6wCqzN3EsgOG2nKU2sQEo++USut2OFxcLcZCZIPEk8=;
        b=pLLoZ9T/9yAJ2WkY9OWD80xko8CIfFGzL920jZTxV7tJa34yH8tWalQOA9HAQMSZGJ
         imN44ugfW68ltZ8UbbrK6UZe7yOOpFsUb9mO1ehfWWmAbQDsfDRXf6QGW32KDeG9e8Ua
         SaaVyizRFyPcMrKUmprp+2LvAOqQ0JBR/FRKpo4i+/8kgqvYNdNaOuTkE6vPpZ21dDi6
         2YUaGQyaBDM7KZH8Fkx0j+RsKVHhgKrEq8p0iZWFq8CkvHrcA2b/eManrANdAhdIyuUg
         Hc7aefhTtEubxEqoPeV7cu0mAf9yp4AdBF6Dz9mNI0rkUx9iwGS6BhY6nz4cWj8+7apl
         brBg==
X-Gm-Message-State: AFq9FYIUnHCIxCxJuc0XSxxypIYB6TP7N4SFQPBBDxWlbXvmCJVJIqTL
	cGAkbdIc2hMONd0CHI/tVmM/l5KAKNd3DPPz4myR2QVn6Da3mdfQqmrvCTtQdA==
X-Gm-Gg: AYBFou3w/kaddM6rzb3+60IAiV3SwcrDQFZ7rBCWCWNRJwcaZ+v6iRaVQ/5kV+nUzbq
	4hYnYTZktCqYlWa7YF5JOTgM3wMu8LDY8Sb3il/xROAgfN+NllzgScj51fYs8IYPWvC2/ZNyWZm
	Bo9bViMBONzdNyRU9O1Dp7DhVkWf5l5AOy7g+mnyuLp+yzLfsypBK8wu4uM4KtgIuSKa/0hJ9Ap
	0Wfs1FacVv9oj5Ky88bM2zfTfiIhH9oJEPzGaTK6AgehKrOHDDAmWcIIc6UGswXdma58ng1zY/A
	kvXZZUSmKW3TAQ6Vm4NlMksE2dSa0C5uHoKp4p+5pQ/yptnUxARAc/XmbzAq+uR9yiXR4NhWa/S
	2YA1fNZ+nGYkaIEt2UrjrE1VKqqycyqiRFcEF1NVe7HYe3RcRKlCr5M5ceNMe6BiUEnTPxl7qli
	F5ETU9nkZTxGlKVI8IhUUWrLQXEhOcfptoDtweKe4NTmNcZJIYwSi0hqNX5TDLraf7hqrGucVNk
	kmrwcW/Uhos3tAhzyJyYeDThpvWd2khGlBc1Ml9RDvTwywq/ROi6fi1Vsxc
X-Received: by 2002:a05:6830:411e:b0:81c:b9c6:16cc with SMTP id 46e09a7af769-850fce9da1amr1693954a34.6.1792850896799;
        Sat, 24 Oct 2026 07:08:16 -0700 (PDT)
Received: from localhost.localdomain ([192.63.62.92])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-850fb649402sm2327349a34.14.2026.10.24.07.08.15
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 24 Oct 2026 07:08:16 -0700 (PDT)
From: Jorge Mora <jmora1300@gmail.com>
X-Google-Original-From: Jorge Mora <mora@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: trondmy@kernel.org,
	anna@kernel.org,
	Rakesh.Bhargava@netapp.com,
	Mohit.Kumar@netapp.com,
	mora@netapp.com
Subject: [PATCH] NFSv4/flexfiles: calculate stripe boundaries from the file offset
Date: Sat, 24 Oct 2026 08:08:11 -0600
Message-ID: <20261024140811.51694-1-mora@netapp.com>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>

ff_layout_pg_test() subtracted the layout segment offset when splitting
I/O across stripes. Device selection in nfs4_ff_layout_calc_dss_id()
uses the absolute file offset, which is also how RFC 8435 sparse
layouts number stripes.

A LAYOUTGET reply that starts off a stripe boundary therefore moves the
clipping point while the data server is still chosen from the file
offset. After a data-server error, a direct write that crosses a stripe
is joined and resent past the real boundary, and a later read of that
range is not split.

Clip with the same file offset used to select the data server. The
segment offset remains the covered byte range; pnfs_generic_pg_test()
already limits coalescing to that range.

Fixes: 4934ccbeaed3 ("NFSv4/flexfiles: Read path updates for striped layouts")

Signed-off-by: Rakesh Bhargava <Rakesh.Bhargava@netapp.com>
Signed-off-by: Jorge Mora <mora@netapp.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 18 +++++++++++-------
 1 file changed, 11 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7fe8b91fa47c..09d44de2676a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -996,7 +996,6 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	unsigned int size;
 	u64 p_stripe, r_stripe;
 	u32 stripe_offset;
-	u64 segment_offset = pgio->pg_lseg->pls_range.offset;
 	u32 stripe_unit = FF_LAYOUT_LSEG(pgio->pg_lseg)->stripe_unit;
 
 	/* calls nfs_generic_pg_test */
@@ -1006,10 +1005,17 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	else if (!ff_layout_lseg_is_striped(FF_LAYOUT_LSEG(pgio->pg_lseg)))
 		return size;
 
-	/* see if req and prev are in the same stripe */
+	/*
+	 * Sparse flexfiles stripes by logical file offset, the same value
+	 * nfs4_ff_layout_calc_dss_id() uses to choose a data server. The
+	 * layout segment offset is only the covered byte range.
+	 * pnfs_generic_pg_test() already stops coalescing at the end of it.
+	 * Subtracting that offset here shifts the stripe phase whenever a
+	 * LAYOUTGET reply starts off a stripe boundary.
+	 */
 	if (prev) {
-		p_stripe = (u64)req_offset(prev) - segment_offset;
-		r_stripe = (u64)req_offset(req) - segment_offset;
+		p_stripe = req_offset(prev);
+		r_stripe = req_offset(req);
 		do_div(p_stripe, stripe_unit);
 		do_div(r_stripe, stripe_unit);
 
@@ -1018,9 +1024,7 @@ ff_layout_pg_test(struct nfs_pageio_descriptor *pgio, struct nfs_page *prev,
 	}
 
 	/* calculate remaining bytes in the current stripe */
-	div_u64_rem((u64)req_offset(req) - segment_offset,
-			stripe_unit,
-			&stripe_offset);
+	div_u64_rem(req_offset(req), stripe_unit, &stripe_offset);
 	WARN_ON_ONCE(stripe_offset > stripe_unit);
 	if (stripe_offset >= stripe_unit)
 		return 0;

base-commit: 18a80121193c6d19519e218434c9acf90e8d0e5c
-- 
2.47.3

