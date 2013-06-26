Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35125 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752504Ab3FZTVb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 26 Jun 2013 15:21:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 3/7] svcrpc: fix handling of too-short rpc's
Date: Wed, 26 Jun 2013 15:21:23 -0400
Message-Id: <1372274488-4752-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1372274488-4752-1-git-send-email-bfields@redhat.com>
References: <1372274488-4752-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

If we detect that an rpc is too short, we abort and close the
connection.  Except, there's a bug here: we're leaving sk_datalen
nonzero without leaving any pages in the sk_pages array.  The most
likely result of the inconsistency is a subsequent crash in
svc_tcp_clear_pages.

Also demote the BUG_ON in svc_tcp_clear_pages to a WARN.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0f679df..df74919 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -917,7 +917,10 @@ static void svc_tcp_clear_pages(struct svc_sock *svsk)
 	len = svsk->sk_datalen;
 	npages = (len + PAGE_SIZE - 1) >> PAGE_SHIFT;
 	for (i = 0; i < npages; i++) {
-		BUG_ON(svsk->sk_pages[i] == NULL);
+		if (svsk->sk_pages[i] == NULL) {
+			WARN_ON_ONCE(1);
+			continue;
+		}
 		put_page(svsk->sk_pages[i]);
 		svsk->sk_pages[i] = NULL;
 	}
@@ -1092,8 +1095,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		goto err_noclose;
 	}
 
-	if (svc_sock_reclen(svsk) < 8)
+	if (svc_sock_reclen(svsk) < 8) {
+		svsk->sk_datalen = 0;
 		goto err_delete; /* client is nuts. */
+	}
 
 	rqstp->rq_arg.len = svsk->sk_datalen;
 	rqstp->rq_arg.page_base = 0;
-- 
1.8.1.4

