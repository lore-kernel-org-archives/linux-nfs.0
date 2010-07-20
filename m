From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 12/24] Removed warnings from nfsstat.c
Date: Tue, 20 Jul 2010 19:37:25 -0400
Message-ID: <1279669057-17509-13-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60366 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761683Ab0GUAmu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:50 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-Ch
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsstat.c: In function 'print_callstats':
nfsstat.c:797: warning: comparison between signed and unsigned integer
expressions
nfsstat.c:801: warning: comparison between signed and unsigned integer
expressions
nfsstat.c:802: warning: comparison between signed and unsigned integer
expressions
nfsstat.c:805: warning: comparison between signed and unsigned integer
expressions

nfsstat.c: In function 'print_callstats_list':
nfsstat.c:821: warning: comparison between signed and unsigned integer
expressions
nfsstat.c:828: warning: comparison between signed and unsigned integer
expressions

nfsstat.c: In function 'unpause':
nfsstat.c:1111: warning: unused parameter 'sig'
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/nfsstat/nfsstat.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/utils/nfsstat/nfsstat.c b/utils/nfsstat/nfsstat.c
index 99d77c9..740a803 100644
--- a/utils/nfsstat/nfsstat.c
+++ b/utils/nfsstat/nfsstat.c
@@ -791,7 +791,7 @@ print_callstats(const char *hdr, const char **names,
 {
 	unsigned long long	total;
 	unsigned long long	pct;
-	int		i, j;
+	unsigned int		i, j;
 
 	fputs(hdr, stdout);
 	for (i = 0, total = 0; i < nr; i++)
@@ -816,7 +816,7 @@ print_callstats_list(const char *hdr, const char **names,
 		 	unsigned int *callinfo, unsigned int nr)
 {
 	unsigned long long	calltotal;
-	int			i;
+	unsigned int			i;
 
 	for (i = 0, calltotal = 0; i < nr; i++) {
 		calltotal += callinfo[i];
@@ -1118,7 +1118,7 @@ unpause(int sig)
 	time_diff = difftime(endtime, starttime);
 	minutes = time_diff / 60;
 	seconds = (int)time_diff % 60;
-	printf("Signal received; displaying (only) statistics gathered over the last %d minutes, %d seconds:\n\n", minutes, seconds);
+	printf("Signal %d received; displaying (only) statistics gathered over the last %d minutes, %d seconds:\n\n", sig, minutes, seconds);
 }
 
 static void
-- 
1.7.0.1

