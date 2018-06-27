Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:38488 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S966053AbeF0RMx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Jun 2018 13:12:53 -0400
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.rdu2.redhat.com [10.11.54.4])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 270A98AA1A
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 17:12:53 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 11A922026D5B
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 17:12:53 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Revert "gssd.c: Remomved a couple of warning errors"
Date: Wed, 27 Jun 2018 13:12:52 -0400
Message-Id: <20180627171252.18145-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 98118f5e382cdeb1acf25370768d5dfdc254ba5d.
Added back the 'm' character which cause memory to be
allocated for the string convertions.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 7b21ee2..2c14e5f 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -279,16 +279,16 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
 	 * (commit bf19aacecbeebccb2c3d150a8bd9416b7dba81fe)
 	 */
 	numfields = fscanf(info,
-			   "RPC server: %s\n"
-			   "service: %s (%d) version %d\n"
-			   "address: %s\n"
-			   "protocol: %s\n"
-			   "port: %s\n",
-			   (char *)&server,
-			   (char *)&service, &program, &version,
-			   (char *)&address,
-			   (char *)&protoname,
-			   (char *)&port);
+			   "RPC server: %ms\n"
+			   "service: %ms (%d) version %d\n"
+			   "address: %ms\n"
+			   "protocol: %ms\n"
+			   "port: %ms\n",
+			   &server,
+			   &service, &program, &version,
+			   &address,
+			   &protoname,
+			   &port);
 
 
 	switch (numfields) {
-- 
2.17.1

