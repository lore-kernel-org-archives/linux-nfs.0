Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60B7D4307B7
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:06:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.198
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784559991; cv=none; b=D+SppU0NhO29J+0cheKO8xUH+c5pTptxobXwEFlzH9EcXGs9G+WSAySgrMmOOAGBIz+D+pDJYmvvyDs+5hHy3/t01tqhkl4USiLnVlQNhN9p53619t1WKpqGkUOG7AtlIRdeHM6ViVKx1I8uOj5pFZadIfxmgEctri4xZlWLf+U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784559991; c=relaxed/simple;
	bh=F1hdAv1BVXhW0ib5eW8/6E+coJBZg/4PK1kV/+S8BiY=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=MiykCyhrZCR4A9URssT8v4BHgaV2HyZLr7Lj1jv2IGHaTY97m6oua8I9d9NuIGelxkg9tQWh1NL/efjCvZVWGj19LcUT/stWZFI0RZW6Iy+W3hraEpiPMVXacPupLA2QaKiD91LPhAAPOU+0HBWlCH4IuNBMeNixnBAmaKbWncY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=V1spRhOk; arc=none smtp.client-ip=209.85.210.198
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="V1spRhOk"
Received: by mail-pf1-f198.google.com with SMTP id d2e1a72fcca58-8484b9fb055so15185498b3a.0
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:06:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784559988; x=1785164788; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=d1yAJMK6cD/e1kuyT9ZxFpud0sasrBE5xVp8jVQmGx4=;
        b=V1spRhOkVNnPITHCk5k6qtQ5NkYYcU/YPdLXvuZyDE0JqBoewWzm3DK9CCaZhCWu4e
         iLKlaLGjLbYOV4fRwoX5qhkHYbe7yDnQVli00l62Cz98i327LiQw6mvzHl90TazyUdtn
         g6Stnbe/kcvEdomRK+4q2vA4r3Ev9w0MepqGXbYclo6mu+7W8Uyr6/Phs1yBjAxN9sMN
         IyFaPQPJzpbO+KiuF67pYhZg5Uhqe9Vpkz1DuyKrBwQcHdVM5HvjomPT4Mc4EfTUYlNd
         2oHUGZvQilqZD2lMqf9xJYPrhgdTiKe3rg7DM602SU9wiJyBbtW9N4nnFgwGA1zyBc+P
         DhBw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784559988; x=1785164788;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=d1yAJMK6cD/e1kuyT9ZxFpud0sasrBE5xVp8jVQmGx4=;
        b=KZXnS67CkePN4gjGmDWTIBjwaOH7XvC+n8GFIHzFYB23fwH8dWS1eKuAoAPu5ktJQx
         vFLOY+KJ0BALhsE4/kijKAQ8fwKlaG56qc7Zw9iY95Pv4ZBZRyRHXIVMze4hchQNwniF
         RqlmlnqC5y9IbBp8opYjK0JLSKrR4tfVX3ZczoNEhFsWT0AtxyosSyElU5S3lqwb/ZEY
         m5LvveTbcYeE8SyuJPKTco/3k7HhSewxaI8PZDyDaLRmBiFeh83XmjkaavKzGesFjJlY
         nNDoModQHYEIGSuHRUWP5i547RKztUeXDzdS8Y6SrwZV3+JS/bWTh1Hnl7BlsVrRlk4P
         NKtQ==
X-Gm-Message-State: AOJu0Yzo5VScu3d0CxUWvHKFW8Zzft06gkRMIYo7/axm2tgllJYQaHkj
	YmDC9CEWNI0EBKDyCLL8ALhrQPhyFad3rPoqZ2p/RdkGxXX977M0NORoTegnrd9gJ+HfbjOgWsk
	QBKlv+OlpythC5ZmdomLq+eFvCmpv6ZaDazNEsJ+lW+DionhwtFGbuWBC/A6dxd8izUi7PxrCiS
	VAw0nEqqEwVqpCYE2pxv6YuI/wj6YwwDGbOpk=
X-Received: from pgfu18.prod.google.com ([2002:a65:6712:0:b0:c9b:f0c9:631a])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a00:c88:b0:848:2f77:e2d9
 with SMTP id d2e1a72fcca58-84c29528adfmr14649468b3a.66.1784559987318; Mon, 20
 Jul 2026 08:06:27 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:05:58 +0000
In-Reply-To: <20260720150601.2702700-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260720150601.2702700-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260720150601.2702700-3-praan@google.com>
Subject: [PATCH v4 2/5] nfs: track number of pinned pages in nfs_page
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Track the number of pinned pages in nfs_page to handle unpinning
correctly, ensuring that only primary requests perform the final
unpinning operation, preventing subrequests from incorrectly
performing unpinning on behalf of their parent requests.

Add wb_nr_pinned to struct nfs_page to store the count of pinned pages
owned by the request. Update request creation and cleanup helpers to
initialize and use wb_nr_pinned for primary requests. Use the
nfs_page_array_len() helper to calculate the number of pages spanned
by a request's offset and length.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/pagelist.c        | 9 +++++++--
 include/linux/nfs_page.h | 1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 606b518fa204..c307daf5f68d 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -457,6 +457,8 @@ struct nfs_page *nfs_page_create_from_page(struct nfs_open_context *ctx,
 			      offset_in_page(offset), count);
 	if (!IS_ERR(ret)) {
 		nfs_page_assign_page(ret, page, pinned);
+		if (pinned)
+			ret->wb_nr_pinned = 1;
 		nfs_page_group_init(ret, NULL);
 	}
 	nfs_put_lock_context(l_ctx);
@@ -489,6 +491,9 @@ struct nfs_page *nfs_page_create_from_folio(struct nfs_open_context *ctx,
 	ret = nfs_page_create(l_ctx, offset, folio->index, offset, count);
 	if (!IS_ERR(ret)) {
 		nfs_page_assign_folio(ret, folio, pinned);
+		if (pinned)
+			ret->wb_nr_pinned = nfs_page_array_len(offset_in_page(offset),
+							      count);
 		nfs_page_group_init(ret, NULL);
 	}
 	nfs_put_lock_context(l_ctx);
@@ -567,14 +572,14 @@ static void nfs_clear_request(struct nfs_page *req)
 
 	if (folio != NULL) {
 		if (test_and_clear_bit(PG_PINNED, &req->wb_flags))
-			unpin_user_folio(folio, 1);
+			unpin_user_folio(folio, req->wb_nr_pinned);
 		else
 			folio_put(folio);
 		req->wb_folio = NULL;
 		clear_bit(PG_FOLIO, &req->wb_flags);
 	} else if (page != NULL) {
 		if (test_and_clear_bit(PG_PINNED, &req->wb_flags))
-			unpin_user_page(page);
+			unpin_user_pages(&page, req->wb_nr_pinned);
 		else
 			put_page(page);
 		req->wb_page = NULL;
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index fd7aafe7cb54..080fa3e23580 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -59,6 +59,7 @@ struct nfs_page {
 	struct nfs_page		*wb_this_page;  /* list of reqs for this page */
 	struct nfs_page		*wb_head;       /* head pointer for req list */
 	unsigned short		wb_nio;		/* Number of I/O attempts */
+	unsigned int		wb_nr_pinned;	/* Number of pinned pages */
 };
 
 struct nfs_pgio_mirror;
-- 
2.55.0.229.g6434b31f56-goog

