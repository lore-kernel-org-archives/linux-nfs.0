Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f174.google.com ([209.85.216.174]:41044 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754701AbaDOPTp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 11:19:45 -0400
Received: by mail-qc0-f174.google.com with SMTP id c9so10275529qcz.5
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 08:19:44 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <androsadamson@gmail.com>
Subject: [PATCH v2 5/6] gssd: explicitly set lifetime_rec to 0 when gss_inquire_context fails
Date: Tue, 15 Apr 2014 11:19:31 -0400
Message-Id: <1397575172-28377-6-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
References: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Contrary to the comment here, the lifetime_rec is not necessarily set
to zero on failure. That's only guaranteed to be the case if the context
has expired.

Cc: Andy Adamson <androsadamson@gmail.com>
Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gssd_proc.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index 7387cce010cf..e26935dcfc8f 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -1174,14 +1174,15 @@ process_krb5_upcall(struct clnt_info *clp, uid_t uid, int fd, char *tgtname,
 		goto out_return_error;
 	}
 
-	/* Grab the context lifetime to pass to the kernel. lifetime_rec
-	 * is set to zero on error */
+	/* Grab the context lifetime to pass to the kernel. */
 	maj_stat = gss_inquire_context(&min_stat, pd.pd_ctx, NULL, NULL,
 				       &lifetime_rec, NULL, NULL, NULL, NULL);
 
-	if (maj_stat)
+	if (maj_stat) {
 		printerr(1, "WARNING: Failed to inquire context for lifetme "
 			    "maj_stat %u\n", maj_stat);
+		lifetime_rec = 0;
+	}
 
 	if (serialize_context_for_kernel(&pd.pd_ctx, &token, &krb5oid, NULL)) {
 		printerr(0, "WARNING: Failed to serialize krb5 context for "
-- 
1.9.0

