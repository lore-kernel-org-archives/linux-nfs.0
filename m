Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:56954 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753007AbaDOPT6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Apr 2014 11:19:58 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so2460586qgf.34
        for <linux-nfs@vger.kernel.org>; Tue, 15 Apr 2014 08:19:58 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 4/6] gssd: add new routine for generating a hostbased principal in a gss_buffer_t
Date: Tue, 15 Apr 2014 11:19:30 -0400
Message-Id: <1397575172-28377-5-git-send-email-jlayton@redhat.com>
In-Reply-To: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
References: <1397575172-28377-1-git-send-email-jlayton@redhat.com>
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

