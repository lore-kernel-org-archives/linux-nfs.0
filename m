Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f169.google.com ([209.85.223.169]:56117 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178AbaEVA5J (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 May 2014 20:57:09 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v4 20/24] xprtrdma: Reset connection timeout after successful
	reconnect
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Wed, 21 May 2014 20:57:07 -0400
Message-ID: <20140522005707.27190.2035.stgit@manet.1015granger.net>
In-Reply-To: <20140522004505.27190.58897.stgit@manet.1015granger.net>
References: <20140522004505.27190.58897.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the new connection is able to make forward progress, reset the
re-establish timeout. Otherwise it keeps growing even if disconnect
events are rare.

The same behavior as TCP is adopted: reconnect immediately if the
transport instance has been able to make some forward progress.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index dc4a826..1334646 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -770,6 +770,8 @@ repost:
 
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;
+	if (xprt->reestablish_timeout)
+		xprt->reestablish_timeout = 0;
 
 	/* check for expected message types */
 	/* The order of some of these tests is important. */

