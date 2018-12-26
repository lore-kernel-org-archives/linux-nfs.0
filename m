Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC747C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 03:24:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B705821720
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 03:24:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umn.edu header.i=@umn.edu header.b="SFCw2GqM"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726906AbeLZDYp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 Dec 2018 22:24:45 -0500
Received: from mta-p8.oit.umn.edu ([134.84.196.208]:54342 "EHLO
        mta-p8.oit.umn.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726011AbeLZDYo (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Dec 2018 22:24:44 -0500
Received: from localhost (unknown [127.0.0.1])
        by mta-p8.oit.umn.edu (Postfix) with ESMTP id 2C494B03
        for <linux-nfs@vger.kernel.org>; Wed, 26 Dec 2018 03:24:43 +0000 (UTC)
X-Virus-Scanned: amavisd-new at umn.edu
Received: from mta-p8.oit.umn.edu ([127.0.0.1])
        by localhost (mta-p8.oit.umn.edu [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id rhpS_GS0FtKS for <linux-nfs@vger.kernel.org>;
        Tue, 25 Dec 2018 21:24:43 -0600 (CST)
Received: from mail-it1-f200.google.com (mail-it1-f200.google.com [209.85.166.200])
        (using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mta-p8.oit.umn.edu (Postfix) with ESMTPS id EEA379BB
        for <linux-nfs@vger.kernel.org>; Tue, 25 Dec 2018 21:24:42 -0600 (CST)
Received: by mail-it1-f200.google.com with SMTP id t143so17572970itc.9
        for <linux-nfs@vger.kernel.org>; Tue, 25 Dec 2018 19:24:42 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umn.edu; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=2q+H2l6fFp4ZdxuUnlhqNB0h89Pka71vAtMO+QvAYpI=;
        b=SFCw2GqMwOZ97jDLlbSiCN17W5d3V0C9QQ41QLWImYgGk3BNtiyM+S3bnI+G7j+pKO
         V4PPMwwgLXfpr4rpBnZwmzfS2bKaZTY+o3/JalwPPZ3sG9I3y8mpJFo2bFb2rnxYFL7N
         ZZLT5MbX+XJAQoq+PZnfz4a5R5HRydg0PE5E4pPBD1zsmBK7XcStE4aa51eCQwTUxPfD
         fEK7wKd286RnJJaqxdE5NOnAbzomXjZg7B7B6FLo/zvUElh3nPiiFmP6WpYfaXW1dBxE
         tgNaMGYRsxThzrpBQrSQc5aFXJphe0JVoaOoKinvB6qR33RvRvd+0LbFaEslSYbEZdhC
         8lMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=2q+H2l6fFp4ZdxuUnlhqNB0h89Pka71vAtMO+QvAYpI=;
        b=jU1LH6sSnwZ4UB8vx3tqa3ABRWruoG2xjrLPj6d0SE61MmBNNs80RqAL4EU2KLs3NR
         4OJpWk1RWFNInnP6Lhbg1z5HanXY3mVm+3/5jdM5tv/gRBBeX5F+JA1BsDIH1Bed515W
         UnMBOG2FjyDyDudmC1px5ccajUWk2mLdCNw5/cOpAH7wG8WTVHrT7qDF4N59jvP+FUPp
         U6LPrFCl4xU0bcry4xdmqM3cMUfc5Mg+U5FszzTGAY5FIm59ShmhWx4SdLxAcFNlJEA6
         zSRUN7DGI77jDVZmkk46KSk0s6IfsM2wqBnJ1klxmmQnskfNcMjccRP3366VZJynnW2Q
         N2Aw==
X-Gm-Message-State: AJcUukeGM2cjo//HKfg/wFEmg/3EqN4aBkWluwhVwpKW5YVxp1OSpjRz
        UskEn/G3l5WNEH45W067Tje2JHVZMHMzri08gqt7X0yG73q0nfT4nCsz8Fh7p0e3BCZaoEr3prO
        m3jGysNBc6cmktP4h7byKFaaw
X-Received: by 2002:a05:660c:34f:: with SMTP id b15mr2966221itl.146.1545794682539;
        Tue, 25 Dec 2018 19:24:42 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4HE61t8ucQ9IGt4wtCx/hrX9MFbRt8n8xTIFiIr41NC489xbtZjPhM7MPDvqXduhaT+j2Qew==
X-Received: by 2002:a05:660c:34f:: with SMTP id b15mr2966208itl.146.1545794682325;
        Tue, 25 Dec 2018 19:24:42 -0800 (PST)
Received: from localhost.localdomain (host-173-230-104-22.mnmigsc.mn.minneapolis.us.clients.pavlovmedia.net. [173.230.104.22])
        by smtp.gmail.com with ESMTPSA id c25sm15500481ioa.86.2018.12.25.19.24.41
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Dec 2018 19:24:41 -0800 (PST)
From:   Kangjie Lu <kjlu@umn.edu>
To:     kjlu@umn.edu
Cc:     pakki001@umn.edu, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc: remove redundant code
Date:   Tue, 25 Dec 2018 21:24:13 -0600
Message-Id: <20181226032415.73064-1-kjlu@umn.edu>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If no bytes to decode, just use "xdr->p" instead of calling
xdr_inline_decode to get it. The fix cleans up the code.

Signed-off-by: Kangjie Lu <kjlu@umn.edu>
---
 net/sunrpc/xprtrdma/rpc_rdma.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 9f53e0240035..2ef86be49bd8 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -1123,7 +1123,6 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 {
 	struct xdr_stream *xdr = &rep->rr_stream;
 	u32 writelist, replychunk, rpclen;
-	char *base;
 
 	/* Decode the chunk lists */
 	if (decode_read_list(xdr))
@@ -1138,10 +1137,9 @@ rpcrdma_decode_msg(struct rpcrdma_xprt *r_xprt, struct rpcrdma_rep *rep,
 		return -EIO;
 
 	/* Build the RPC reply's Payload stream in rqst->rq_rcv_buf */
-	base = (char *)xdr_inline_decode(xdr, 0);
 	rpclen = xdr_stream_remaining(xdr);
 	r_xprt->rx_stats.fixup_copy_count +=
-		rpcrdma_inline_fixup(rqst, base, rpclen, writelist & 3);
+		rpcrdma_inline_fixup(rqst, xdr->p, rpclen, writelist & 3);
 
 	r_xprt->rx_stats.total_rdma_reply += writelist;
 	return rpclen + xdr_align_size(writelist);
-- 
2.17.2 (Apple Git-113)

