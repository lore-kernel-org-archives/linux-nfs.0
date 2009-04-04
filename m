From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 1/2] nfsstat: Print diff stats every N seconds
Date: Sat, 04 Apr 2009 06:42:54 -0400
Message-ID: <49D739AE.50002@RedHat.com>
References: <1238785592-18869-1-git-send-email-kevin.constantine@disneyanimation.com> <1238785592-18869-2-git-send-email-kevin.constantine@disneyanimation.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40623 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752756AbZDDKpo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 4 Apr 2009 06:45:44 -0400
In-Reply-To: <1238785592-18869-2-git-send-email-kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Kevin Constantine wrote:
>  nfsstat.c: Implements an optional "interval" argument to --sleep
>  nfsstat.man: Explains the use of --sleep[interval]
> 
> Signed-off-by: Kevin Constantine <kevin.constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>
> ---
>  utils/nfsstat/nfsstat.c   |  106 ++++++++++++++++++++++++++++++++++-----------
>  utils/nfsstat/nfsstat.man |    6 ++-
>  2 files changed, 85 insertions(+), 27 deletions(-)
> 
I'm making a slight modification to this patch.

I noticed when there was no NFS traffic and you
ran the 'nfsstat -Z5' command would continually 
spit out:

Client rpc stats:
calls      retrans    authrefrsh
0          0          0       

which makes the output a bit "messy" imho... 
So I added a the following code that will 
keep the interval output quite when there 
is no NFS traffic. 

steved.


Keep the interval output quite when there is no NFS traffic.

The  'nfsstat -Z5' command continually outputs the following
when there is no NFS traffic.

Client rpc stats:
calls      retrans    authrefrsh
0          0          0       

This patch adds code that will keep the interval output 
quite so real results will not be scrolled of the screen

Signed-off-by: Steve Dickson <steved@redhat.com>
-----------------------
diff -up nfs-utils/utils/nfsstat/nfsstat.c.orig nfs-utils/utils/nfsstat/nfsstat.c
--- nfs-utils/utils/nfsstat/nfsstat.c.orig	2009-04-03 15:28:19.000000000 -0400
+++ nfs-utils/utils/nfsstat/nfsstat.c	2009-04-04 06:23:02.000000000 -0400
@@ -184,6 +184,7 @@ static int		mounts(const char *);
 static void		get_stats(const char *, struct statinfo *, int *, int,
 					int);
 static int		has_stats(const unsigned int *);
+static int		has_rpcstats(const unsigned int *, int);
 static void 		diff_stats(struct statinfo *, struct statinfo *, int);
 static void 		unpause(int);
 static void 		update_old_counters(struct statinfo *, struct statinfo *);
@@ -256,6 +257,7 @@ static struct option longopts[] =
 	{ "since", 1, 0, 'S' },
 	{ NULL, 0, 0, 0 }
 };
+int opt_sleep;
 
 int
 main(int argc, char **argv)
@@ -264,7 +266,6 @@ main(int argc, char **argv)
 			opt_srv = 0,
 			opt_clt = 0,
 			opt_prt = 0,
-			opt_sleep = 0,
 			sleep_time = 0,
 			opt_since = 0;
 	int		c;
@@ -458,12 +459,14 @@ print_server_stats(int opt_srv, int opt_
 			printf("\n");
 		}
 		if (opt_prt & PRNT_RPC) {
-			print_numbers(
-			LABEL_srvrpc
-			"calls      badcalls   badauth    badclnt    xdrcall\n",
-			srvrpcinfo, 5
-			);
-			printf("\n");
+			if (!opt_sleep && !has_rpcstats(srvrpcinfo, 5)) {
+				print_numbers(
+				LABEL_srvrpc
+				"calls      badcalls   badauth    badclnt    xdrcall\n",
+				srvrpcinfo, 5
+				);
+				printf("\n");
+			}
 		}
 		if (opt_prt & PRNT_RC) {
 			print_numbers(
@@ -536,12 +539,14 @@ print_client_stats(int opt_clt, int opt_
 			printf("\n");
 		}
 		if (opt_prt & PRNT_RPC) {
-			print_numbers(
-			LABEL_cltrpc
-			"calls      retrans    authrefrsh\n",
-			cltrpcinfo, 3
-			);
-			printf("\n");
+			if (!opt_sleep && !has_rpcstats(cltrpcinfo, 3)) {
+				print_numbers(
+				LABEL_cltrpc
+				"calls      retrans    authrefrsh\n",
+				cltrpcinfo, 3
+				);
+				printf("\n");
+			}
 		}
 		if (opt_prt & PRNT_CALLS) {
 			if ((opt_prt & PRNT_V2) || ((opt_prt & PRNT_AUTO) && has_stats(cltproc2info)))
@@ -836,6 +841,15 @@ has_stats(const unsigned int *info)
 {
 	return (info[0] && info[info[0] + 1] > info[0]);
 }
+static int
+has_rpcstats(const unsigned int *info, int size)
+{
+	int i, cnt;
+
+	for (i=0, cnt=0; i < size; i++)
+		cnt += info[i];
+	return cnt;
+}
 
 /*
  * take the difference of each individual stat value in 'new' and 'old'

