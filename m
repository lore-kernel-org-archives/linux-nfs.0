From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsstat: process nfs41 client and server stats
Date: Fri, 10 Jul 2009 12:39:03 +0300
Message-ID: <1247218743-14126-1-git-send-email-bhalevy@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Steve Dickson <steved@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:27777
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751215AbZGJJjG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2009 05:39:06 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Augment nfs4 stats to cover new nfs41 client and
server operations' stats.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 utils/nfsstat/nfsstat.c |   46 ++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 40 insertions(+), 6 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 7e9f327..fa46d5d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -30,8 +30,8 @@ static unsigned int	cltproc2info[20], cltproc2info_old[20];	/* NFSv2 call counts
 static unsigned int	srvproc3info[24], srvproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	cltproc3info[24], cltproc3info_old[24];	/* NFSv3 call counts ([0] == 22) */
 static unsigned int	srvproc4info[4], srvproc4info_old[4];	/* NFSv4 call counts ([0] == 2) */
-static unsigned int	cltproc4info[37], cltproc4info_old[37];	/* NFSv4 call counts ([0] == 35) */
-static unsigned int	srvproc4opsinfo[42], srvproc4opsinfo_old[42];	/* NFSv4 call counts ([0] == 40) */
+static unsigned int	cltproc4info[49], cltproc4info_old[49];	/* NFSv4 call counts ([0] == 35) */
+static unsigned int	srvproc4opsinfo[61], srvproc4opsinfo_old[61];	/* NFSv4 call counts ([0] == 40) */
 static unsigned int	srvnetinfo[5], srvnetinfo_old[5];	/* 0  # of received packets
 								 * 1  UDP packets
 								 * 2  TCP packets
@@ -93,24 +93,58 @@ static const char *	nfssrvproc4name[2] = {
 	"compound",
 };
 
-static const char *	nfscltproc4name[35] = {
+static const char *	nfscltproc4name[47] = {
 	"null",      "read",      "write",   "commit",      "open",        "open_conf",
 	"open_noat", "open_dgrd", "close",   "setattr",     "fsinfo",      "renew",
 	"setclntid", "confirm",   "lock",
 	"lockt",     "locku",     "access",  "getattr",     "lookup",      "lookup_root",
 	"remove",    "rename",    "link",    "symlink",     "create",      "pathconf",
 	"statfs",    "readlink",  "readdir", "server_caps", "delegreturn", "getacl",
-	"setacl",    "fs_locations"
+	"setacl",    "fs_locations",
+	/* nfsv4.1 client ops */
+	"exchange_id",
+	"create_ses",
+	"destroy_ses",
+	"sequence",
+	"get_lease_t",
+	"layoutget",
+	"layoutcommit",
+	"layoutreturn",
+	"getdevlist",
+	"getdevinfo",
+	/* nfsv4.1 pnfs client ops to data server only */
+	"ds_write",
+	"ds_commit",
 };
 
-static const char *     nfssrvproc4opname[40] = {
+static const char *     nfssrvproc4opname[59] = {
         "op0-unused",   "op1-unused", "op2-future",  "access",     "close",       "commit",
         "create",       "delegpurge", "delegreturn", "getattr",    "getfh",       "link",
         "lock",         "lockt",      "locku",       "lookup",     "lookup_root", "nverify",
         "open",         "openattr",   "open_conf",   "open_dgrd",  "putfh",       "putpubfh",
         "putrootfh",    "read",       "readdir",     "readlink",   "remove",      "rename",
         "renew",        "restorefh",  "savefh",      "secinfo",    "setattr",     "setcltid",
-        "setcltidconf", "verify",     "write",       "rellockowner"
+        "setcltidconf", "verify",     "write",       "rellockowner",
+	/* nfsv4.1 server ops */
+	"bc_ctl",
+	"bind_conn",
+	"exchange_id",
+	"create_ses",
+	"destroy_ses",
+	"free_stateid",
+	"getdirdeleg",
+	"getdevinfo",
+	"getdevlist",
+	"layoutcommit",
+	"layoutget",
+	"layoutreturn",
+	"secinfononam",
+	"sequence",
+	"set_ssv",
+	"test_stateid",
+	"want_deleg",
+	"destroy_clid",
+	"reclaim_comp",
 };
 
 #define LABEL_srvnet		"Server packet stats:\n"
-- 
1.6.3.3

