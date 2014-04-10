Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f48.google.com ([209.85.192.48]:55128 "EHLO
	mail-qg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934020AbaDJUbJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:31:09 -0400
Received: by mail-qg0-f48.google.com with SMTP id i50so4484414qgf.35
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:31:09 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 1/5] gssd: handle malloc failure appropriately in do_downcall
Date: Thu, 10 Apr 2014 16:30:59 -0400
Message-Id: <1397161863-29266-2-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...and get rid of some pointless NULL ptr checks.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 33cfeb2afd2e..5f7fb32c41b5 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -694,6 +694,9 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length;
 	p = buf = malloc(buf_size);
+	if (!buf)
+		goto out_err;
+
 	end = buf + buf_size;
 
 	/* context_timeout set by -t option overrides context lifetime */
@@ -706,10 +709,10 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	if (write_buffer(&p, end, context_token)) goto out_err;
 
 	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
-	if (buf) free(buf);
+	free(buf);
 	return 0;
 out_err:
-	if (buf) free(buf);
+	free(buf);
 	printerr(1, "Failed to write downcall!\n");
 	return -1;
 }
-- 
1.9.0

