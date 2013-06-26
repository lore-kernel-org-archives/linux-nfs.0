Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35128 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab3FZTVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@vger.kernel.org
Subject: [PATCH 4/7] svcrpc: don't error out on small tcp fragment
Date: Wed, 26 Jun 2013 15:21:24 -0400
Message-Id: <1372274488-4752-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Though clients we care about mostly don't do this, it is possible for
rpc requests to be sent in multiple fragments.  Here we have a sanity
check to ensure that the final received rpc isn't too small--except that
the number we're actually checking is the length of just the final
fragment, not of the whole rpc.  So a perfectly legal rpc that's
unluckily fragmented could cause the server to close the connection
here.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index df74919..305374d 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1095,7 +1095,7 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto err_noclose;
 	}
 
-	if (svc_sock_reclen(svsk) < 8) {
+	if (svsk->sk_datalen < 8) {
 		svsk->sk_datalen = 0;
 		goto err_delete; /* client is nuts. */
 	}
-- 
1.8.1.4

