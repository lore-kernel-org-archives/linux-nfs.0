Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx4.science-computing.de ([193.197.16.30]:27711 "EHLO
	mx4.science-computing.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756584Ab2CLUML (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Mar 2012 16:12:11 -0400
Date: Mon, 12 Mar 2012 21:02:21 +0100
From: Michael Weiser <M.Weiser@science-computing.de>
To: linux-nfs@vger.kernel.org
Subject: NFSv4 post-1.2.2 nfs-utils client fails to mount from pre-1.2.3
 nfs-utils server
Message-ID: <20120312200221.GS29573@science-computing.de>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--PNTmBPCT7hxwcZjr
Content-Disposition: inline
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

Hi,

from what I can gather, nfs-utils-1.2.3 introduced support for
encryption other than Single DES for NFSv4: Previously, gssd would
proactively limit Kerberos encryption types of session keys to
des-cbc-crc (and perhaps -md5 and -md4). So while the actual ticket
might be encrypted using something way stronger, the included session
key would only be Single DES.

Due to this self-limitation of the client, the server would never get
anything else than Single DES session keys and therefore needed no
mechanism of working around the problems caused by stronger session keys
with a kernel that does not support them.

Beginning with version 1.2.3 of nfs-utils, gssd does no longer limits
itself to Single DES. Instead, it detects the encryption types supported
by the *client's* kernel and limits the session key's encryption type to
those reported as supported. This, however, ignores the fact, that the
*server's* kernel might not support them. Since the userspace of the
server (svcgssd) does not check what its kernel supports and has no
mechanism of renegotiating with the client, it happily accepts stronger
encryption types and tries to push them into the kernel.

nfs-utils-1.2.4 includes a patch to svcgssd that uses
/proc/fs/nfsd/supported_encryption_types of newer kernels (2.6.35+ ?) to
determine the encryption types supported by the server's kernel and uses
subkey negotiation of current MIT Kerberos versions (1.9.1+) to
negotiate a possibly weaker encryption type with the client. While this
is a good solution for future enhancements and backwards compatibility
from now on it still leaves all the older installations with a problem.
RHEL5 for example only has MIT Kerberos 1.6 and will therefore most
likely never benefit from this fix.

A direct workaround is to set the following options in /etc/krb5.conf of
client and server:

[libdefaults]
default_tkt_enctypes =3D des-cbc-md5
permitted_enctypes =3D des-cbc-md5

, add des-cbc-md5 keys to the keytabs of both machines and allow Single
DES for both machines' principals on the KDC (MS AD 2008r2 in particular
wants it enabled explicitly). This however not only limits the
encryption types of session keys but all tickets as well and applies to
the whole machine not just the NFSv4 service. This has a needlessly high
security impact on both machines.

I quickly implemented a more self-contained fix that adds an option -l
to rpc.gssd that effectively reverts it to legacy behaviour: It ignores
its local kernel's capabilities and uses just Single DES. This option
could be set in e.g. /etc/sysconfig/nfs:GSSDARGS on all RHEL6 clients
that need to work with RHEL5 servers. It could possibly be enhanced to
be configurable on a per-machine basis. Inclusion of this or a similar
patch would be greatly appreciated.

Obviously this is just a proof-of-concept and still needs some
polishing. I was just wondering if my reasoning is sound and the
solution acceptable.

Thanks in advance,
-- =

Michael Weiser                science + computing ag
Senior Systems Engineer       Geschaeftsstelle Duesseldorf
                              Martinstrasse 47-55, Haus A
phone: +49 211 302 708 32     D-40223 Duesseldorf
fax:   +49 211 302 708 50     www.science-computing.de
-- =

Vorstandsvorsitzender/Chairman of the board of management:
Gerd-Lothar Leonhart
Vorstand/Board of Management:
Dr. Bernd Finkbeiner, Michael Heinrichs, =

Dr. Arno Steitz, Dr. Ingrid Zech
Vorsitzender des Aufsichtsrats/
Chairman of the Supervisory Board:
Philippe Miltin
Sitz/Registered Office: Tuebingen
Registergericht/Registration Court: Stuttgart
Registernummer/Commercial Register No.: HRB 382196

--PNTmBPCT7hxwcZjr
Content-Type: text/x-diff; charset=iso-8859-1
Content-Disposition: attachment; filename="0001-Add-l-option-to-gssd-to-force-legacy-behaviour.patch"

>From bd051cd3cc50d8d4695693c8f2d8cf78935c5711 Mon Sep 17 00:00:00 2001
From: Michael Weiser <weiser@science-computing.de>
Date: Mon, 12 Mar 2012 20:43:36 +0100
Subject: [PATCH] Add -l option to gssd to force legacy behaviour

A new option -l forces gssd to ignore its kernel's crypto capabilities
and use just the Single DES legacy encryption types to be compatible
with old servers without re-negotiation functionality.
---
 utils/gssd/gssd.c      |   12 +++++++++++-
 utils/gssd/krb5_util.c |    6 +++++-
 utils/gssd/krb5_util.h |    1 +
 3 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index ccadb07..fff9d21 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -100,9 +100,14 @@ main(int argc, char *argv[])
 	int i;
 	extern char *optarg;
 	char *progname;
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+ 	const char *opts = "fvrmnMp:k:d:t:R:l";
+#else
+ 	const char *opts = "fvrmnMp:k:d:t:R";
+#endif
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrmnMp:k:d:t:R:")) != -1) {
+	while ((opt = getopt(argc, argv, opts)) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -143,6 +148,11 @@ main(int argc, char *argv[])
 			case 'R':
 				preferred_realm = strdup(optarg);
 				break;
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+			case 'l':
+				limit_to_legacy_enctypes = 1;
+				break;
+#endif
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 4b13fa1..887d118 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -129,6 +129,10 @@
 /* Global list of principals/cache file names for machine credentials */
 struct gssd_k5_kt_princ *gssd_k5_kt_princ_list = NULL;
 
+#ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+int limit_to_legacy_enctypes = 0;
+#endif
+
 /*==========================*/
 /*===  Internal routines ===*/
 /*==========================*/
@@ -1342,7 +1346,7 @@ limit_krb5_enctypes(struct rpc_gss_sec *sec)
 	 * If we failed for any reason to produce global
 	 * list of supported enctypes, use local default here.
 	 */
-	if (krb5_enctypes == NULL)
+	if (krb5_enctypes == NULL || limit_to_legacy_enctypes)
 		maj_stat = gss_set_allowable_enctypes(&min_stat, credh,
 					&krb5oid, num_enctypes, enctypes);
 	else
diff --git a/utils/gssd/krb5_util.h b/utils/gssd/krb5_util.h
index b42b91e..cd6e107 100644
--- a/utils/gssd/krb5_util.h
+++ b/utils/gssd/krb5_util.h
@@ -36,6 +36,7 @@ char *gssd_k5_err_msg(krb5_context context, krb5_error_code code);
 void gssd_k5_get_default_realm(char **def_realm);
 
 #ifdef HAVE_SET_ALLOWABLE_ENCTYPES
+extern int limit_to_legacy_enctypes;
 int limit_krb5_enctypes(struct rpc_gss_sec *sec);
 #endif
 
-- 
1.7.3.4


--PNTmBPCT7hxwcZjr--

