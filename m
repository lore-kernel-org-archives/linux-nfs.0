Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33418 "EHLO
	mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751306AbbFDPUx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 11:20:53 -0400
Received: by qkhg32 with SMTP id g32so25511618qkh.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 08:20:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 2/7] SUNRPC: Move EXPORT_SYMBOL for svc_process
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Thu, 04 Jun 2015 11:20:49 -0400
Message-ID: <20150604152049.7835.81554.stgit@klimt.1015granger.net>
In-Reply-To: <20150604151716.7835.65047.stgit@klimt.1015granger.net>
References: <20150604151716.7835.65047.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/svc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 78974e4..852ae60 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -1290,7 +1290,6 @@ err_bad:
 	svc_putnl(resv, ntohl(rpc_stat));
 	goto sendit;
 }
-EXPORT_SYMBOL_GPL(svc_process);
 
 /*
  * Process the RPC request.
@@ -1338,6 +1337,7 @@ out_drop:
 	svc_drop(rqstp);
 	return 0;
 }
+EXPORT_SYMBOL_GPL(svc_process);
 
 #if defined(CONFIG_SUNRPC_BACKCHANNEL)
 /*

