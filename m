Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54358 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755702Ab2HTVta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 17:49:30 -0400
Received: from bfields by fieldses.org with local (Exim 4.72)
	(envelope-from <bfields@fieldses.org>)
	id 1T3Zqk-00026k-6r
	for linux-nfs@vger.kernel.org; Mon, 20 Aug 2012 17:49:30 -0400
Date: Mon, 20 Aug 2012 17:49:30 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] svcrpc: fix BUG() in svc_tcp_clear_pages
Message-ID: <20120820214930.GI5779@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Examination of svc_tcp_clear_pages shows that it assumes sk_tcplen is
consistent with sk_pages[] (in particular, sk_pages[n] can't be NULL if
sk_tcplen would lead us to expect n pages of data).

svc_tcp_restore_pages zeroes out sk_pages[] while leaving sk_tcplen.
This is OK, since both functions are serialized by XPT_BUSY.  However,
that means the inconsistency must be repaired before dropping XPT_BUSY.

Therefore we should be ensuring that svc_tcp_save_pages repairs the
problem before exiting svc_tcp_recv_record on error.

Symptoms were a BUG() in svc_tcp_clear_pages.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Sending in for 3.6 soon absent objections.--b.

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 18bc130..998aa8c 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -1129,9 +1129,9 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	if (len >= 0)
 		svsk->sk_tcplen += len;
 	if (len != want) {
+		svc_tcp_save_pages(svsk, rqstp);
 		if (len < 0 && len != -EAGAIN)
 			goto err_other;
-		svc_tcp_save_pages(svsk, rqstp);
 		dprintk("svc: incomplete TCP record (%d of %d)\n",
 			svsk->sk_tcplen, svsk->sk_reclen);
 		goto err_noclose;
-- 
1.7.9.5

