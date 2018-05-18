Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:40174 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751184AbeERPjT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 18 May 2018 11:39:19 -0400
Received: by mail-it0-f66.google.com with SMTP id j186-v6so13626135ita.5
        for <linux-nfs@vger.kernel.org>; Fri, 18 May 2018 08:39:18 -0700 (PDT)
Subject: [PATCH RFC 1/4] sunrpc: Enable the kernel to specify the hostname
 part of service principals
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Cc: simo@redhat.com
Date: Fri, 18 May 2018 11:39:17 -0400
Message-ID: <20180518153917.7706.31603.stgit@klimt.1015granger.net>
In-Reply-To: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
References: <20180518153018.7706.87172.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A multi-homed NFS server may have more than one "nfs" key in its
keytab. Enable the kernel to pick the key it wants as a machine
credential when establishing a GSS context.

This is useful for GSS-protected NFSv4.0 callbacks, which are
required by RFC 7530 S3.3.3 to use the same principal as the service
principal the client used when establishing its lease.

A complementary modification to rpc.gssd is required to fully enable
this feature.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/auth_gss/auth_gss.c |   20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index 9463af4..818c695 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -284,7 +284,12 @@ struct gss_auth {
 	return p;
 }
 
-#define UPCALL_BUF_LEN 128
+/* XXX: Need some documentation about why UPCALL_BUF_LEN is so small.
+ *	Is user space expecting no more than UPCALL_BUF_LEN bytes?
+ *	Note that there are now _two_ NI_MAXHOST sized data items
+ *	being passed in this string.
+ */
+#define UPCALL_BUF_LEN	256
 
 struct gss_upcall_msg {
 	refcount_t count;
@@ -462,8 +467,17 @@ static int gss_encode_v1_msg(struct gss_upcall_msg *gss_msg,
 		p += len;
 		gss_msg->msg.len += len;
 	}
-	if (service_name != NULL) {
-		len = scnprintf(p, buflen, "service=%s ", service_name);
+	if (service_name) {
+		char *c = strchr(service_name, '@');
+
+		if (!c)
+			len = scnprintf(p, buflen, "service=%s ",
+					service_name);
+		else
+			len = scnprintf(p, buflen,
+					"service=%.*s srchost=%s ",
+					(int)(c - service_name),
+					service_name, c + 1);
 		buflen -= len;
 		p += len;
 		gss_msg->msg.len += len;

