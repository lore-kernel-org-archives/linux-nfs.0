Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:35455 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbbKXXLz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 18:11:55 -0500
From: Colin King <colin.king@canonical.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        "David S . Miller" <davem@davemloft.net>,
        Chuck Lever <chuck.lever@oracle.com>,
        Sagi Grimberg <sagig@mellanox.com>,
        Steve Wise <swise@opengridcomputing.com>,
        Doug Ledford <dledford@redhat.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] xprtrdma: add missing curly braces, set rc to zero on non-zero
Date: Tue, 24 Nov 2015 23:11:41 +0000
Message-Id: <1448406701-12474-1-git-send-email-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

Add the missing curly braces so that rc is only set to zero when
it is non-zero.  Without this minor fix, rc is set to zero even
when it is zero, which is slightly redundant.

Detected with smatch static analysis.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 net/sunrpc/xprtrdma/verbs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index eadd1655..2cc1014 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -852,10 +852,11 @@ retry:
 
 		if (extras) {
 			rc = rpcrdma_ep_post_extra_recv(r_xprt, extras);
-			if (rc)
+			if (rc) {
 				pr_warn("%s: rpcrdma_ep_post_extra_recv: %i\n",
 					__func__, rc);
 				rc = 0;
+			}
 		}
 	}
 
-- 
2.6.2

