Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D2431C433FE
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Dec 2020 14:49:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id A2AFE23609
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Dec 2020 14:49:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733076AbgLIOt3 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Dec 2020 09:49:29 -0500
Received: from mail.kernel.org ([198.145.29.99]:50668 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1733077AbgLIOt3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Dec 2020 09:49:29 -0500
From:   trondmy@kernel.org
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 05/16] SUNRPC: _copy_to/from_pages() now check for zero length
Date:   Wed,  9 Dec 2020 09:47:50 -0500
Message-Id: <20201209144801.700778-6-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201209144801.700778-5-trondmy@kernel.org>
References: <20201209144801.700778-1-trondmy@kernel.org>
 <20201209144801.700778-2-trondmy@kernel.org>
 <20201209144801.700778-3-trondmy@kernel.org>
 <20201209144801.700778-4-trondmy@kernel.org>
 <20201209144801.700778-5-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Clean up callers of _copy_to/from_pages() that still check for a zero
length.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xdr.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index cbf1bccac4fc..196a06d32312 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1624,8 +1624,7 @@ static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigne
 	len -= this_len;
 	obj += this_len;
 	this_len = min_t(unsigned int, len, subbuf->page_len);
-	if (this_len)
-		_copy_from_pages(obj, subbuf->pages, subbuf->page_base, this_len);
+	_copy_from_pages(obj, subbuf->pages, subbuf->page_base, this_len);
 	len -= this_len;
 	obj += this_len;
 	this_len = min_t(unsigned int, len, subbuf->tail[0].iov_len);
@@ -1655,8 +1654,7 @@ static void __write_bytes_to_xdr_buf(struct xdr_buf *subbuf, void *obj, unsigned
 	len -= this_len;
 	obj += this_len;
 	this_len = min_t(unsigned int, len, subbuf->page_len);
-	if (this_len)
-		_copy_to_pages(subbuf->pages, subbuf->page_base, obj, this_len);
+	_copy_to_pages(subbuf->pages, subbuf->page_base, obj, this_len);
 	len -= this_len;
 	obj += this_len;
 	this_len = min_t(unsigned int, len, subbuf->tail[0].iov_len);
-- 
2.29.2

