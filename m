Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46880 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753172AbbLJQMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Dec 2015 11:12:31 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, jlayton@poochiereds.net
Subject: [PATCH 2/2] nfsstat: update nfs server operations
Date: Thu, 10 Dec 2015 11:12:29 -0500
Message-Id: <c5b5477b18f3f423b800aee6f48c3ce1e6d17786.1449763231.git.bcodding@redhat.com>
In-Reply-To: <745dd74bb752e97b40c79d27c29427c0942f952c.1449763231.git.bcodding@redhat.com>
References: <745dd74bb752e97b40c79d27c29427c0942f952c.1449763231.git.bcodding@redhat.com>
In-Reply-To: <745dd74bb752e97b40c79d27c29427c0942f952c.1449763231.git.bcodding@redhat.com>
References: <745dd74bb752e97b40c79d27c29427c0942f952c.1449763231.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 utils/nfsstat/nfsstat.c |   15 ++++++++++++++-
 1 files changed, 14 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index b882c41..b67f0aa 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -32,7 +32,7 @@ enum {
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
 	CLTPROC4_SZ = 60,
-	SRVPROC4OPS_SZ = 59,
+	SRVPROC4OPS_SZ = 71,
 };
 
 static unsigned int	srvproc2info[SRVPROC2_SZ+2],
@@ -182,6 +182,19 @@ static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
 	"want_deleg",
 	"destroy_clid",
 	"reclaim_comp",
+	/* nfsv4.2 server ops */
+	"allocate",
+	"copy",
+	"copy_notify",
+	"deallocate",
+	"ioadvise",
+	"layouterror",
+	"layoutstats",
+	"offloadcancel",
+	"offloadstatus",
+	"readplus",
+	"seek",
+	"write_same",
 };
 
 #define LABEL_srvnet		"Server packet stats:\n"
-- 
1.7.1

