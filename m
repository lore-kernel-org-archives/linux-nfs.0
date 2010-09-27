Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw-k01.its.kfa-juelich.de ([134.94.4.24]:53509 "HELO
	mailgw-k01.its.kfa-juelich.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S932829Ab0I0Ig3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Sep 2010 04:36:29 -0400
Received: from localhost (localhost [127.0.0.1])
	by mailgw-k01.its.kfa-juelich.de (Postfix) with ESMTP id 93C9A666C42
	for <linux-nfs@vger.kernel.org>; Mon, 27 Sep 2010 10:29:46 +0200 (CEST)
Received: from mailgw-k01.its.kfa-juelich.de ([127.0.0.1])
	by localhost (mailgw-k01.its.kfa-juelich.de [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id MOLUAvunDCfT for <linux-nfs@vger.kernel.org>;
	Mon, 27 Sep 2010 10:29:44 +0200 (CEST)
Received: from edge-k01.its.kfa-juelich.de (edge-k01.its.kfa-juelich.de [134.94.4.20])
	by mailgw-k01.its.kfa-juelich.de (Postfix) with ESMTP id 7FF18666C2E
	for <linux-nfs@vger.kernel.org>; Mon, 27 Sep 2010 10:29:44 +0200 (CEST)
From: Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>
To: linux-nfs@vger.kernel.org
Subject: Patch proposal for svcgssd
Date: Mon, 27 Sep 2010 10:29:43 +0200
Content-Type: multipart/mixed; boundary="Boundary-00=_3XFoMP0saWOhVeN"
Message-ID: <201009271029.43607.E.Kuemmerle@fz-juelich.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--Boundary-00=_3XFoMP0saWOhVeN
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable

Hello,

we use a two-node cluster (pacemaker, corosync, drbd) as nfs-server.
We configured a virtual cluster-IP (using ocf::heartbeat:IPaddr2, iptables =
CLUSTERIP),
i.e. the nfs clients call the server as OurClusterIP.OurDomain.de while the=
 real hostnames of the servers are
OurServer1.OurDomain.de and OurServer2.OurDomain.de.

If I tried to use the mount option krb5, svcgssd denied the mount with the =
message:
ERROR: GSS-API: error in handle_nullreq: gss_accept_sec_context(): Unspecif=
ied GSS failure.  Minor code may provide more information - Wrong principal=
 in request

I patched svcgssd that we can specify the principal to use as an option:
svcgssd -p nfs/OurClusterIP.OurDomain.de

Now, krb5 works fine!

I suggest to include that patch in the main line of nfs-utils to enable the=
 use of krb5 with such virtual IP's.
The small patch is appended to the mail.

Best regards
  Eberhard Kuemmerle

---------------------------------------------------------------------------=
---------------------
---------------------------------------------------------------------------=
---------------------
Forschungszentrum Juelich GmbH
52425 Juelich
Sitz der Gesellschaft: Juelich
Eingetragen im Handelsregister des Amtsgerichts Dueren Nr. HR B 3498
Vorsitzender des Aufsichtsrats: MinDirig Dr. Karl Eugen Huthmacher
Geschaeftsfuehrung: Prof. Dr. Achim Bachem (Vorsitzender),
Dr. Ulrich Krafft (stellv. Vorsitzender), Prof. Dr.-Ing. Harald Bolt,
Prof. Dr. Sebastian M. Schmidt
---------------------------------------------------------------------------=
---------------------
---------------------------------------------------------------------------=
---------------------

--Boundary-00=_3XFoMP0saWOhVeN
Content-Type: text/x-patch; charset="ISO-8859-1";
	name="nfs-utils-1.2.1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename="nfs-utils-1.2.1.patch"

diff -rupN nfs-utils-1.2.1/utils/gssd/gssd.h nfs-utils-1.2.1_mod/utils/gssd/gssd.h
--- nfs-utils-1.2.1/utils/gssd/gssd.h	2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gssd.h	2010-09-27 08:25:31.000000000 +0200
@@ -90,7 +90,6 @@ void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_spkm3_upcall(struct clnt_info *clp);
-int gssd_acquire_cred(char *server_name);
 void gssd_run(void);
 
 
diff -rupN nfs-utils-1.2.1/utils/gssd/gss_util.c nfs-utils-1.2.1_mod/utils/gssd/gss_util.c
--- nfs-utils-1.2.1/utils/gssd/gss_util.c	2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gss_util.c	2010-09-27 08:14:47.000000000 +0200
@@ -191,7 +191,7 @@ pgsserr(char *msg, u_int32_t maj_stat, u
 }
 
 int
-gssd_acquire_cred(char *server_name)
+gssd_acquire_cred(char *server_name, const gss_OID oid)
 {
 	gss_buffer_desc name;
 	gss_name_t target_name;
@@ -203,7 +203,7 @@ gssd_acquire_cred(char *server_name)
 	name.length = strlen(server_name);
 
 	maj_stat = gss_import_name(&min_stat, &name,
-			(const gss_OID) GSS_C_NT_HOSTBASED_SERVICE,
+			oid,
 			&target_name);
 
 	if (maj_stat != GSS_S_COMPLETE) {
diff -rupN nfs-utils-1.2.1/utils/gssd/gss_util.h nfs-utils-1.2.1_mod/utils/gssd/gss_util.h
--- nfs-utils-1.2.1/utils/gssd/gss_util.h	2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gss_util.h	2010-09-27 08:22:11.000000000 +0200
@@ -37,7 +37,7 @@
 
 extern gss_cred_id_t	gssd_creds;
 
-int gssd_acquire_cred(char *server_name);
+int gssd_acquire_cred(char *server_name, const gss_OID oid);
 void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
 	const gss_OID mech);
 int gssd_check_mechs(void);
diff -rupN nfs-utils-1.2.1/utils/gssd/svcgssd.c nfs-utils-1.2.1_mod/utils/gssd/svcgssd.c
--- nfs-utils-1.2.1/utils/gssd/svcgssd.c	2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/svcgssd.c	2010-09-27 08:26:33.000000000 +0200
@@ -167,7 +167,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-p principal]\n",
 		progname);
 	exit(1);
 }
@@ -183,6 +183,7 @@ main(int argc, char *argv[])
 	int opt;
 	extern char *optarg;
 	char *progname;
+	char *principal = NULL;
 
 	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
 		switch (opt) {
@@ -201,6 +202,9 @@ main(int argc, char *argv[])
 			case 'r':
 				rpc_verbosity++;
 				break;
+			case 'p':
+				principal = optarg;
+				break;
 			default:
 				usage(argv[0]);
 				break;
@@ -244,7 +248,9 @@ main(int argc, char *argv[])
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
 
-	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
+	if (get_creds && !(principal
+			   ? gssd_acquire_cred(principal, GSS_C_NT_USER_NAME)
+			   : gssd_acquire_cred(GSSD_SERVICE_NAME, GSS_C_NT_HOSTBASED_SERVICE))) {
                 printerr(0, "unable to obtain root (machine) credentials\n");
                 printerr(0, "do you have a keytab entry for "
 			    "nfs/<your.host>@<YOUR.REALM> in "

--Boundary-00=_3XFoMP0saWOhVeN--
