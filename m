Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:55324 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756620Ab1KROfE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 09:35:04 -0500
Message-ID: <4EC66D12.2090505@Calva.COM>
Date: Fri, 18 Nov 2011 15:34:58 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket expiry.
 Try 2 with added man pages.
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Description: Add "-e" (ticket expiry is error) option to rpc.gssd
  In kernels starting around 2.6.34 the nfs4 server will block all I/O
  when a user ticket expires.  In earlier kernels the I/O would fail
  with an EACCESS error.  This patch adds a "-e" option to rpc.gssd
  which allow the earlier behaviour (EKEYEXPIRED is converted to
  EACCESS).  This behaviour is particularly useful when user home
  directories are nfs4 mounted with krb5 security - if the user is
  absent from their workstation for long enough for the ticket to
  expire a new ticket will be obtained (via pam_krb5) by the screen
  unlock process.
Author: John Hughes<john@calva.com>
Signed-off-by: John Hughes<john@calva.com>
Bug-Debian: http://bugs.debian.org/648155
Bug-Ubuntu: https://launchpad.net/bugs/648155

--- nfs-utils-1.2.5.orig/utils/gssd/gssd_proc.c
+++ nfs-utils-1.2.5/utils/gssd/gssd_proc.c
@@ -1007,7 +1007,7 @@ process_krb5_upcall(struct clnt_info *cl
  		/* Tell krb5 gss which credentials cache to use */
  		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
  			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
-			if (err == -EKEYEXPIRED)
+			if (err == -EKEYEXPIRED&&  !ticket_expiry_is_error)
  				downcall_err = -EKEYEXPIRED;
  			else if (!err)
  				create_resp = create_auth_rpc_client(clp,&rpc_clnt,&auth, uid,
--- nfs-utils-1.2.5.orig/utils/gssd/gssd.c
+++ nfs-utils-1.2.5/utils/gssd/gssd.c
@@ -63,6 +63,7 @@ int  use_memcache = 0;
  int  root_uses_machine_creds = 1;
  unsigned int  context_timeout = 0;
  char *preferred_realm = NULL;
+int ticket_expiry_is_error = 0;

  void
  sig_die(int signal)
@@ -85,7 +86,7 @@ sig_hup(int signal)
  static void
  usage(char *progname)
  {
-	fprintf(stderr, "usage: %s [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
+	fprintf(stderr, "usage: %s [-e] [-f] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
  		progname);
  	exit(1);
  }
@@ -102,8 +103,11 @@ main(int argc, char *argv[])
  	char *progname;

  	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:R:")) != -1) {
+	while ((opt = getopt(argc, argv, "efvrmnMp:k:d:t:R:")) != -1) {
  		switch (opt) {
+			case 'e':
+				ticket_expiry_is_error = 1;
+				break;
  			case 'f':
  				fg = 1;
  				break;
--- nfs-utils-1.2.5.orig/utils/gssd/gssd.h
+++ nfs-utils-1.2.5/utils/gssd/gssd.h
@@ -66,6 +66,7 @@ extern int			use_memcache;
  extern int			root_uses_machine_creds;
  extern unsigned int 		context_timeout;
  extern char			*preferred_realm;
+extern int			ticket_expiry_is_error;

  TAILQ_HEAD(clnt_list_head, clnt_info) clnt_list;

diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 073379d..e2b7b7a 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -6,7 +6,7 @@
  .SH NAME
  rpc.gssd \- rpcsec_gss daemon
  .SH SYNOPSIS
-.B "rpc.gssd [-f] [-n] [-k keytab] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
+.B "rpc.gssd [-e] [-f] [-n] [-k keytab] [-p pipefsdir] [-v] [-r] [-d ccachedir]"
  .SH DESCRIPTION
  The rpcsec_gss protocol gives a means of using the gss-api generic security
  api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -20,6 +20,25 @@ daemon uses files in the rpc_pipefs filesystem to communicate with the kernel.

  .SH OPTIONS
  .TP
+.TO
+.B -e
+Versions of
+.B rpc.gssd
+before 1.2.2 reported ticket expiry to the kernel as
+.B EACCESS
+(permission denied).  More recent versions return
+.B EKEYEXPIRED
+which causes recent kernels to block all I/O to a nfs mount until a new
+key is obtained.  The
+.B -e
+option restores the old behaviour.
+
+This is useful in the common case that the user home directories are
+nfs mounted.  Without the
+.B -e
+option the user may have difficulty getting a new ticket as she will
+only find out about the expiry of the old one when her processes hang.
+.TP
  .B -f
  Runs
  .B rpc.gssd

