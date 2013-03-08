Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:44811 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3CHTqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:50 -0500
Received: by mail-ie0-f177.google.com with SMTP id 16so2464128iea.8
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:49 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/11] gssd: Provide an introduction in gssd(8)
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:47 -0500
Message-ID: <20130308194647.5656.13713.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's good practice in user documentation to define terms before they
are used.  Add an INTRODUCTION section that defines important terms
that are used in the DESCRIPTION and OPTIONS sections.  The key
concepts are GSS context, user credential, machine credential, and
keytab.

The RFCs I looked at capitalize both "gss" and "rpcsec_gss".  For
consistency I changed this throughout the man page.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.man |   73 +++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 59 insertions(+), 14 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index dbbfbbb..fb3ab97 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -2,9 +2,10 @@
 .\" rpc.gssd(8)
 .\"
 .\" Copyright (C) 2003 J. Bruce Fields <bfields@umich.edu>
-.TH rpc.gssd 8 "14 Mar 2007"
+.\"
+.TH rpc.gssd 8 "20 Feb 2013"
 .SH NAME
-rpc.gssd \- rpcsec_gss daemon
+rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
 .RB [ \-fMnlvr ]
@@ -18,17 +19,58 @@ rpc.gssd \- rpcsec_gss daemon
 .IR timeout ]
 .RB [ \-R
 .IR realm ]
+.SH INTRODUCTION
+The RPCSEC_GSS protocol, defined in RFC 5403, is used to provide
+strong security for RPC-based protocols such as NFS.
+.P
+Before exchanging RPC requests using RPCSEC_GSS, an RPC client must
+establish a GSS
+.IR "security context" .
+A security context is shared state on each
+end of a network transport that enables GSS-API security services.
+.P
+Security contexts are established using
+.IR "security credentials" .
+A credential grants temporary access to a secure network service,
+much as a railway ticket grants temporary access to use a rail service.
+.P
+A user typically obtains a credential by providing a password to the
+.BR kinit (1)
+command, or via a PAM library at login time.
+A credential acquired with a
+.I user principal
+is known as a
+.I user credential
+(see
+.BR kerberos (1)
+for more on principals).
+.P
+For certain operations, a credential is required
+which represents no user,
+is otherwise unprivileged,
+and is always available.
+This is referred to as a
+.IR "machine credential" .
+.P
+Machine credentials are typically established using a
+.IR "service principal" ,
+whose encrypted password, called its
+.IR key ,
+is stored in a file, called a
+.IR keytab ,
+to avoid requiring a user prompt.
+A machine credential effectively does not expire because the system
+can renew it as needed without user intervention.
+.P
+Once obtained, credentials are typically stored in local temporary files
+with well-known pathnames.
 .SH DESCRIPTION
-The rpcsec_gss protocol gives a means of using the gss-api generic security
-api to provide security for protocols using rpc (in particular, nfs).  Before
-exchanging any rpc requests using rpcsec_gss, the rpc client must first
-establish a security context.  The linux kernel's implementation of rpcsec_gss
-depends on the userspace daemon
-.B rpc.gssd
-to establish security contexts.  The
+To establish GSS security contexts using these credential files,
+the Linux kernel RPC client depends on a userspace daemon called
+.BR rpc.gssd .
+The
 .B rpc.gssd
-daemon uses files in the rpc_pipefs filesystem to communicate with the kernel.
-
+daemon uses the rpc_pipefs filesystem to communicate with the kernel.
 .SH OPTIONS
 .TP
 .B -f
@@ -134,7 +176,7 @@ stores machine credentials in memory instead.
 Increases the verbosity of the output (can be specified multiple times).
 .TP
 .B -r
-If the rpcsec_gss library supports setting debug level,
+If the RPCSEC_GSS library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
 .TP
 .BI "-R " realm
@@ -145,14 +187,17 @@ used to create a context.  By default, the default realm, as configured
 in the Kerberos configuration file, is preferred.
 .TP
 .BI "-t " timeout
-Timeout, in seconds, for kernel gss contexts. This option allows you to force 
+Timeout, in seconds, for kernel GSS contexts. This option allows you to force 
 new kernel contexts to be negotiated after
 .I timeout
 seconds, which allows changing Kerberos tickets and identities frequently.
 The default is no explicit timeout, which means the kernel context will live
 the lifetime of the Kerberos service ticket used in its creation.
 .SH SEE ALSO
-.BR rpc.svcgssd(8)
+.BR rpc.svcgssd (8),
+.BR kerberos (1),
+.BR kinit (1),
+.BR krb5.conf (5)
 .SH AUTHORS
 .br
 Dug Song <dugsong@umich.edu>

