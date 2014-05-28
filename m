Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f180.google.com ([209.85.223.180]:42629 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbaE1Oen (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 May 2014 10:34:43 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v5 20/24] xprtrdma: Reset connection timeout after successful
	reconnect
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Cc: Anna.Schumaker@netapp.com
Date: Wed, 28 May 2014 10:34:41 -0400
Message-ID: <20140528143441.23214.36316.stgit@manet.1015granger.net>
In-Reply-To: <20140528142521.23214.39655.stgit@manet.1015granger.net>
References: <20140528142521.23214.39655.stgit@manet.1015granger.net>
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

 net/sunrpc/xprtrdma/rpc_rdma.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index dc4a826..ac65b0c 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -770,6 +770,7 @@ repost:
 
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;
+	xprt->reestablish_timeout = 0;
 
 	/* check for expected message types */
 	/* The order of some of these tests is important. */

