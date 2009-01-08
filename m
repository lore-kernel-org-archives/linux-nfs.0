From: wengang wang <wen.gang.wang@oracle.com>
Subject: [PATCH 1/1] rpc.statd: fix the failure of SM_DIR creation
Date: Thu,  8 Jan 2009 21:44:16 +0800
Message-ID: <200901081345.n08Dje4F025471@rgminet15.oracle.com>
Cc: greg.marsden@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:32280 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755693AbZAHNpq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 08:45:46 -0500
Received: from rgminet15.oracle.com (rcsinet15.oracle.com [148.87.113.117])
	by acsinet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n08DjDoo004322
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jan 2009 13:45:14 GMT
Received: from acsmt705.oracle.com (acsmt705.oracle.com [141.146.40.83])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n08Dje4F025471
	for <linux-nfs@vger.kernel.org>; Thu, 8 Jan 2009 13:45:41 GMT
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Please let me if here is not the place talking about rpc.statd.

this's going to talk about rpc.statd.
in case SM_DIR doesn't exist, it may not be created.
according code in shuffle_dirs(), since st is not initailized, whether
the SM_DIR is created depends on the thread stack of rpc.statd.
the fix is to insert a memset() before calling stat().

#the patch is against nfs-utils 1.0.9

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
--
 state.c |    2 ++
 1 file changed, 2 insertions(+)
diff -up ./utils/statd/state.c.orig ./utils/statd/state.c
--- ./utils/statd/state.c.orig	2009-01-08 20:32:44.000000000 +0800
+++ ./utils/statd/state.c	2009-01-08 20:33:07.000000000 +0800
@@ -89,6 +89,8 @@ shuffle_dirs (void)
   char *src, *dst;
   int len1, len2, len;
   
+  memset (&st, 0, sizeof st);
+
   if (stat (SM_DIR, &st) == -1 && errno != ENOENT)
     die ("stat (%s): %s", SM_DIR, strerror (errno));
 
