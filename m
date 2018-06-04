Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39790 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753379AbeFDOuz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 4 Jun 2018 10:50:55 -0400
Received: from smtp.corp.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.26])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id B7D90D819A
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:54 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-116-215.phx2.redhat.com [10.3.116.215])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 715B730012D0
        for <linux-nfs@vger.kernel.org>; Mon,  4 Jun 2018 14:50:54 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/4] gssd.c: Remomved a couple of warning errors
Date: Mon,  4 Jun 2018 10:50:51 -0400
Message-Id: <20180604145051.146390-5-steved@redhat.com>
In-Reply-To: <20180604145051.146390-1-steved@redhat.com>
References: <20180604145051.146390-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

gssd.c:291:7: error: ISO C does not support the 'm' scanf flag
[-Werror=format=]

gssd.c:291:7: error: format '%s' expects argument of type 'char *', but
argument 4 has type 'char **' [-Werror=format=]

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gssd.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 2c14e5f..7b21ee2 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -279,16 +279,16 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
 	 * (commit bf19aacecbeebccb2c3d150a8bd9416b7dba81fe)
 	 */
 	numfields = fscanf(info,
-			   "RPC server: %ms\n"
-			   "service: %ms (%d) version %d\n"
-			   "address: %ms\n"
-			   "protocol: %ms\n"
-			   "port: %ms\n",
-			   &server,
-			   &service, &program, &version,
-			   &address,
-			   &protoname,
-			   &port);
+			   "RPC server: %s\n"
+			   "service: %s (%d) version %d\n"
+			   "address: %s\n"
+			   "protocol: %s\n"
+			   "port: %s\n",
+			   (char *)&server,
+			   (char *)&service, &program, &version,
+			   (char *)&address,
+			   (char *)&protoname,
+			   (char *)&port);
 
 
 	switch (numfields) {
-- 
1.8.3.1

