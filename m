Return-Path: <SRS0=Vlol=SS=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 926CCC10F13
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:36:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6316221841
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Apr 2019 13:36:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="UwMRlmVw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726837AbfDPNg7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Apr 2019 09:36:59 -0400
Received: from mail-io1-f66.google.com ([209.85.166.66]:45836 "EHLO
        mail-io1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726576AbfDPNg6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Apr 2019 09:36:58 -0400
Received: by mail-io1-f66.google.com with SMTP id s7so17596292iom.12;
        Tue, 16 Apr 2019 06:36:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=UwMRlmVw5we9KlEjzAprDXMMw98l19puDMb5+JOfK7NR8/1BqQgXmEK+lnDYwlSg36
         GtOFJ4g9J+9jThrcGHt37fKdv0NFkNIyzyx7fvFK6FQfbxHfAtDMFgen3ONg4e+YfQd7
         TEccy+HZEuZFmIL4yOC3Di9y1o8wmh4n595QvIYwd5/DZbPnSWpRvlTxVIRUItk7cW7b
         a4FeGgN15HOjoI/wl6coHuQhwpGOm8Jgl3ZCflnb3LkDpZ8dU8bQnc7LdDg/Y/yysVow
         zPW9WGEj4Cj1WyEClkMiZN8o5/MUOQ1uN6vDc2EhP2zxTIsE1gn0U5AshycUZPC0ePz5
         mrhA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=WHZ+h/q/YGUHYxMZ5j/Bf+5zZq+eqcPhO1i86doUWqA=;
        b=D0kHtojpi69O7R0loMAzAbMwEiXmEPjrndlrOW//W3aEW87N43GAxSvLieDhIGKBPq
         Wz3c/TLcOMfPo33+F08jw3C3a5cauqxriIvSyLkvSwhoTgdn9YKhfScx0asVncyyF5PE
         62/lgfYMBLAGV2ZG9+io9CGkjbV0aZRhzVmKuV6dzG9uzvm45XhXvVFEMupB22n/SB7t
         aRHCyjynZt+VxL6BI+R729LEC0gOq8Wugm+dYqxvDDYAyDWE0NKlhcY6Xapw8h0ickwT
         oOiZ2yZRQ0Q41OYKVJ+HlVgiBIlZoSZpgvc/qtAApDQ3GZE59y+0H2LIR9vK+z4aYOSc
         kEZQ==
X-Gm-Message-State: APjAAAWycEH6r/Ss++UNHsan0kMRtBajCBmm3o3swxI5ibklZa201oHx
        MgEMkZKQXZ9a9t/d1O0XNRJ65xuz
X-Google-Smtp-Source: APXvYqzPm0FQrDRo3MWqvdIFy6Y0FLlzdc6qKLaUEzwCowksNYNdfbPffdg49e6SlZLVnuuknSZQvA==
X-Received: by 2002:a5e:8f08:: with SMTP id c8mr4026677iok.102.1555421817712;
        Tue, 16 Apr 2019 06:36:57 -0700 (PDT)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id k11sm9336372itk.25.2019.04.16.06.36.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Apr 2019 06:36:57 -0700 (PDT)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id x3GDaubH021199;
        Tue, 16 Apr 2019 13:36:56 GMT
Subject: [PATCH v2 01/21] SUNRPC: Avoid digging into the ATOMIC pool
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Tue, 16 Apr 2019 09:36:56 -0400
Message-ID: <20190416133656.23113.32435.stgit@manet.1015granger.net>
In-Reply-To: <20190416133156.23113.91846.stgit@manet.1015granger.net>
References: <20190416133156.23113.91846.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Page allocation requests made when the SPARSE_PAGES flag is set are
allowed to fail, and are not critical. No need to spend a rare
resource.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/socklib.c           |    2 +-
 net/sunrpc/xprtrdma/rpc_rdma.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 7e55cfc..9faea12 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -106,7 +106,7 @@ static size_t xdr_skb_read_and_csum_bits(struct xdr_skb_reader *desc, void *to,
 		/* ACL likes to be lazy in allocating pages - ACLs
 		 * are small by default but can get huge. */
 		if ((xdr->flags & XDRBUF_SPARSE_PAGES) && *ppage == NULL) {
-			*ppage = alloc_page(GFP_ATOMIC);
+			*ppage = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (unlikely(*ppage == NULL)) {
 				if (copied == 0)
 					copied = -ENOMEM;
diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index 6c1fb27..b759b16 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -238,7 +238,7 @@ static bool rpcrdma_results_inline(struct rpcrdma_xprt *r_xprt,
 		 */
 		if (unlikely(xdrbuf->flags & XDRBUF_SPARSE_PAGES)) {
 			if (!*ppages)
-				*ppages = alloc_page(GFP_ATOMIC);
+				*ppages = alloc_page(GFP_NOWAIT | __GFP_NOWARN);
 			if (!*ppages)
 				return -ENOBUFS;
 		}

