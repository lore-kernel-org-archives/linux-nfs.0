From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] nfs-utils: make nfsstat read and print stats as unsigned integers
Date: Wed, 16 Apr 2008 12:10:06 -0400
Message-ID: <1208362206-19653-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56849 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757673AbYDPQKL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2008 12:10:11 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsstat program reads /proc/net/rpc/* files to gets info about
calls. This info is output as unsigned numbers (at least on any
relatively recent kernel). When nfsstat prints these numbers, they are
printed as signed integers. When the call counters reach 2^31, things
start being printed as negative numbers.

This patch changes nfsstat to read and print all counters as unsigned
integers. Tested by hacking up a kernel to initialize call counters to
2^31+1.

Thanks to Takafumi Miki for the initial version of this patch.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/nfsstat/nfsstat.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index aa6c961..36ad8ce 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -539,7 +539,7 @@ print_numbers(const char *hdr, unsigned int *info, unsigned int nr)
 
 	fputs(hdr, stdout);
 	for (i = 0; i < nr; i++)
-		printf("%s%-8d", i? "   " : "", info[i]);
+		printf("%s%-8u", i? "   " : "", info[i]);
 	printf("\n");
 }
 
@@ -562,7 +562,7 @@ print_callstats(const char *hdr, const char **names,
 		printf("\n");
 		for (j = 0; j < 6 && i + j < nr; j++) {
 			pct = ((unsigned long long) info[i+j]*100)/total;
-			printf("%-8d%3llu%% ", info[i+j], pct);
+			printf("%-8u%3llu%% ", info[i+j], pct);
 		}
 		printf("\n");
 	}
@@ -604,7 +604,7 @@ parse_raw_statfile(const char *name, struct statinfo *statp)
 		for (i = 0; i < cnt; i++) {
 			if (!(sp = strtok(NULL, " \t")))
 				break;
-			ip->valptr[i] = atoi(sp);
+			ip->valptr[i] = (unsigned int) strtoul(sp, NULL, 0);
 			total += ip->valptr[i];
 		}
 		ip->valptr[cnt - 1] = total;
-- 
1.5.3.6

