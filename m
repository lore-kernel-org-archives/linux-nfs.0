Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it1-f182.google.com ([209.85.166.182]:52007 "EHLO
        mail-it1-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726353AbeJBBF5 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Oct 2018 21:05:57 -0400
Subject: [PATCH v2 20/20] xprtrdma: Squelch a sparse warning
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 01 Oct 2018 14:26:51 -0400
Message-ID: <20181001182651.18578.65184.stgit@manet.1015granger.net>
In-Reply-To: <20181001182005.18578.57544.stgit@manet.1015granger.net>
References: <20181001182005.18578.57544.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

linux/include/trace/events/rpcrdma.h:501:1: warning: expression using sizeof bool
linux/include/trace/events/rpcrdma.h:501:1: warning: odd constant _Bool cast (ffffffffffffffff becomes 1)

Fixes: ab03eff58eb5 ("xprtrdma: Add trace points in RPC Call ... ")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 include/trace/events/rpcrdma.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/include/trace/events/rpcrdma.h b/include/trace/events/rpcrdma.h
index a4d9ff9..b093058 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -509,7 +509,7 @@
 	TP_STRUCT__entry(
 		__field(const void *, req)
 		__field(int, num_sge)
-		__field(bool, signaled)
+		__field(int, signaled)
 		__field(int, status)
 	),
 
