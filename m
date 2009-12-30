From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfsstat: use symbolic constants for operation array sizes
Date: Wed, 30 Dec 2009 16:55:26 +0200
Message-ID: <1262184926-13440-1-git-send-email-bhalevy@panasas.com>
References: <4B3B6981.8030807@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Benny Halevy <bhalevy@panasas.com>
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:47403 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752991AbZL3Oz3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Dec 2009 09:55:29 -0500
In-Reply-To: <4B3B6981.8030807@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsstat/nfsstat.c |   41 +++++++++++++++++++++++++++++------------
 1 files changed, 29 insertions(+), 12 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 533b4b5..99d77c9 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -25,13 +25,30 @@
 
 #define MAXNRVALS	32
 
-static unsigned int	srvproc2info[20], srvproc2info_old[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	cltproc2info[20], cltproc2info_old[20];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	srvproc3info[24], srvproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	cltproc3info[24], cltproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	srvproc4info[4], srvproc4info_old[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[50], cltproc4info_old[50];	/* NFSv4 call counts ([0] == 48) */
-static unsigned int	srvproc4opsinfo[61], srvproc4opsinfo_old[61];	/* NFSv4 call counts ([0] == 40) */
+enum {
+	SRVPROC2_SZ = 18,
+	CLTPROC2_SZ = 18,
+	SRVPROC3_SZ = 22,
+	CLTPROC3_SZ = 22,
+	SRVPROC4_SZ = 2,
+	CLTPROC4_SZ = 48,
+	SRVPROC4OPS_SZ = 59,
+};
+
+static unsigned int	srvproc2info[SRVPROC2_SZ+2],
+			srvproc2info_old[SRVPROC2_SZ+2];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	cltproc2info[CLTPROC2_SZ+2],
+			cltproc2info_old[CLTPROC2_SZ+2];	/* NFSv2 call counts ([0] == 18) */
+static unsigned int	srvproc3info[SRVPROC3_SZ+2],
+			srvproc3info_old[SRVPROC3_SZ+2];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	cltproc3info[CLTPROC3_SZ+2],
+			cltproc3info_old[CLTPROC3_SZ+2];	/* NFSv3 call counts ([0] == 22) */
+static unsigned int	srvproc4info[SRVPROC4_SZ+2],
+			srvproc4info_old[SRVPROC4_SZ+2];	/* NFSv4 call counts ([0] == 2) */
+static unsigned int	cltproc4info[CLTPROC4_SZ+2],
+			cltproc4info_old[CLTPROC4_SZ+2];	/* NFSv4 call counts ([0] == 48) */
+static unsigned int	srvproc4opsinfo[SRVPROC4OPS_SZ+2],
+			srvproc4opsinfo_old[SRVPROC4OPS_SZ+2];	/* NFSv4 call counts ([0] == 59) */
 static unsigned int	srvnetinfo[5], srvnetinfo_old[5];	/* 0  # of received packets
 								 * 1  UDP packets
 								 * 2  TCP packets
@@ -75,25 +92,25 @@ static unsigned int	srvfhinfo[7], srvfhinfo_old[7];		/* (for kernels >= 2.4.0)
 								 *    compatability.
 								 */
 
-static const char *	nfsv2name[18] = {
+static const char *	nfsv2name[SRVPROC2_SZ] = {
 	"null", "getattr", "setattr", "root",   "lookup",  "readlink",
 	"read", "wrcache", "write",   "create", "remove",  "rename",
 	"link", "symlink", "mkdir",   "rmdir",  "readdir", "fsstat"
 };
 
-static const char *	nfsv3name[22] = {
+static const char *	nfsv3name[SRVPROC3_SZ] = {
 	"null",   "getattr", "setattr",  "lookup", "access",  "readlink",
 	"read",   "write",   "create",   "mkdir",  "symlink", "mknod",
 	"remove", "rmdir",   "rename",   "link",   "readdir", "readdirplus",
 	"fsstat", "fsinfo",  "pathconf", "commit"
 };
 
-static const char *	nfssrvproc4name[2] = {
+static const char *	nfssrvproc4name[SRVPROC4_SZ] = {
 	"null",
 	"compound",
 };
 
-static const char *	nfscltproc4name[48] = {
+static const char *	nfscltproc4name[CLTPROC4_SZ] = {
 	"null",      "read",      "write",   "commit",      "open",        "open_conf",
 	"open_noat", "open_dgrd", "close",   "setattr",     "fsinfo",      "renew",
 	"setclntid", "confirm",   "lock",
@@ -118,7 +135,7 @@ static const char *	nfscltproc4name[48] = {
 	"ds_commit",
 };
 
-static const char *     nfssrvproc4opname[59] = {
+static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
         "op0-unused",   "op1-unused", "op2-future",  "access",     "close",       "commit",
         "create",       "delegpurge", "delegreturn", "getattr",    "getfh",       "link",
         "lock",         "lockt",      "locku",       "lookup",     "lookup_root", "nverify",
-- 
1.6.5.1

