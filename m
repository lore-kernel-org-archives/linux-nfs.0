Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f43.google.com ([209.85.220.43]:64175 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755200AbbBLJHf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 04:07:35 -0500
Received: by mail-pa0-f43.google.com with SMTP id fa1so10189465pad.2
        for <linux-nfs@vger.kernel.org>; Thu, 12 Feb 2015 01:07:34 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Peng Tao <tao.peng@primarydata.com>
Subject: [PATCH] nfsstat: update client op to match latest kernel
Date: Thu, 12 Feb 2015 17:07:21 +0800
Message-Id: <1423732041-18082-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've added a bunch of ops and removed getdevicelist.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 utils/nfsstat/nfsstat.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 9f481db..de57109 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -31,7 +31,7 @@ enum {
 	SRVPROC3_SZ = 22,
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
-	CLTPROC4_SZ = 49,
+	CLTPROC4_SZ = 55,
 	SRVPROC4OPS_SZ = 59,
 };
 
@@ -127,7 +127,7 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
 	"setacl",    "fs_locations",
-	"rel_lkowner", "secinfo",
+	"rel_lkowner", "secinfo", "fsid_present",
 	/* nfsv4.1 client ops */
 	"exchange_id",
 	"create_ses",
@@ -139,7 +139,12 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"getdevinfo",
 	"layoutcommit",
 	"layoutreturn",
-	"getdevlist",
+	"secinfo_no_n",
+	"test_stateid",
+	"free_stateid",
+	"bind_con_ses",
+	"destroy_clid",
+	"seek",
 };
 
 static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
-- 
1.9.1

