Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:39839 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756762Ab1DFXGc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Apr 2011 19:06:32 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/7] svcrpc: close connection if client sends short packet
Date: Wed,  6 Apr 2011 19:06:23 -0400
Message-Id: <1302131186-6578-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1302131186-6578-1-git-send-email-bfields@redhat.com>
References: <1302131186-6578-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

If the client sents a record too short to contain even the beginning of
the rpc header, then just close the connection.

The current code drops the record data and continues.  I don't see the
point.  It's a hopeless situation and simpler just to cut off the
connection completely.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/svcsock.c |   21 +++++++--------------
 1 files changed, 7 insertions(+), 14 deletions(-)

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 2053259..9d72a79 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -949,6 +949,9 @@ static int svc_tcp_recv_record(struct svc_sock *svsk, struct svc_rqst *rqstp)
 		}
 	}
 
+	if (svsk->sk_reclen < 8)
+		goto err_delete; /* client is nuts. */
+
 	/* Check whether enough data is available */
 	len = svc_recv_available(svsk);
 	if (len < 0)
@@ -1052,20 +1055,10 @@ static int svc_tcp_recvfrom(struct svc_rqst *rqstp)
 	vec[0] = rqstp->rq_arg.head[0];
 	vlen = PAGE_SIZE;
 
-	/*
-	 * We have enough data for the whole tcp record. Let's try and read the
-	 * first 8 bytes to get the xid and the call direction. We can use this
-	 * to figure out if this is a call or a reply to a callback. If
-	 * sk_reclen is < 8 (xid and calldir), then this is a malformed packet.
-	 * In that case, don't bother with the calldir and just read the data.
-	 * It will be rejected in svc_process.
-	 */
-	if (len >= 8) {
-		len = svc_process_calldir(svsk, rqstp, &req, vec);
-		if (len < 0)
-			goto err_again;
-		vlen -= 8;
-	}
+	len = svc_process_calldir(svsk, rqstp, &req, vec);
+	if (len < 0)
+		goto err_again;
+	vlen -= 8;
 
 	pnum = 1;
 	while (vlen < svsk->sk_reclen - 8) {
-- 
1.7.1

