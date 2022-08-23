Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F065C32772
	for <linux-nfs@archiver.kernel.org>; Tue, 23 Aug 2022 21:00:44 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230270AbiHWVAn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 23 Aug 2022 17:00:43 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48722 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230035AbiHWVAh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Aug 2022 17:00:37 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 5559579A75
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2022 14:00:36 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 70812B82185
        for <linux-nfs@vger.kernel.org>; Tue, 23 Aug 2022 21:00:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0A68CC433C1;
        Tue, 23 Aug 2022 21:00:33 +0000 (UTC)
Subject: [PATCH v1 5/7] NFSD: Clean up WRITE arg decoders
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Tue, 23 Aug 2022 17:00:32 -0400
Message-ID: <166128843291.2788.7684141655548514185.stgit@manet.1015granger.net>
In-Reply-To: <166128840714.2788.7887913547062461761.stgit@manet.1015granger.net>
References: <166128840714.2788.7887913547062461761.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

xdr_stream_subsegment() already returns a boolean value.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs3xdr.c |    4 +---
 fs/nfsd/nfsxdr.c  |    4 +---
 2 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 71e32cf28885..3308dd671ef0 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -571,10 +571,8 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		args->count = max_blocksize;
 		args->len = max_blocksize;
 	}
-	if (!xdr_stream_subsegment(xdr, &args->payload, args->count))
-		return false;
 
-	return true;
+	return xdr_stream_subsegment(xdr, &args->payload, args->count);
 }
 
 bool
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index aba8520b4b8b..caf6355b18fa 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -338,10 +338,8 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 		return false;
 	if (args->len > NFSSVC_MAXBLKSIZE_V2)
 		return false;
-	if (!xdr_stream_subsegment(xdr, &args->payload, args->len))
-		return false;
 
-	return true;
+	return xdr_stream_subsegment(xdr, &args->payload, args->len);
 }
 
 bool


