Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:21864 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751450AbaAQQVX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Jan 2014 11:21:23 -0500
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0HGLMNh015202
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 11:21:23 -0500
Received: from smallhat.boston.devel.redhat.com (vpn-55-225.rdu2.redhat.com [10.10.55.225])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s0HGLLqp025784
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 11:21:22 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] exportfs: Exit with correct value when an error occurs
Date: Fri, 17 Jan 2014 11:23:09 -0500
Message-Id: <1389975789-3981-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 support/nfs/exports.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index d18667f..819d6c4 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -366,7 +366,7 @@ mkexportent(char *hname, char *path, char *options)
 	ee.e_hostname = xstrdup(hname);
 
 	if (strlen(path) >= sizeof(ee.e_path)) {
-		xlog(L_WARNING, "path name %s too long", path);
+		xlog(L_ERROR, "path name %s too long", path);
 		return NULL;
 	}
 	strncpy(ee.e_path, path, sizeof (ee.e_path));
-- 
1.8.3.1

