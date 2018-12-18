Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44929C43612
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D52E21873
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:23 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726720AbeLROaV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:21 -0500
Received: from mx1.redhat.com ([209.132.183.28]:42162 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727028AbeLROaU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7FEBD89AE3;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 5C4375D738;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 97D6E2293E; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 5/7] nfsdcld: the -p option should specify the rpc_pipefs mountpoint
Date:   Tue, 18 Dec 2018 09:30:16 -0500
Message-Id: <20181218143018.28575-6-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Change the -p option to specify the rpc_pipefs mountpoint rather than
the full path to the cld pipe file.  This is consistent with other
daemons that use the rpc_pipefs filesystem.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsdcld/nfsdcld.c   | 17 ++++++++++-------
 utils/nfsdcld/nfsdcld.man |  9 ++++-----
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 9b1ad98..272c7c5 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -46,11 +46,11 @@
 #include "sqlite.h"
 #include "../mount/version.h"
 
-#ifndef PIPEFS_DIR
-#define PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
+#ifndef DEFAULT_PIPEFS_DIR
+#define DEFAULT_PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
 #endif
 
-#define DEFAULT_CLD_PATH	PIPEFS_DIR "/nfsd/cld"
+#define DEFAULT_CLD_PATH	"/nfsd/cld"
 
 #ifndef CLD_DEFAULT_STORAGEDIR
 #define CLD_DEFAULT_STORAGEDIR NFS_STATEDIR "/nfsdcld"
@@ -63,7 +63,8 @@
 /* private data structures */
 
 /* global variables */
-static char *pipepath = DEFAULT_CLD_PATH;
+static char pipefs_dir[PATH_MAX] = DEFAULT_PIPEFS_DIR;
+static char pipepath[PATH_MAX];
 static int 		inotify_fd = -1;
 static struct event	pipedir_event;
 static bool old_kernel = false;
@@ -73,7 +74,7 @@ static struct option longopts[] =
 	{ "help", 0, NULL, 'h' },
 	{ "foreground", 0, NULL, 'F' },
 	{ "debug", 0, NULL, 'd' },
-	{ "pipe", 1, NULL, 'p' },
+	{ "pipefsdir", 1, NULL, 'p' },
 	{ "storagedir", 1, NULL, 's' },
 	{ NULL, 0, 0, 0 },
 };
@@ -84,7 +85,7 @@ static void cldcb(int UNUSED(fd), short which, void *data);
 static void
 usage(char *progname)
 {
-	printf("%s [ -hFd ] [ -p pipe ] [ -s dir ]\n", progname);
+	printf("%s [ -hFd ] [ -p pipefsdir ] [ -s storagedir ]\n", progname);
 }
 
 static int
@@ -663,7 +664,7 @@ main(int argc, char **argv)
 			foreground = true;
 			break;
 		case 'p':
-			pipepath = optarg;
+			strlcpy(pipefs_dir, optarg, sizeof(pipefs_dir));
 			break;
 		case 's':
 			storagedir = optarg;
@@ -674,6 +675,8 @@ main(int argc, char **argv)
 		}
 	}
 
+	strlcpy(pipepath, pipefs_dir, sizeof(pipepath));
+	strlcat(pipepath, DEFAULT_CLD_PATH, sizeof(pipepath));
 
 	xlog_open(progname);
 	if (!foreground) {
diff --git a/utils/nfsdcld/nfsdcld.man b/utils/nfsdcld/nfsdcld.man
index 9ddaf64..b607ba6 100644
--- a/utils/nfsdcld/nfsdcld.man
+++ b/utils/nfsdcld/nfsdcld.man
@@ -155,11 +155,10 @@ Enable debug level logging.
 .IP "\fB\-F\fR, \fB\-\-foreground\fR" 4
 .IX Item "-F, --foreground"
 Runs the daemon in the foreground and prints all output to stderr
-.IP "\fB\-p\fR \fIpipe\fR, \fB\-\-pipe\fR=\fIpipe\fR" 4
-.IX Item "-p pipe, --pipe=pipe"
-Location of the \*(L"cld\*(R" upcall pipe. The default value is
-\&\fI/var/lib/nfs/rpc_pipefs/nfsd/cld\fR. If the pipe does not exist when the
-daemon starts then it will wait for it to be created.
+.IP "\fB\-p\fR \fIpath\fR, \fB\-\-pipefsdir\fR=\fIpath\fR" 4
+.IX Item "-p path, --pipefsdir=path"
+Location of the rpc_pipefs filesystem. The default value is
+\&\fI/var/lib/nfs/rpc_pipefs\fR.
 .IP "\fB\-s\fR \fIstorage_dir\fR, \fB\-\-storagedir\fR=\fIstorage_dir\fR" 4
 .IX Item "-s storagedir, --storagedir=storage_dir"
 Directory where stable storage information should be kept. The default
-- 
2.17.1

