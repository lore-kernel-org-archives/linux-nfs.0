Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:44679 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753918Ab3CHTrn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Mar 2013 14:47:43 -0500
Received: by mail-ie0-f174.google.com with SMTP id k10so2554003iea.33
        for <linux-nfs@vger.kernel.org>; Fri, 08 Mar 2013 11:47:43 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] gssd: Add "-c" command line option
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>
Date: Fri, 08 Mar 2013 14:47:41 -0500
Message-ID: <20130308194741.5656.56599.stgit@seurat.1015granger.net>
In-Reply-To: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
References: <20130308193830.5656.44184.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When a system does not have a keytab, it has no way to obtain
machine credentials.  In the past, we've fudged it by simply using
root's user credential as the machine credential.  (root must kinit
in this case, of course).

Since v1 of the kernel's GSS upcall was introduced, rpc.gssd can
tell when the kernel requests a machine credential specifically,
say, for NFSv4 operations that are required to use one
(SETCLIENTID).

Since I moved SETCLIENTID to the first operation performed against
a new server, this means a sec=krb5 NFSv4 mount can't succeed at all
if there is no machine credential.  Previously, this kind of mount
could work at least until a SETCLIENTID was done, as the kernel
could use root's user credential for housekeeping like grabbing the
server's root FH.  (Or maybe there is some kind of gssd bug that
allowed it to keep working?).

In any event, what we want to do is provide a clean and secure way
for rpc.gssd to substitute a specific user credential if there is no
machine credential available.  (I'm actually not clear on why this
is OK to do).

Recent work to add Active Directory support to rpc.gssd gives us a
potential user principal that can be used for this purpose:

  HOSTNAME$@REALM

We have a specific user principal then.  We have to tell rpc.gssd
where to look for the credential file.  Introduce a command line
option that specifies exactly where the file containing the
credential for this principal can be found.  This credential would
be used only if no other machine credential is available.

One might then use it this way:

  # /usr/sbin/rpc.gssd -n -c /tmp/krb5cc_0
  # kinit <hostname>$@<REALM>
  Password for <hostname>$@<REALM>:
  # mount -t nfs4 -o sec=krb5 server:/export /mnt

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/gssd/gssd.c      |   14 +++++++++-
 utils/gssd/gssd.h      |    1 +
 utils/gssd/gssd.man    |   18 +++++++++++++
 utils/gssd/krb5_util.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 98 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 0be2517..7537a97 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -58,6 +58,7 @@
 char pipefs_dir[PATH_MAX] = GSSD_PIPEFS_DIR;
 char keytabfile[PATH_MAX] = GSSD_DEFAULT_KEYTAB_FILE;
 char ccachedir[PATH_MAX] = GSSD_DEFAULT_CRED_DIR ":" GSSD_USER_CRED_DIR;
+char mach_cred_file[PATH_MAX] = "";
 char *ccachesearch[GSSD_MAX_CCACHE_SEARCH + 1];
 int  use_memcache = 0;
 int  root_uses_machine_creds = 1;
@@ -85,7 +86,9 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
+	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] "
+		"[-p pipefsdir] [-k keytab] [-d ccachedir] "
+		"[-t timeout] [-R preferred realm] [-c credfile]\n",
 		progname);
 	exit(1);
 }
@@ -102,7 +105,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R:c:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -122,6 +125,11 @@ main(int argc, char *argv[])
 			case 'r':
 				rpc_verbosity++;
 				break;
+			case 'c':
+				strncpy(mach_cred_file, optarg, sizeof(mach_cred_file));
+				if (mach_cred_file[sizeof(mach_cred_file)-1] != '\0')
+					errx(1, "credential file name too long");
+				break;
 			case 'p':
 				strncpy(pipefs_dir, optarg, sizeof(pipefs_dir));
 				if (pipefs_dir[sizeof(pipefs_dir)-1] != '\0')
@@ -156,6 +164,8 @@ main(int argc, char *argv[])
 		}
 	}
 
