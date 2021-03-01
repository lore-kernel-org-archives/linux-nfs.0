Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-13.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E8E9AC4332B
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 15:19:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id CC1A264E04
	for <linux-nfs@archiver.kernel.org>; Mon,  1 Mar 2021 15:19:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237042AbhCAPTl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 1 Mar 2021 10:19:41 -0500
Received: from mail.kernel.org ([198.145.29.99]:41522 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S237044AbhCAPTh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 1 Mar 2021 10:19:37 -0500
Received: by mail.kernel.org (Postfix) with ESMTPSA id 2253164E01
        for <linux-nfs@vger.kernel.org>; Mon,  1 Mar 2021 15:18:56 +0000 (UTC)
Subject: [PATCH v1 36/42] NFSD: Update the NFSv2 SETACL result encoder to use
 struct xdr_stream
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 01 Mar 2021 10:18:55 -0500
Message-ID: <161461193540.8508.1354993347803383125.stgit@klimt.1015granger.net>
In-Reply-To: <161461145466.8508.13379815439337754427.stgit@klimt.1015granger.net>
References: <161461145466.8508.13379815439337754427.stgit@klimt.1015granger.net>
User-Agent: StGit/1.0-5-g755c
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The SETACL result encoder is exactly the same as the NFSv2
attrstatres decoder.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs2acl.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 4a15ae6fdbc2..9c572ffa5e7b 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -365,8 +365,8 @@ static const struct svc_procedure nfsd_acl_procedures2[5] = {
 	[ACLPROC2_SETACL] = {
 		.pc_func = nfsacld_proc_setacl,
 		.pc_decode = nfsaclsvc_decode_setaclargs,
-		.pc_encode = nfsaclsvc_encode_attrstatres,
-		.pc_release = nfsaclsvc_release_attrstat,
+		.pc_encode = nfssvc_encode_attrstatres,
+		.pc_release = nfssvc_release_attrstat,
 		.pc_argsize = sizeof(struct nfsd3_setaclargs),
 		.pc_ressize = sizeof(struct nfsd_attrstat),
 		.pc_cachetype = RC_NOCACHE,


