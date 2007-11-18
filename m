From: "Steinar H. Gunderson" <sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org>
Subject: [NFS] [andrew.phillips-5jPdWwX6g8k@public.gmane.org: Bug#451402:
	nfs-kernel-server:	rpc.svcgssd needs option to authenticate
	using different hostname]
Date: Sun, 18 Nov 2007 12:05:51 +0100
Message-ID: <20071118110551.GA10815@uio.no>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="y0ulUmNC+osPPQO6"
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IthyN-0003E6-N5
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 03:05:55 -0800
Received: from cassarossa.samfundet.no ([129.241.93.19] ident=Debian-exim)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IthyR-00006U-NY
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 03:06:01 -0800
Received: from trofast.ipv6.sesse.net ([2001:700:300:1803:20e:cff:fe36:a766]
	helo=trofast.sesse.net) by cassarossa.samfundet.no with esmtps
	(TLS-1.0:RSA_AES_256_CBC_SHA1:32) (Exim 4.63)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>) id 1IthyK-0006Ta-0g
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 12:05:53 +0100
Received: from root by trofast.sesse.net with local (Exim 4.68)
	(envelope-from <sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org>) id 1IthyJ-0002q3-CP
	for nfs@lists.sourceforge.net; Sun, 18 Nov 2007 12:05:51 +0100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>


--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hi,

I'm sending this on from a user. Does the patch seem reasonable to you?

/* Steinar */
-- 
Homepage: http://www.sesse.net/

--y0ulUmNC+osPPQO6
Content-Type: message/rfc822
Content-Disposition: inline

Received: from cassarossa.samfundet.no ([2001:700:300:1800::1919]
	ident=Debian-exim) by trofast.sesse.net with esmtp (Exim 4.68)
	(envelope-from
	<bounces+20071115-sesse=debian.org-R+A61+qa7K0CNxpy2Jgn7Xx8IIHWJNfj@public.gmane.org>)
	id 1IsrD1-0000G3-SF
	for passopp-gJKA1zGhDwenXvgWXzQSL/y+ZNuC7F5L@public.gmane.org; Fri, 16 Nov 2007 03:45:31 +0100
Received: from mail-kr1.bigfoot.com ([210.109.98.21])
	by cassarossa.samfundet.no with smtp (Exim 4.63) (envelope-from
	<bounces+20071115-sesse=debian.org-R+A61+qa7K0CNxpy2Jgn7Xx8IIHWJNfj@public.gmane.org>)
	id 1IsrCv-00083T-OW
	for sesse-BrfabpQBY5qlHtIdYg32fQ@public.gmane.org; Fri, 16 Nov 2007 03:45:31 +0100
Received: from mail-kr.bigfoot.com ([211.115.216.226])
	by BFLITEMAIL-KR1.bigfoot.com (LiteMail v3.03(BFLITEMAIL-KR1)) with
	SMTP id 0711152145_BFLITEMAIL-KR1_584972_41930127;
	Thu, 15 Nov 2007 21:48:51 -0500 EST
Received: from master.debian.org ([70.103.162.29])
	by BFLITEMAIL-KR3.bigfoot.com (LiteMail v3.03(BFLITEMAIL-KR3)) with
	SMTP id 0711151336_BFLITEMAIL-KR3_1047508_10085568;
	Thu, 15 Nov 2007 13:37:11 -0500 EST
Received: from qa by master.debian.org with local (Exim 4.50)
	id 1IsjJy-0006aD-7h
	for sgunderson-jG/AHqQBv7lBDgjK7y7TUQ@public.gmane.org; Thu, 15 Nov 2007 18:20:10 +0000
Received: from rietz.debian.org ([140.211.166.43]) by master.debian.org
	with esmtp (Exim 4.50) id 1IsjFA-0003jf-Vk for
	nfs-utils-R+A61+qa7K0CNxpy2Jgn7Xx8IIHWJNfj@public.gmane.org; Thu, 15 Nov 2007 18:15:13 +0000
Received: from debbugs by rietz.debian.org with local (Exim 4.50) id
	1IsjF2-00020F-5w; Thu, 15 Nov 2007 18:15:04 +0000