+	if (mach_cred_file[0] != '\0' && use_memcache)
+		errx(1, "Cannot use memcache and credential file together");
 	i = 0;
 	ccachesearch[i++] = strtok(ccachedir, ":");
 	do {
diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
index 86472a1..e76bad1 100644
--- a/utils/gssd/gssd.h
+++ b/utils/gssd/gssd.h
@@ -62,6 +62,7 @@ enum {AUTHTYPE_KRB5, AUTHTYPE_LIPKEY};
 
 extern char			pipefs_dir[PATH_MAX];
 extern char			keytabfile[PATH_MAX];
+extern char			mach_cred_file[PATH_MAX];
 extern char			*ccachesearch[];
 extern int			use_memcache;
 extern int			root_uses_machine_creds;
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 79d9bf9..ef26577 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -19,6 +19,8 @@ rpc.gssd \- RPCSEC_GSS daemon
 .IR timeout ]
 .RB [ \-R
 .IR realm ]
+.RB [ \-c
+.IR file ]
 .SH INTRODUCTION
 The RPCSEC_GSS protocol, defined in RFC 5403, is used to provide
 strong security for RPC-based protocols such as NFS.
@@ -146,6 +148,18 @@ You can specify another keytab by using the
 option if
 .I /etc/krb5.keytab
 does not exist or does not provide one of these principals.
+.P
+If no keytab is found, the
+.B -c
+option can specify a file containing a credential that
+.B rpc.gssd
+should use as a machine credential.
+The principal must be of the form
+.sp
+   <HOSTNAME>$@<REALM>
+.sp
+Where <HOSTNAME> is the hostname of the local system, and <REALM> is the
+system's Kerberos realm.
 .SS Credentials for UID 0
 UID 0 is a special case.
 By default
@@ -213,6 +227,10 @@ to obtain machine credentials.
 The default value is
 .IR /etc/krb5.keytab .
 .TP
+.BI "-c " file
+Specifies a file in which to find a credential that can be used
+as a machine credential, if the local system has no keytab.
+.TP
 .B -l
 When specified, restricts
 .B rpc.gssd
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 215c0a4..c49aed9 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -937,6 +937,63 @@ out:
 	return retval;
 }
 
+/*
+ * Returns zero if credential cache file can be used for a machine credential
+ */
+static int
+verify_mach_cc(const char *ccache)
+{
+	char *hostname = NULL;
+	char *default_realm = NULL;
+	char *buf = NULL;
+	char *princname = NULL;
+	char *realm = NULL;
+	int retval;
+
+	retval = ENOMEM;
+	buf = malloc(PATH_MAX + 5);
+	if (buf == NULL)
+		goto out;
+
+	hostname = malloc(NI_MAXHOST + 1);
+	if (hostname == NULL)
+		goto out;
+	if (gethostname(hostname, NI_MAXHOST) == -1) {
+		retval = errno;
+		goto out;
+	}
+	strcat(hostname, "$");
+
+	retval = EKEYEXPIRED;
+	gssd_k5_get_default_realm(&default_realm);
+	if (default_realm == NULL)
+		goto out;
+
+	printerr(2, "looking for machine credentials in %s\n", ccache);
+	snprintf(buf, PATH_MAX + 5, "FILE:%s", ccache);
+	if (!query_krb5_ccache(buf, &princname, &realm))
+		goto out;
+
+	if (strcasecmp(princname, hostname) != 0) {
+		printerr(2, "ERROR: found principal name %s in %s\n",
+				princname, ccache);
+		goto out;
+	}
+	if (strcasecmp(realm, default_realm) != 0) {
+		printerr(2, "ERROR: found realm name %s in %s\n",
+				realm, ccache);
+		goto out;
+	}
+	retval = 0;
+
+out:
+	free(realm);
+	free(princname);
+	free(default_realm);
+	free(buf);
+	free(hostname);
+	return retval;
+}
 
 static inline int data_is_equal(krb5_data d1, krb5_data d2)
 {
@@ -1147,6 +1204,16 @@ gssd_get_krb5_machine_cred_list(char ***list)
 			}
 		}
 	}
+	if (i == 0 && mach_cred_file[0] != '\0') {
+		if (verify_mach_cc(mach_cred_file)) {
+			retval = EKEYEXPIRED;
+			goto out;
+		}
+		if ((l[i++] = strdup(mach_cred_file)) == NULL) {
+			retval = ENOMEM;
+			goto out;
+		}
+	}
 	if (i > 0) {
 		l[i] = NULL;
 		*list = l;

