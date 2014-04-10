Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:62185 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935777AbaDJUbP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Apr 2014 16:31:15 -0400
Received: by mail-qc0-f170.google.com with SMTP id x13so5037514qcv.15
        for <linux-nfs@vger.kernel.org>; Thu, 10 Apr 2014 13:31:14 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: trond.myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: [PATCH 4/5] gssd: add new routine for generating a hostbased principal in a gss_buffer_t
Date: Thu, 10 Apr 2014 16:31:02 -0400
Message-Id: <1397161863-29266-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
References: <1397161863-29266-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We'll need a gss_buffer_t to pass to the downcall marshalling code.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/gss_names.c | 15 +++++++++++++++
 utils/gssd/gss_names.h |  2 ++
 2 files changed, 17 insertions(+)

diff --git a/utils/gssd/gss_names.c b/utils/gssd/gss_names.c
index aa61e4d7a851..047069de1755 100644
--- a/utils/gssd/gss_names.c
+++ b/utils/gssd/gss_names.c
@@ -121,3 +121,18 @@ out_rel_buf:
 out_err:
 	return res;
 }
+
+void
+get_hostbased_client_buffer(gss_name_t client_name, gss_OID mech,
+			    gss_buffer_t buf)
+{
+	char *hname;
+
+	if (!get_hostbased_client_name(client_name, mech, &hname)) {
+		buf->length = strlen(hname) + 1;
+		buf->value = hname;
+	} else {
+		buf->length = 0;
+		buf->value = NULL;
+	}
+}
diff --git a/utils/gssd/gss_names.h b/utils/gssd/gss_names.h
index 1d5f49c1c1d2..ce182f7985f3 100644
--- a/utils/gssd/gss_names.h
+++ b/utils/gssd/gss_names.h
@@ -32,3 +32,5 @@
 
 extern int get_hostbased_client_name(gss_name_t client_name, gss_OID mech,
 					char **hostbased_name);
+extern void get_hostbased_client_buffer(gss_name_t client_name,
+			gss_OID mech, gss_buffer_t buf);
-- 
1.9.0

