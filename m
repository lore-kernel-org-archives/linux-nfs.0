Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57979 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1946324AbcBROUi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Feb 2016 09:20:38 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (Postfix) with ESMTPS id 930CA1E22
	for <linux-nfs@vger.kernel.org>; Thu, 18 Feb 2016 14:20:38 +0000 (UTC)
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>, Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH] libexport.a: fix missing brace in host_ntop() fallback
Date: Thu, 18 Feb 2016 14:20:36 +0000
Message-Id: <1455805236-30534-1-git-send-email-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

An if statement has been missing a brace since host_ntop() was added in
commit 94ce1eb94babb4c587b2826452fb053cba745098 ("libexport.a: Add
helpers to manage DNS lookups").

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/export/hostname.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 4daabe9..94e98a5 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -69,7 +69,7 @@ host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
 
 	memset(buf, 0, buflen);
 
-	if (sin->sin_family != AF_INET)
+	if (sin->sin_family != AF_INET) {
 		(void)strncpy(buf, "bad family", buflen - 1);
 		return buf;
 	}
-- 
2.5.0