X-Loop: owner@bugs.debian.org
Subject: Bug#451402: nfs-kernel-server: rpc.svcgssd needs option to
	authenticate using different hostname
Reply-To: Andrew Phillips <andrew.phillips-5jPdWwX6g8k@public.gmane.org>, 451402@bugs.debian.org
Resent-From: Andrew Phillips <andrew.phillips-5jPdWwX6g8k@public.gmane.org>
Resent-To: debian-bugs-dist@lists.debian.org
Resent-CC: Anibal Monsalve Salazar <anibal@debian.org>
Resent-Date: Thu, 15 Nov 2007 18:15:01 +0000
Resent-Message-Id: <handler.451402.B.1195150295780@bugs.debian.org>
X-Debian-PR-Message: report 451402
X-Debian-PR-Package: nfs-kernel-server
X-Debian-PR-Keywords: patch
X-Debian-PR-Source: nfs-utils
Received: via spool by submit@bugs.debian.org id=B.1195150295780 (code B
	ref -1); Thu, 15 Nov 2007 18:15:01 +0000
Received: (at submit) by bugs.debian.org; 15 Nov 2007 18:11:35 +0000
X-Spam-Checker-Version: SpamAssassin 3.1.4-bugs.debian.org_2005_01_02
	(2006-07-26) on rietz.debian.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=4.0 tests=BAYES_00, FOURLA, HAS_PACKAGE,
	IMPRONONCABLE_1,MDO_DATING2,MURPHY_DRUGS_REL8,MURPHY_WRONG_WORD1,
	MURPHY_WRONG_WORD2 autolearn=no
	version=3.1.4-bugs.debian.org_2005_01_02
Received: from fwdar1-1.ns.ec.gc.ca ([199.212.16.20]
	helo=atlantic-exgate.Atlantic.int.ec.gc.ca) by rietz.debian.org with
	esmtp
	(Exim 4.50) id 1IsjBf-000092-3C for submit@bugs.debian.org; Thu,
	15 Nov 2007 18:11:35 +0000
Received: from phillipsa-lx.dart.ns.ec.gc.ca ([131.235.10.69]) by
	atlantic-exgate.Atlantic.int.ec.gc.ca with Microsoft
	SMTPSVC(6.0.3790.3959); Thu, 15 Nov 2007 14:11:29 -0400
Received: from phillipsa by phillipsa-lx.dart.ns.ec.gc.ca with local (Exim
	4.67) (envelope-from <andrew.phillips-5jPdWwX6g8k@public.gmane.org>) id 1IsjBZ-0003ul-E8;
	Thu, 15 Nov 2007 14:11:29 -0400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: Andrew Phillips <andrew.phillips-5jPdWwX6g8k@public.gmane.org>
To: Debian Bug Tracking System <submit@bugs.debian.org>
Message-Id: <20071115181129.14914.6007.reportbug-bmuJXYsvn0hRdhyElPwyhWvNCLGBfJgzPBtRn7vrt+k@public.gmane.org>
X-Mailer: reportbug 3.39
Date: Thu, 15 Nov 2007 14:11:29 -0400
X-Originalarrivaltime: 15 Nov 2007 18:11:29.0513 (UTC)
	FILETIME=[F1D72590:01C827B2]
Delivered-To: submit@bugs.debian.org
Resent-Sender: Debian BTS <debbugs@bugs.debian.org>
Resent-Date: Thu, 15 Nov 2007 18:15:04 +0000
Delivered-To: nfs-utils-R+A61+qa7K0CNxpy2Jgn7Xx8IIHWJNfj@public.gmane.org
Precedence: list
X-Loop: nfs-utils-R+A61+qa7K0CNxpy2Jgn7Xx8IIHWJNfj@public.gmane.org
X-PTS-Package: nfs-utils
X-PTS-Keyword: bts
List-Unsubscribe: <mailto:pts-eGGfNCsEAyqEi8DpZVb4nw@public.gmane.org?body=unsubscribe+nfs-utils>
X-Spam-Score: 0.0 (/)
X-Spam-Report: Status=No hits=0.0 required=5.0 tests=UNPARSEABLE_RELAY
	version=3.1.7-deb hostname=cassarossa.samfundet.no

