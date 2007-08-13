From: "david m. richter" <richterd@citi.umich.edu>
Subject: [PATCH 5/5] nfsstat: Add -S/--since flag.
Date: Mon, 13 Aug 2007 15:16:14 -0400 (EDT)
Message-ID: <Pine.BSO.4.64.0708131509010.6965@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IKfOf-000243-Q4
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:16:14 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IKfOh-0001SA-EB
	for nfs@lists.sourceforge.net; Mon, 13 Aug 2007 12:16:18 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

	Read statistics from the file given with -S/--since and display 
the difference between those and the current statistics.  Valid stat files 
are those in the form of /proc/net/rpc/nfs, /proc/net/rpc/nfsd, or any 
"pretty" output from nfsstat itself.  Statistics that are missing from a 
"pretty" stat file are treated as zeroes.

	Similar to Neil Brown's suggestion, one might use this in 
conjunction with watch(1) like this:

$ watch "nfsstat --since /tmp/stats; nfsstat >/tmp/stats"


Signed-off-by: David M. Richter <richterd@citi.umich.edu>

---
 utils/nfsstat/nfsstat.c |  152 +++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 134 insertions(+), 18 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index c6f2ace..828119b 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -171,7 +171,8 @@ static void		print_numbers(const char *,
 					unsigned int);
 static void		print_callstats(const char *, const char **,
 					unsigned int *, unsigned int);
-static int		parse_statfile(const char *, struct statinfo *);
+static int		parse_raw_statfile(const char *, struct statinfo *);
+static int 		parse_pretty_statfile(const char *, struct statinfo *);
 
 static statinfo		*get_stat_info(const char *, struct statinfo *);
 
@@ -222,7 +223,8 @@ void usage(char *name)
   -v, --verbose, --all\tSame as '-o all'\n\
   -r, --rpc\t\tShow RPC statistics\n\
   -n, --nfs\t\tShow NFS statistics\n\
-  -Z, --sleep\tSaves stats, pauses, diffs current and saved\n\
+  -Z, --sleep\t\tSaves stats, pauses, diffs current and saved\n\
+  -S, --since file\tShows difference between current stats and those in 'file'\n\
   --version\t\tShow program version\n\
   --help\t\tWhat you just did\n\
 \n", name);
@@ -244,6 +246,7 @@ static struct option longopts[] =
 	{ "help", 0, 0, '\1' },
 	{ "version", 0, 0, '\2' },
 	{ "sleep", 0, 0, 'Z' },
+	{ "since", 1, 0, 'S' },
 	{ NULL, 0, 0, 0 }
 };
 
@@ -254,9 +257,12 @@ main(int argc, char **argv)
 			opt_srv = 0,
 			opt_clt = 0,
 			opt_prt = 0,
-			opt_sleep = 0;
+			opt_sleep = 0,
+			opt_since = 0;
 	int		c;
-	char           *progname;
+	char           *progname,
+		       *serverfile = NFSSRVSTAT,
+		       *clientfile = NFSCLTSTAT;
 
 	struct statinfo *serverinfo = srvinfo,
 			*serverinfo_tmp = srvinfo_old,
@@ -273,7 +279,7 @@ main(int argc, char **argv)
 	else
 		progname = argv[0];
 
