From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 3/3] nfsd: ensure sockets are closed on error
Date: Wed, 31 Mar 2010 15:34:10 -0400
Message-ID: <1270064050-5239-3-git-send-email-bfields@citi.umich.edu>
References: <20100331193029.GC4937@fieldses.org>
 <1270064050-5239-1-git-send-email-bfields@citi.umich.edu>
 <1270064050-5239-2-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: stable@kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:33507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756885Ab0CaTb7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Mar 2010 15:31:59 -0400
In-Reply-To: <1270064050-5239-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Neil Brown <neilb@suse.de>

One the changes in commit d7979ae4a "svc: Move close processing to a
single place" is:

  err_delete:
-       svc_delete_socket(svsk);
+       set_bit(SK_CLOSE, &svsk->sk_flags);
        return -EAGAIN;

This is insufficient. The recvfrom methods must always call
svc_xprt_received on completion so that the socket gets re-queued if
there is any more work to do.  This particular path did not make that
call because it actually destroyed the svsk, making requeue pointless.
When the svc_delete_socket was change to just set a bit, we should have
added a call to svc_xprt_received,

This is the problem that b0401d7253 attempted to fix, incorrectly.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 net/sunrpc/svcsock.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 1c246a4..70b0a22 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -968,6 +968,7 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 	return len;
  err_delete:
 	set_bit(XPT_CLOSE, &svsk->sk_xprt.xpt_flags);
+	svc_xprt_received(&svsk->sk_xprt);
  err_again:
 	return -EAGAIN;
 }
-- 
1.6.3.3

