Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D22B6285056
	for <linux-nfs@vger.kernel.org>; Thu, 26 Feb 2026 14:47:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772117263; cv=none; b=tWgqmVwZ8mfVkW/o4NbqfqtDtXsYBgWxCfrddpL1ftsb9bv3GiMRDY9knLIhdN04J3zuLyOB+aW+i3Qgn5BdnMrH09pMpCwDzpc0XFg3/a2ScWnQjdUYWQZA3CEkMGhdvcgLJTUpIyqpAPNDU3tWHU4MGoDtm7iI9DV8Ibi4E+I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772117263; c=relaxed/simple;
	bh=c+hhMtJic2Edu145pCNRlSHdjtkb5bWjz/1Qkx4cTjU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jAzoqRSurHqIeiaNX1j065pF1OaGSNn6eDePdOgTGJnfz/usjoFEKsC1XV+Cv5Tmw6/nwULKEmrnkHDOw+fqZU3YtGyLanZ1YpZ+f6jQn+ihyuc2sQg45SvbpA9LOlIEsNZGmJc8O4AlWemvBlPyBjbuE/Pqzap4zVEuHHn5xJY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=V6YlyreZ; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="V6YlyreZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5EA1C19422;
	Thu, 26 Feb 2026 14:47:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772117263;
	bh=c+hhMtJic2Edu145pCNRlSHdjtkb5bWjz/1Qkx4cTjU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=V6YlyreZ2SS3uZEHzNxJMszXL+eKspHahrWDqiqviUAURl3tKhRkaZZ2GAS1bwSCJ
	 780pQ3GjFj7jdbhV4YP/BhRVqIhw3MMNp8f1ZeLmTS51VSgPEzdOcnefBC16uxNUJ0
	 LVUTQk4n1H3qprmvcgzfDyeVfEzTvf24krnUN3LyWC03lVOJLRWkOszBcmNh2p7iJN
	 Ik75133ZvKmli1N6gbnY4PT5EMZ9gB5CgOm3bOoWQp8LtMmC+oUS7YaeSViQUBezay
	 7/uzhFuQXRJdqEFuo5dsaB8mq1cMfyM7Fyg5npDEB3kfailwidbqCtx2MelT+v34HS
	 c6lqsOWFbKNgg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 1/6] SUNRPC: Tighten bounds checking in svc_rqst_replace_page
Date: Thu, 26 Feb 2026 09:47:34 -0500
Message-ID: <20260226144739.193129-2-cel@kernel.org>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260226144739.193129-1-cel@kernel.org>
References: <20260226144739.193129-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

svc_rqst_replace_page() builds the Reply buffer by advancing
rq_next_page through the response page range. The bounds
check validates rq_next_page against the full rq_pages array,
but the valid range for rq_next_page is

  [rq_respages, rq_page_end].

Use those bounds instead.

This is correct today because rq_respages and rq_page_end
both point into rq_pages, and it prepares for a subsequent
change that separates the Reply page array from rq_pages.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index d8ccb8e4b5c2..f7ec02457328 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -934,11 +934,11 @@ svc_set_num_threads(struct svc_serv *serv, unsigned int min_threads,
 EXPORT_SYMBOL_GPL(svc_set_num_threads);
 
 /**
- * svc_rqst_replace_page - Replace one page in rq_pages[]
+ * svc_rqst_replace_page - Replace one page in rq_respages[]
  * @rqstp: svc_rqst with pages to replace
  * @page: replacement page
  *
- * When replacing a page in rq_pages, batch the release of the
+ * When replacing a page in rq_respages, batch the release of the
  * replaced pages to avoid hammering the page allocator.
  *
  * Return values:
@@ -947,8 +947,8 @@ EXPORT_SYMBOL_GPL(svc_set_num_threads);
  */
 bool svc_rqst_replace_page(struct svc_rqst *rqstp, struct page *page)
 {
-	struct page **begin = rqstp->rq_pages;
-	struct page **end = &rqstp->rq_pages[rqstp->rq_maxpages];
+	struct page **begin = rqstp->rq_respages;
+	struct page **end = rqstp->rq_page_end;
 
 	if (unlikely(rqstp->rq_next_page < begin || rqstp->rq_next_page > end)) {
 		trace_svc_replace_page_err(rqstp);
-- 
2.53.0

