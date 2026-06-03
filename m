Received: from mail-pf1-f201.google.com (mail-pf1-f201.google.com [209.85.210.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 371E937F8BC
	for <linux-nfs@vger.kernel.org>; Wed,  3 Jun 2026 05:30:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780464651; cv=none; b=KhHpHl73b2xiCO8P9MKvxl+hExp4+ozTmx9lcM3ts7HBIZY2dOT8F9qm6TlK/mou/CTW745ZvBCo9SsDLXzb5342l0t123ASOenUu8sjLmN89n3p9moQ/vfQZKPTuihsbBfy6j5ICE1r0goNx1HYmyoJ93AWcbTwGvQ+FBSN4AY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780464651; c=relaxed/simple;
	bh=3uJU8vtiz8KIhmPO16VbFFhKJTkeUhYQ78W5xGMY6PQ=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=UYUr7UIb8Oz+BJGWlVts3XENVOZBVjNcm3UbIAce0AyS1PMIove+2wex8MofzB+nDWnLVLhjZDOqFeY/9cRd/9qcCqG4vRE0GATHkqOP3jb+SI3TBD2E+eRwaAGTn26Np092xfTG43vyNwz4w5ADw2qMZMSg7oxfmP1Q1ODkPQg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=Nu9hwOro; arc=none smtp.client-ip=209.85.210.201
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Nu9hwOro"
Received: by mail-pf1-f201.google.com with SMTP id d2e1a72fcca58-8421ffff8a3so5336332b3a.2
        for <linux-nfs@vger.kernel.org>; Tue, 02 Jun 2026 22:30:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1780464649; x=1781069449; darn=vger.kernel.org;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:from:to:cc:subject:date:message-id:reply-to;
        bh=x6Uqa0WEXeSiOVPV/6N5if1ansZWBVyiMj0eE4epAYA=;
        b=Nu9hwOroBub1aPj9ZoSa/tnIhRnhbYBbMEAn5PUeSCrZor7S4RjQz5FqvVBoaW53bJ
         I7R5loPvjzbngFMGtdwGDeSfW8Zqj4vA3l+rGUlVcGRtfOMOWQkM+K9Hr53dN9vWr/F0
         oW8StZAjPqOpG2WPzQcwhxCX2Q5nhfbrg4Sr4+0DTUq8sJEzKThlxtFQPx8v7IKR5JOB
         TGWZ1YbBeStqzVh8BjLj/UhO4mljDXzFCSzBCrmcxiBPVUySTv2G/e8pk+BIWC1mmP6M
         Htt1elhR5Axi0aFGRhFmh+Pueyn5AlPgW/FgmJDqnVrpwtHYoNtypIBpYhdNLDq7t2FO
         nmBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1780464649; x=1781069449;
        h=cc:to:from:subject:message-id:references:mime-version:in-reply-to
         :date:x-gm-message-state:from:to:cc:subject:date:message-id:reply-to;
        bh=x6Uqa0WEXeSiOVPV/6N5if1ansZWBVyiMj0eE4epAYA=;
        b=GaDzKgB1yyS98mENfhFmXzm9AIIoRsIiOBkwYZg2cXLjxzt68dCt/upXXJY5YNfoCj
         Y90mewXQZoczZ7Ocxu3cg8NjZutZQ3F8xvoou/mZQ5qHMw63fm3sSmjrqpW7n4lZgdWK
         wFmxNtvqiL/kg8j8LHu6fLcOMBWPkSmoD1k45mFudDh94OMblpgT9HRi/s2FTcwdWiMI
         4QNHn0vL6LSZf5vgDPCagtb9Mty0t9qk2s38SecvXk/F9nuZPySy35J+077L30k3RmdH
         6N9NaAuT3KAqV5jMcz2QjSbBOVQQst4LVBm2yn9a83vugLHxcmOYY7qSatIWfyeGilN/
         ws2w==
X-Gm-Message-State: AOJu0YwDrQ79fsevSsaTMqulFmiaSJzYprG1Snuss75dn9+GdeinLNYn
	7LMlR0tI94YGhQS6xbhvHAd6zSX4CRQIDPexfk9aiJh/vPHrgM1IzctayaK3L8Q3SuIwO3ID0Fa
	VAaKY4H6CJnaQzize9eTtTiBSeCIasfM5tQDum6nJSwG80ENwpJT/ITgayKg+NSpxxxxViGBYZd
	4LrX8ckMADa+ksgFUBE7vE/8BjGxCy/+ajAQ8=
X-Received: from pgmh4.prod.google.com ([2002:a63:5744:0:b0:c82:73de:68e2])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a05:6a20:c786:b0:3b4:cd6:891
 with SMTP id adf61e73a8af0-3b49766e89dmr2274598637.20.1780464649190; Tue, 02
 Jun 2026 22:30:49 -0700 (PDT)
Date: Wed,  3 Jun 2026 05:30:32 +0000
In-Reply-To: <20260603053033.3300318-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260603053033.3300318-1-praan@google.com>
X-Mailer: git-send-email 2.54.0.1013.g208068f2d8-goog
Message-ID: <20260603053033.3300318-7-praan@google.com>
Subject: [PATCH v1 6/7] nfs: Optimize direct I/O to use folios for requests
From: Pranjal Shrivastava <praan@google.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, Christoph Hellwig <hch@lst.de>, 
	Christoph Hellwig <hch@infradead.org>, Shivaji Kant <shivajikant@google.com>, 
	Pranjal Shrivastava <praan@google.com>
Content-Type: text/plain; charset="UTF-8"

Optimize nfs_direct_extract_pages() to group contiguous pages from the
same folio into single nfs_page structures. This effectively migrates
NFS Direct I/O from being page-based to being folio-based.

Reduce the number of nfs_page allocations and subsequent iterations
by utilizing nfs_page_create_from_folio() to create aggregated
requests.

Signed-off-by: Pranjal Shrivastava <praan@google.com>
---
 fs/nfs/direct.c | 36 +++++++++++++++++++++++++++++-------
 1 file changed, 29 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 59002c150f23..93e1af9ec36b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -194,23 +194,45 @@ static ssize_t nfs_direct_extract_pages(struct nfs_direct_req *dreq,
 		return result;
 
 	npages = (result + pgbase + PAGE_SIZE - 1) >> PAGE_SHIFT;
-	for (i = 0; i < npages; i++) {
+	for (i = 0; i < npages; ) {
+		unsigned int chunk_len, folio_offset;
+		unsigned int nr_to_add = 1;
 		struct nfs_page *req;
-		unsigned int req_len = min_t(size_t, result - bytes, PAGE_SIZE - pgbase);
+		struct folio *folio;
 
-		req = nfs_page_create_from_page(dreq->ctx, pagevec[i],
-						pinned, pgbase, *pos,
-						req_len);
+		folio = page_folio(pagevec[i]);
+		folio_offset = (folio_page_idx(folio, pagevec[i]) << PAGE_SHIFT) + pgbase;
+		chunk_len = min_t(size_t, result - bytes, PAGE_SIZE - pgbase);
+
+		while (i + nr_to_add < npages) {
+			struct page *next_page = pagevec[i + nr_to_add];
+			struct page *prev_page = pagevec[i + nr_to_add - 1];
+
+			if (page_folio(next_page) != folio ||
+			    next_page != prev_page + 1)
+				break;
+
+			chunk_len += min_t(size_t, result - bytes - chunk_len, PAGE_SIZE);
+			nr_to_add++;
+		}
+
+		req = nfs_page_create_from_folio(dreq->ctx, folio,
+						  pinned, folio_offset,
+						  chunk_len);
 		if (IS_ERR(req)) {
 			if (!bytes)
 				bytes = PTR_ERR(req);
 			break;
 		}
 
+		req->wb_index = *pos >> PAGE_SHIFT;
+		req->wb_offset = *pos;
+
 		list_add_tail(&req->wb_list, list);
 		pgbase = 0;
-		bytes += req_len;
-		*pos += req_len;
+		bytes += chunk_len;
+		*pos += chunk_len;
+		i += nr_to_add;
 	}
 
 	if (i < npages) {
-- 
2.54.0.1013.g208068f2d8-goog

