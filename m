Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:57631 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752853Ab2LDM6u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 07:58:50 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/5] svcrpc: fix off-by-4 error in "incomplete TCP record" dprintk
Date: Tue,  4 Dec 2012 07:58:44 -0500
Message-Id: <1354625926-18527-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1354625926-18527-1-git-send-email-bfields@redhat.com>
References: <1354625926-18527-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The full reclen doesn't include the fragment header, but sk_tcplen does.
Fix this to make it an apples-to-apples comparison.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1557179..1db42b1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1073,7 +1073,8 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		if (len < 0 && len != -EAGAIN)
 			goto err_delete;
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
-			svsk->sk_tcplen, svc_sock_reclen(svsk));
+			svsk->sk_tcplen - sizeof(rpc_fraghdr),
+			svc_sock_reclen(svsk));
 		goto err_noclose;
 	}
 
-- 
1.7.9.5

