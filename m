Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85F44C433FE
	for <linux-nfs@archiver.kernel.org>; Sat,  8 Oct 2022 19:00:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229695AbiJHTAJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 8 Oct 2022 15:00:09 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:44006 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229761AbiJHS7r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Oct 2022 14:59:47 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B572025F3
        for <linux-nfs@vger.kernel.org>; Sat,  8 Oct 2022 11:58:33 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 622E2B80BA9
        for <linux-nfs@vger.kernel.org>; Sat,  8 Oct 2022 18:58:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E4DA1C433C1;
        Sat,  8 Oct 2022 18:58:30 +0000 (UTC)
Subject: [PATCH] SUNRPC: Fix crasher in gss_unwrap_resp_integ()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Date:   Sat, 08 Oct 2022 14:58:29 -0400
Message-ID: <166525550985.1954655.13884581337321315995.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If a zero length is passed to kmalloc() it returns 0x10, which is
not a valid address. gss_unwrap_resp_integ() subsequently crashes
when it attempts to dereference that pointer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/auth_gss.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index a31a27816cc0..7bb247c51e2f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1989,7 +1989,7 @@ gss_unwrap_resp_integ(struct rpc_task *task, struct rpc_cred *cred,
 		goto unwrap_failed;
 	mic.len = len;
 	mic.data = kmalloc(len, GFP_KERNEL);
-	if (!mic.data)
+	if (ZERO_OR_NULL_PTR(mic.data))
 		goto unwrap_failed;
 	if (read_bytes_from_xdr_buf(rcv_buf, offset, mic.data, mic.len))
 		goto unwrap_failed;


