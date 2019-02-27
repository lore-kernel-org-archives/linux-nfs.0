Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07361C00319
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D474D20863
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730483AbfB0OwC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 09:52:02 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:46675 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726590AbfB0OwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 09:52:02 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 5552C604E3BCC;
        Wed, 27 Feb 2019 15:52:00 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 1/4] nfs: Fix copy-and-paste error in debug message
Date:   Wed, 27 Feb 2019 15:51:27 +0100
Message-Id: <20190227145130.22323-2-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190227145130.22323-1-buczek@molgen.mpg.de>
References: <20190227145130.22323-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The debug message of decode_attr_lease_time incorrectly
says "file size". Fix it to "lease time".

Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2fc8f6fa25e4..34adaa899a8c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3471,7 +3471,7 @@ static int decode_attr_lease_time(struct xdr_stream *xdr, uint32_t *bitmap, uint
 		*res = be32_to_cpup(p);
 		bitmap[0] &= ~FATTR4_WORD0_LEASE_TIME;
 	}
-	dprintk("%s: file size=%u\n", __func__, (unsigned int)*res);
+	dprintk("%s: lease time=%u\n", __func__, (unsigned int)*res);
 	return 0;
 out_overflow:
 	print_overflow_msg(__func__, xdr);
-- 
2.21.0

