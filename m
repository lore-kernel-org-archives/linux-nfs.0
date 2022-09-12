Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A86DC6FA86
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Sep 2022 21:23:37 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229771AbiILVXf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Sep 2022 17:23:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52514 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229768AbiILVXd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2022 17:23:33 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 471EE2AC65
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 14:23:33 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 3A0AB61297
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:23:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9C776C433D7
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:23:31 +0000 (UTC)
Subject: [PATCH v1 11/12] NFSD: Remove unused nfsd4_compoundargs::cachetype
 field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 12 Sep 2022 17:23:30 -0400
Message-ID: <166301781087.89884.14388516757829822205.stgit@oracle-102.nfsv4.dev>
In-Reply-To: <166301759113.89884.7985359396842428444.stgit@oracle-102.nfsv4.dev>
References: <166301759113.89884.7985359396842428444.stgit@oracle-102.nfsv4.dev>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This field was added by commit 1091006c5eb1 ("nfsd: turn on reply
cache for NFSv4") but was never put to use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/xdr4.h |    1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 7fcbc7a46c15..b2bc85421b50 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -724,7 +724,6 @@ struct nfsd4_compoundargs {
 	u32				opcnt;
 	struct nfsd4_op			*ops;
 	struct nfsd4_op			iops[8];
-	int				cachetype;
 };
 
 struct nfsd4_compoundres {


