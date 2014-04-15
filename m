Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:50412 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbaDOPTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 11:19:42 -0400
Received: by mail-qc0-f180.google.com with SMTP id w7so10525837qcr.39
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 08:19:41 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/6] gssd: make do_downcall a void return
Date: Tue, 15 Apr 2014 11:19:28 -0400
Message-Id: <1397575172-28377-3-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
References: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

...since its return code is ignored anyway.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 5f7fb32c41b5..7387cce010cf 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -681,7 +681,7 @@ parse_enctypes(char *enctypes)
 	return 0;
 }
 
-static int
+static void
 do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	    gss_buffer_desc *context_token, OM_uint32 lifetime_rec)
 {
@@ -710,11 +710,11 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 
 	if (write(k5_fd, buf, p - buf) < p - buf) goto out_err;
 	free(buf);
-	return 0;
+	return;
 out_err:
 	free(buf);
 	printerr(1, "Failed to write downcall!\n");
-	return -1;
+	return;
 }
 
 static int
-- 
1.9.0

