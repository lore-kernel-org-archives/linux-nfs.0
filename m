From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 3/3] nfsstat: Eliminate the displaying zero stats
Date: Wed, 08 Apr 2009 12:05:08 -0400
Message-ID: <49DCCB34.4080901@RedHat.com>
References: <49DCB9DA.5000300@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48391 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752080AbZDHQHy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Apr 2009 12:07:54 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n38G7swq027636
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:07:54 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n38G7tKl030324
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:07:56 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-147.bos.redhat.com [10.16.10.147])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n38G7rQj000896
	for <linux-nfs@vger.kernel.org>; Wed, 8 Apr 2009 12:07:54 -0400
In-Reply-To: <49DCB9DA.5000300-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eliminate the displaying zero stats when the explicit protocol
is specified (-2, -3, -4) the -Z and or --list options.
    
When a particular protocol is specified and either
the -Z or --list options are used, zeros or blank lines
are echoed to the screen when there is not any NFS traffic.
This cause any useful data to be scroll off the screen.
    
With this patch only non-zero stats will be shown, which
makes the output of these options more condensed and
in turn more useful.
    
Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index d5bdad7..6d81f66 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -466,79 +466,96 @@ print_all_stats (int opt_srv, int opt_clt, int opt_prt)
 static void 
 print_server_stats(int opt_srv, int opt_prt) 
 {
-	if (opt_srv) {
-		if (opt_prt & PRNT_NET) {
-			print_numbers(
-			LABEL_srvnet
-			"packets    udp        tcp        tcpconn\n",
-			srvnetinfo, 4
-			);
+	if (!opt_srv)
+		return;
+
+	if (opt_prt & PRNT_NET) {
+		if (opt_sleep && !has_rpcstats(srvnetinfo, 4)) {
+		} else {
+			print_numbers( LABEL_srvnet
+				"packets    udp        tcp        tcpconn\n",
+			srvnetinfo, 4);
 			printf("\n");
 		}
-		if (opt_prt & PRNT_RPC) {
-			if (!opt_sleep && !has_rpcstats(srvrpcinfo, 5)) {
-				print_numbers(
-				LABEL_srvrpc
+	}
+	if (opt_prt & PRNT_RPC) {
+		if (opt_sleep && !has_rpcstats(srvrpcinfo, 5)) {
+			;
+		} else {
+			print_numbers(LABEL_srvrpc
 				"calls      badcalls   badauth    badclnt    xdrcall\n",
-				srvrpcinfo, 5
-				);
-				printf("\n");
-			}
+				srvrpcinfo, 5);
+			printf("\n");
 		}
-		if (opt_prt & PRNT_RC) {
-			print_numbers(
-			LABEL_srvrc
-			"hits       misses     nocache\n",
-			srvrcinfo, 3
-			);
+	}
+	if (opt_prt & PRNT_RC) {
+		if (opt_sleep && !has_rpcstats(srvrcinfo, 3)) {
+			;
+		} else {
+			print_numbers(LABEL_srvrc
+				"hits       misses     nocache\n",
+				srvrcinfo, 3);
 			printf("\n");
 		}
+	}
 
-		/*
-		 * 2.2 puts all fh-related info after the 'rc' header
-		 * 2.4 puts all fh-related info after the 'fh' header, but relocates
-		 *     'stale' to the start and swaps dir and nondir :-(  
-		 *     We preseve the 2.2 order
-		 */
-		if (opt_prt & PRNT_FH) {
-			if (get_stat_info("fh", srvinfo)) {	/* >= 2.4 */
-				int t = srvfhinfo[3];
-				srvfhinfo[3]=srvfhinfo[4];
-				srvfhinfo[4]=t;
-				
-				srvfhinfo[5]=srvfhinfo[0]; /* relocate 'stale' */
-				
-				print_numbers(
-					LABEL_srvfh
-					"lookup     anon       ncachedir  ncachedir  stale\n",
-					srvfhinfo + 1, 5);
-			} else					/* < 2.4 */
-				print_numbers(
-					LABEL_srvfh
-					"lookup     anon       ncachedir  ncachedir  stale\n",
-					srvrcinfo + 3, 5);
-			printf("\n");
+	/*
+	 * 2.2 puts all fh-related info after the 'rc' header
+	 * 2.4 puts all fh-related info after the 'fh' header, but relocates
+	 *     'stale' to the start and swaps dir and nondir :-(  
+	 *     We preseve the 2.2 order
+	 */
+	if (opt_prt & PRNT_FH) {
+		if (get_stat_info("fh", srvinfo)) {	/* >= 2.4 */
+			int t = srvfhinfo[3];
+			srvfhinfo[3]=srvfhinfo[4];
+			srvfhinfo[4]=t;
+			
+			srvfhinfo[5]=srvfhinfo[0]; /* relocate 'stale' */
+			
+			print_numbers(
+				LABEL_srvfh
+				"lookup     anon       ncachedir  ncachedir  stale\n",
+				srvfhinfo + 1, 5);
+		} else					/* < 2.4 */
+			print_numbers(
+				LABEL_srvfh
+				"lookup     anon       ncachedir  ncachedir  stale\n",
+				srvrcinfo + 3, 5);
+		printf("\n");
+	}
+	if (opt_prt & PRNT_CALLS) {
+		if ((opt_prt & PRNT_V2) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc2info))) {
+			if (opt_sleep && !has_stats(srvproc2info)) {
+				;
+			} else {
+				print_callstats(LABEL_srvproc2,
+					nfsv2name, srvproc2info + 1, 
+					sizeof(nfsv2name)/sizeof(char *));
+			}
+		}
+		if ((opt_prt & PRNT_V3) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc3info))) {
+			if (opt_sleep && !has_stats(srvproc3info)) {
+				;
+			} else {
+				print_callstats(LABEL_srvproc3,
+					nfsv3name, srvproc3info + 1, 
+					sizeof(nfsv3name)/sizeof(char *));
+			}
 		}
-		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc2info)))
-				print_callstats(
-				LABEL_srvproc2,
-				nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *)
-				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc3info)))
-				print_callstats(
-				LABEL_srvproc3,
-				nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
-				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(srvproc4info))) {
-				print_callstats(
-				LABEL_srvproc4,
-				nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *)
-				);
-				print_callstats(
-				LABEL_srvproc4ops,
-				nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *)
-				);
+		if ((opt_prt & PRNT_V4) || 
+				((opt_prt & PRNT_AUTO) && has_stats(srvproc4info))) {
+			if (opt_sleep && !has_stats(srvproc4info)) {
+				;
+			} else {
+				print_callstats( LABEL_srvproc4,
+					nfssrvproc4name, srvproc4info + 1, 
+					sizeof(nfssrvproc4name)/sizeof(char *));
+				print_callstats(LABEL_srvproc4ops,
+					nfssrvproc4opname, srvproc4opsinfo + 1, 
+					sizeof(nfssrvproc4opname)/sizeof(char *));
 			}
 		}
 	}
