Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f174.google.com ([209.85.210.174]:56988 "EHLO
	mail-ia0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757156Ab2JKPKw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Oct 2012 11:10:52 -0400
Received: by mail-ia0-f174.google.com with SMTP id y32so1303750iag.19
        for <linux-nfs@vger.kernel.org>; Thu, 11 Oct 2012 08:10:52 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/8] mountd: Warn when a broken junction is encountered
To: steved@redhat.com
Cc: bfields@redhat.com, linux-nfs@vger.kernel.org
Date: Thu, 11 Oct 2012 11:10:48 -0400
Message-ID: <20121011151048.4665.10650.stgit@lebasque.1015granger.net>
In-Reply-To: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
References: <20121011150421.4665.35964.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A broken junction is a problem that administrators will want to
know about and correct.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |   19 ++++++++++++++-----
 1 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7d80432..942fdbd 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -975,8 +975,8 @@ static struct exportent *locations_to_export(struct jp_ops *ops,
 static struct exportent *invoke_junction_ops(void *handle,
 		const char *junction)
 {
+	struct exportent *exp = NULL;
 	nfs_fsloc_set_t locations;
-	struct exportent *exp;
 	enum jp_status status;
 	struct jp_ops *ops;
 	char *error;
@@ -1002,15 +1002,24 @@ static struct exportent *invoke_junction_ops(void *handle,
 	}
 
 	status = ops->jp_get_locations(junction, &locations);
-	if (status != JP_OK) {
-		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
-			__func__, junction, ops->jp_error(status));
-		return NULL;
+	switch (status) {
+	case JP_OK:
+		break;
+	case JP_NOTJUNCTION:
+		xlog(D_GENERAL, "%s: %s is not a junction",
+			__func__, junction);
+		goto out;
+	default:
+		xlog(L_WARNING, "Dangling junction %s: %s",
+			junction, ops->jp_error(status));
+		goto out;
 	}
 
 	exp = locations_to_export(ops, locations, junction);
 
 	ops->jp_put_locations(locations);
+
+out:
 	ops->jp_done();
 	return exp;
 }

