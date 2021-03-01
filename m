Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F347C433E0
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 15:18:31 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6603B64E12
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 15:18:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237084AbhCAPSX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Mar 2021 10:18:23 -0500
Received: from mail.kernel.org ([198.145.29.99]:40900 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S237139AbhCAPSB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 1 Mar 2021 10:18:01 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id C48DE64E01
        for <linux-nfs@vger.kernel.org>; Mon,  1 Mar 2021 15:17:13 +0000 (UTC)
Subject: [PATCH v1 19/42] SUNRPC: Fix xdr_get_next_encode_buffer() page
 boundary handling
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 01 Mar 2021 10:17:13 -0500
Message-ID: <161461183307.8508.17196295994390119297.stgit@klimt.1015granger.net>
In-Reply-To: <161461145466.8508.13379815439337754427.stgit@klimt.1015granger.net>
References: <161461145466.8508.13379815439337754427.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The description of commit 2825a7f90753 ("nfsd4: allow encoding
across page boundaries") states:

> Also we can't handle a new operation starting close to the end of
> a page.

But does not detail why this is the case.

Subtracting the scratch buffer's "shift" value from the remaining
stream space seems to make reserving space close to the end of the
buf->pages array reliable.

This change is needed to make entry encoding with struct xdr_stream,
introduced in a subsequent patch, work correctly when it approaches
the end of the dirlist buffer.

Fixes: 2825a7f90753 ("nfsd4: allow encoding across page boundaries")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 3964ff74ee51..043b67229792 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -978,7 +978,7 @@ static __be32 *xdr_get_next_encode_buffer(struct xdr_stream *xdr,
 	 * shifted this one back:
 	 */
 	xdr->p = (void *)p + frag2bytes;
-	space_left = xdr->buf->buflen - xdr->buf->len;
+	space_left = xdr->buf->buflen - xdr->buf->len - frag1bytes;
 	xdr->end = (void *)p + min_t(int, space_left, PAGE_SIZE);
 	xdr->buf->page_len += frag2bytes;
 	xdr->buf->len += nbytes;