@@ -546,41 +563,59 @@ print_server_stats(int opt_srv, int opt_prt)
 static void
 print_client_stats(int opt_clt, int opt_prt) 
 {
-	if (opt_clt) {
-		if (opt_prt & PRNT_NET) {
-			print_numbers(
-			LABEL_cltnet
-			"packets    udp        tcp        tcpconn\n",
-			cltnetinfo, 4
-			);
+	if (!opt_clt)
+		return;
+
+	if (opt_prt & PRNT_NET) {
+		if (opt_sleep && !has_rpcstats(cltnetinfo, 4)) {
+			;
+		} else { 
+			print_numbers(LABEL_cltnet
+				"packets    udp        tcp        tcpconn\n",
+				cltnetinfo, 4);
 			printf("\n");
 		}
-		if (opt_prt & PRNT_RPC) {
-			if (!opt_sleep && !has_rpcstats(cltrpcinfo, 3)) {
-				print_numbers(
-				LABEL_cltrpc
+	}
+	if (opt_prt & PRNT_RPC) {
+		if (opt_sleep && !has_rpcstats(cltrpcinfo, 3)) {
+			;
+		} else {
+			print_numbers(LABEL_cltrpc
 				"calls      retrans    authrefrsh\n",
-				cltrpcinfo, 3
-				);
-				printf("\n");
+				cltrpcinfo, 3);
+			printf("\n");
+		}
+	}
+	if (opt_prt & PRNT_CALLS) {
+		if ((opt_prt & PRNT_V2) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc2info))) {
+			if (opt_sleep && !has_stats(cltproc2info)) {
+				;
+			} else {
+				print_callstats(LABEL_cltproc2,
+					nfsv2name, cltproc2info + 1,  
+					sizeof(nfsv2name)/sizeof(char *));
+			}
+		}
+		if ((opt_prt & PRNT_V3) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
+			if (opt_sleep && !has_stats(cltproc3info)) {
+				;
+			} else {
+				print_callstats( LABEL_cltproc3,
+					nfsv3name, cltproc3info + 1, 
+					sizeof(nfsv3name)/sizeof(char *));
 			}
 		}
-		if (opt_prt & PRNT_CALLS) {
-			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info)))
-				print_callstats(
-				LABEL_cltproc2,
-				nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *)
-				);
-			if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info)))
-				print_callstats(
-				LABEL_cltproc3,
-				nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *)
-				);
-			if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info)))
-				print_callstats(
-				LABEL_cltproc4,
-				nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *)
-				);
+		if ((opt_prt & PRNT_V4) || 
+				((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
+			if (opt_sleep && !has_stats(cltproc4info)) {
+				;
+			} else {
+				print_callstats(LABEL_cltproc4,
+					nfscltproc4name, cltproc4info + 1,  
+					sizeof(nfscltproc4name)/sizeof(char *));
+			}
 		}
 	}
 }
