Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f43.google.com ([209.85.216.43]:58231 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754817AbaCLPhb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 11:37:31 -0400
Received: by mail-qa0-f43.google.com with SMTP id j15so10033929qaq.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 08:37:31 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] xprtrdma: fix Kconfig option for SUNRPC_XPRT_RDMA
Date: Wed, 12 Mar 2014 11:37:23 -0400
Message-Id: <1394638643-22183-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The option for this is currently hidden and it can't easily be disabled.
Add a comment to the "tristate" line for it, so that it shows up in the
configuration.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
index 241b54f30204..f1668df078b6 100644
--- a/net/sunrpc/Kconfig
+++ b/net/sunrpc/Kconfig
@@ -10,7 +10,7 @@ config SUNRPC_BACKCHANNEL
 	depends on SUNRPC
 
 config SUNRPC_XPRT_RDMA
-	tristate
+	tristate "SUNRPC over RDMA transport"
 	depends on SUNRPC && INFINIBAND && INFINIBAND_ADDR_TRANS
 	default SUNRPC && INFINIBAND
 	help
-- 
1.8.5.3

