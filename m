Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CADEDECAAA2
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Aug 2022 18:51:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229547AbiH1SvD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Aug 2022 14:51:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37342 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229939AbiH1SvD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2022 14:51:03 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 59F0D101CE
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 11:51:02 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id E553360DED
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 18:51:01 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3169CC433D6;
        Sun, 28 Aug 2022 18:51:01 +0000 (UTC)
Subject: [PATCH v2 7/7] NFSD: Clean up nfs4svc_encode_compoundres()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 28 Aug 2022 14:51:00 -0400
Message-ID: <166171266025.21449.2692376100575745686.stgit@manet.1015granger.net>
In-Reply-To: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
References: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In today's Linux NFS server implementation, the NFS dispatcher
initializes each XDR result stream, and the NFSv4 .pc_func and
.pc_encode methods all use xdr_stream-based encoding. This keeps
rq_res.len automatically updated. There is no longer a need for
the WARN_ON_ONCE() check in nfs4svc_encode_compoundres().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1e9690a061ec..af51e2a8ceb7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5423,12 +5423,8 @@ bool
 nfs4svc_encode_compoundres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 {
 	struct nfsd4_compoundres *resp = rqstp->rq_resp;
-	struct xdr_buf *buf = xdr->buf;
 	__be32 *p;
 
-	WARN_ON_ONCE(buf->len != buf->head[0].iov_len + buf->page_len +
-				 buf->tail[0].iov_len);
-
 	/*
 	 * Send buffer space for the following items is reserved
 	 * at the top of nfsd4_proc_compound().


