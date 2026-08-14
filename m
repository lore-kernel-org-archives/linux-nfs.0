Received: from mail-pj1-f71.google.com (mail-pj1-f71.google.com [209.85.216.71])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 59E8947607A
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:33:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.216.71
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786717990; cv=none; b=AA3CsFVyGFncMwXcY7YLe8oTqXa5riKW3lfKiTOUdFMVtYF3fga2qsTQCmtSsYPrUHUwZlJRHHxrt3kKzi0uIlsoobDtIzcs1BpT+AYHi4c5pM0iNLOSgNoNY9gZ7DXzw88LxxrBx4cKXdhiENc55X8+5Nj8PgwbTYnWA4xWKn8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786717990; c=relaxed/simple;
	bh=u0MKNRKgDVwVPGRV+6Ey10B0Yv0u0Jn1oxVRulYF4u0=;
	h=Date:In-Reply-To:Mime-Version:References:Message-ID:Subject:From:
	 To:Cc:Content-Type; b=VKhNb4FjZaR/g+SlDDQ8/MIuKR8wmc/fOMapbaVXu06e9sXc0i7NxAJq99ceFvDjbmqrXmEHfemswtrvwI2TIS1y/9aRymzYGJNEBdCsBhphOj5N1T+mI0UvywtGHz7kCAl90k0JUfmqX370Ts3l1OEgDGOqRps4OEOzthHsWtA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com; spf=pass smtp.mailfrom=flex--praan.bounces.google.com; dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b=N093Uj+4; arc=none smtp.client-ip=209.85.216.71
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--praan.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="N093Uj+4"
Received: by mail-pj1-f71.google.com with SMTP id 98e67ed59e1d1-38dc085b0a7so1826738a91.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:33:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20251104; t=1786717984; x=1787322784; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=VC79kGoXaLgBrqdL04SZQWwyFvo3s0PHCta3qnTuB/A=;
        b=N093Uj+4IjrFgJc79huP/de34mPTNZp6wxRZ9DEFJTnqjRJineALuS/FHHiZPLoWd8
         zfFczokF79jY7V8jB54JKboRE7DDKpmADkm6/ajUFn3N7HzzZ9urUhIS6Yht7Cki4zkc
         I1mUf6b+efJFVDnAU1Mpqg04wFeYxBgjepKBkamOImCTUW9uidUVhDOpcJTHpG4uh1u0
         kBVITEOkIeNl4J3IwxXYVcm5XNvKZZ4abheXvzPLb2MT4/pFvNmTkIviHIG0e/9AyvNB
         cYLZzVwedMU0++Y64T7127b+RLpOgd5IJJkdeh49w3yOyhaUwUyqbutp2Ws+5l4KV6TJ
         QYlw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786717984; x=1787322784;
        h=content-type:cc:to:from:subject:message-id:references:mime-version
         :in-reply-to:date:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=VC79kGoXaLgBrqdL04SZQWwyFvo3s0PHCta3qnTuB/A=;
        b=JxbnSwGY61IEq+6uaVZDvKOqBMyQ7w6Inbw0WmY/oxnAeLpsS8oCK5uor9MKOUk4aa
         Ge4eIFY+Dkzkyb/TMWpPWeP72QElOKFuCYz2s3ueGKoqf6LVyggHpdD7OaK8yrjKEl+3
         kVSh6ZMq03DrbwgPhSyHW/szVJkAFtspUOryA5i0De6d297AqBVXREyE74X4ytnHjayM
         gPDGerYhRr7yMpRgtVoyBdaQljmJMSn788E82HI0eXksU1lVPSpZT8JYzIG+l0zSnVAu
         jZnRaP/H0C9XHM6jusLPAJhu88o2P9tQ2Vk33/J6+1IPwCqI6FySa3CtB+Y9ZqMPPrdi
         k9Cg==
X-Gm-Message-State: AOJu0YynVvchJtRBBR3kYN1Ybvui7zNNyadLM9NRKx4JP11TLu68rLzV
	A3e8ncEZE/wBEYpj6MPwFu64beEIxREL3Bjx1fqVPsPZLZ2uH+2kWn3o8EZyOEBYdcOkMhLfHPX
	NJn9LdbWz0d5pkjEDpjbNzyyAgCtrekGI1hzDoTlbPnzXfk7x6XsmFF2rgjI3ovH9TXa6hMeGqF
	vd1UfX/36XAK3m0IfHQMss/O80cJ/6X6EF34E=
X-Received: from pjbnl15.prod.google.com ([2002:a17:90b:384f:b0:38f:a3cc:f600])
 (user=praan job=prod-delivery.src-stubby-dispatcher) by 2002:a17:90b:1b47:b0:38e:5964:97a8
 with SMTP id 98e67ed59e1d1-3933e63167amr6649209a91.16.1786717983830; Fri, 14
 Aug 2026 07:33:03 -0700 (PDT)
Date: Fri, 14 Aug 2026 14:32:52 +0000
In-Reply-To: <20260814143255.861084-1-praan@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
Mime-Version: 1.0
References: <20260814143255.861084-1-praan@google.com>
X-Mailer: git-send-email 2.55.0.691.gc56d675ccc-goog
Message-ID: <20260814143255.861084-3-praan@google.com>
Subject: [PATCH v6 2/5] nfs: track number of pinned pages in nfs_page
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
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfs/pagelist.c        | 13 +++++++++----
 include/linux/nfs_page.h |  1 +
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a562cfe2a126..b9ccf2a87e3c 100644
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
@@ -567,8 +572,8 @@ static void nfs_clear_request(struct nfs_page *req)
 
 	if (folio != NULL) {
 		if (test_and_clear_bit(PG_PINNED, &req->wb_flags)) {
-			if (req == req->wb_head)
-				unpin_user_folio(folio, 1);
+			if (req->wb_nr_pinned > 0)
+				unpin_user_folio(folio, req->wb_nr_pinned);
 		} else {
 			folio_put(folio);
 		}
@@ -576,8 +581,8 @@ static void nfs_clear_request(struct nfs_page *req)
 		clear_bit(PG_FOLIO, &req->wb_flags);
 	} else if (page != NULL) {
 		if (test_and_clear_bit(PG_PINNED, &req->wb_flags)) {
-			if (req == req->wb_head)
-				unpin_user_page(page);
+			if (req->wb_nr_pinned > 0)
+				unpin_user_pages(&page, req->wb_nr_pinned);
 		} else {
 			put_page(page);
 		}
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
2.55.0.691.gc56d675ccc-goog

