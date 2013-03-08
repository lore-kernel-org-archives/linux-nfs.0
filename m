Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f175.google.com ([209.85.210.175]:49509 "EHLO
	mail-ia0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751264Ab3CHTql (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:41 -0500
Received: by mail-ia0-f175.google.com with SMTP id e16so154887iaa.34
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:40 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/11] gssd: gssd.man is missing a description of the "-M"
 option
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:38 -0500
Message-ID: <20130308194638.5656.3498.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.man |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 0cc7bf4..dbbfbbb 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -7,7 +7,7 @@
 rpc.gssd \- rpcsec_gss daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-fnlvr ]
+.RB [ \-fMnlvr ]
 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -112,17 +112,23 @@ Tells
 where to look for the rpc_pipefs filesystem.  The default value is
 .IR /var/lib/nfs/rpc_pipefs .
 .TP
-.BI "-d " directory
-Tells
+.BI "-d " search-path
+This option specifies a colon separated list of directories that
 .B rpc.gssd
-where to look for Kerberos credential files.  The default value is
+searches for credential files.  The default value is
 .IR /tmp:/run/user/%U .
-This can also be a colon separated list of directories to be searched for
-Kerberos credential files.  The sequence "%U", if used, is replaced with
-the UID of the user for whom credentials are being searched.
-Note that if machine credentials are being
-stored in files, then the first directory on this list is where the
-machine credentials are stored.
+The literal sequence "%U" can be specified to substitue the UID
+of the user for whom credentials are being searched.
+.TP
+.B -M
+By default, machine credentials are stored in files in the first
+directory in the credential directory search path (see the
+.B -d
+option).  When
+.B -M
+is set,
+.B rpc.gssd
+stores machine credentials in memory instead.
 .TP
 .B -v
 Increases the verbosity of the output (can be specified multiple times).

