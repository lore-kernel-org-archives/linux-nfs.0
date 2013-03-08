Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f175.google.com ([209.85.223.175]:42405 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753778Ab3CHTqc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:32 -0500
Received: by mail-ie0-f175.google.com with SMTP id c12so2502785ieb.6
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:32 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/11] gssd: Use italics for option values and pathnames
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:30 -0500
Message-ID: <20130308194630.5656.81032.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: The usual convention for the values of command line
options and for pathnames is for them to appear italicized,
rather than emboldened or in double quotes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.man |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index c74b7e8..0cc7bf4 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -6,7 +6,18 @@
 .SH NAME
 rpc.gssd \- rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.gssd [-f] [-n] [-k keytab] [-l] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
+.B rpc.gssd
+.RB [ \-fnlvr ]
+.RB [ \-k
+.IR keytab ]
+.RB [ \-p
+.IR pipefsdir ]
+.RB [ \-d
+.IR ccachedir ]
+.RB [ \-t
+.IR timeout ]
+.RB [ \-R
+.IR realm ]
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -38,13 +49,14 @@ manually like all other users.  Use of this option means that
 attempting to mount an nfs filesystem requiring Kerberos
 authentication.
 .TP
-.B -k keytab
+.BI "-k " keytab
 Tells
 .B rpc.gssd
 to use the keys found in
 .I keytab
 to obtain "machine credentials".
-The default value is "/etc/krb5.keytab".
+The default value is
+.I /etc/krb5.keytab.
 .IP
 Previous versions of
 .B rpc.gssd
@@ -94,17 +106,17 @@ encryption.
 This option is only available with Kerberos libraries that 
 support setable encryption types.
 .TP
-.B -p path
+.BI "-p " path
 Tells
 .B rpc.gssd
 where to look for the rpc_pipefs filesystem.  The default value is
-"/var/lib/nfs/rpc_pipefs".
+.IR /var/lib/nfs/rpc_pipefs .
 .TP
-.B -d directory
+.BI "-d " directory
 Tells
 .B rpc.gssd
 where to look for Kerberos credential files.  The default value is
-"/tmp:/run/user/%U".
+.IR /tmp:/run/user/%U .
 This can also be a colon separated list of directories to be searched for
 Kerberos credential files.  The sequence "%U", if used, is replaced with
 the UID of the user for whom credentials are being searched.
@@ -119,14 +131,14 @@ Increases the verbosity of the output (can be specified multiple times).
 If the rpcsec_gss library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
 .TP
-.B -R realm
+.BI "-R " realm
 Kerberos tickets from this
 .I realm
 will be preferred when scanning available credentials cache files to be
 used to create a context.  By default, the default realm, as configured
 in the Kerberos configuration file, is preferred.
 .TP
-.B -t timeout
+.BI "-t " timeout
 Timeout, in seconds, for kernel gss contexts. This option allows you to force 
 new kernel contexts to be negotiated after
 .I timeout

