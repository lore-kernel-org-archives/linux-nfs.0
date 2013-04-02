Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:19653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760343Ab3DBRtN (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 13:49:13 -0400
Received: from int-mx12.intmail.prod.int.phx2.redhat.com (int-mx12.intmail.prod.int.phx2.redhat.com [10.5.11.25])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnDWY017276
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:13 -0400
Received: from willson.li.ssimo.org.com (ovpn-113-117.phx2.redhat.com [10.3.113.117])
	by int-mx12.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r32HnB4H006259
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 13:49:13 -0400
From: Simo Sorce <simo@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/3] Avoid reverse resolution for server name
Date: Tue,  2 Apr 2013 13:49:06 -0400
Message-Id: <1364924947-16985-3-git-send-email-simo@redhat.com>
In-Reply-To: <1364924947-16985-1-git-send-email-simo@redhat.com>
References: <1364924947-16985-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A NFS client should be able to work properly even if the DNS Reverse record
for the server is not set. There is no excuse to forcefully prevent that
from working when it can.

This patch adds a new -N option that takes an 'on' or 'off' argument and
controls whether forced PTR resolution is avoided (on) or performed (off)

To avoid breaking current behavior the option defaults to off by default,
ideally we will turn this on by default after a transition period.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/gss_util.h  |    2 ++
 utils/gssd/gssd.c      |   18 ++++++++++++++++--
 utils/gssd/gssd_proc.c |   25 +++++++++++++++++++++----
 3 files changed, 39 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index aa9f77806075f9ab67a7763a75a010369ba2d1b9..663fb0998bede6144118f890b9311ee8687176e3 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -52,4 +52,6 @@ int gssd_check_mechs(void);
 		gss_krb5_set_allowable_enctypes(min, cred, num, types)
 #endif
 
+extern int avoid_ptr;
+
 #endif /* _GSS_UTIL_H_ */
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 07b1e52e6b84e9bcba96e7a63b0505ca7823482a..cc326dc2a729c1191c9f72ffd32203a58452b793 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -82,10 +82,19 @@ sig_hup(int signal)
 	return;
 }
 
+static int get_bool_arg(const char *arg)
+{
+	if (strcmp(arg, "on") == 0)
+		return 1;
+	if (strcmp(arg, "off") == 0)
+		return 0;
+	return -1;
+}
+
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
+	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-N on|off] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
 		progname);
 	exit(1);
 }
@@ -102,7 +111,7 @@ main(int argc, char *argv[])
 	char *progname;
 
 	memset(ccachesearch, 0, sizeof(ccachesearch));
-	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R:")) != -1) {
+	while ((opt = getopt(argc, argv, "fvrlmnMp:k:d:t:R:N:")) != -1) {
 		switch (opt) {
 			case 'f':
 				fg = 1;
@@ -150,6 +159,11 @@ main(int argc, char *argv[])
 				errx(1, "Encryption type limits not supported by Kerberos libraries.");
 #endif
 				break;
+			case 'N':
+				avoid_ptr = get_bool_arg(optarg);
+				if (avoid_ptr == -1)
+					errx(1, "Invalid argument for -N option");
+				break;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index ea01e92e4565670b97dea1a936d2f0dbdc7c4610..21d4e1d78eb54d177626cb0a19b9de4e93e0a20d 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -67,6 +67,7 @@
 #include <errno.h>
 #include <gssapi/gssapi.h>
 #include <netdb.h>
+#include <ctype.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -107,6 +108,8 @@ struct pollfd * pollarray;
 
 unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
 
+int avoid_ptr = 0;
+
 /*
  * convert a presentation address string to a sockaddr_storage struct. Returns
  * true on success or false on failure.
@@ -165,12 +168,26 @@ addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
  * convert a sockaddr to a hostname
  */
 static char *
-sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
+get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 {
 	socklen_t		addrlen;
 	int			err;
 	char			*hostname;
 	char			hbuf[NI_MAXHOST];
+	unsigned char		buf[sizeof(struct in6_addr)];
+	int			do_ptr_lookup = 0;
+
+	if (avoid_ptr) {
+		/* try to determine if this is a name, or an IP address.
+		 * If it is an IP fallback to a PTR lookup */
+		if (strchr(name, '.') && inet_pton(AF_INET, name, buf) == 1)
+			do_ptr_lookup = 1; /* IPv4 */
+		else if (strchr(name, ':') && inet_pton(AF_INET6, name, buf) == 1)
+			do_ptr_lookup = 1; /* or IPv6 */
+		if (!do_ptr_lookup) {
+			return strdup(name);
+		}
+	}
 
 	switch (sa->sa_family) {
 	case AF_INET:
@@ -208,7 +225,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		  struct sockaddr *addr) {
 #define INFOBUFLEN 256
 	char		buf[INFOBUFLEN + 1];
-	static char	dummy[128];
+	static char	server[128];
 	int		nbytes;
 	static char	service[128];
 	static char	address[128];
@@ -236,7 +253,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		   "service: %127s %15s version %15s\n"
 		   "address: %127s\n"
 		   "protocol: %15s\n",
-		   dummy,
+		   server,
 		   service, program, version,
 		   address,
 		   protoname);
@@ -258,7 +275,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	if (!addrstr_to_sockaddr(addr, address, port))
 		goto fail;
 
-	*servername = sockaddr_to_hostname(addr, address);
+	*servername = get_servername(server, addr, address);
 	if (*servername == NULL)
 		goto fail;
 
-- 
1.7.1