Package: nfs-kernel-server
Version: 1:1.1.1~git-20070929-1
Severity: wishlist
Tags: patch

Normally you can only connect to NFS using Kerberos using the hostname
of the server.  If you have a cluster where the NFS service can
failover between machines, using heartbeat for instance, you would
want to connect to a single address.  This does not work with
rpc.svcgssd as it will only authenticate machines connecting to it's
hostname, not another address the machine handles.  For instance, if
you have servers nfs1.foo and nfs2.foo, you might want to have an
address nfs.foo that passes between each other.

The following two patches (one for 1.1.1~git-2007092 (sid), and one
for 1.0.10 (etch)) add an option to rpc.svcgssd to specify the
hostname (-h) you will be connecting to it by.  They also remove
references to options that rpc.svcgssd does not support.  

Ideally, in the long run nfs-utils would provide an option similar to
what recent openssh versions use, and authenticate with any key in the
keytab.

Patch for 1.1.1~git-2007092:
diff -rud nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.c nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.c
--- nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.c	2007-09-29 09:55:13.000000000 -0300
+++ nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.c	2007-11-15 10:43:33.000000000 -0400
@@ -155,7 +155,7 @@
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-i] [-h hostname]\n",
 		progname);
 	exit(1);
 }
@@ -171,8 +171,9 @@
 	int opt;
 	extern char *optarg;
 	char *progname;
+	char *servicename = NULL;
 
