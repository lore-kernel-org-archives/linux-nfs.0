Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:44667 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752991Ab1GUUfW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Jul 2011 16:35:22 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p6LKEAsL007481
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 16:14:10 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p6LKZKo4146564
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 16:35:21 -0400
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p6LEYr13012205
	for <linux-nfs@vger.kernel.org>; Thu, 21 Jul 2011 08:34:53 -0600
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH 2/2] nfs4-acl-tools: Don't call free_fields when memory isn't allocated.
Date: Thu, 21 Jul 2011 13:35:07 -0700
Message-Id: <1311280507-28957-2-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
References: <1311280507-28957-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0


Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 libnfs4acl/nfs4_ace_from_string.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libnfs4acl/nfs4_ace_from_string.c b/libnfs4acl/nfs4_ace_from_string.c
index 462fcc0..510ffee 100644
--- a/libnfs4acl/nfs4_ace_from_string.c
+++ b/libnfs4acl/nfs4_ace_from_string.c
@@ -150,7 +150,7 @@ struct nfs4_ace * nfs4_ace_from_string(char *ace_buf, int is_dir)
 	/* parse_alloc_fields had split up ace_buf so now we copy it to bufp */
 	bufp = malloc(strlen(ace_buf) + 1);
 	if (!bufp)
-		goto out_free;
+		goto out;
 	strcpy(bufp,ace_buf);
 
 	ret = parse_alloc_fields(bufp, fields);
-- 
1.7.4.4

