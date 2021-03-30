Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D5891C433F2
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B3F3361985
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Mar 2021 00:19:52 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230223AbhC3ATQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Mar 2021 20:19:16 -0400
Received: from mail.kernel.org ([198.145.29.99]:50406 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S230214AbhC3ASr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 29 Mar 2021 20:18:47 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id D597960C41
        for <linux-nfs@vger.kernel.org>; Tue, 30 Mar 2021 00:18:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1617063527;
        bh=q48Ky1nmUGHIcEwWxnjWjx302h1CqIWJtkjhILW9cRg=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=pHNy4rXfP9AD6nb4CpOFHWRw7O4CxFEYEVvFjUsnoLgt4n8fVf/lPXcDVUdCoL4Fb
         Xo4d4Qgtpo3DaBqFduDET6Q6QTBg3Px3iiMB4WQQrJfY7BdLTyf0uRfDo9GE+f1hiI
         qkIYMU6KcoJMuDgx9J41Y7Uizn2idP0wesmDBWqG4JNbB3XkoRowm7D7AY6z58nD3a
         yZRUKSINGZ+H99QZ5lo6BFaEl9iRsQ+aNYMLG+IPvGy4MBZj7EU4G9058jPxwxYv0I
         bdEmV9Jp9Q90OBc5prxbC/hcxzXYL2E0QLcGuQtrqUWdyP5D/uD4XUbM+i3yqqoxpN
         VieyOTFxMIcRQ==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 15/17] NFSv4: Fix value of decode_fsinfo_maxsz
Date:   Mon, 29 Mar 2021 20:18:33 -0400
Message-Id: <20210330001835.41914-16-trondmy@kernel.org>
X-Mailer: git-send-email 2.30.2
In-Reply-To: <20210330001835.41914-15-trondmy@kernel.org>
References: <20210330001835.41914-1-trondmy@kernel.org>
 <20210330001835.41914-2-trondmy@kernel.org>
 <20210330001835.41914-3-trondmy@kernel.org>
 <20210330001835.41914-4-trondmy@kernel.org>
 <20210330001835.41914-5-trondmy@kernel.org>
 <20210330001835.41914-6-trondmy@kernel.org>
 <20210330001835.41914-7-trondmy@kernel.org>
 <20210330001835.41914-8-trondmy@kernel.org>
 <20210330001835.41914-9-trondmy@kernel.org>
 <20210330001835.41914-10-trondmy@kernel.org>
 <20210330001835.41914-11-trondmy@kernel.org>
 <20210330001835.41914-12-trondmy@kernel.org>
 <20210330001835.41914-13-trondmy@kernel.org>
 <20210330001835.41914-14-trondmy@kernel.org>
 <20210330001835.41914-15-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

At least two extra fields have been added to fsinfo since this was last
updated.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4xdr.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index ac6b79ee9355..d8a1911dd39e 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -144,7 +144,16 @@ static int decode_layoutget(struct xdr_stream *xdr, struct rpc_rqst *req,
  * layout types will be returned.
  */
 #define decode_fsinfo_maxsz	(op_decode_hdr_maxsz + \
-				 nfs4_fattr_bitmap_maxsz + 4 + 8 + 5)
+				 nfs4_fattr_bitmap_maxsz + 1 + \
+				 1 /* lease time */ + \
+				 2 /* max filesize */ + \
+				 2 /* max read */ + \
+				 2 /* max write */ + \
+				 nfstime4_maxsz /* time delta */ + \
+				 5 /* fs layout types */ + \
+				 1 /* layout blksize */ + \
+				 1 /* clone blksize */ + \
+				 1 /* xattr support */)
 #define encode_renew_maxsz	(op_encode_hdr_maxsz + 3)
 #define decode_renew_maxsz	(op_decode_hdr_maxsz)
 #define encode_setclientid_maxsz \
-- 
2.30.2

