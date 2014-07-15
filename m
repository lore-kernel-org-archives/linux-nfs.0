Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:36641 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753472AbaGOPJq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jul 2014 11:09:46 -0400
From: Steve Dickson <steved@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 04/15] gss_log_status: reformat output to use one line.
Date: Tue, 15 Jul 2014 11:09:23 -0400
Message-Id: <1405436974-4161-5-git-send-email-steved@redhat.com>
In-Reply-To: <1405436974-4161-1-git-send-email-steved@redhat.com>
References: <1405436974-4161-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

With the new LIBTIRPC_DEBUG() macros a new-line
is appended on each output buffer. So concatenate
gss_log_status()'s output into one buffer.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/authgss_prot.c | 20 +++++++++-----------
 1 file changed, 9 insertions(+), 11 deletions(-)

diff --git a/src/authgss_prot.c b/src/authgss_prot.c
index d7480fc..f233c24 100644
--- a/src/authgss_prot.c
+++ b/src/authgss_prot.c
@@ -312,21 +312,19 @@ gss_log_debug(const char *fmt, ...)
 void
 gss_log_status(char *m, OM_uint32 maj_stat, OM_uint32 min_stat)
 {
-	OM_uint32 min;
-	gss_buffer_desc msg;
+	OM_uint32 min, maj;
+	gss_buffer_desc maj_msg, min_msg;
 	u_int32_t msg_ctx = 0;
 
-	LIBTIRPC_DEBUG(1, ("rpcsec_gss: %s: ", m));
+	gss_display_status(&maj, maj_stat, GSS_C_GSS_CODE, GSS_C_NULL_OID,
+			   &msg_ctx, &maj_msg);
+	gss_display_status(&min, min_stat, GSS_C_MECH_CODE, GSS_C_NULL_OID,
+			   &msg_ctx, &min_msg);
 
-	gss_display_status(&min, maj_stat, GSS_C_GSS_CODE, GSS_C_NULL_OID,
-			   &msg_ctx, &msg);
-	LIBTIRPC_DEBUG(1, ("%s - ", (char *)msg.value));
-	gss_release_buffer(&min, &msg);
+	LIBTIRPC_DEBUG(1, ("%s: %s - %s", m, (char *)maj_msg.value, (char *)min_msg.value));
 
-	gss_display_status(&min, min_stat, GSS_C_MECH_CODE, GSS_C_NULL_OID,
-			   &msg_ctx, &msg);
-	LIBTIRPC_DEBUG(1, ("%s", (char *)msg.value));
-	gss_release_buffer(&min, &msg);
+	gss_release_buffer(&maj, &maj_msg);
+	gss_release_buffer(&min, &min_msg);
 }
 
 void
-- 
1.9.3

