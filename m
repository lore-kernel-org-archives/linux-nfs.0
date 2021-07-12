Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B74EFC07E99
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 14:52:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 9CC5261166
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Jul 2021 14:52:48 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235151AbhGLOzf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Jul 2021 10:55:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:38696 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231202AbhGLOzf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Jul 2021 10:55:35 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id CA5B96120A
        for <linux-nfs@vger.kernel.org>; Mon, 12 Jul 2021 14:52:46 +0000 (UTC)
Subject: [PATCH RFC 5/7] NFS: Remove unused callback void encoder and decoder
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 12 Jul 2021 10:52:46 -0400
Message-ID: <162610156611.2466.756413495359030925.stgit@klimt.1015granger.net>
In-Reply-To: <162610122257.2466.7452891285800059767.stgit@klimt.1015granger.net>
References: <162610122257.2466.7452891285800059767.stgit@klimt.1015granger.net>
User-Agent: StGit/1.1
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up: The callback RPC dispatcher no longer invokes these call
outs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/callback_xdr.c |   13 -------------
 1 file changed, 13 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 34cb84174196..c72f46e2857a 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -63,16 +63,6 @@ static __be32 nfs4_callback_null(struct svc_rqst *rqstp)
 	return htonl(NFS4_OK);
 }
 
-static int nfs4_decode_void(struct svc_rqst *rqstp, __be32 *p)
-{
-	return xdr_argsize_check(rqstp, p);
-}
-
-static int nfs4_encode_void(struct svc_rqst *rqstp, __be32 *p)
-{
-	return xdr_ressize_check(rqstp, p);
-}
-
 static __be32 decode_string(struct xdr_stream *xdr, unsigned int *len,
 		const char **str, size_t maxlen)
 {
@@ -1067,14 +1057,11 @@ static struct callback_op callback_ops[] = {
 static const struct svc_procedure nfs4_callback_procedures1[] = {
 	[CB_NULL] = {
 		.pc_func = nfs4_callback_null,
-		.pc_decode = nfs4_decode_void,
-		.pc_encode = nfs4_encode_void,
 		.pc_xdrressize = 1,
 		.pc_name = "NULL",
 	},
 	[CB_COMPOUND] = {
 		.pc_func = nfs4_callback_compound,
-		.pc_encode = nfs4_encode_void,
 		.pc_argsize = 256,
 		.pc_ressize = 256,
 		.pc_xdrressize = NFS4_CALLBACK_BUFSIZE,


