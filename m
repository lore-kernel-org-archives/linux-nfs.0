Return-Path: <SRS0=g2h7=O3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D4936C43614
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id AFE8E21873
	for <linux-nfs@archiver.kernel.org>; Tue, 18 Dec 2018 14:30:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726426AbeLROaU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 18 Dec 2018 09:30:20 -0500
Received: from mx1.redhat.com ([209.132.183.28]:53856 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726971AbeLROaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 18 Dec 2018 09:30:19 -0500
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 76CF7D215C;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-125-147.rdu2.redhat.com [10.10.125.147])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 56FB8105959E;
        Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id 9C40B2293F; Tue, 18 Dec 2018 09:30:18 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     steved@redhat.com
Cc:     jlayton@kernel.org, linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH v2 6/7] nfsdcld: add /etc/nfs.conf support
Date:   Tue, 18 Dec 2018 09:30:17 -0500
Message-Id: <20181218143018.28575-7-smayhew@redhat.com>
In-Reply-To: <20181218143018.28575-1-smayhew@redhat.com>
References: <20181218143018.28575-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 18 Dec 2018 14:30:19 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs.conf                  |  4 ++++
 utils/nfsdcld/nfsdcld.c   | 13 +++++++++++++
 utils/nfsdcld/nfsdcld.man | 15 +++++++++++++++
 3 files changed, 32 insertions(+)

diff --git a/nfs.conf b/nfs.conf
index 796bee4..aabf300 100644
--- a/nfs.conf
+++ b/nfs.conf
@@ -34,6 +34,10 @@
 # state-directory-path=/var/lib/nfs
 # ha-callout=
 #
+[nfsdcld]
+# debug=0
+# storagedir=/var/lib/nfs/nfsdcld
+#
 [nfsdcltrack]
 # debug=0
 # storagedir=/var/lib/nfs/nfsdcltrack
diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 272c7c5..313c68f 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -45,6 +45,7 @@
 #include "cld-internal.h"
 #include "sqlite.h"
 #include "../mount/version.h"
+#include "conffile.h"
 
 #ifndef DEFAULT_PIPEFS_DIR
 #define DEFAULT_PIPEFS_DIR NFS_STATEDIR "/rpc_pipefs"
@@ -640,6 +641,7 @@ main(int argc, char **argv)
 	char *progname;
 	char *storagedir = CLD_DEFAULT_STORAGEDIR;
 	struct cld_client clnt;
+	char *s;
 
 	memset(&clnt, 0, sizeof(clnt));
 
@@ -653,6 +655,17 @@ main(int argc, char **argv)
 	xlog_syslog(0);
 	xlog_stderr(1);
 
+	conf_init_file(NFS_CONFFILE);
+	s = conf_get_str("general", "pipefs-directory");
+	if (s)
+		strlcpy(pipefs_dir, s, sizeof(pipefs_dir));
+	s = conf_get_str("nfsdcld", "storagedir");
+	if (s)
+		storagedir = s;
+	rc = conf_get_num("nfsdcld", "debug", 0);
+	if (rc > 0)
+		xlog_config(D_ALL, 1);
+
 	/* process command-line options */
 	while ((arg = getopt_long(argc, argv, "hdFp:s:", longopts,
 				  NULL)) != EOF) {
diff --git a/utils/nfsdcld/nfsdcld.man b/utils/nfsdcld/nfsdcld.man
index b607ba6..c271d14 100644
--- a/utils/nfsdcld/nfsdcld.man
+++ b/utils/nfsdcld/nfsdcld.man
@@ -163,6 +163,21 @@ Location of the rpc_pipefs filesystem. The default value is
 .IX Item "-s storagedir, --storagedir=storage_dir"
 Directory where stable storage information should be kept. The default
 value is \fI/var/lib/nfs/nfsdcld\fR.
+.SH "CONFIGURATION FILE"
+.IX Header "CONFIGURATION FILE"
+The following values are recognized in the \fB[nfsdcld]\fR section
+of the \fI/etc/nfs.conf\fR configuration file:
+.IP "\fBstoragedir\fR" 4
+.IX Item "storagedir"
+Equivalent to \fB\-s\fR/\fB\-\-storagedir\fR.
+.IP "\fBdebug\fR" 4
+.IX Item "debug"
+Setting "debug = 1" is equivalent to \fB\-d\fR/\fB\-\-debug\fR.
+.LP
+In addition, the following value is recognized from the \fB[general]\fR section:
+.IP "\fBpipefs\-directory\fR" 4
+.IX Item "pipefs-directory"
+Equivalent to \fB\-p\fR/\fB\-\-pipefsdir\fR.
 .SH "NOTES"
 .IX Header "NOTES"
 The Linux kernel NFSv4 server has historically tracked this information
-- 
2.17.1

