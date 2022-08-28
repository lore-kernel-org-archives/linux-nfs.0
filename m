Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3262BECAAD5
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Aug 2022 18:51:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230028AbiH1SvA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Aug 2022 14:51:00 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37234 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230073AbiH1Su6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2022 14:50:58 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 96E06E0A6
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 11:50:57 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 52B9FB80B87
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 18:50:56 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E43EFC433D6;
        Sun, 28 Aug 2022 18:50:54 +0000 (UTC)
Subject: [PATCH v2 6/7] SUNRPC: Fix typo in xdr_buf_subsegment's kdoc comment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 28 Aug 2022 14:50:54 -0400
Message-ID: <166171265398.21449.11749625023129698282.stgit@manet.1015granger.net>
In-Reply-To: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
References: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 482586c23fdd..8ad637ca703e 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -1575,7 +1575,7 @@ EXPORT_SYMBOL_GPL(xdr_buf_from_iov);
  *
  * @buf and @subbuf may be pointers to the same struct xdr_buf.
  *
- * Returns -1 if base of length are out of bounds.
+ * Returns -1 if base or length are out of bounds.
  */
 int xdr_buf_subsegment(const struct xdr_buf *buf, struct xdr_buf *subbuf,
 		       unsigned int base, unsigned int len)


