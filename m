Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:8692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161051Ab2JXSLf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Oct 2012 14:11:35 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q9OIBYFP005944
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:34 -0400
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id q9OIBWSH020176
	for <linux-nfs@vger.kernel.org>; Wed, 24 Oct 2012 14:11:34 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 5/5] Fixed warnings in src/g_unseal.c and src/g_verify.c
Date: Wed, 24 Oct 2012 14:08:44 -0400
Message-Id: <1351102124-24036-6-git-send-email-steved@redhat.com>
In-Reply-To: <1351102124-24036-1-git-send-email-steved@redhat.com>
References: <1351102124-24036-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Changed the signedness qop_state argument from int * to gss_qop_t *

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/g_unseal.c | 2 +-
 src/g_verify.c | 2 +-
 src/mglueP.h   | 4 ++--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/src/g_unseal.c b/src/g_unseal.c
index 5f5ccf0..a1c78e3 100644
--- a/src/g_unseal.c
+++ b/src/g_unseal.c
@@ -41,7 +41,7 @@ gss_ctx_id_t		context_handle;
 gss_buffer_t		input_message_buffer;
 gss_buffer_t		output_message_buffer;
 int *			conf_state;
-int *			qop_state;
+gss_qop_t *		qop_state;
 
 {
     OM_uint32		status;
diff --git a/src/g_verify.c b/src/g_verify.c
index 4439405..6c734bc 100644
--- a/src/g_verify.c
+++ b/src/g_verify.c
@@ -74,7 +74,7 @@ int *			qop_state;
 				      ctx->internal_ctx_id,
 				      message_buffer,
 				      token_buffer,
-				      qop_state);
+				      (gss_qop_t *)qop_state);
 	else
 	    status = GSS_S_BAD_BINDINGS;
 
diff --git a/src/mglueP.h b/src/mglueP.h
index da3eaed..78eabdd 100644
--- a/src/mglueP.h
+++ b/src/mglueP.h
@@ -171,7 +171,7 @@ typedef struct gss_config {
 		    gss_buffer_t,	/* input_message_buffer */
 		    gss_buffer_t,	/* output_message_buffer */
 		    int*,		/* conf_state */
-		    int*		/* qop_state */
+		    gss_qop_t *	/* qop_state */
 		    );
     OM_uint32       (*gss_display_status)
 	(
@@ -316,7 +316,7 @@ typedef struct gss_config {
 		    gss_ctx_id_t,	/* context_handle */
 		    gss_buffer_t,	/* message_buffer */
 		    gss_buffer_t,	/* token_buffer */
-		    int*		/* qop_state */
+		    gss_qop_t  *	/* qop_state */
 		    );
 
     OM_uint32       (*gss_export_lucid_sec_context)
-- 
1.7.11.7

