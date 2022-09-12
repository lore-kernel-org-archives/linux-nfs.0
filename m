Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FD63C6FA83
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Sep 2022 21:23:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229765AbiILVXm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Sep 2022 17:23:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52614 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229767AbiILVXj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2022 17:23:39 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 92C104B0E7
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 14:23:38 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id EEE396124A
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:23:37 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 60314C433D6
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:23:37 +0000 (UTC)
Subject: [PATCH v1 12/12] NFSD: Pack struct nfsd4_compoundres
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 12 Sep 2022 17:23:36 -0400
Message-ID: <166301781661.89884.929657087786529361.stgit@oracle-102.nfsv4.dev>
In-Reply-To: <166301759113.89884.7985359396842428444.stgit@oracle-102.nfsv4.dev>
References: <166301759113.89884.7985359396842428444.stgit@oracle-102.nfsv4.dev>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Remove a couple of 4-byte holes on platforms with 64-bit pointers.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/xdr4.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b2bc85421b50..0eb00105d845 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -732,8 +732,8 @@ struct nfsd4_compoundres {
 	struct svc_rqst *		rqstp;
 
 	__be32				*statusp;
-	u32				taglen;
 	char *				tag;
+	u32				taglen;
 	u32				opcnt;
 
 	struct nfsd4_compound_state	cstate;


