Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qc0-f169.google.com ([209.85.216.169]:34245 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751030AbbEDQTD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 May 2015 12:19:03 -0400
Received: by qcyk17 with SMTP id k17so74317565qcy.1
        for <linux-nfs@vger.kernel.org>; Mon, 04 May 2015 09:19:03 -0700 (PDT)
Received: from klimt.1015granger.net ([2604:8800:100:81fc:be5f:f4ff:fed6:c3ba])
        by mx.google.com with ESMTPSA id o65sm10166190qge.34.2015.05.04.09.19.01
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 May 2015 09:19:02 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 3/8] SUNRPC: Move EXPORT_SYMBOL for svc_process
To: linux-nfs@vger.kernel.org
Date: Mon, 04 May 2015 12:19:00 -0400
Message-ID: <20150504161900.16870.3392.stgit@klimt.1015granger.net>
In-Reply-To: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
References: <20150504160738.16870.19295.stgit@klimt.1015granger.net>
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

