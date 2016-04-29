Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37176 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752985AbcD2NZ6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 29 Apr 2016 09:25:58 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6F7E03D6
	for <linux-nfs@vger.kernel.org>; Fri, 29 Apr 2016 13:25:57 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] exportfs: add the debug option
Date: Fri, 29 Apr 2016 09:25:56 -0400
Message-Id: <1461936356-26727-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Since calling xlog(D_GENERAL) will cause exportfs to exit with a status
of 1, there really should be a way to see those messages for debugging
purposes.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/exportfs/exportfs.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index a9151ff..a5eb156 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -108,11 +108,14 @@ main(int argc, char **argv)
 	xlog_stderr(1);
 	xlog_syslog(0);
 
-	while ((c = getopt(argc, argv, "afhio:ruvs")) != EOF) {
+	while ((c = getopt(argc, argv, "ad:fhio:ruvs")) != EOF) {
 		switch(c) {
 		case 'a':
 			f_all = 1;
 			break;
+		case 'd':
+			xlog_sconfig(optarg, 1);
+			break;
 		case 'f':
 			force_flush = 1;
 			break;
-- 
2.4.11

