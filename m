Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:36274 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbbEZRtB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 26 May 2015 13:49:01 -0400
Received: by qkx62 with SMTP id 62so95561522qkx.3
        for <linux-nfs@vger.kernel.org>; Tue, 26 May 2015 10:49:00 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 03/10] SUNRPC: Move EXPORT_SYMBOL for svc_process
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Date: Tue, 26 May 2015 13:48:57 -0400
Message-ID: <20150526174857.7061.99676.stgit@klimt.1015granger.net>
In-Reply-To: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
References: <20150526174401.7061.43137.stgit@klimt.1015granger.net>
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

