Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58838 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932088Ab0GTGJ4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 02:09:56 -0400
Message-ID: <4C453DB2.3000502@panasas.com>
Date: Tue, 20 Jul 2010 09:09:54 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: Fwd: [PATCH for-2.6.36]: nfsstat: add release_lockowner to client
 stats
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Forwarding... (forgot to Cc the list)

Benny

On Jul. 20, 2010, 8:45 +0300, Benny Halevy <bhalevy@panasas.com> wrote:

Add stat for the RELEASE_LOCKOWNER client operation as implemented in
Linux 2.6.36

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---

 utils/nfsstat/nfsstat.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 99d77c9..3cd6635 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -31,7 +31,7 @@ enum {
 	SRVPROC3_SZ = 22,
 	CLTPROC3_SZ = 22,
 	SRVPROC4_SZ = 2,
-	CLTPROC4_SZ = 48,
+	CLTPROC4_SZ = 49,
 	SRVPROC4OPS_SZ = 59,
 };
 
@@ -118,6 +118,7 @@ static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
 	"setacl",    "fs_locations",
+	"rel_lkowner",
 	/* nfsv4.1 client ops */
 	"exchange_id",
 	"create_ses",
-- 
1.7.1.1

