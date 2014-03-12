Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:45407 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755870AbaCLRrc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 13:47:32 -0400
Received: by mail-ig0-f181.google.com with SMTP id h18so15186igc.2
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 10:47:31 -0700 (PDT)
Received: from seurat.1015granger.net ([2604:8800:100:81fc:20c:29ff:fe44:ec31])
        by mx.google.com with ESMTPSA id m6sm60353624igx.9.2014.03.12.10.47.31
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Mar 2014 10:47:31 -0700 (PDT)
Subject: [PATCH 2/2] exportfs: Support raw IPv6 addresses with "client:/path"
To: linux-nfs@vger.kernel.org
From: Chuck Lever <chuck.lever@oracle.com>
Date: Wed, 12 Mar 2014 13:47:30 -0400
Message-ID: <20140312174730.42433.59724.stgit@seurat.1015granger.net>
In-Reply-To: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
References: <20140312172811.42433.13869.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Wrap IPv6 presentation addresses in square brackets.  This echoes
the same syntax used when specifying IPv6 server addresses with the
mount.nfs command.

BugLink: https://bugzilla.redhat.com/show_bug.cgi?id=817557
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/exportfs/exportfs.c   |   64 ++++++++++++++++++++++++++++++++++++++++++-
 utils/exportfs/exportfs.man |   16 +++++++++++
 2 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 771d6eb..2c8d64a 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -349,12 +349,42 @@ static int exportfs_legacy(char *arg, char *options, int verbose)
 	return 0;
 }
 
+static int exportfs_ipv6(char *arg, char *options, int verbose)
+{
+	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
+
+	arg++;
+	c = strchr(arg, ']');
+	if (c == NULL)
+		return 1;
+	strncpy(hname, arg, c - arg);
+
+	/* no colon means this is a wildcarded DNS hostname */
+	if (strchr(hname, ':') == NULL)
+		return exportfs_legacy(--arg, options, verbose);
+
+	path = strstr(c, ":/");
+	if (path == NULL)
+		return 1;
+	*path++ = '\0';
+
+	/* if there's anything between the closing brace and the
+	 * path separator, it's probably a prefix length */
+	strcat(hname, ++c);
+
+	exportfs_parsed(hname, path, options, verbose);
+	return 0;
+}
+
 static void
 exportfs(char *arg, char *options, int verbose)
 {
 	int failed;
 
-	failed = exportfs_legacy(arg, options, verbose);
+	if (*arg == '[')
+		failed = exportfs_ipv6(arg, options, verbose);
+	else
+		failed = exportfs_legacy(arg, options, verbose);
 	if (failed)
 		xlog(L_ERROR, "Invalid export syntax: %s", arg);
 }
@@ -426,12 +456,42 @@ static int unexportfs_legacy(char *arg, int verbose)
 	return 0;
 }
 
+static int unexportfs_ipv6(char *arg, int verbose)
+{
+	char *path, *c, hname[NI_MAXHOST + strlen("/128")];
+
+	arg++;
+	c = strchr(arg, ']');
+	if (c == NULL)
+		return 1;
+	strncpy(hname, arg, c - arg);
+
+	/* no colon means this is a wildcarded DNS hostname */
+	if (strchr(hname, ':') == NULL)
+		return unexportfs_legacy(--arg, verbose);
+
+	path = strstr(c, ":/");
+	if (path == NULL)
+		return 1;
+	*path++ = '\0';
+
+	/* if there's anything between the closing brace and the
+	 * path separator, it's probably a prefix length */
+	strcat(hname, ++c);
+
+	unexportfs_parsed(hname, path, verbose);
+	return 0;
+}
+
 static void
 unexportfs(char *arg, int verbose)
 {
 	int failed;
 
-	failed = unexportfs_legacy(arg, verbose);
+	if (*arg == '[')
+		failed = unexportfs_ipv6(arg, verbose);
+	else
+		failed = unexportfs_legacy(arg, verbose);
 	if (failed)
 		xlog(L_ERROR, "Invalid export syntax: %s", arg);
 }
diff --git a/utils/exportfs/exportfs.man b/utils/exportfs/exportfs.man
index d481645..75d952a 100644
--- a/utils/exportfs/exportfs.man
+++ b/utils/exportfs/exportfs.man
@@ -159,6 +159,14 @@ along with the client or clients who are permitted to access it.
 See
 .B exports(5)
 for a description of supported options and access list formats.
+.PP
+IPv6 presentation addresses contain colons, which are already used
+to separate the "host" and "path" command line arguments.
+When specifying a client using a raw IPv6 address,
+enclose the address in square brackets.
+For IPv6 network addresses, place the prefix just after the closing
+bracket.
+.PP
 To export a directory to the world, simply specify
 .IR :/path .
 .PP
@@ -244,6 +252,14 @@ and files under
 .nf
 .B "# exportfs -au
 .fi
+.PP
+To export the
+.I /usr/tmp
+directory to IPv6 link-local clients:
+.PP
+.nf
+.B "# exportfs [fe80::]/64:/usr/tmp
+.fi
 .SH USAGE NOTES
 Exporting to IP networks or DNS and NIS domains does not enable clients
 from these groups to access NFS immediately.

