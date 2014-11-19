Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f53.google.com ([209.85.216.53]:44796 "EHLO
	mail-qa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753534AbaKSMvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Nov 2014 07:51:32 -0500
Received: by mail-qa0-f53.google.com with SMTP id bm13so297158qab.40
        for <linux-nfs@vger.kernel.org>; Wed, 19 Nov 2014 04:51:31 -0800 (PST)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 01/10] sunrpc: release svc_pool_map reference when serv allocation fails
Date: Wed, 19 Nov 2014 07:51:13 -0500
Message-Id: <1416401482-2562-2-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
References: <1416401482-2562-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, it leaks when the allocation fails.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 net/sunrpc/svc.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 2783fd80c229..d38b75b0e236 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -505,13 +505,15 @@ svc_create_pooled(struct svc_program *prog, unsigned int bufsize,
 	unsigned int npools = svc_pool_map_get();
 
 	serv = __svc_create(prog, bufsize, npools, shutdown);
+	if (!serv)
+		goto out_err;
 
-	if (serv != NULL) {
-		serv->sv_function = func;
-		serv->sv_module = mod;
-	}
-
+	serv->sv_function = func;
+	serv->sv_module = mod;
 	return serv;
+out_err:
+	svc_pool_map_put();
+	return NULL;
 }
 EXPORT_SYMBOL_GPL(svc_create_pooled);
 
-- 
2.1.0

