Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11805 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752037Ab0KISuH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Nov 2010 13:50:07 -0500
Received: from int-mx01.intmail.prod.int.phx2.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id oA9Io6gb010477
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 9 Nov 2010 13:50:07 -0500
Subject: [PATCH] nfs-utils: nfsstat: has_stats() does not function
 correctly for NFSv4 client stats
From: Harshula Jayasuriya <harshula@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Steve Dickson <steved@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 05:50:03 +1100
Message-ID: <1289328603.9490.18.camel@serendib>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

The NFSv4 client procs/ops in "struct rpc_procinfo nfs4_procedures" is
used to generate the NFS client stats interface:
------------------------------------------------------------
# cat /proc/net/rpc/nfs 
net 0 0 0 0
rpc 15 0 0
proc2 18 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
proc3 22 0 2 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 2 1 0
proc4 42 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0
0 0 0
0 0 0 0 0 0 0
------------------------------------------------------------
Note, for proc4, the number 42. That is the number of stats that follow
on the same line. Currently nfsstat's has_stats() relies on this number
to be equal to CLTPROC4_SZ. Unfortunately this is not the case. I have
changed has_stats() not to rely on these two values being equal. This
should also allow nfsstat to work with different kernel versions that
expose a different number of NFS client ops.

* Fix has_stats()
* Stop print_clnt_list() printing server stats!
* Describe the option -3 and -4 completely in the nfsstat manpage.

Signed-off-by: Harshula Jayasuriya <harshula@redhat.com>
---
 utils/nfsstat/nfsstat.c   |  124 ++++++++++++++++++++-------------------------
 utils/nfsstat/nfsstat.man |    6 ++-
 2 files changed, 59 insertions(+), 71 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index bacef8e..f31bb81 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -46,7 +46,7 @@ static unsigned int	cltproc3info[CLTPROC3_SZ+2],
 static unsigned int	srvproc4info[SRVPROC4_SZ+2],
 			srvproc4info_old[SRVPROC4_SZ+2];	/* NFSv4 call counts ([0] == 2) */
 static unsigned int	cltproc4info[CLTPROC4_SZ+2],
