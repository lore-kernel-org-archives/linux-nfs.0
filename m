Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailgw-e01.its.kfa-juelich.de ([134.94.4.23]:37141 "HELO
	mailgw-e01.its.kfa-juelich.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750996Ab0I1Ggt convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Sep 2010 02:36:49 -0400
From: Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] svcgssd: Adding a <-p principal> flag
Date: Tue, 28 Sep 2010 08:36:45 +0200
CC: Steve Dickson <SteveD@redhat.com>
Content-Type: text/plain; charset="us-ascii"
Message-ID: <201009280836.45487.E.Kuemmerle@fz-juelich.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello Steve,

we use a two-node cluster (pacemaker, corosync, drbd) as nfs-server.
We configured a virtual cluster-IP (using ocf::heartbeat:IPaddr2, iptables CLUSTERIP),
i.e. the nfs clients call the server as OurClusterIP.OurDomain.de while the real hostnames of the servers are
OurServer1.OurDomain.de and OurServer2.OurDomain.de.

If I tried to use the mount option krb5, svcgssd denied the mount with the message:
ERROR: GSS-API: error in handle_nullreq: gss_accept_sec_context(): Unspecified GSS failure.  Minor code may provide more information - Wrong principal in request

I patched svcgssd that we can specify the principal to use as an option:
svcgssd -p nfs/OurClusterIP.OurDomain.de

Signed-off-by:  Eberhard Kuemmerle <E.Kuemmerle@fz-juelich.de>

Here comes the code patch:

**************************************************

diff -rupN nfs-utils-1.2.1/utils/gssd/gssd.h nfs-utils-1.2.1_mod/utils/gssd/gssd.h
--- nfs-utils-1.2.1/utils/gssd/gssd.h   2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gssd.h       2010-09-27 08:25:31.000000000 +0200
@@ -90,7 +90,6 @@ void init_client_list(void);
 int update_client_list(void);
 void handle_krb5_upcall(struct clnt_info *clp);
 void handle_spkm3_upcall(struct clnt_info *clp);
-int gssd_acquire_cred(char *server_name);
 void gssd_run(void);


diff -rupN nfs-utils-1.2.1/utils/gssd/gss_util.c nfs-utils-1.2.1_mod/utils/gssd/gss_util.c
--- nfs-utils-1.2.1/utils/gssd/gss_util.c       2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gss_util.c   2010-09-27 08:14:47.000000000 +0200
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
-                       (const gss_OID) GSS_C_NT_HOSTBASED_SERVICE,
+                       oid,
                        &target_name);

        if (maj_stat != GSS_S_COMPLETE) {
diff -rupN nfs-utils-1.2.1/utils/gssd/gss_util.h nfs-utils-1.2.1_mod/utils/gssd/gss_util.h
--- nfs-utils-1.2.1/utils/gssd/gss_util.h       2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/gss_util.h   2010-09-27 08:22:11.000000000 +0200
@@ -37,7 +37,7 @@

 extern gss_cred_id_t   gssd_creds;

-int gssd_acquire_cred(char *server_name);
+int gssd_acquire_cred(char *server_name, const gss_OID oid);
 void pgsserr(char *msg, u_int32_t maj_stat, u_int32_t min_stat,
        const gss_OID mech);
 int gssd_check_mechs(void);
diff -rupN nfs-utils-1.2.1/utils/gssd/svcgssd.c nfs-utils-1.2.1_mod/utils/gssd/svcgssd.c
--- nfs-utils-1.2.1/utils/gssd/svcgssd.c        2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/svcgssd.c    2010-09-27 15:48:47.000000000 +0200
@@ -167,7 +167,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-       fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
+       fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-P principal]\n",
                progname);
        exit(1);
 }
@@ -183,8 +183,9 @@ main(int argc, char *argv[])
        int opt;
        extern char *optarg;
        char *progname;
+       char *principal = NULL;

-       while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
+       while ((opt = getopt(argc, argv, "fivrnP:")) != -1) {
                switch (opt) {
                        case 'f':
                                fg = 1;
@@ -201,6 +202,9 @@ main(int argc, char *argv[])
                        case 'r':
                                rpc_verbosity++;
                                break;
+                       case 'P':
+                               principal = optarg;
+                               break;
                        default:
                                usage(argv[0]);
                                break;
@@ -244,7 +248,9 @@ main(int argc, char *argv[])
        signal(SIGTERM, sig_die);
        signal(SIGHUP, sig_hup);

-       if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
+       if (get_creds && !(principal
+                          ? gssd_acquire_cred(principal, GSS_C_NT_USER_NAME)
+                          : gssd_acquire_cred(GSSD_SERVICE_NAME, GSS_C_NT_HOSTBASED_SERVICE))) {
                 printerr(0, "unable to obtain root (machine) credentials\n");
                 printerr(0, "do you have a keytab entry for "
                            "nfs/<your.host>@<YOUR.REALM> in "

**************************************************

And here is the man page patch.

I removed the old option [-p pipefsdir] from the man page because it is
obviously removed in the code.

**************************************************

diff -rupN nfs-utils-1.2.1/utils/gssd/svcgssd.man nfs-utils-1.2.1_mod/utils/gssd/svcgssd.man
--- nfs-utils-1.2.1/utils/gssd/svcgssd.man      2009-11-04 12:13:56.000000000 +0100
+++ nfs-utils-1.2.1_mod/utils/gssd/svcgssd.man  2010-09-27 16:01:28.000000000 +0200
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p pipefsdir]"
+.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-P principal]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -35,9 +35,12 @@ increases the verbosity of the output (c
 .B -i
 If the nfsidmap library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -P
+Use \fIprincipal\fR instead of the default nfs/host.domain.

 .SH SEE ALSO
-.BR rpc.gssd(8),
+.BR rpc.gssd(8)
 .SH AUTHORS
 .br
 Dug Song <dugsong@umich.edu>

**************************************************

Signed-off-by: Eberhard Kuemmerle <e.kuemmerle@fz-juelich.de>

Best regards,

Eberhard

------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
Forschungszentrum Juelich GmbH
52425 Juelich
Sitz der Gesellschaft: Juelich
Eingetragen im Handelsregister des Amtsgerichts Dueren Nr. HR B 3498
Vorsitzender des Aufsichtsrats: MinDirig Dr. Karl Eugen Huthmacher
Geschaeftsfuehrung: Prof. Dr. Achim Bachem (Vorsitzender),
Dr. Ulrich Krafft (stellv. Vorsitzender), Prof. Dr.-Ing. Harald Bolt,
Prof. Dr. Sebastian M. Schmidt
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
