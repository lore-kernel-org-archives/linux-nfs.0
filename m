From: Steve Dickson <SteveD@redhat.com>
Subject: Re: NFS admin for Linux
Date: Fri, 02 Apr 2004 13:43:50 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <406DB466.4070302@RedHat.com>
References: <200404021759.38269.frederic.jolly@ext.bull.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060404030801060107090702"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B9TeX-0003Y4-Nu
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 10:44:29 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1B9TeX-00045O-69
	for nfs@lists.sourceforge.net; Fri, 02 Apr 2004 10:44:29 -0800
To: Jolly Frederic <frederic.jolly@ext.bull.net>
In-Reply-To: <200404021759.38269.frederic.jolly@ext.bull.net>
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

This is a multi-part message in MIME format.
--------------060404030801060107090702
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Jolly Frederic wrote:

>First of all, I'd like to know if the commands showmount and nfsstat have been 
>updated for NFSv4? Are there people currently working on them?
>  
>
no... nfsstat has not been updated to use show v4 stats...

But I've recently purposed a nfs zero stats patch that does that
will zero out the v2/v3 status and only prints non-zero stats
which is really needed for the v4 support... imho... so you
don't get screens and screens of zero stats when only one
version of the protocol is being used...

Also only displaying non-zero stats will allow a realtime
(top like) interface that could be used to monitoring
NFS traffic... Way back when... I did something similar
to another nfsstat... It actually sorted the output so you
could tell (in realtime) which were the most active opts.
I found it be pretty handy tool...


SteveD.

--------------060404030801060107090702
Content-Type: text/plain;
 name="nfs-utils-1.0.6-zerostats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs-utils-1.0.6-zerostats.patch"

--- ./utils/nfsstat/nfsstat.man.orig	2003-12-30 05:54:35.000000000 -0500
+++ ./utils/nfsstat/nfsstat.man	2003-12-30 10:28:46.000000000 -0500
@@ -13,6 +13,9 @@ The
 displays statistics kept about NFS client and server activity.
 .SH OPTIONS
 .TP
+.B -a
+Print all statistics.
+.TP
 .B -s
 Print only server-side statistics. The default is to print both server and
 client statistics.
@@ -49,6 +52,20 @@ total number of lookups, and the number 
 Usage information on the server's request reply cache, including the
 total number of lookups, and the number of hits and misses.
 .RE
+.TP
+.B -z
+Zeros out all or some of the statistics. Typical uses would be:
+.RS 10
+nfsstat -z  - zeros all statistics
+.br
+nfsstat -zc - zeros only client statistics
+.br
+nfsstat -zs - zeros only server statistics
+.br
+nfsstat -zr - zeros only RPC statistics
+.br
+nfsstat -zn - zeros only NFS call statistics
+.RE
 .SH EXAMPLES
 .\" --------------------- FILES ----------------------------------
 .SH FILES
--- ./utils/nfsstat/nfsstat.c.orig	2003-12-30 05:54:35.000000000 -0500
+++ ./utils/nfsstat/nfsstat.c	2003-12-30 10:25:44.000000000 -0500
@@ -107,6 +107,7 @@ static void		print_numbers(const char *,
 static void		print_callstats(const char *, const char **,
 					unsigned int *, unsigned int);
 static int		parse_statfile(const char *, struct statinfo *);
+static int      zero_statfile(int, int , int);
 
 static statinfo		*get_stat_info(const char *, struct statinfo *);
 
@@ -118,6 +119,8 @@ static statinfo		*get_stat_info(const ch
 #define PRNT_RC		0x0010
 #define PRNT_ALL	0xffff
 
+static int	opt_prt = 0;
+
 int
 main(int argc, char **argv)
 {
@@ -126,7 +129,7 @@ main(int argc, char **argv)
 			opt_clt = 0,
 			srv_info = 0,
 			clt_info = 0,
-			opt_prt = 0;
+			opt_zero = 0;
 	int		c;
 
 	while ((c = getopt(argc, argv, "acno:rsz")) != -1) {
@@ -164,9 +167,8 @@ main(int argc, char **argv)
 			opt_srv = 1;
 			break;
 		case 'z':
-			fprintf(stderr, "nfsstat: zeroing of nfs statistics "
-					"not yet supported\n");
-			return 2;
+			opt_zero = 1;
+			break;
 		}
 	}
 
@@ -186,6 +188,12 @@ main(int argc, char **argv)
 			"server.\n");
 	}
 
