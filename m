From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/3] nfsstat: The --list option does not work on server stats.
Date: Wed, 08 Apr 2009 12:01:26 -0400
Message-ID: <49DCCA56.9040208@RedHat.com>
References: <49DCB9DA.5000300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36601 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751462AbZDHQEU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2009 12:04:20 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n38G4JaO026514
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:04:19 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n38G4Ecu029165
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:04:15 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-147.bos.redhat.com [10.16.10.147])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n38G4CV4032564
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:04:12 -0400
In-Reply-To: <49DCB9DA.5000300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The print_stats_list() routine was using the client's
stats to decide whether to display any stats. This did
not work when there was only server stats.
    
This patch breaks up print_stats_list into two different
routines allowing both server and clients stats to be
listed.
    
Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 5adb571..7e9f327 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -170,7 +170,7 @@ DECLARE_CLT(cltinfo, _old);
 static void		print_all_stats(int, int, int);
 static void		print_server_stats(int, int);
 static void		print_client_stats(int, int);
-static void		print_stats_list(int);
+static void		print_stats_list(int, int, int);
 static void		print_numbers(const char *, unsigned int *,
 					unsigned int);
 static void		print_callstats(const char *, const char **,
@@ -436,7 +436,7 @@ main(int argc, char **argv)
 				diff_stats(clientinfo_tmp, clientinfo, 0);
 			}
 			if (opt_list) {
-				print_stats_list(opt_prt);
+				print_stats_list(opt_srv, opt_clt, opt_prt);
 			} else {
 				print_all_stats(opt_srv, opt_clt, opt_prt);
 			}
@@ -451,7 +451,7 @@ main(int argc, char **argv)
 		}	
 	} else {
 		if (opt_list) {
-			print_stats_list(opt_prt);
+			print_stats_list(opt_srv, opt_clt, opt_prt);
 		} else {
 			print_all_stats(opt_srv, opt_clt, opt_prt);
 		}
@@ -606,7 +606,7 @@ print_client_stats(int opt_clt, int opt_prt)
 			if (opt_sleep && !has_stats(cltproc3info)) {
 				;
 			} else {
-				print_callstats( LABEL_cltproc3,
+				print_callstats(LABEL_cltproc3,
 					nfsv3name, cltproc3info + 1, 
 					sizeof(nfsv3name)/sizeof(char *));
 			}
@@ -625,38 +625,89 @@ print_client_stats(int opt_clt, int opt_prt)
 }
 
 static void
-print_stats_list(int opt_prt) 
+print_clnt_list(int opt_prt) 
 {
 	if (opt_prt & PRNT_CALLS) {
-		if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
-			print_callstats_list(
-			"nfs v2 server",
-			nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *));
-			print_callstats_list(
-			"nfs v2 client",
-			nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *));
+		if ((opt_prt & PRNT_V2) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
+			if (opt_sleep && !has_stats(cltproc2info)) {
+				;
+			} else {
+				print_callstats_list("nfs v2 client",
+					nfsv2name, cltproc2info + 1,  
+					sizeof(nfsv2name)/sizeof(char *));
+			}
+		}
+		if ((opt_prt & PRNT_V3) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
+			if (opt_sleep && !has_stats(cltproc3info)) {
+				;
+			} else { 
+				print_callstats_list("nfs v3 client",
+					nfsv3name, cltproc3info + 1, 
+					sizeof(nfsv3name)/sizeof(char *));
+			}
+		}
+		if ((opt_prt & PRNT_V4) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
+			if (opt_sleep && !has_stats(cltproc4info)) {
+				;
+			} else {
+				print_callstats_list("nfs v4 ops",
+					nfssrvproc4opname, srvproc4opsinfo + 1, 
+					sizeof(nfssrvproc4opname)/sizeof(char *));
+				print_callstats_list("nfs v4 client",
+					nfscltproc4name, cltproc4info + 1,  
+					sizeof(nfscltproc4name)/sizeof(char *));
+			}
+		}
+	}
+}
+static void
+print_serv_list(int opt_prt) 
+{
+	if (opt_prt & PRNT_CALLS) {
+		if ((opt_prt & PRNT_V2) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc2info))) {
+			if (opt_sleep && !has_stats(srvproc2info)) {
+				;
+			} else {
+				print_callstats_list("nfs v2 server",
+					nfsv2name, srvproc2info + 1, 
+					sizeof(nfsv2name)/sizeof(char *));
+			}
 		}
-		if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
-			print_callstats_list(
-			"nfs v3 server",
-			nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
-			print_callstats_list(
-			"nfs v3 client",
-			nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
+		if ((opt_prt & PRNT_V3) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc3info))) {
+			if (opt_sleep && !has_stats(srvproc3info)) {
+				;
+			} else {
+				print_callstats_list("nfs v3 server",
+					nfsv3name, srvproc3info + 1, 
+					sizeof(nfsv3name)/sizeof(char *));
+			}
 		}
-		if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
-			print_callstats_list(
-			"nfs v4 server",
-			nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *));
-			print_callstats_list(
-			"nfs v4 ops",
-			nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *));
-			print_callstats_list(
-			"nfs v4 client",
-			nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *));
+		if ((opt_prt & PRNT_V4) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc4opsinfo))) {
+			if (opt_sleep && !has_stats(srvproc4info)) {
+				;
+			} else {
+				print_callstats_list("nfs v4 ops",
+					nfssrvproc4opname, srvproc4opsinfo + 1, 
+					sizeof(nfssrvproc4opname)/sizeof(char *));
+			}
 		}
 	}
 }
+static void
+print_stats_list(int opt_srv, int opt_clt, int opt_prt) 
+{
+	if (opt_srv)
+		print_serv_list(opt_prt);
+
+	if (opt_clt)
+		print_clnt_list(opt_prt);
+}
 
 static statinfo *
 get_stat_info(const char *sp, struct statinfo *statp)