@@ -593,35 +628,28 @@ print_stats_list(int opt_prt)
 			print_callstats_list(
 			"nfs v2 server",
 			nfsv2name, srvproc2info + 1, sizeof(nfsv2name)/sizeof(char *));
-			printf("\n");
 			print_callstats_list(
 			"nfs v2 client",
 			nfsv2name, cltproc2info + 1,  sizeof(nfsv2name)/sizeof(char *));
-			printf("\n");
 		}
 		if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc3info))) {
 			print_callstats_list(
 			"nfs v3 server",
 			nfsv3name, srvproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
-			printf("\n");
 			print_callstats_list(
 			"nfs v3 client",
 			nfsv3name, cltproc3info + 1, sizeof(nfsv3name)/sizeof(char *));
-			printf("\n");
 		}
 		if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc4info))) {
 			print_callstats_list(
 			"nfs v4 server",
 			nfssrvproc4name, srvproc4info + 1, sizeof(nfssrvproc4name)/sizeof(char *));
-			printf("\n");
 			print_callstats_list(
 			"nfs v4 ops",
 			nfssrvproc4opname, srvproc4opsinfo + 1, sizeof(nfssrvproc4opname)/sizeof(char *));
-			printf("\n");
 			print_callstats_list(
 			"nfs v4 client",
 			nfscltproc4name, cltproc4info + 1,  sizeof(nfscltproc4name)/sizeof(char *));
-			printf("\n");
 		}
 	}
 }
@@ -686,11 +714,15 @@ print_callstats_list(const char *hdr, const char **names,
 	for (i = 0, calltotal = 0; i < nr; i++) {
 		calltotal += callinfo[i];
 	}
+	if (!calltotal)
+		return;
 	printf("%13s %13s %8llu \n", hdr, "total:", calltotal);
 	printf("------------- ------------- --------\n");
 	for (i = 0; i < nr; i++) {
-			printf("%13s %12s: %8u \n", hdr, names[i], callinfo[i]);
+			if (callinfo[i])
+				printf("%13s %12s: %8u \n", hdr, names[i], callinfo[i]);
 	}
+	printf("\n");
 		
 }
 
