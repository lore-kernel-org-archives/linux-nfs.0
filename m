Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42295 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753486AbaIVMoT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Sep 2014 08:44:19 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s8MCiJ9Z008779
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 08:44:19 -0400
Received: from mmyllyne.csb (vpn1-7-112.ams2.redhat.com [10.36.7.112])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id s8MCiHMh029013
	for <linux-nfs@vger.kernel.org>; Mon, 22 Sep 2014 08:44:18 -0400
Message-ID: <542019A1.9040706@redhat.com>
Date: Mon, 22 Sep 2014 15:44:17 +0300
From: Marko Myllynen <myllynen@redhat.com>
Reply-To: myllynen@redhat.com
MIME-Version: 1.0
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfsstat: add server io stats
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>From 15fc547d8deb3d1975d160deacc05a0f5bec0845 Mon Sep 17 00:00:00 2001
From: Marko Myllynen <myllynen@redhat.com>
Date: Mon, 22 Sep 2014 15:30:07 +0300
Subject: [PATCH v2] nfsstat: add server io stats

Add server io statistics to nfsstat.

Signed-off-by: Marko Myllynen <myllynen@redhat.com>
---
 utils/nfsstat/nfsstat.c |   26 +++++++++++++++++++++++---
 1 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 298adcf..83bde9d 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -92,6 +92,10 @@ static unsigned int	srvfhinfo[7], srvfhinfo_old[7];		/* (for kernels >= 2.4.0)
 								 *    compatability.
 								 */
 
+static unsigned int	srvioinfo[3], srvioinfo_old[3];		/* 0  bytes read
+								 * 1  bytes written
+								 */
+
 static const char *	nfsv2name[SRVPROC2_SZ] = {
 	"null", "getattr", "setattr", "root",   "lookup",  "readlink",
 	"read", "wrcache", "write",   "create", "remove",  "rename",
@@ -167,6 +171,7 @@ static const char *     nfssrvproc4opname[SRVPROC4OPS_SZ] = {
 #define LABEL_srvrpc		"Server rpc stats:\n"
 #define LABEL_srvrc		"Server reply cache:\n"
 #define LABEL_srvfh		"Server file handle cache:\n"
+#define LABEL_srvio		"Server io stats:\n"
 #define LABEL_srvproc2		"Server nfs v2:\n"
 #define LABEL_srvproc3		"Server nfs v3:\n"
 #define LABEL_srvproc4		"Server nfs v4:\n"
@@ -198,6 +203,7 @@ typedef struct statinfo {
 					SRV(rpc,s), \
 					SRV(rc,s), \
 					SRV(fh,s), \
+					SRV(io,s), \
 					SRV(proc2,s), \
 					SRV(proc3,s),\
 					SRV(proc4,s), \
@@ -249,6 +255,7 @@ static time_t		starttime;
 #define PRNT_NET	0x0004
 #define PRNT_FH		0x0008
 #define PRNT_RC		0x0010
+#define PRNT_IO		0x0020
 #define PRNT_AUTO	0x1000
 #define PRNT_V2		0x2000
 #define PRNT_V3		0x4000
@@ -277,6 +284,7 @@ void usage(char *name)
      net		Network layer statistics\n\
      fh			Usage information on the server's file handle cache\n\
      rc			Usage information on the server's request reply cache\n\
+     io			Usage information on the server's io statistics\n\
      all		Select all of the above\n\
   -v, --verbose, --all	Same as '-o all'\n\
   -r, --rpc		Show RPC statistics\n\
@@ -366,8 +374,10 @@ main(int argc, char **argv)
 				opt_prt |= PRNT_RC;
 			else if (!strcmp(optarg, "fh"))
 				opt_prt |= PRNT_FH;
+			else if (!strcmp(optarg, "io"))
+				opt_prt |= PRNT_IO;
 			else if (!strcmp(optarg, "all"))
-				opt_prt |= PRNT_CALLS | PRNT_RPC | PRNT_NET | PRNT_RC | PRNT_FH;
+				opt_prt |= PRNT_CALLS | PRNT_RPC | PRNT_NET | PRNT_RC | PRNT_FH | PRNT_IO;
 			else {
 				fprintf(stderr, "nfsstat: unknown category: "
 						"%s\n", optarg);
@@ -435,9 +445,9 @@ main(int argc, char **argv)
 	if (!(opt_prt & 0xe000)) {
 		opt_prt |= PRNT_AUTO;
 	}
-	if ((opt_prt & (PRNT_FH|PRNT_RC)) && !opt_srv) {
+	if ((opt_prt & (PRNT_FH|PRNT_RC|PRNT_IO)) && !opt_srv) {
 		fprintf(stderr,
-			"You requested file handle or request cache "
+			"You requested io, file handle, or request cache "
 			"statistics while using the -c option.\n"
 			"This information is available only for the NFS "
 			"server.\n");
@@ -552,6 +562,16 @@ print_server_stats(int opt_prt)
 			printf("\n");
 		}
 	}
+	if (opt_prt & PRNT_IO) {
+		if (opt_sleep && !has_rpcstats(srvioinfo, 3)) {
+			;
+		} else {
+			print_numbers(LABEL_srvio
+				"read       write\n",
+				srvioinfo, 2);
+			printf("\n");
+		}
+	}
 
 	/*
 	 * 2.2 puts all fh-related info after the 'rc' header
-- 
1.7.1

-- 
Marko Myllynen
