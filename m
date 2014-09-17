Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:37541 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbaIQXso (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 17 Sep 2014 19:48:44 -0400
Received: from ucsinet22.oracle.com (ucsinet22.oracle.com [156.151.31.94])
	by userp1040.oracle.com (Sentrion-MTA-4.3.2/Sentrion-MTA-4.3.2) with ESMTP id s8HNmfTb010756
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 17 Sep 2014 23:48:42 GMT
From: Todd Vierling <todd.vierling@oracle.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] exportfs: Properly parse IPv6 literal strings with null termination
Date: Wed, 17 Sep 2014 19:48:39 -0400
Message-Id: <1410997719-17913-1-git-send-email-todd.vierling@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The original implementation was using strncpy() with a truncation
length to an uninitialized stack buffer, leaving a string that
was only null terminated by luck.

While here, change to use no-copy semantics (no extra buffer) to
avoid buffer overflows altogether.
---
 utils/exportfs/exportfs.c | 18 ++++++++----------
 1 file changed, 8 insertions(+), 10 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index e7d1ac8..bdea12b 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -351,16 +351,15 @@ static int exportfs_generic(char *arg, char *options, int verbose)
 
 static int exportfs_ipv6(char *arg, char *options, int verbose)
 {
-	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
+	char *path, *c;
 
 	arg++;
 	c = strchr(arg, ']');
 	if (c == NULL)
 		return 1;
-	strncpy(hname, arg, c - arg);
 
 	/* no colon means this is a wildcarded DNS hostname */
-	if (strchr(hname, ':') == NULL)
+	if (memchr(arg, ':', c - arg) == NULL)
 		return exportfs_generic(--arg, options, verbose);
 
 	path = strstr(c, ":/");
@@ -370,9 +369,9 @@ static int exportfs_ipv6(char *arg, char *options, int verbose)
 
 	/* if there's anything between the closing brace and the
 	 * path separator, it's probably a prefix length */
-	strcat(hname, ++c);
+	memmove(c, c + 1, path - c);
 
-	exportfs_parsed(hname, path, options, verbose);
+	exportfs_parsed(arg, path, options, verbose);
 	return 0;
 }
 
@@ -458,16 +457,15 @@ static int unexportfs_generic(char *arg, int verbose)
 
 static int unexportfs_ipv6(char *arg, int verbose)
 {
-	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
+	char *path, *c;
 
 	arg++;
 	c = strchr(arg, ']');
 	if (c == NULL)
 		return 1;
-	strncpy(hname, arg, c - arg);
 
 	/* no colon means this is a wildcarded DNS hostname */
-	if (strchr(hname, ':') == NULL)
+	if (memchr(arg, ':', c - arg) == NULL)
 		return unexportfs_generic(--arg, verbose);
 
 	path = strstr(c, ":/");
@@ -477,9 +475,9 @@ static int unexportfs_ipv6(char *arg, int verbose)
 
 	/* if there's anything between the closing brace and the
 	 * path separator, it's probably a prefix length */
-	strcat(hname, ++c);
+	memmove(c, c + 1, path - c);
 
-	unexportfs_parsed(hname, path, verbose);
+	unexportfs_parsed(arg, path, verbose);
 	return 0;
 }
 
-- 
1.8.3.1

