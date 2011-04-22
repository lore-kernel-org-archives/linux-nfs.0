Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:6980 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485Ab1DVIqb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Apr 2011 04:46:31 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsstat: reorder nfs4 stats for 2.6.38 and up
Date: Fri, 22 Apr 2011 11:46:20 +0300
Message-Id: <1303461980-6731-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

match order in 2.6.38, 2.6.39 (-rc3) and development tree
while at it, get rid of obsolete ds_write and ds_commit

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsstat/nfsstat.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

git://linux-nfs.org/~bhalevy/pnfs-nfs-utils.git
updated respectively

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index f31bb81..a4a8034 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -126,14 +126,11 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"sequence",
 	"get_lease_t",
 	"reclaim_comp",
+	"getdevinfo",
 	"layoutget",
 	"layoutcommit",
 	"layoutreturn",
 	"getdevlist",
-	"getdevinfo",
-	/* nfsv4.1 pnfs client ops to data server only */
-	"ds_write",
-	"ds_commit",
 };
 
 static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
-- 
1.7.3.4

