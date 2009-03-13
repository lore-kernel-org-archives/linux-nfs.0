From: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Subject: [PATCH] nfsstat.c: Print diff stats every N seconds
Date: Thu, 12 Mar 2009 19:00:40 -0700
Message-ID: <49B9BE48.7080906@disney.com>
References: <1236909465-25818-1-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Kevin Constantine <Kevin.Constantine-P5ys19MLBK/QT0dZR+AlfA@public.gmane.org>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgate1.disneyanimation.com ([12.188.26.101]:2302 "EHLO
	mailgate1.disneyanimation.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750991AbZCMCAm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 22:00:42 -0400
Received: from ling.fas.fa.disney.com (ling.fas.fa.disney.com [172.30.192.99])
	by mailhub.fa.disney.com (Postfix) with ESMTP id A75C81253BC
	for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2009 19:00:40 -0700 (PDT)
In-Reply-To: <1236909465-25818-1-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch to nfsstat.c allows for an optional argument to --sleep or 
-Z.  This optional argument is the interval at which differences in the 
nfsstat block are printed.

nfsstat --sleep=1 will print the following every second

nfs v3 stats:   Server   Client
        total:        0      213
         null:        0        0
      getattr:        0       23
      setattr:        0        9
       lookup:        0        8
       access:        0        1
     readlink:        0        0
         read:        0        7
        write:        0       23
       create:        0        8
        mkdir:        0        0
      symlink:        0        0
        mknod:        0        0
       remove:        0        7
        rmdir:        0        0
       rename:        0        1
         link:        0        0
      readdir:        0        0
  readdirplus:        0        0
       fsstat:        0      126
       fsinfo:        0        0
     pathconf:        0        0
       commit:        0        0

Moving to a listed output format instead of the traditional nfsstat 
output makes it trivial with a simple grep to watch the  stats that you 
really care about and ignore the rest.

nfsv4 output still retains the original output format because I can't 
think of a good way to output that in a list.



---
  utils/nfsstat/nfsstat.c |  119 
++++++++++++++++++++++++++++++++++++++++++++---
  1 files changed, 112 insertions(+), 7 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 1517414..1d2874f 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -167,10 +167,16 @@ DECLARE_SRV(srvinfo, _old);
  DECLARE_CLT(cltinfo);
  DECLARE_CLT(cltinfo, _old);

+static void		print_server_stats(int, int);
+static void		print_client_stats(int, int);
+static void		print_stats_list(int);
  static void		print_numbers(const char *, unsigned int *,
  					unsigned int);
  static void		print_callstats(const char *, const char **,
  					unsigned int *, unsigned int);
+static void		print_callstats_list(const char *, const char **,
+                        		unsigned int *, unsigned int *,
+		                        unsigned int);
  static int		parse_raw_statfile(const char *, struct statinfo *);
  static int 		parse_pretty_statfile(const char *, struct statinfo *);

@@ -183,6 +189,7 @@ static void		get_stats(const char *, struct statinfo 
*, int *, int,
  static int		has_stats(const unsigned int *);
  static void 		diff_stats(struct statinfo *, struct statinfo *, int);
  static void 		unpause(int);
+static void 		update_old_counters(struct statinfo *, struct statinfo *);

  static time_t		starttime;

@@ -223,7 +230,9 @@ void usage(char *name)
    -v, --verbose, --all\tSame as '-o all'\n\
    -r, --rpc\t\tShow RPC statistics\n\
    -n, --nfs\t\tShow NFS statistics\n\
-  -Z, --sleep\t\tSaves stats, pauses, diffs current and saved\n\
+  -Z[#], --sleep[=#]	Saves stats, pauses, diffs current and saved.\n\
+          		    if # is provided, stats will be output every\n\
+			    # seconds\n\
    -S, --since file\tShows difference between current stats and those 
in 'file'\n\
    --version\t\tShow program version\n\
    --help\t\tWhat you just did\n\
@@ -245,7 +254,7 @@ static struct option longopts[] =
  	{ "zero", 0, 0, 'z' },
  	{ "help", 0, 0, '\1' },
  	{ "version", 0, 0, '\2' },
-	{ "sleep", 0, 0, 'Z' },
+	{ "sleep", 2, 0, 'Z' },
  	{ "since", 1, 0, 'S' },
  	{ NULL, 0, 0, 0 }
  };
@@ -258,6 +267,7 @@ main(int argc, char **argv)
  			opt_clt = 0,
  			opt_prt = 0,
  			opt_sleep = 0,
+			sleep_time = 0,
  			opt_since = 0;
  	int		c;
  	char           *progname,
@@ -279,7 +289,7 @@ main(int argc, char **argv)
  	else
  		progname = argv[0];

-	while ((c = getopt_long(argc, argv, "234acmno:ZS:vrsz\1\2", longopts, 
NULL)) != EOF) {
+	while ((c = getopt_long(argc, argv, "234acmno:Z::S:vrsz\1\2", 
longopts, NULL)) != EOF) {
  		switch (c) {
  		case 'a':
  			fprintf(stderr, "nfsstat: nfs acls are not yet supported.\n");
@@ -311,6 +321,9 @@ main(int argc, char **argv)
  			break;
  		case 'Z':
  			opt_sleep = 1;
+			if (optarg) {
+				sleep_time = atoi(optarg);
+			}
  			break;
  		case 'S':
  			opt_since = 1;
@@ -384,7 +397,7 @@ main(int argc, char **argv)
  	if (opt_clt)
  		get_stats(clientfile, clientinfo, &opt_clt, opt_srv, 0);

-	if (opt_sleep) {
+	if (opt_sleep && !sleep_time) {
  		starttime = time(NULL);
  		printf("Collecting statistics; press CTRL-C to view results from 
interval (i.e., from pause to CTRL-C).\n");
  		if (sigaction(SIGINT, &act, NULL) != 0) {
@@ -404,7 +417,33 @@ main(int argc, char **argv)
  			diff_stats(clientinfo_tmp, clientinfo, 0);
  		}
  	}
+	if(sleep_time) {
+		while(1) {
+			if (opt_srv) {
+				get_stats(NFSSRVSTAT, serverinfo_tmp , &opt_srv, opt_clt, 1);
+				diff_stats(serverinfo_tmp, serverinfo, 1);
+			}
+			if (opt_clt) {
+				get_stats(NFSCLTSTAT, clientinfo_tmp, &opt_clt, opt_srv, 0);
+				diff_stats(clientinfo_tmp, clientinfo, 0);
+			}
+			print_stats_list(opt_prt);
+			fflush(stdout);
+
+			update_old_counters(clientinfo_tmp, clientinfo);
+			sleep(sleep_time);
+		}	
+	}
+	else {
+		print_server_stats(opt_srv, opt_prt);
+		print_client_stats(opt_clt, opt_prt);
+	}

+	return 0;
+}
+
+static void
+print_server_stats(int opt_srv, int opt_prt) {
  	if (opt_srv) {
  		if (opt_prt & PRNT_NET) {
  			print_numbers(
@@ -479,7 +518,9 @@ main(int argc, char **argv)
  			}
  		}
  	}
-
+}
+static void
+print_client_stats(int opt_clt, int opt_prt) {
  	if (opt_clt) {
  		if (opt_prt & PRNT_NET) {
  			print_numbers(
@@ -515,10 +556,42 @@ main(int argc, char **argv)
  				);
  		}
  	}
-
-	return 0;
  }

+static void
+print_stats_list(int opt_prt) {
+	if (opt_prt & PRNT_CALLS) {
+		if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && 
has_stats(cltproc2info)))
+			print_callstats_list(
+			"nfs v2 stats:",
+			nfsv2name, srvproc2info + 1, cltproc2info + 1,
+			sizeof(nfsv2name)/sizeof(char *)
+			);
+			printf("\n");
+		if ((opt_prt & PRNT_V3) || ((opt_prt & PRNT_AUTO) && 
has_stats(cltproc3info)))
+			print_callstats_list(
+			"nfs v3 stats:",
+			nfsv3name, srvproc3info + 1, cltproc3info + 1,
+			sizeof(nfsv3name)/sizeof(char *)
+			);
+			printf("\n");
+		if ((opt_prt & PRNT_V4) || ((opt_prt & PRNT_AUTO) && 
has_stats(cltproc4info))) {
+				print_callstats(
+				LABEL_srvproc4,
+				nfssrvproc4name, srvproc4info + 1, 
sizeof(nfssrvproc4name)/sizeof(char *)
+				);
+				print_callstats(
+				LABEL_srvproc4ops,
+				nfssrvproc4opname, srvproc4opsinfo + 1, 
sizeof(nfssrvproc4opname)/sizeof(char *)
+				);
+				print_callstats(
+				LABEL_cltproc4,
+				nfscltproc4name, cltproc4info + 1, 
sizeof(nfscltproc4name)/sizeof(char *)
+				);
+		}
+	}
+}
+	
  static statinfo *
  get_stat_info(const char *sp, struct statinfo *statp)
  {
@@ -569,6 +642,28 @@ print_callstats(const char *hdr, const char **names,
  	printf("\n");
  }

+static void
+print_callstats_list(const char *hdr, const char **names,
+		 	unsigned int *srvinfo, unsigned int *cltinfo,
+			unsigned int nr)
+{
+	unsigned long long	srvtotal, clttotal;
+	int			i;
+
+	for (i = 0, srvtotal = 0, clttotal = 0; i < nr; i++) {
+		if (srvinfo[i])
+			srvtotal += srvinfo[i];
+		if (cltinfo[i])
+			clttotal += cltinfo[i];
+	}
+	printf("%13s %8s %8s\n", hdr, "Server", "Client");
+	printf("%12s: %8llu %8llu \n", "total", srvtotal, clttotal);
+	for (i = 0; i < nr; i++) {
+			printf("%12s: %8u %8u \n", names[i], srvinfo[i], cltinfo[i]);
+	}
+		
+}
+
  /* returns 0 on success, 1 otherwise */
  static int
  parse_raw_statfile(const char *name, struct statinfo *statp)
@@ -846,3 +941,13 @@ unpause(int sig)
  	seconds = (int)time_diff % 60;
  	printf("Signal received; displaying (only) statistics gathered over 
the last %d minutes, %d seconds:\n\n", minutes, seconds);
  }
+
+static void
+update_old_counters(struct statinfo *new, struct statinfo *old)
+{
+	int z, i;
+	for (z = 0; old[z].tag; z++)
+		for (i = 0; i <= old[z].nrvals; i++)
+			old[z].valptr[i] += new[z].valptr[i];
+
+}
-- 
1.6.0.4.761.g47577

