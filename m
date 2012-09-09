Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e8.ny.us.ibm.com ([32.97.182.138]:56688 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752199Ab2IIPZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Sep 2012 11:25:54 -0400
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Sun, 9 Sep 2012 11:25:53 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id C8DD638C803B
	for <linux-nfs@vger.kernel.org>; Sun,  9 Sep 2012 11:25:49 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q89FPn3X37093512
	for <linux-nfs@vger.kernel.org>; Sun, 9 Sep 2012 11:25:49 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q89FPmTr002121
	for <linux-nfs@vger.kernel.org>; Sun, 9 Sep 2012 11:25:48 -0400
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q89FPmw6002093
	for <linux-nfs@vger.kernel.org>; Sun, 9 Sep 2012 11:25:48 -0400
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: pass null terminated buf to kstrtouint()
Date: Sun,  9 Sep 2012 10:25:47 -0500
Message-Id: <1347204347-23706-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The 'buf' is prepared with null termination with intention of using it for
this purpose, but 'name' is passed instead!

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfsd/nfs4idmap.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4idmap.c b/fs/nfsd/nfs4idmap.c
index fdc91a6..ccfe0d0 100644
--- a/fs/nfsd/nfs4idmap.c
+++ b/fs/nfsd/nfs4idmap.c
@@ -598,7 +598,7 @@ numeric_name_to_id(struct svc_rqst *rqstp, int type, const char *name, u32 namel
 	/* Just to make sure it's null-terminated: */
 	memcpy(buf, name, namelen);
 	buf[namelen] = '\0';
-	ret = kstrtouint(name, 10, id);
+	ret = kstrtouint(buf, 10, id);
 	return ret == 0;
 }
 
-- 
1.7.0.4

