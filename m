Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:38166 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755600Ab1FQOVn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jun 2011 10:21:43 -0400
Received: by vxi39 with SMTP id 39so1992071vxi.19
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jun 2011 07:21:43 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <benny@tonian.com>
Subject: [PATCH] nfsstat: reorder nfs4 stats for 2.6.39
Date: Fri, 17 Jun 2011 10:21:40 -0400
Message-Id: <1308320500-9950-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 utils/nfsstat/nfsstat.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index a4a8034..8e6ca21 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -118,7 +118,7 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
 	"setacl",    "fs_locations",
-	"rel_lkowner",
+	"rel_lkowner", "secinfo",
 	/* nfsv4.1 client ops */
 	"exchange_id",
 	"create_ses",
@@ -126,8 +126,8 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"sequence",
 	"get_lease_t",
 	"reclaim_comp",
-	"getdevinfo",
 	"layoutget",
+	"getdevinfo",
 	"layoutcommit",
 	"layoutreturn",
 	"getdevlist",
-- 
1.7.4.4

