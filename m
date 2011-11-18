Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oceanic.CalvaEDI.COM ([89.202.194.168]:54077 "EHLO
	oceanic.CalvaEDI.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754665Ab1KRLdF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Nov 2011 06:33:05 -0500
Message-ID: <4EC6426A.3020306@Calva.COM>
Date: Fri, 18 Nov 2011 12:32:58 +0100
From: John Hughes <john@Calva.COM>
MIME-Version: 1.0
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH] Add "-e" option to rpc.gssd to allow error on ticket expiry
Content-Type: multipart/mixed;
 boundary="------------060904090904060300040001"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060904090904060300040001
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

By adding a new option to rpc.gssd the administrator can choose whether 
she wants the old "EACCESS on ticket expiry" or the new "wait for new 
ticket" behaviour.



--------------060904090904060300040001
Content-Type: text/x-patch;
 name="ticket-expired-error.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ticket-expired-error.patch"

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
Author: John Hughes <john@calva.com>
Signed-off-by: John Hughes <john@calva.com>
Bug-Debian: http://bugs.debian.org/648155
Bug-Ubuntu: https://launchpad.net/bugs/648155

--- nfs-utils-1.2.5.orig/utils/gssd/gssd_proc.c
+++ nfs-utils-1.2.5/utils/gssd/gssd_proc.c
@@ -1007,7 +1007,7 @@ process_krb5_upcall(struct clnt_info *cl
 		/* Tell krb5 gss which credentials cache to use */
 		for (dirname = ccachesearch; *dirname != NULL; dirname++) {
 			err = gssd_setup_krb5_user_gss_ccache(uid, clp->servername, *dirname);
-			if (err == -EKEYEXPIRED)
+			if (err == -EKEYEXPIRED && !ticket_expiry_is_error)
 				downcall_err = -EKEYEXPIRED;
 			else if (!err)
 				create_resp = create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
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
 

--------------060904090904060300040001--
