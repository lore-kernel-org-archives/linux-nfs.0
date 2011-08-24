Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:42819 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab1HXPeG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Aug 2011 11:34:06 -0400
Received: by mail-ew0-f46.google.com with SMTP id 4so527255ewy.19
        for <linux-nfs@vger.kernel.org>; Wed, 24 Aug 2011 08:34:06 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/5] sm-notify: Disable syslog messages when debugging is
	enabled
To: linux-nfs@vger.kernel.org
Date: Wed, 24 Aug 2011 11:34:03 -0400
Message-ID: <20110824153403.3138.74467.stgit@matisse.1015granger.net>
In-Reply-To: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
References: <20110824153024.3138.63294.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

statd's "-F" flag disables syslog output, and specifies sm-notify's
"-d" option when it runs it.  sm-notify's "-d" option should therefore
also disable syslog output.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/sm-notify.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 1f490b0..f05eadf 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -395,12 +395,14 @@ usage:		fprintf(stderr,
 		exit(1);
 	}
 
-	xlog_syslog(1);
 	if (opt_debug) {
+		xlog_syslog(0);
 		xlog_stderr(1);
 		xlog_config(D_ALL, 1);
-	} else
+	} else {
+		xlog_syslog(1);
 		xlog_stderr(0);
+	}
 
 	xlog_open(progname);
 	xlog(L_NOTICE, "Version " VERSION " starting");

