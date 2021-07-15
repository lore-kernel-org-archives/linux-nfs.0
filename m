Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 99BB6C636C9
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Jul 2021 19:55:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 81C68613C0
	for <linux-nfs@archiver.kernel.org>; Thu, 15 Jul 2021 19:55:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S241582AbhGOT6E (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 15 Jul 2021 15:58:04 -0400
Received: from mail.kernel.org ([198.145.29.99]:46458 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S244428AbhGOT4C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 15 Jul 2021 15:56:02 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id BE66761380;
        Thu, 15 Jul 2021 19:52:25 +0000 (UTC)
Subject: [PATCH v2 4/7] NFS: Add a private local dispatcher for NFSv4 callback
 operations
From:   Chuck Lever <chuck.lever@oracle.com>
To:     trondmy@hammerspace.com
Cc:     linux-nfs@vger.kernel.org
Date:   Thu, 15 Jul 2021 15:52:25 -0400
Message-ID: <162637874506.728653.1633959557885214141.stgit@manet.1015granger.net>
In-Reply-To: <162637843471.728653.5920517086867549998.stgit@manet.1015granger.net>
References: <162637843471.728653.5920517086867549998.stgit@manet.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The client's NFSv4 callback service is the only remaining user of
svc_generic_dispatch().

Note that the NFSv4 callback service doesn't use the .pc_encode and
.pc_decode callouts in any substantial way, so they are removed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/callback_xdr.c |   13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 7ff99155b023..e30374e363a6 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -992,6 +992,15 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
+static int
+nfs_callback_dispatch(struct svc_rqst *rqstp, __be32 *statp)
+{
+	const struct svc_procedure *procp = rqstp->rq_procinfo;
+
+	*statp = procp->pc_func(rqstp);
+	return 1;
+}
+
 /*
  * Define NFS4 callback COMPOUND ops.
  */
@@ -1080,7 +1089,7 @@ const struct svc_version nfs4_callback_version1 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_count = nfs4_callback_count1,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
-	.vs_dispatch = NULL,
+	.vs_dispatch = nfs_callback_dispatch,
 	.vs_hidden = true,
 	.vs_need_cong_ctrl = true,
 };
@@ -1092,7 +1101,7 @@ const struct svc_version nfs4_callback_version4 = {
 	.vs_proc = nfs4_callback_procedures1,
 	.vs_count = nfs4_callback_count4,
 	.vs_xdrsize = NFS4_CALLBACK_XDRSIZE,
-	.vs_dispatch = NULL,
+	.vs_dispatch = nfs_callback_dispatch,
 	.vs_hidden = true,
 	.vs_need_cong_ctrl = true,
 };


