Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA699C32772
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Aug 2022 21:00:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231373AbiHWVAs (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Aug 2022 17:00:48 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48660 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229955AbiHWVAl (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2022 17:00:41 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 6CE2F49B7A
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2022 14:00:41 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 089656159D
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2022 21:00:41 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E85AC433D6;
        Tue, 23 Aug 2022 21:00:40 +0000 (UTC)
Subject: [PATCH v1 6/7] SUNRPC: Clean up xdr_buf_subsegment's kdoc comment
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Tue, 23 Aug 2022 17:00:39 -0400
Message-ID: <166128843940.2788.14690289839086531152.stgit@manet.1015granger.net>
In-Reply-To: <166128840714.2788.7887913547062461761.stgit@manet.1015granger.net>
References: <166128840714.2788.7887913547062461761.stgit@manet.1015granger.net>
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


