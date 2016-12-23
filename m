Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:44304 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S966279AbcLWQLp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 23 Dec 2016 11:11:45 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH] GSSD: Add RPCSEC_GSS version to downcall
Date: Fri, 23 Dec 2016 11:09:48 -0500
Message-ID: <1482509388-22430-2-git-send-email-andros@netapp.com>
In-Reply-To: <1482509388-22430-1-git-send-email-andros@netapp.com>
References: <1482509388-22430-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/gssd/gssd_proc.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d74d372..a045133 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -150,9 +150,11 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	unsigned int timeout = context_timeout;
 	unsigned int buf_size = 0;
 
-	printerr(2, "doing downcall: lifetime_rec=%u acceptor=%.*s\n",
-		lifetime_rec, acceptor->length, acceptor->value);
-	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
+	printerr(1, "doing downcall: lifetime_rec=%u acceptor=%.*s"
+		"gss vers %d\n", lifetime_rec, acceptor->length,
+		acceptor->value, pd->pd_gss_vers);
+	buf_size = sizeof(uid) + sizeof(timeout) +
+		sizeof(pd->pd_gss_vers) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length +
 		sizeof(acceptor->length) + acceptor->length;
@@ -167,6 +169,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 		timeout = lifetime_rec;
 	if (WRITE_BYTES(&p, end, uid)) goto out_err;
 	if (WRITE_BYTES(&p, end, timeout)) goto out_err;
+	if (WRITE_BYTES(&p, end, pd->pd_gss_vers)) goto out_err;
 	if (WRITE_BYTES(&p, end, pd->pd_seq_win)) goto out_err;
 	if (write_buffer(&p, end, &pd->pd_ctx_hndl)) goto out_err;
 	if (write_buffer(&p, end, context_token)) goto out_err;
-- 
1.8.3.1

