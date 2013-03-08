Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ia0-f177.google.com ([209.85.210.177]:57167 "EHLO
	mail-ia0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3CHTq6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:46:58 -0500
Received: by mail-ia0-f177.google.com with SMTP id y25so1850678iay.36
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:46:58 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/11] gssd: Clarify use of the term "machine credentials" in
 rpc.gssd(8)
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:46:56 -0500
Message-ID: <20130308194656.5656.52231.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Out NFSv4 implementation uses machine credentials for operations
that manage state on behalf of the whole client (for example,
SETCLIENTID or RENEW).  The rpc.gssd man page is missing a
description of this usage, especially in the discussion of the "-n"
option.

The issue is that rpc.gssd's "-n" option requires root to acquire a
user credential.  In the absense of a system keytab (for instance,
if the system is diskless) root's credential is not to be used as
the machine credential that manages NFSv4 state.

Group the discussion of machine credentials and UID 0 in one place
to help clarify the discussion and simplify the description of
several of these options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.man |  142 ++++++++++++++++++++++++++++++++++++++-------------
 1 files changed, 105 insertions(+), 37 deletions(-)

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index fb3ab97..1d6fb4c 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -71,6 +71,107 @@ the Linux kernel RPC client depends on a userspace daemon called
 The
 .B rpc.gssd
 daemon uses the rpc_pipefs filesystem to communicate with the kernel.
+.SS User Credentials
+When a user authenticates using a command such as
+.BR kinit (1),
+the resulting credential is stored in a file with a well-known name
+constructed using the user's UID.
+.P
+To interact with an NFS server
+on behalf of a particular Kerberos-authenticated user,
+the Linux kernel RPC client requests that
+.B rpc.gssd
+initialize a security context with the credential
+in that user's credential file.
+.P
+Typically, credential files are placed in
+.IR /tmp .
+However,
+.B rpc.gssd
+can search for credential files in more than one directory.
+See the description of the
+.B -d
+option for details.
+.SS Machine Credentials
+A user credential is established by a user and
+is then shared with the kernel and
+.BR rpc.gssd .
+A machine credential is established by
+.B rpc.gssd
+for the kernel when there is no user.
+Therefore
+.B rpc.gssd
+must already have the materials on hand to establish this credential
+without requiring user intervention.
+.P
+.B rpc.gssd
+searches the local system's keytab for a principal and key to use
+to establish the machine credential.
+By default,
+.B rpc.gssd
+assumes the file
+.I /etc/krb5.keytab
+contains principals and keys that can be used to obtain machine credentials.
+.P
+.B rpc.gssd
+searches in the following order for a principal to use.
+The first matching credential is used.
+For the search, <hostname> and <REALM> are replaced with the local
+system's hostname and Kerberos realm.
+.sp
+   <HOSTNAME>$@<REALM>
+.br
+   root/<hostname>@<REALM>
+.br
+   nfs/<hostname>@<REALM>
+.br
+   host/<hostname>@<REALM>
+.br
+   root/<anyname>@<REALM>
+.br
+   nfs/<anyname>@<REALM>
+.br
+   host/<anyname>@<REALM>
+.sp
+The <anyname> entries match on the service name and realm, but ignore the hostname.
+These can be used if a principal matching the local host's name is not found.
+.P
+Note that the first principal in the search order is a user principal
+that enables Kerberized NFS when the local system is joined
+to an Active Directory domain using Samba.
+A password for this principal must be provided in the local system's keytab.
+.P
+You can specify another keytab by using the
+.B -k
+option if
+.I /etc/krb5.keytab
+does not exist or does not provide one of these principals.
+.SS Credentials for UID 0
+UID 0 is a special case.
+By default
+.B rpc.gssd
+uses the system's machine credentials for UID 0 accesses
+that require GSS authentication.
+This limits the privileges of the root user
+when accessing network resources that require authentication.
+.P
+Specify the
+.B -n
+option when starting
+.B rpc.gssd
+if you'd like to force the root user to obtain a user credential
+rather than use the local system's machine credential.
+.P
+When
+.B -n
+is specified,
+the kernel continues to request a GSS context established
+with a machine credential for NFSv4 operations,
+such as SETCLIENTID or RENEW, that manage state.
+If
+.B rpc.gssd
+cannot obtain a machine credential (say, the local system has
+no keytab), NFSv4 operations that require machine credentials will fail.
 .SH OPTIONS
 .TP
 .B -f
@@ -79,50 +180,17 @@ Runs
 in the foreground and sends output to stderr (as opposed to syslogd)
 .TP
 .B -n
-By default,
-.B rpc.gssd
-treats accesses by the user with UID 0 specially, and uses
-"machine credentials" for all accesses by that user which
-require Kerberos authentication.
-With the \-n option, "machine credentials" will not be used
-for accesses by UID 0.  Instead, credentials must be obtained
-manually like all other users.  Use of this option means that
-"root" must manually obtain Kerberos credentials before
-attempting to mount an nfs filesystem requiring Kerberos
-authentication.
+When specified, UID 0 is forced to obtain user credentials
+which are used instead of the local system's machine credentials.
 .TP
 .BI "-k " keytab
 Tells
 .B rpc.gssd
 to use the keys found in
 .I keytab
-to obtain "machine credentials".
+to obtain machine credentials.
 The default value is
-.I /etc/krb5.keytab.
-.IP
-Previous versions of
-.B rpc.gssd
-used only "nfs/*" keys found within the keytab.
-To be more consistent with other implementations, we now look for
-specific keytab entries.  The search order for keytabs to be used
-for "machine credentials" is now:
-.br
-  <HOSTNAME>$@<REALM>
-.br
-  root/<hostname>@<REALM>
-.br
-  nfs/<hostname>@<REALM>
-.br
-  host/<hostname>@<REALM>
-.br
-  root/<anyname>@<REALM>
-.br
-  nfs/<anyname>@<REALM>
-.br
-  host/<anyname>@<REALM>
-.IP
-If this search order does not use the correct key then provide a
-keytab file that contains only correct keys.
+.IR /etc/krb5.keytab .
 .TP
 .B -l
 Tells