-	while ((opt = getopt(argc, argv, "fivrnp:")) != -1) {
+	while ((opt = getopt(argc, argv, "fivrnh:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -189,6 +190,12 @@
 			case 'r':
 				rpc_verbosity++;
 				break;
+			case 'h':
+				servicename = calloc(strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, sizeof(char));
+
+				/* GSSAPI needs @ instead of / between service name and hostname */
+				snprintf(servicename, strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, "%s@%s", GSSD_SERVICE_NAME, optarg);
+				break;
 			default:
 				usage(argv[0]);
 				break;
@@ -228,7 +235,10 @@
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
 
-	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
+	if (servicename == NULL)
+		servicename = GSSD_SERVICE_NAME;
+
+	if (get_creds && !gssd_acquire_cred(servicename)) {
                 printerr(0, "unable to obtain root (machine) credentials\n");
                 printerr(0, "do you have a keytab entry for "
 			    "nfs/<your.host>@<YOUR.REALM> in "
Only in nfs-utils-1.1.1~git-20070929-krb/utils/gssd: svcgssd.c.orig
diff -rud nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.man nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.man
--- nfs-utils-1.1.1~git-20070929/utils/gssd/svcgssd.man	2007-09-29 09:55:13.000000000 -0300
+++ nfs-utils-1.1.1~git-20070929-krb/utils/gssd/svcgssd.man	2007-11-15 10:26:01.000000000 -0400
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-p pipefsdir]"
+.B "rpc.svcgssd [-v] [-r] [-i] [-f] [-h hostname]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -35,6 +35,10 @@
 .B -i
 If the nfsidmap library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -h hostname
+Specify the hostname to use when looking for the service principal in
+the keytab.
 
 .SH SEE ALSO
 .BR rpc.gssd(8),


Patch for 1.0.10:
diff -rud nfs-utils-1.0.10/utils/gssd/svcgssd.c nfs-utils-1.0.10-krb/utils/gssd/svcgssd.c
--- nfs-utils-1.0.10/utils/gssd/svcgssd.c	2006-08-07 03:40:50.000000000 -0300
+++ nfs-utils-1.0.10-krb/utils/gssd/svcgssd.c	2007-11-15 10:41:58.000000000 -0400
@@ -154,7 +154,7 @@
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r]\n",
+	fprintf(stderr, "usage: %s [-n] [-f] [-v] [-r] [-h hostname]\n",
 		progname);
 	exit(1);
 }
@@ -169,8 +169,9 @@
 	int opt;
 	extern char *optarg;
 	char *progname;
+	char *servicename = NULL;
 
-	while ((opt = getopt(argc, argv, "fvrnp:")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrnh:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -184,6 +185,12 @@
 			case 'r':
 				rpc_verbosity++;
 				break;
+			case 'h':
+				servicename = calloc(strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, sizeof(char));
+
+				/* GSSAPI needs @ instead of / between service name and hostname */
+				snprintf(servicename, strlen(optarg) + strlen(GSSD_SERVICE_NAME) + 2, "%s@%s", GSSD_SERVICE_NAME, optarg);
+				break;
 			default:
 				usage(argv[0]);
 				break;
@@ -216,7 +223,10 @@
 	signal(SIGTERM, sig_die);
 	signal(SIGHUP, sig_hup);
 
-	if (get_creds && !gssd_acquire_cred(GSSD_SERVICE_NAME)) {
+	if (servicename == NULL)
+		servicename = GSSD_SERVICE_NAME;
+
+	if (get_creds && !gssd_acquire_cred(servicename)) {
                 printerr(0, "unable to obtain root (machine) credentials\n");
                 printerr(0, "do you have a keytab entry for "
 			    "nfs/<your.host>@<YOUR.REALM> in "
diff -rud nfs-utils-1.0.10/utils/gssd/svcgssd.man nfs-utils-1.0.10-krb/utils/gssd/svcgssd.man
--- nfs-utils-1.0.10/utils/gssd/svcgssd.man	2006-08-07 03:40:50.000000000 -0300
+++ nfs-utils-1.0.10-krb/utils/gssd/svcgssd.man	2007-11-15 10:27:42.000000000 -0400
@@ -6,7 +6,7 @@
 .SH NAME
 rpc.svcgssd \- server-side rpcsec_gss daemon
 .SH SYNOPSIS
-.B "rpc.svcgssd [-v] [-r] [-f] [-p pipefsdir]"
+.B "rpc.svcgssd [-v] [-r] [-f] [-h hostname]"
 .SH DESCRIPTION
 The rpcsec_gss protocol gives a means of using the gss-api generic security
 api to provide security for protocols using rpc (in particular, nfs).  Before
@@ -31,6 +31,10 @@
 .B -r
 If the rpcsec_gss library supports setting debug level,
 increases the verbosity of the output (can be specified multiple times).
+.TP
+.B -h hostname
+Specify the hostname to use when looking for the service principal in
+the keytab.
 
 .SH SEE ALSO
 .BR rpc.gssd(8),

-- System Information:
Debian Release: lenny/sid
  APT prefers testing
  APT policy: (500, 'testing'), (500, 'stable')
Architecture: i386 (i686)

Kernel: Linux 2.6.22-2-686 (SMP w/2 CPU cores)
Locale: LANG=en_CA.UTF-8, LC_CTYPE=en_CA.UTF-8 (charmap=UTF-8)
Shell: /bin/sh linked to /bin/bash

Versions of packages nfs-kernel-server depends on:
ii  libblkid1         1.40.2-1               block device id library
ii  libc6             2.6.1-1+b1             GNU C Library: Shared libraries
ii  libcomerr2        1.40.2-1               common error description library
ii  libgssglue1       0.1-1                  mechanism-switch gssapi library
ii  libkrb53          1.6.dfsg.3~beta1-2     MIT Kerberos runtime libraries
ii  libnfsidmap2      0.20-0                 An nfs idmapping library
ii  librpcsecgss3     0.17-1                 allows secure rpc communication us
ii  libwrap0          7.6.dbs-14             Wietse Venema's TCP wrappers libra
ii  lsb-base          3.1-24                 Linux Standard Base 3.1 init scrip
ii  nfs-common        1:1.1.1~git-20070929-1 NFS support files common to client
ii  ucf               3.003                  Update Configuration File: preserv

nfs-kernel-server recommends no packages.

-- no debconf information





--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--y0ulUmNC+osPPQO6
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--y0ulUmNC+osPPQO6--