+	if (opt_zero) {
+		if (opt_srv || opt_clt) {
+			if (zero_statfile(opt_srv, opt_clt, opt_prt))
+				return 1;
+		}
+	}
 	if (opt_srv) {
 		srv_info = parse_statfile(NFSSVCSTAT, svcinfo);
 		if (srv_info == 0 && opt_clt == 0) {
@@ -206,6 +214,7 @@ main(int argc, char **argv)
 			opt_clt = 0;
 	}
 
+
 	if (opt_srv) {
 		if (opt_prt & PRNT_NET) {
 			print_numbers(
@@ -329,11 +338,15 @@ print_callstats(const char *hdr, const c
 	unsigned long long	pct;
 	int		i, j;
 
-	fputs(hdr, stdout);
 	for (i = 0, total = 0; i < nr; i++)
 		total += info[i];
+	if ((opt_prt & PRNT_ALL) != PRNT_ALL) {
+		if (!total)
+			return;
+	}
 	if (!total)
 		total = 1;
+	fputs(hdr, stdout);
 	for (i = 0; i < nr; i += 6) {
 		for (j = 0; j < 6 && i + j < nr; j++)
 			printf("%-11s", names[i+j]);
@@ -346,6 +359,93 @@ print_callstats(const char *hdr, const c
 	}
 	printf("\n");
 }
+static int
+zero_statfile(int opt_srv, int opt_clt, int what)
+{
+	FILE	*fp=NULL;
+	struct  stat sb;
+
+	if (getuid() != 0) {
+		fprintf(stderr, "nfsstat: Only root can zero nfs statistics\n");
+		return 1;
+	}
+	if (opt_srv) {
+		/*
+		 * See if NFSSVCSTAT exists. If so, get the mode bits and open it
+		 */
+		if (stat(NFSSVCSTAT, &sb) < 0) {
+			if (!opt_clt) {
+				switch(errno) {
+				case ENOENT: 
+					fprintf(stderr, "nfsstat: Server not started\n");
+					break;
+				default:
+					fprintf(stderr, "nfsstat: Unable to stat statistics file: %s: %m\n",
+						NFSSVCSTAT);
+					break;
+				}
+				return 1;
+			}
+			goto next;
+		}
+		/* 
+		 * Check the to see if it's writeable. If not 
+		 * this means the RPC module does not support zeroing.
+		 */
+		if (!(sb.st_mode & S_IWUSR)) {
+				fprintf(stderr, "nfsstat: zeroing of nfs server statistics is not supported\n");
+			if (!opt_clt)
+				return 1;
+			goto next;
+		}
+		if ((fp = fopen(NFSSVCSTAT, "w")) != NULL) {
+			fprintf(fp,"%x", what);
+			fclose(fp);
+		} else {
+			fprintf(stderr, "nfsstat: Unable open server statistics file: %s: %m\n", NFSSVCSTAT);
+			if (!opt_clt)
+				return 1;
+		}
+	}
+next:
+
+	if (opt_clt) {
+		/*
+		 * See if NFSCLTSTAT exists. If so, get the mode bits and open it
+		 */
+		if (stat(NFSCLTSTAT, &sb) < 0) {
+			if (!opt_srv) {
+				switch(errno) {
+				case ENOENT: 
+					fprintf(stderr, "nfsstat: No NFS filesystems mounted\n");
+					break;
+				default:
+					fprintf(stderr, "nfsstat: Unable open statistics file: %s: %m\n",
+						NFSSVCSTAT);
+					break;
+				}
+			}
+			return 1;
+		} 
+		/* 
+		 * Check the to see if it's writeable. If not 
+		 * this means the RPC module does not support zeroing.
+		 */
+		if (!(sb.st_mode & S_IWUSR)) {
+			fprintf(stderr, "nfsstat: zeroing of nfs client statistics is not supported\n");
+			return 1;
+		}
+		if ((fp = fopen(NFSCLTSTAT, "w")) != NULL) {
+			fprintf(fp,"%x", what);
+			fclose(fp);
+		} else {
+			fprintf(stderr, "nfsstat: Unable open client statistics file: %s: %m\n", NFSSVCSTAT);
+			return 1;
+		}
+	}
+
+	return 0;
+}
 
 
 static int

--------------060404030801060107090702--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
