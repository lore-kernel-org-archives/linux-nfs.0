Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f173.google.com ([209.85.223.173]:41012 "EHLO
	mail-ie0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340AbaJPTiX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:38:23 -0400
Received: by mail-ie0-f173.google.com with SMTP id tp5so4174555ieb.18
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:38:22 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id z131sm3539052iod.32.2014.10.16.12.38.22
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:38:22 -0700 (PDT)
Subject: [PATCH v1 01/16] xprtrdma: Return an errno from
 rpcrdma_register_external()
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:38:21 -0400
Message-ID: <20141016193821.13414.10228.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The RPC/RDMA send_request method and the chunk registration code
expects an errno from the registration function. This allows
the upper layers to distinguish between a recoverable failure
(for example, temporary memory exhaustion) and a hard failure
(for example, a bug in the registration logic).

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 61c4129..6ea2942 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -1918,10 +1918,10 @@ rpcrdma_register_external(struct rpcrdma_mr_seg *seg,
 		break;
 
 	default:
-		return -1;
+		return -EIO;
 	}
 	if (rc)
-		return -1;
+		return rc;
 
 	return nsegs;
 }