-	while ((c = getopt_long(argc, argv, "234acmno:Zvrsz\1\2", longopts, NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:ZS:vrsz\1\2", longopts, NULL)) != EOF) {
 		switch (c) {
 		case 'a':
 			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -306,6 +312,11 @@ main(int argc, char **argv)
 		case 'Z':
 			opt_sleep = 1;
 			break;
+		case 'S':
+			opt_since = 1;
+			serverfile = optarg;
+			clientfile = optarg;
+			break;
 		case '2':
 		case '3':
 		case '4':
@@ -361,7 +372,7 @@ main(int argc, char **argv)
 			"server.\n");
 	}
 
-	if (opt_sleep) {
+	if (opt_since || opt_sleep) {
 		serverinfo = srvinfo_old;
 		serverinfo_tmp = srvinfo;
 		clientinfo = cltinfo_old;
@@ -369,11 +380,10 @@ main(int argc, char **argv)
 	}
 
 	if (opt_srv)
-		get_stats(NFSSRVSTAT, serverinfo, &opt_srv, opt_clt, 1);
+		get_stats(serverfile, serverinfo, &opt_srv, opt_clt, 1);
 	if (opt_clt)
-		get_stats(NFSCLTSTAT, clientinfo, &opt_clt, opt_srv, 0);
+		get_stats(clientfile, clientinfo, &opt_clt, opt_srv, 0);
 
-	/* save stat snapshots; wait for signal; then diff current and saved stats */
 	if (opt_sleep) {
 		starttime = time(NULL);
 		printf("Collecting statistics; press CTRL-C to view results from interval (i.e., from pause to CTRL-C).\n");
@@ -382,6 +392,9 @@ main(int argc, char **argv)
 			return 1;
 		}
 		pause();
+	}
+
+	if (opt_since || opt_sleep) {
 		if (opt_srv) {
 			get_stats(NFSSRVSTAT, serverinfo_tmp, &opt_srv, opt_clt, 1);
 			diff_stats(serverinfo_tmp, serverinfo, 1);
@@ -556,9 +569,9 @@ print_callstats(const char *hdr, const c
 	printf("\n");
 }
 
-
+/* returns 0 on success, 1 otherwise */
 static int
-parse_statfile(const char *name, struct statinfo *statp)
+parse_raw_statfile(const char *name, struct statinfo *statp)
 {
 	char	buffer[4096], *next;
 	FILE	*fp;
@@ -568,7 +581,7 @@ parse_statfile(const char *name, struct
 	 */
 	if ((fp = fopen(name, "r")) == NULL) {
 		// fprintf(stderr, "Warning: %s: %m\n", name);
-		return 0;
+		return 1;
 	}
 
 	while (fgets(buffer, sizeof(buffer), fp) != NULL) {
@@ -598,7 +611,79 @@ parse_statfile(const char *name, struct
 	}
 
 	fclose(fp);
-	return 1;
+	return 0;
+}
+
+/* returns 0 on success, 1 otherwise */
+static int
+parse_pretty_statfile(const char *filename, struct statinfo *info)
+{
+	int numvals, curindex, numconsumed, n, sum, err = 1;
+	char buf[4096], *bufp, *fmt, is_proc;
+	FILE *fp = NULL;
+	struct statinfo *ip;
+
+	if ((fp = fopen(filename, "r")) == NULL)
+		//err(2, "Unable to open statfile '%s'.\n", filename);
+		goto out;
+
+	while (fgets(buf, sizeof(buf), fp) != NULL) {
+		for (ip = info; ip->tag; ip++) {
+			if (strcmp(buf, ip->label))
+				continue;
+
+			sum = 0;
+			numvals = ip->nrvals - 1;
+			is_proc = strncmp("proc", ip->tag, 4) ? 0 : 1;
+			if (is_proc) {
+				fmt = " %u %*u%% %n";
+				curindex = 1;
+				ip->valptr[0] = 0;
+			} else {
+				fmt = " %u %n";
+				curindex = 0;
+			}
+more_stats:
+			/* get (and skip) header */
+			if (fgets(buf, sizeof(buf), fp) == NULL) {
+				fprintf(stderr, "Failed to locate header after "
+						"label for '%s' in %s.\n",
+						ip->tag, filename);
+				goto out;
+			}
+			/* no header -- done with this "tag" */
+			if (*buf == '\n') {
+				ip->valptr[numvals] = sum;
+				break;
+			}
+			/* get stats */
+			if (fgets(buf, sizeof(buf), fp) == NULL) {
+				fprintf(stderr, "Failed to locate stats after "
+						"header for '%s' in %s.\n",
+						ip->tag, filename);
+				goto out;
+			}
+			bufp = buf;
+			for (; curindex < numvals; curindex++) {
+				n = sscanf(bufp, fmt, &ip->valptr[curindex],
+						&numconsumed);
+				if (n != 1)
+					break;
+				if (is_proc) {
+					ip->valptr[0]++;
+					sum++;
+				}
+				sum += ip->valptr[curindex];
+				bufp += numconsumed;
+			}
+			goto more_stats;
+		}
+	}
+	err = 0;
+out:
+	if (fp)
+		fclose(fp);
+	return err;
 }
 
 static int
@@ -653,11 +738,42 @@ static void
 get_stats(const char *file, struct statinfo *info, int *opt, int other_opt,
 		int is_srv)
 {
-	const char *label = is_srv ? "Server" : "Client";
-
-	if (!parse_statfile(file, info)) {
+	FILE *fp;
+	char buf[10];
+	int err = 1;
+	char *label = is_srv ? "Server" : "Client";
+
+	/* try to guess what type of stat file we're dealing with */
+	if ((fp = fopen(file, "r")) == NULL)
+		goto out;
+	if (fgets(buf, 10, fp) == NULL)
+		goto out;
+	if (!strncmp(buf, "net ", 4)) {
+		/* looks like raw client stats */
+		if (is_srv) {
+			fprintf(stderr, "Warning: no server info present in "
+					"raw client stats file.\n");
+			*opt = 0;
+		} else
+			err = parse_raw_statfile(file, info);
+	} else if (!strncmp(buf, "rc ", 3)) {
+		/* looks like raw server stats */
+		if (!is_srv) {
+			fprintf(stderr, "Warning: no client info present in "
+					"raw server stats file.\n");
+			*opt = 0;
+		} else
+			err = parse_raw_statfile(file, info);
+	} else
+		/* looks like pretty client and server stats */
+		err = parse_pretty_statfile(file, info);
+out:
+	if (fp)
+		fclose(fp);
+	if (err) {
 		if (!other_opt) {
-			fprintf(stderr, "Warning: No %s Stats (%s: %m). \n", label, file);
+			fprintf(stderr, "Error: No %s Stats (%s: %m). \n",
+					label, file);
 			exit(2);
 		}
 		*opt = 0;
@@ -711,7 +827,7 @@ diff_stats(struct statinfo *new, struct
 		 * diff -- i.e., it should always be included in the
 		 * total.
 		 */
-		if (!strncmp("proc", new[i].tag, 4))
+		if (!strncmp("proc", new[i].tag, 4) && old[i].valptr[0])
 			new[i].valptr[new[i].nrvals - 1] += new[i].valptr[0];
 	}
 }
-- 
1.4.4

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
