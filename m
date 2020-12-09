Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1DA7C433FE
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Dec 2020 14:49:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6E82F233EA
	for <linux-nfs@archiver.kernel.org>; Wed,  9 Dec 2020 14:49:19 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1733075AbgLIOsy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 9 Dec 2020 09:48:54 -0500
Received: from mail.kernel.org ([198.145.29.99]:49204 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1733219AbgLIOsr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 9 Dec 2020 09:48:47 -0500
From:   trondmy@kernel.org
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 01/16] SUNRPC: _shift_data_left/right_pages should check the shift length
Date:   Wed,  9 Dec 2020 09:47:46 -0500
Message-Id: <20201209144801.700778-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201209144801.700778-1-trondmy@kernel.org>
References: <20201209144801.700778-1-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Exit early if the shift is zero.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/xdr.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index f9efc207a7d5..1d48934bdf9e 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -226,6 +226,9 @@ _shift_data_left_pages(struct page **pages, size_t pgto_base,
 
 	BUG_ON(pgfrom_base <= pgto_base);
 
+	if (!len)
+		return;
+
 	pgto = pages + (pgto_base >> PAGE_SHIFT);
 	pgfrom = pages + (pgfrom_base >> PAGE_SHIFT);
 
@@ -308,6 +311,9 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 
 	BUG_ON(pgto_base <= pgfrom_base);
 
+	if (!len)
+		return;
+
 	pgto_base += len;
 	pgfrom_base += len;
 
@@ -406,6 +412,9 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 	char *vto;
 	size_t copy;
 
+	if (!len)
+		return;
+
 	pgto = pages + (pgbase >> PAGE_SHIFT);
 	pgbase &= ~PAGE_MASK;
 
@@ -450,6 +459,9 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 	char *vfrom;
 	size_t copy;
 
+	if (!len)
+		return;
+
 	pgfrom = pages + (pgbase >> PAGE_SHIFT);
 	pgbase &= ~PAGE_MASK;
 
-- 
2.29.2

