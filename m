From: Michael Haardt <michael@moria.de>
Subject: More readable nfsstat output
Date: Thu, 18 Aug 2005 15:54:03 +0200
Message-ID: <20050818135403.GA20006@fangorn.moria.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5uIa-0000Uk-GV
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 16:59:52 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5uIa-0004aT-8D
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 16:59:52 -0700
Received: from fangorn.moria.de ([194.97.106.210] ident=exim)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1E5kt4-0001f6-Vy
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 06:56:58 -0700
Received: from michael by fangorn.moria.de with local (ID michael) (Exim 4.51 #1)
	id 1E5kqJ-0005Cr-2R
	for nfs@lists.sourceforge.net; Thu, 18 Aug 2005 15:54:03 +0200
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hello,

here is a patch against 1.0.7 that enhances readability of nfsstat and
fixes the kernel problem of outputting negative numbers.  Please put me
on Cc:, as I am not subscribed to the list.

Michael

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfsstat.c.diff"

--- nfsstat.c.orig	2005-07-19 15:58:16.000000000 +0200
+++ nfsstat.c	2005-07-19 23:34:50.000000000 +0200
@@ -16,54 +16,57 @@
 #include <fcntl.h>
 #include <errno.h>
 
+#define INT unsigned long long
+#define INTFMT "llu"
+
 #define MAXNRVALS	32
 
-static unsigned int	svcv2info[19];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	cltv2info[19];	/* NFSv2 call counts ([0] == 18) */
-static unsigned int	svcv3info[23];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	cltv3info[23];	/* NFSv3 call counts ([0] == 22) */
-static unsigned int	svcnetinfo[4];	/* 0  # of received packets
-					 * 1  UDP packets
-					 * 2  TCP packets
-					 * 3  TCP connections
-					 */
-static unsigned int	cltnetinfo[4];	/* 0  # of received packets
-					 * 1  UDP packets
-					 * 2  TCP packets
-					 * 3  TCP connections
-					 */
-
-static unsigned int	svcrpcinfo[5];	/* 0  total # of RPC calls
-					 * 1  total # of bad calls
-					 * 2  bad format
-					 * 3  authentication failed
-					 * 4  unknown client
-					 */
-static unsigned int	cltrpcinfo[3];	/* 0  total # of RPC calls
-					 * 1  retransmitted calls
-					 * 2  cred refreshs
-					 */
-
-static unsigned int	svcrcinfo[8];	/* 0  repcache hits
-					 * 1  repcache hits
-					 * 2  uncached reqs
-					 * (for pre-2.4 kernels:)
-					 * 3  FH lookups
-					 * 4  'anon' FHs
-					 * 5  noncached non-directories
-					 * 6  noncached directories
-					 * 7  stale
-					 */
-
-static unsigned int	svcfhinfo[6];	/* (for kernels >= 2.4.0)
-					 * 0  stale
-					 * 1  FH lookups
-					 * 2  'anon' FHs
-					 * 3  noncached directories
-					 * 4  noncached non-directories
-					 * leave hole to relocate stale for order
-					 *    compatability.
-					 */
+static INT	svcv2info[19];	/* NFSv2 call counts ([0] == 18) */
+static INT	cltv2info[19];	/* NFSv2 call counts ([0] == 18) */
+static INT	svcv3info[23];	/* NFSv3 call counts ([0] == 22) */
+static INT	cltv3info[23];	/* NFSv3 call counts ([0] == 22) */
+static INT	svcnetinfo[4];	/* 0  # of received packets
+				 * 1  UDP packets
+				 * 2  TCP packets
+				 * 3  TCP connections
+				 */
+static INT	cltnetinfo[4];	/* 0  # of received packets
+				 * 1  UDP packets
+				 * 2  TCP packets
+				 * 3  TCP connections
+				 */
+
+static INT	svcrpcinfo[5];	/* 0  total # of RPC calls
+				 * 1  total # of bad calls
+				 * 2  bad format
+				 * 3  authentication failed
+				 * 4  unknown client
+				 */
+static INT	cltrpcinfo[3];	/* 0  total # of RPC calls
+				 * 1  retransmitted calls
+				 * 2  cred refreshs
+				 */
+
+static INT	svcrcinfo[8];	/* 0  repcache hits
+				 * 1  repcache hits
+				 * 2  uncached reqs
+				 * (for pre-2.4 kernels:)
+				 * 3  FH lookups
+				 * 4  'anon' FHs
+				 * 5  noncached non-directories
+				 * 6  noncached directories
+				 * 7  stale
+				 */
+
+static INT	svcfhinfo[6];	/* (for kernels >= 2.4.0)
+				 * 0  stale
+				 * 1  FH lookups
+				 * 2  'anon' FHs
+				 * 3  noncached directories
+				 * 4  noncached non-directories
+				 * leave hole to relocate stale for order
+				 *    compatability.
+				 */
 
 static const char *	nfsv2name[18] = {
 	"null", "getattr", "setattr", "root",   "lookup",  "readlink",
@@ -78,10 +81,30 @@
 	"fsstat", "fsinfo",  "pathconf", "commit"
 };
 
+static const char *	netinfo[] = {
+	"packets","udp","tcp","tcpconn"
+};
+
+static const char *	srpcinfo[] = {
+	"calls","badcalls","badauth","badclnt","xdrcall"
+};
+
+static const char *	crpcinfo[] = {
+	"calls","retrans","authrefresh",
+};
+
+static const char *	rcinfo[] = {
+	"hits","misses","nocache"
+};
+
+static const char *	fhinfo[] = {
+	"lookup","anon","ncachedir","ncachedir","stale"
+};
+
 typedef struct statinfo {
 	char		*tag;
 	int		nrvals;
-	unsigned int *	valptr;
+	INT *	valptr;
 } statinfo;
 
 static statinfo		svcinfo[] = {
@@ -102,14 +125,15 @@
 	{ NULL,		0,	0		}
 };
 
-static void		print_numbers(const char *, unsigned int *,
+static void		print_numbers(const char *, const char **, INT *,
 					unsigned int);
 static void		print_callstats(const char *, const char **,
-					unsigned int *, unsigned int);
+					INT *, unsigned int);
 static int		parse_statfile(const char *, struct statinfo *);
 
 static statinfo		*get_stat_info(const char *, struct statinfo *);
 
+static INT		number(const char *);
 
 #define PRNT_CALLS	0x0001
 #define PRNT_RPC	0x0002
@@ -209,22 +233,22 @@
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
-			"Server packet stats:\n"
-			"packets    udp        tcp        tcpconn\n",
+			"Server packet stats:\n",
+			netinfo,
 			svcnetinfo, 4
 			);
 		}
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
-			"Server rpc stats:\n"
-			"calls      badcalls   badauth    badclnt    xdrcall\n",
+			"Server rpc stats:\n",
+			srpcinfo,
 			svcrpcinfo, 5
 			);
 		}
 		if (opt_prt & PRNT_RC) {
 			print_numbers(
-			"Server reply cache:\n"
-			"hits       misses     nocache\n",
+			"Server reply cache:\n",
+			rcinfo,
 			svcrcinfo, 3
 			);
 		}
