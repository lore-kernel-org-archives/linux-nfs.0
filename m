Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f45.google.com ([209.85.192.45]:35634 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750968AbbHEOph (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 10:45:37 -0400
Received: by qgj62 with SMTP id 62so6059336qgj.2
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 07:45:36 -0700 (PDT)
Subject: [PATCH v2 1/6] nfsidmap: Display the effective NFSv4 domain name
From: Chuck Lever <chuck.lever@oracle.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 10:45:34 -0400
Message-ID: <20150805144534.13266.4474.stgit@manet.1015granger.net>
In-Reply-To: <20150805143258.13266.92369.stgit@manet.1015granger.net>
References: <20150805143258.13266.92369.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry for the extensive man page changes. I added the description
for the new "-d" option, then realized there was no explanation
about what an "NFSv4 domain name" is.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 utils/nfsidmap/nfsidmap.c   |   26 +++++++++++++++++--
 utils/nfsidmap/nfsidmap.man |   59 +++++++++++++++++++++++++++++++++++--------
 2 files changed, 71 insertions(+), 14 deletions(-)

diff --git a/utils/nfsidmap/nfsidmap.c b/utils/nfsidmap/nfsidmap.c
index 1f5ba67..dd490aa 100644
--- a/utils/nfsidmap/nfsidmap.c
+++ b/utils/nfsidmap/nfsidmap.c
@@ -16,7 +16,7 @@
 #include "conffile.h"
 
 int verbose = 0;
-char *usage="Usage: %s [-v] [-c || [-u|-g|-r key] || [-t timeout] key desc]";
+char *usage = "Usage: %s [-v] [-c || [-u|-g|-r key] || -d || [-t timeout] key desc]";
 
 #define MAX_ID_LEN   11
 #define IDMAP_NAMESZ 128
@@ -37,6 +37,21 @@ static int keyring_clear(char *keyring);
 #define UIDKEYS 0x1
 #define GIDKEYS 0x2
 
+static int display_default_domain(void)
+{
+	char domain[NFS4_MAX_DOMAIN_LEN];
+	int rc;
+
+	rc = nfs4_get_default_domain(NULL, domain, NFS4_MAX_DOMAIN_LEN);
+	if (rc) {
+		xlog_errno(rc, "nfs4_get_default_domain failed: %m");
+		return EXIT_FAILURE;
+	}
+
+	printf("%s\n", domain);
+	return EXIT_SUCCESS;
+}
+
 /*
  * Find either a user or group id based on the name@domain string
  */
@@ -248,7 +263,7 @@ int main(int argc, char **argv)
 	int timeout = 600;
 	key_serial_t key;
 	char *progname, *keystr = NULL;
-	int clearing = 0, keymask = 0;
+	int clearing = 0, keymask = 0, display = 0;
 
 	/* Set the basename */
 	if ((progname = strrchr(argv[0], '/')) != NULL)
@@ -258,8 +273,11 @@ int main(int argc, char **argv)
 
 	xlog_open(progname);
 
-	while ((opt = getopt(argc, argv, "u:g:r:ct:v")) != -1) {
+	while ((opt = getopt(argc, argv, "du:g:r:ct:v")) != -1) {
 		switch (opt) {
+		case 'd':
+			display++;
+			break;
 		case 'u':
 			keymask = UIDKEYS;
 			keystr = strdup(optarg);
@@ -294,6 +312,8 @@ int main(int argc, char **argv)
 	if (!verbose)
 		verbose = conf_get_num("General", "Verbosity", 0);
 
+	if (display)
+		return display_default_domain();
 	if (keystr) {
 		rc = key_invalidate(keystr, keymask);
 		return rc;		
diff --git a/utils/nfsidmap/nfsidmap.man b/utils/nfsidmap/nfsidmap.man
index 3a3a523..04ddff6 100644
--- a/utils/nfsidmap/nfsidmap.man
+++ b/utils/nfsidmap/nfsidmap.man
@@ -11,27 +11,54 @@ nfsidmap \- The NFS idmapper upcall program
 .B "nfsidmap [-v] [-c]"
 .br
 .B "nfsidmap [-v] [-u|-g|-r user]"
+.br
+.B "nfsidmap -d"
 .SH DESCRIPTION
-The file
+The NFSv4 protocol represents the local system's UID and GID values
+on the wire as strings of the form
+.IR user@domain .
+The process of translating from UID to string and string to UID is
+referred to as "ID mapping."
+.PP
+The system derives the
+.I user
+part of the string by performing a password or group lookup.
+The lookup mechanism is configured in
+.IR /etc/idmapd.conf .
+.PP
+By default, the
+.I domain
+part of the string is the system's DNS domain name.
+It can also be specified in
+.I /etc/idmapd.conf
+if the system is multi-homed,
+or if the system's DNS domain name does
+not match the name of the system's Kerberos realm.
+.PP
+The
 .I /usr/sbin/nfsidmap
-is used by the NFS idmapper to translate user and group ids into names, and to
-translate user and group names into ids. Idmapper uses request-key to perform
-the upcall and cache the result.
+program performs translations on behalf of the kernel.
+The kernel uses the request-key mechanism to perform
+an upcall.
 .I /usr/sbin/nfsidmap
-is called by /sbin/request-key, and will perform the translation and
-initialize a key with the resulting information.
+is invoked by /sbin/request-key, performs the translation,
+and initializes a key with the resulting information.
+The kernel then caches the translation results in the key.
 .PP
 .I nfsidmap
-can also used to clear the keyring of all the keys or 
-revoke one particular key.  
-This is useful when the id mappings have failed to due 
-to a lookup error resulting in all the cached uids/gids to be set 
-to the user id nobody.
+can also clear cached ID map results in the kernel,
+or revoke one particular key.
+An incorrect cached key can result in file and directory ownership
+reverting to "nobody" on NFSv4 mount points.
 .SH OPTIONS
 .TP
 .B -c 
 Clear the keyring of all the keys.
 .TP
+.B -d
+Display the system's effective NFSv4 domain name on
+.IR stdout .
+.TP
 .B -g user
 Revoke the gid key of the given user.
 .TP
@@ -89,5 +116,15 @@ Notice that the new line was added above the line for the generic program.
 request-key will find the first matching line and run the corresponding program.
 In this case, /some/other/program will handle all uid lookups, and
 /usr/sbin/nfsidmap will handle gid, user, and group lookups.
+.SH FILES
+.TP
+.I /etc/idmapd.conf
+ID mapping configuration file
+.TP
+.I /etc/request-key.conf
+Request key configuration file
+.SH "SEE ALSO"
+.BR idmapd.conf (5),
+.BR request-key (8)
 .SH AUTHOR
 Bryan Schumaker, <bjschuma@netapp.com>

