Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:39100 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727940AbeIJUF0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Sep 2018 16:05:26 -0400
Subject: [PATCH v1 22/22] xprtrdma: Squelch a sparse warning
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 10 Sep 2018 11:10:52 -0400
Message-ID: <20180910151052.10564.3747.stgit@manet.1015granger.net>
In-Reply-To: <20180910150040.10564.97487.stgit@manet.1015granger.net>
References: <20180910150040.10564.97487.stgit@manet.1015granger.net>
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
index d8ddcac..3f1fc5f 100644
--- a/include/trace/events/rpcrdma.h
+++ b/include/trace/events/rpcrdma.h
@@ -511,7 +511,7 @@
 	TP_STRUCT__entry(
 		__field(const void *, req)
 		__field(int, num_sge)
-		__field(bool, signaled)
+		__field(int, signaled)
 		__field(int, status)
 	),
 