@@ -237,20 +261,20 @@
 		 */
 		if (opt_prt & PRNT_FH) {
 			if (get_stat_info("fh", svcinfo)) {	/* >= 2.4 */
-				int t = svcfhinfo[3];
+				INT t = svcfhinfo[3];
 				svcfhinfo[3]=svcfhinfo[4];
 				svcfhinfo[4]=t;
 				
 				svcfhinfo[5]=svcfhinfo[0]; /* relocate 'stale' */
 				
 				print_numbers(
-					"Server file handle cache:\n"
-					"lookup     anon       ncachedir ncachedir  stale\n",
+					"Server file handle cache:\n",
+					fhinfo,
 					svcfhinfo + 1, 5);
 			} else					/* < 2.4 */
 				print_numbers(
-					"Server file handle cache:\n"
-					"lookup     anon       ncachedir ncachedir  stale\n",
+					"Server file handle cache:\n",
+					fhinfo,
 					svcrcinfo + 3, 5);
 		}
 		if (opt_prt & PRNT_CALLS) {
@@ -269,15 +293,15 @@
 	if (opt_clt) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
-			"Client packet stats:\n"
-			"packets    udp        tcp        tcpconn\n",
+			"Client packet stats:\n",
+			netinfo,
 			cltnetinfo, 4
 			);
 		}
 		if (opt_prt & PRNT_RPC) {
 			print_numbers(
-			"Client rpc stats:\n"
-			"calls      retrans    authrefrsh\n",
+			"Client rpc stats:\n",
+			crpcinfo,
 			cltrpcinfo, 3
 			);
 		}
@@ -311,36 +335,39 @@
 }
 
 static void
-print_numbers(const char *hdr, unsigned int *info, unsigned int nr)
+print_numbers(const char *hdr, const char **names, INT *info, unsigned int nr)
 {
 	unsigned int	i;
 
 	fputs(hdr, stdout);
 	for (i = 0; i < nr; i++)
-		printf("%s%-8d", i? "   " : "", info[i]);
+		printf("%s%-12s",i? "   " : "", names[i]);
+	printf("\n");
+	for (i = 0; i < nr; i++)
+		printf("%s%-12" INTFMT "", i? "   " : "", info[i]);
 	printf("\n");
 }
 
 static void
 print_callstats(const char *hdr, const char **names,
-				 unsigned int *info, unsigned int nr)
+				 INT *info, unsigned int nr)
 {
-	unsigned long long	total;
-	unsigned long long	pct;
-	int		i, j;
+	INT	total;
+	INT	pct;
+	int	i, j;
 
 	fputs(hdr, stdout);
 	for (i = 0, total = 0; i < nr; i++)
 		total += info[i];
 	if (!total)
 		total = 1;
-	for (i = 0; i < nr; i += 6) {
-		for (j = 0; j < 6 && i + j < nr; j++)
-			printf("%-11s", names[i+j]);
+	for (i = 0; i < nr; i += 5) {
+		for (j = 0; j < 5 && i + j < nr; j++)
+			printf("%-15s", names[i+j]);
 		printf("\n");
-		for (j = 0; j < 6 && i + j < nr; j++) {
-			pct = ((unsigned long long) info[i+j]*100)/total;
-			printf("%-6d %2llu%% ", info[i+j], pct);
+		for (j = 0; j < 5 && i + j < nr; j++) {
+			pct = (info[i+j]*100)/total;
+			printf("%-10" INTFMT " %2" INTFMT "%% ", info[i+j], pct);
 		}
 		printf("\n");
 	}
@@ -381,10 +408,22 @@
 		for (i = 0; i < cnt; i++) {
 			if (!(sp = strtok(NULL, " \t")))
 				break;
-			ip->valptr[i] = atoi(sp);
+			ip->valptr[i] = number(sp);
 		}
 	}
 
 	fclose(fp);
 	return 1;
 }
+
+static INT
+number(const char *s)
+{
+	int signed_int_hack=0;
+	INT n;
+
+	if (*s=='-') { signed_int_hack=1; ++s; }
+	for (n=0; *s>='0' && *s<='9'; ++s) n=10*n+(*s-'0');
+	if (signed_int_hack) n=(unsigned int)-((signed int)n);
+	return n;
+}

--bg08WKrSYDhXBjb5--


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
