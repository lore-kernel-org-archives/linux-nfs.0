Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f170.google.com ([209.85.192.170]:47028 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750872AbbBMA5K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Feb 2015 19:57:10 -0500
Received: by pdjy10 with SMTP id y10so15598936pdj.13
        for <linux-nfs@vger.kernel.org>; Thu, 12 Feb 2015 16:57:10 -0800 (PST)
From: Peng Tao <tao.peng@primarydata.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>, Peng Tao <tao.peng@primarydata.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Subject: [PATCH v2] nfsstat: update client op to match latest kernel
Date: Fri, 13 Feb 2015 08:56:39 +0800
Message-Id: <1423788999-54229-1-git-send-email-tao.peng@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We've added a bunch of ops and removed getdevicelist.

Cc: Anna Schumaker <Anna.Schumaker@netapp.com>
Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 utils/nfsstat/nfsstat.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 9f481db..427c724 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -31,7 +31,7 @@ enum {
 	SRVPROC3_SZ = 22,
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
-	CLTPROC4_SZ = 49,
+	CLTPROC4_SZ = 56,
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
@@ -139,7 +139,14 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
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
+	"allocate",
+	"deallocate",
 };
 
 static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
-- 
1.9.1

