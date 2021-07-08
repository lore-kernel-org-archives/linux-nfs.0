Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.0 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94499C07E96
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Jul 2021 15:26:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 80BE36144E
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Jul 2021 15:26:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231845AbhGHP3G (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Jul 2021 11:29:06 -0400
Received: from mail.kernel.org ([198.145.29.99]:51116 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231804AbhGHP3F (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 8 Jul 2021 11:29:05 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id BC0876142C;
        Thu,  8 Jul 2021 15:26:23 +0000 (UTC)
Subject: [PATCH v3 1/3] NFSD: Clean up splice actor
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, linux-mm@kvack.org
Cc:     neilb@suse.de
Date:   Thu, 08 Jul 2021 11:26:23 -0400
Message-ID: <162575798303.2532.14679105103126974177.stgit@klimt.1015granger.net>
In-Reply-To: <162575623717.2532.8517369487503961860.stgit@klimt.1015granger.net>
References: <162575623717.2532.8517369487503961860.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A few useful observations:

 - The value in @size is never modified.

 - splice_desc.len is an unsigned int, and so is xdr_buf.page_len.
   An implicit cast to size_t is unnecessary.

 - The computation of .page_len is the same in all three arms
   of the "if" statement, so hoist it out to make it clear that
   the operation is an unconditional invariant.

The resulting function is 18 bytes shorter on my system (-Os).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/vfs.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 15adf1f6ab21..da5340dc0203 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -847,26 +847,21 @@ nfsd_splice_actor(struct pipe_inode_info *pipe, struct pipe_buffer *buf,
 	struct svc_rqst *rqstp = sd->u.data;
 	struct page **pp = rqstp->rq_next_page;
 	struct page *page = buf->page;
-	size_t size;
-
-	size = sd->len;
 
 	if (rqstp->rq_res.page_len == 0) {
 		get_page(page);
 		put_page(*rqstp->rq_next_page);
 		*(rqstp->rq_next_page++) = page;
 		rqstp->rq_res.page_base = buf->offset;
-		rqstp->rq_res.page_len = size;
 	} else if (page != pp[-1]) {
 		get_page(page);
 		if (*rqstp->rq_next_page)
 			put_page(*rqstp->rq_next_page);
 		*(rqstp->rq_next_page++) = page;
-		rqstp->rq_res.page_len += size;
-	} else
-		rqstp->rq_res.page_len += size;
+	}
+	rqstp->rq_res.page_len += sd->len;
 
-	return size;
+	return sd->len;
 }
 
 static int nfsd_direct_splice_actor(struct pipe_inode_info *pipe,


