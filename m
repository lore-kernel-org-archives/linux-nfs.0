Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7113C43334
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jul 2022 19:08:10 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230413AbiGVTIK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Jul 2022 15:08:10 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46648 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229593AbiGVTIJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2022 15:08:09 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7AB9125C66
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 12:08:08 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 3DA30B829B3
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 19:08:07 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CEC0EC341C6;
        Fri, 22 Jul 2022 19:08:05 +0000 (UTC)
Subject: [PATCH v2 1/4] SUNRPC: Fail faster on bad verifier
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com, trondmy@hammerspace.com
Cc:     linux-nfs@vger.kernel.org
Date:   Fri, 22 Jul 2022 15:08:04 -0400
Message-ID: <165851688478.2312015.9119100251679837612.stgit@morisot.1015granger.net>
In-Reply-To: <165851677341.2312015.16636288284789960852.stgit@morisot.1015granger.net>
References: <165851677341.2312015.16636288284789960852.stgit@morisot.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A bad verifier is not a garbage argument, it's an authentication
failure. Retrying it doesn't make the problem go away, and delays
upper layer recovery steps.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index b6781ada3aa8..a97d4e06cae3 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -2650,7 +2650,7 @@ rpc_decode_header(struct rpc_task *task, struct xdr_stream *xdr)
 
 out_verifier:
 	trace_rpc_bad_verifier(task);
-	goto out_garbage;
+	goto out_err;
 
 out_msg_denied:
 	error = -EACCES;


