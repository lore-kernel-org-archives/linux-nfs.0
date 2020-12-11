Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.0 required=3.0 tests=BAYES_00,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D7A7C4361B
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 19:08:19 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 2A6CD24057
	for <linux-nfs@archiver.kernel.org>; Fri, 11 Dec 2020 19:08:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2394392AbgLKR0d (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Dec 2020 12:26:33 -0500
Received: from mail.kernel.org ([198.145.29.99]:50690 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2395209AbgLKR0D (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Dec 2020 12:26:03 -0500
From:   trondmy@kernel.org
Authentication-Results: mail.kernel.org; dkim=permerror (bad message/signature format)
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 01/15] SUNRPC: _shift_data_left/right_pages should check the shift length
Date:   Fri, 11 Dec 2020 12:25:07 -0500
Message-Id: <20201211172521.5567-2-trondmy@kernel.org>
X-Mailer: git-send-email 2.29.2
In-Reply-To: <20201211172521.5567-1-trondmy@kernel.org>
References: <20201211172521.5567-1-trondmy@kernel.org>
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
index c852d199c789..5833329c132c 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -225,6 +225,9 @@ _shift_data_left_pages(struct page **pages, size_t pgto_base,
 
 	BUG_ON(pgfrom_base <= pgto_base);
 
+	if (!len)
+		return;
+
 	pgto = pages + (pgto_base >> PAGE_SHIFT);
 	pgfrom = pages + (pgfrom_base >> PAGE_SHIFT);
 
@@ -307,6 +310,9 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 
 	BUG_ON(pgto_base <= pgfrom_base);
 
+	if (!len)
+		return;
+
 	pgto_base += len;
 	pgfrom_base += len;
 
@@ -405,6 +411,9 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 	char *vto;
 	size_t copy;
 
+	if (!len)
+		return;
+
 	pgto = pages + (pgbase >> PAGE_SHIFT);
 	pgbase &= ~PAGE_MASK;
 
@@ -449,6 +458,9 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 	char *vfrom;
 	size_t copy;
 
+	if (!len)
+		return;
+
 	pgfrom = pages + (pgbase >> PAGE_SHIFT);
 	pgbase &= ~PAGE_MASK;
 
-- 
2.29.2

