Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8576F432E7D
	for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 15:06:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.199
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784559997; cv=none; b=GXWJww6kt5xVS5U8FOJN8gb+6DjkS9M2GmsNGcR0rF6q9xwq7nAPC9oxwUgXNhXipmQjTK9v7i1uuxspWUBjitcBdsbC9sI7b62cIVY9Q8Wu5d0sLpj0n0AOCnpRzEJ2YS/CL6AK3jzZ+AsQ2UxShRsXKuCEjvl9jWGy2Qdpn0U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784559997; c=relaxed/simple;
	bh=uHl1U9uqrn0K6pJWxrCywcw/LqoTgBI8N0t/dHCfA0w=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=YwWHc5j8aIEKCxJnf1d/UWbUWf2zPe8EQGP6U1V2DkLz7NWe3iUdBZ2dklnHcS316pkMbDdg0dN0LzMxQl/6J1Zx3VYY9W9A5en1w3RKZbyI3b1u6KJYui08N5qFVVq1J6OJ5WOkGuT+QwLD5Vf8zEphHnbthBLG9nNp6CfoEdY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=IOxUjVPo; arc=none smtp.client-ip=209.85.214.199
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IOxUjVPo"
Received: by mail-pl1-f199.google.com with SMTP id d9443c01a7336-2cc88e22f92so220369655ad.1
        for <linux-nfs@vger.kernel.org>; Mon, 20 Jul 2026 08:06:35 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1784559994; x=1785164794; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=iEr3VNvmBkqEprXTi3pXlF49HoF9BORq25oSTaK+MZQ=;
        b=IOxUjVPoR4z3ZzWeLtENBcF3FDNb21BqoZg/JjOW32uWsKIC4avYISG1sRgvhDN5BB
         QaGinyrmzOUg3oc2/1kzkEbzNWn4q2RYlnz7A2b62tYXURn5/Xb+3VGVY0QdZYtM0574
         QuybZtx+9t57FCGCVjwRWKELNS8nsf2D5LxyFPJdRZ7zWkK4Yxf1ZcYsXVVe5KX5TYg8
         XQ2AyIUosZKeD6HT7LOTdVSfQru+5Dmdk9v9aX87DfBECtyRA4eCR7YDcKhZOhpHBh8f
         cZWc9ujpPMXzHua2iwx1q5mOmFAkuUz2aux2DlT1SNMwbU8YnS8+AQ1KU5hvfauIEWE4
         TGpg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784559994; x=1785164794;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=iEr3VNvmBkqEprXTi3pXlF49HoF9BORq25oSTaK+MZQ=;
        b=BOkex8bauev7YWuJqP+rm/Ga6oLb7W8r/FQdI4p92YsWUrnKssL5CRhYxoqTwFNNlt
         s37mO3bkO+ySFE7ZKNpnB2A5khhw+fq7mlzkp/Hw9YwxTlHolH60e8992Hs6i4qz+t4H
         pIDKLvQlfYzo1aqu+oIfDcuvKye1qD9xFzK1RbTmpCrz6wu17tib0AbrKpvjkWhMBwvM
         Rxjot+2oT/IG/7G1C0LiTYn86tDNXCuUgmMSKpiUW2E9BI2fsU2ttSI3TJXnBLH76ID4
         kmpqnNc3Yiy41URXXI4lglUK4sE/Kv911KTfjgOgrUPEwEjPOwRV2pD+sRHzmKXgRMXG
         xdXw==
X-Gm-Message-State: AOJu0YxkkqEiDh1k/e9vdB2fEu4OgMXyBcRDcCv3Wrrh2xmDmqNxm9t7
	BehZHueVPg6+aDz3iEiKSgxjE8AvyubsYFRdDVfYPV4OOPWzEGPSl8omadDt9vl5ndPv357Gov0
	w3LtLOap6U+tSEM1vqDL85Mv12fGEbbytbB29shZtZv+MRXQhqc3/GURS3M9lGFM4mdYWtaGfuI
	C7i/WZpBKu7J00Vi7LEeBPzhUZV7C3MaWdKbI=
