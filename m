Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:38035 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbaCLRrX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 13:47:23 -0400
Received: by mail-ie0-f177.google.com with SMTP id rl12so10820443iec.22
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 10:47:23 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id ro10sm59831508igb.6.2014.03.12.10.47.22
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Mar 2014 10:47:22 -0700 (PDT)
Subject: [PATCH 1/2] exportfs: Refactor exportfs() and unexportfs()
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 12 Mar 2014 13:47:22 -0400
Message-ID: <20140312174722.42433.98278.stgit@seurat.1015granger.net>
In-Reply-To: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
References: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Separate parsing the "client:/path" argument from the actual
processing.

BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=817557
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/exportfs/exportfs.c |   74 +++++++++++++++++++++++++++++++--------------
 1 file changed, 51 insertions(+), 23 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 8c86790..771d6eb 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -299,23 +299,13 @@ export_all(int verbose)
 
 
 static void
-exportfs(char *arg, char *options, int verbose)
+exportfs_parsed(char *hname, char *path, char *options, int verbose)
 {
 	struct exportent *eep;
 	nfs_export	*exp = NULL;
 	struct addrinfo	*ai = NULL;
-	char		*path;
-	char		*hname = arg;
 	int		htype;
 
-	if ((path = strchr(arg, ':')) != NULL)
-		*path++ = '\0';
-
-	if (!path || *path != '/') {
-		xlog(L_ERROR, "Invalid exporting option: %s", arg);
-		return;
-	}
-
 	if ((htype = client_gettype(hname)) == MCL_FQDN) {
 		ai = host_addrinfo(hname);
 		if (ai != NULL) {
@@ -345,24 +335,38 @@ out:
 	freeaddrinfo(ai);
 }
 
+static int exportfs_legacy(char *arg, char *options, int verbose)
+{
+	char *path;
+
+	if ((path = strchr(arg, ':')) != NULL)
+		*path++ = '\0';
+
+	if (!path || *path != '/')
+		return 1;
+
+	exportfs_parsed(arg, path, options, verbose);
+	return 0;
+}
+
 static void
-unexportfs(char *arg, int verbose)
+exportfs(char *arg, char *options, int verbose)
+{
+	int failed;
+
+	failed = exportfs_legacy(arg, options, verbose);
+	if (failed)
+		xlog(L_ERROR, "Invalid export syntax: %s", arg);
+}
+
+static void
+unexportfs_parsed(char *hname, char *path, int verbose)
 {
 	nfs_export	*exp;
 	struct addrinfo *ai = NULL;
-	char		*path;
-	char		*hname = arg;
 	int		htype;
 	int		success = 0;
 
-	if ((path = strchr(arg, ':')) != NULL)
-		*path++ = '\0';
-
-	if (!path || *path != '/') {
-		xlog(L_ERROR, "Invalid unexporting option: %s", arg);
-		return;
-	}
-
 	if ((htype = client_gettype(hname)) == MCL_FQDN) {
 		ai = host_addrinfo(hname);
 		if (ai)
@@ -403,11 +407,35 @@ unexportfs(char *arg, int verbose)
 		success = 1;
 	}
 	if (!success)
-		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", arg, path);
+		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
 
 	freeaddrinfo(ai);
 }
 
+static int unexportfs_legacy(char *arg, int verbose)
+{
+	char *path;
+
+	if ((path = strchr(arg, ':')) != NULL)
+		*path++ = '\0';
+
+	if (!path || *path != '/')
+		return 1;
+
+	unexportfs_parsed(arg, path, verbose);
+	return 0;
+}
+
+static void
+unexportfs(char *arg, int verbose)
+{
+	int failed;
+
+	failed = unexportfs_legacy(arg, verbose);
+	if (failed)
+		xlog(L_ERROR, "Invalid export syntax: %s", arg);
+}
+
 static int can_test(void)
 {
 	char buf[1024];

