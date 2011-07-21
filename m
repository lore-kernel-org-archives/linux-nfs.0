Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:51567 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991Ab1GUUfR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 16:35:17 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6LK6IAH005479
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 16:06:18 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6LKZGii166184
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 16:35:16 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6LKZGNB025549
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 16:35:16 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH 1/2] nfs4-acl-tools: Fix segfault if format of the input file is incorrect
Date: Thu, 21 Jul 2011 13:35:06 -0700
Message-Id: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The sizeof operator, when applied to a parameter declared to have array,
yields the size of the adjusted (pointer) type, even if the parameter
declaration specifies a length.

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 libnfs4acl/nfs4_ace_from_string.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
index 9d877fb..462fcc0 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -100,7 +100,7 @@ parse_alloc_fields(char *buf, char *fields[NUMFIELDS])
 	if (!buf)
 		return -EINVAL;
 
-	memset(fields, 0, sizeof(fields));
+	memset(fields, 0, sizeof(char *) * NUMFIELDS);
 
 	for (i = 0; buf[i] != '\0'; i++) {
 		if (buf[i] == ':')
-- 
1.7.4.4