X-Received: from plot12.prod.google.com ([2002:a17:902:8c8c:b0:2ce:9c0d:171f])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:902:dad0:b0:2c9:97a8:afe5
 with SMTP id d9443c01a7336-2cf349eee08mr154630795ad.40.1784559993879; Mon, 20
 Jul 2026 08:06:33 -0700 (PDT)
Date: Mon, 20 Jul 2026 15:05:59 +0000
In-Reply-To: <20260720150601.2702700-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260720150601.2702700-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.229.g6434b31f56-goog
Message-ID: <20260720150601.2702700-4-praan@google.com>
Subject: [PATCH v4 3/5] nfs: introduce nfs_release_request_list helper
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, linux-kernel@vger.kernel.org, 
	Christoph Hellwig <hch@lst.de>, Logan Gunthorpe <logang@deltatee.com>, Jason Gunthorpe <jgg@ziepe.ca>, 
	linux-pci@vger.kernel.org, linux-rdma@vger.kernel.org, 
	Shivaji Kant <shivajikant@google.com>, Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Introduce a centralized helper, nfs_release_request_list, to handle
the bulk release of nfs_page requests from a list.

This serves as a preparatory step for two upcoming improvements:

   1. Pin-Aware Cleanup: As we migrate to iov_iter_extract_* API,
      requests will hold pins (GUP) instead of standard references. The
      helper ensures that the correct unpinning logic gets applied
      consistently across all requests in a list.

   2. Folio Support: In subsequent patches where nfs_page structures
      will cover multi-page folios, this helper provides a clean
      infrastructure to unlock these larger units of I/O in bulk during
      completion, similar to the pattern in bio_release_pages.

Additionally, refactor nfs_read_sync_pgio_error() to utilize this new
helper.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
Reviewed-by: Shivaji Kant <shivajikant@google.com>
---
 fs/nfs/direct.c          |  8 +-------
 fs/nfs/pagelist.c        | 17 +++++++++++++++++
 include/linux/nfs_page.h |  4 ++--
 3 files changed, 20 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 19792a38c924..96995736fac2 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -314,13 +314,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 
 static void nfs_read_sync_pgio_error(struct list_head *head, int error)
 {
-	struct nfs_page *req;
-
-	while (!list_empty(head)) {
-		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_release_request(req);
-	}
+	nfs_release_request_list(head);
 }
 
 static void nfs_direct_pgio_init(struct nfs_pgio_header *hdr)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index c307daf5f68d..80fb553528d9 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -624,6 +624,23 @@ void nfs_release_request(struct nfs_page *req)
 }
 EXPORT_SYMBOL_GPL(nfs_release_request);
 
+/*
+ * nfs_release_request_list - Release a list of NFS read/write requests
+ * @head: list of requests to release
+ *
+ * Removes each request from the list and drops it's refcount.
+ */
+void nfs_release_request_list(struct list_head *head)
+{
+	while (!list_empty(head)) {
+		struct nfs_page *req = nfs_list_entry(head->next);
+
+		nfs_list_remove_request(req);
+		nfs_release_request(req);
+	}
+}
+EXPORT_SYMBOL_GPL(nfs_release_request_list);
+
 /*
  * nfs_generic_pg_test - determine if requests can be coalesced
  * @desc: pointer to descriptor
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 080fa3e23580..c38e4b380be5 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -136,8 +136,8 @@ extern struct nfs_page *nfs_page_create_from_folio(struct nfs_open_context *ctx,
 						   bool pinned,
 						   unsigned int offset,
 						   unsigned int count);
-extern	void nfs_release_request(struct nfs_page *);
-
+void nfs_release_request(struct nfs_page *req);
+void nfs_release_request_list(struct list_head *head);
 
 extern	void nfs_pageio_init(struct nfs_pageio_descriptor *desc,
 			     struct inode *inode,
-- 
2.55.0.229.g6434b31f56-goog