-			cltproc4info_old[CLTPROC4_SZ+2];	/* NFSv4 call counts ([0] == 48) */
+			cltproc4info_old[CLTPROC4_SZ+2];	/* NFSv4 call counts ([0] == 49) */
 static unsigned int	srvproc4opsinfo[SRVPROC4OPS_SZ+2],
 			srvproc4opsinfo_old[SRVPROC4OPS_SZ+2];	/* NFSv4 call counts ([0] == 59) */
 static unsigned int	srvnetinfo[5], srvnetinfo_old[5];	/* 0  # of received packets
@@ -221,8 +221,8 @@ DECLARE_CLT(cltinfo);
 DECLARE_CLT(cltinfo, _old);
 
 static void		print_all_stats(int, int, int);
-static void		print_server_stats(int, int);
-static void		print_client_stats(int, int);
+static void		print_server_stats(int);
+static void		print_client_stats(int);
 static void		print_stats_list(int, int, int);
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
@@ -239,7 +239,7 @@ static int		mounts(const char *);
 
 static void		get_stats(const char *, struct statinfo *, int *, int,
 					int);
-static int		has_stats(const unsigned int *);
+static int		has_stats(const unsigned int *, int);
 static int		has_rpcstats(const unsigned int *, int);
 static void 		diff_stats(struct statinfo *, struct statinfo *, int);
 static void 		unpause(int);
@@ -468,7 +468,7 @@ main(int argc, char **argv)
 		pause();
 	}
 
-	if (opt_since || opt_sleep) {
+	if (opt_since || (opt_sleep && !sleep_time)) {
 		if (opt_srv) {
 			get_stats(NFSSRVSTAT, serverinfo_tmp, &opt_srv, opt_clt, 1);
 			diff_stats(serverinfo_tmp, serverinfo, 1);
@@ -516,16 +516,16 @@ main(int argc, char **argv)
 static void
 print_all_stats (int opt_srv, int opt_clt, int opt_prt)
 {
-	print_server_stats(opt_srv, opt_prt);
-	print_client_stats(opt_clt, opt_prt);
+	if (opt_srv)
+		print_server_stats(opt_prt);
+
+	if (opt_clt)
+		print_client_stats(opt_prt);
 }
 
 static void 
-print_server_stats(int opt_srv, int opt_prt) 
+print_server_stats(int opt_prt) 
 {
-	if (!opt_srv)
-		return;
-
 	if (opt_prt & PRNT_NET) {
 		if (opt_sleep && !has_rpcstats(srvnetinfo, 4)) {
 		} else {
@@ -582,31 +582,29 @@ print_server_stats(int opt_srv, int opt_prt)
 		printf("\n");
 	}
 	if (opt_prt & PRNT_CALLS) {
+		int has_v2_stats = has_stats(srvproc2info, SRVPROC2_SZ+2);
+		int has_v3_stats = has_stats(srvproc3info, SRVPROC3_SZ+2);
+		int has_v4_stats = has_stats(srvproc4info, SRVPROC4_SZ+2);
+
 		if ((opt_prt & PRNT_V2) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc2info))) {
-			if (opt_sleep && !has_stats(srvproc2info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v2_stats)) {
+			if (!opt_sleep || has_v2_stats) {
 				print_callstats(LABEL_srvproc2,
 					nfsv2name, srvproc2info + 1, 
 					sizeof(nfsv2name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V3) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc3info))) {
-			if (opt_sleep && !has_stats(srvproc3info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v3_stats)) {
+			if (!opt_sleep || has_v3_stats) {
 				print_callstats(LABEL_srvproc3,
 					nfsv3name, srvproc3info + 1, 
 					sizeof(nfsv3name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V4) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc4info))) {
-			if (opt_sleep && !has_stats(srvproc4info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v4_stats)) {
+			if (!opt_sleep || has_v4_stats) {
 				print_callstats( LABEL_srvproc4,
 					nfssrvproc4name, srvproc4info + 1, 
 					sizeof(nfssrvproc4name)/sizeof(char *));
@@ -618,11 +616,8 @@ print_server_stats(int opt_srv, int opt_prt)
 	}
 }
 static void
-print_client_stats(int opt_clt, int opt_prt) 
+print_client_stats(int opt_prt) 
 {
-	if (!opt_clt)
-		return;
-
 	if (opt_prt & PRNT_NET) {
 		if (opt_sleep && !has_rpcstats(cltnetinfo, 4)) {
 			;
@@ -644,31 +639,28 @@ print_client_stats(int opt_clt, int opt_prt)
 		}
 	}
 	if (opt_prt & PRNT_CALLS) {
+		int has_v2_stats = has_stats(cltproc2info, CLTPROC2_SZ+2);
+		int has_v3_stats = has_stats(cltproc3info, CLTPROC3_SZ+2);
+		int has_v4_stats = has_stats(cltproc4info, CLTPROC4_SZ+2);
 		if ((opt_prt & PRNT_V2) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
-			if (opt_sleep && !has_stats(cltproc2info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v2_stats)) {
+			if (!opt_sleep || has_v2_stats) {
 				print_callstats(LABEL_cltproc2,
 					nfsv2name, cltproc2info + 1,  
 					sizeof(nfsv2name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V3) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
-			if (opt_sleep && !has_stats(cltproc3info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v3_stats)) {
+			if (!opt_sleep || has_v3_stats) {
 				print_callstats(LABEL_cltproc3,
 					nfsv3name, cltproc3info + 1, 
 					sizeof(nfsv3name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V4) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
-			if (opt_sleep && !has_stats(cltproc4info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v4_stats)) {
+			if (!opt_sleep || has_v4_stats) {
 				print_callstats(LABEL_cltproc4,
 					nfscltproc4name, cltproc4info + 1,  
 					sizeof(nfscltproc4name)/sizeof(char *));
@@ -681,34 +673,28 @@ static void
 print_clnt_list(int opt_prt) 
 {
 	if (opt_prt & PRNT_CALLS) {
+		int has_v2_stats = has_stats(cltproc2info, CLTPROC2_SZ+2);
+		int has_v3_stats = has_stats(cltproc3info, CLTPROC3_SZ+2);
+		int has_v4_stats = has_stats(cltproc4info, CLTPROC4_SZ+2);
 		if ((opt_prt & PRNT_V2) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
-			if (opt_sleep && !has_stats(cltproc2info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v2_stats)) {
+			if (!opt_sleep || has_v2_stats) {
 				print_callstats_list("nfs v2 client",
 					nfsv2name, cltproc2info + 1,  
 					sizeof(nfsv2name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V3) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
-			if (opt_sleep && !has_stats(cltproc3info)) {
-				;
-			} else { 
+				((opt_prt & PRNT_AUTO) && has_v3_stats)) {
+			if (!opt_sleep || has_v3_stats) {
 				print_callstats_list("nfs v3 client",
 					nfsv3name, cltproc3info + 1, 
 					sizeof(nfsv3name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V4) || 
-				((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
-			if (opt_sleep && !has_stats(cltproc4info)) {
-				;
-			} else {
-				print_callstats_list("nfs v4 ops",
-					nfssrvproc4opname, srvproc4opsinfo + 1, 
-					sizeof(nfssrvproc4opname)/sizeof(char *));
+				((opt_prt & PRNT_AUTO) && has_v4_stats)) {
+			if (!opt_sleep || has_v4_stats) {
 				print_callstats_list("nfs v4 client",
 					nfscltproc4name, cltproc4info + 1,  
 					sizeof(nfscltproc4name)/sizeof(char *));
@@ -720,32 +706,32 @@ static void
 print_serv_list(int opt_prt) 
 {
 	if (opt_prt & PRNT_CALLS) {
+		int has_v2_stats = has_stats(srvproc2info, SRVPROC2_SZ+2);
+		int has_v3_stats = has_stats(srvproc3info, SRVPROC3_SZ+2);
+		int has_v4_stats = has_stats(srvproc4info, SRVPROC4_SZ+2);
 		if ((opt_prt & PRNT_V2) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc2info))) {
-			if (opt_sleep && !has_stats(srvproc2info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v2_stats)) {
+			if (!opt_sleep || has_v2_stats) {
 				print_callstats_list("nfs v2 server",
 					nfsv2name, srvproc2info + 1, 
 					sizeof(nfsv2name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V3) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc3info))) {
-			if (opt_sleep && !has_stats(srvproc3info)) {
-				;
-			} else {
+				((opt_prt & PRNT_AUTO) && has_v3_stats)) {
+			if (!opt_sleep || has_v3_stats) {
 				print_callstats_list("nfs v3 server",
 					nfsv3name, srvproc3info + 1, 
 					sizeof(nfsv3name)/sizeof(char *));
 			}
 		}
 		if ((opt_prt & PRNT_V4) || 
-				((opt_prt & PRNT_AUTO) && has_stats(srvproc4opsinfo))) {
-			if (opt_sleep && !has_stats(srvproc4info)) {
-				;
-			} else {
-				print_callstats_list("nfs v4 ops",
+				((opt_prt & PRNT_AUTO) && has_v4_stats)) {
+			if (!opt_sleep || has_v4_stats) {
+				print_callstats_list("nfs v4 server",
+					nfssrvproc4name, srvproc4info + 1, 
+					sizeof(nfssrvproc4name)/sizeof(char *));
+				print_callstats_list("nfs v4 servop",
 					nfssrvproc4opname, srvproc4opsinfo + 1, 
 					sizeof(nfssrvproc4opname)/sizeof(char *));
 			}
@@ -1054,9 +1040,9 @@ out:
  * there are stats if the sum's greater than the entry-count.
  */
 static int
-has_stats(const unsigned int *info)
+has_stats(const unsigned int *info, int nr)
 {
-	return (info[0] && info[info[0] + 1] > info[0]);
+	return (info[0] && info[nr-1] > info[0]);
 }
 static int
 has_rpcstats(const unsigned int *info, int size)
diff --git a/utils/nfsstat/nfsstat.man b/utils/nfsstat/nfsstat.man
index 52215a9..cd573b0 100644
--- a/utils/nfsstat/nfsstat.man
+++ b/utils/nfsstat/nfsstat.man
@@ -30,10 +30,12 @@ Print only NFS v2 statistics. The default is to only print information
 about the versions of \fBNFS\fR that have non-zero counts.
 .TP
 .B \-3
-Print only NFS v3 statistics. 
+Print only NFS v3 statistics. The default is to only print information
+about the versions of \fBNFS\fR that have non-zero counts.
 .TP
 .B \-4
-Print only NFS v4 statistics. 
+Print only NFS v4 statistics. The default is to only print information
+about the versions of \fBNFS\fR that have non-zero counts.
 .TP
 .B \-m, \-\-mounts
 Print information about each of the mounted \fBNFS\fR file systems.
-- 
1.7.3.2

