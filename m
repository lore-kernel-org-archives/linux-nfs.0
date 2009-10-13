From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/26] statd: Introduce statd version of matchhostname()
Date: Tue, 13 Oct 2009 10:57:23 -0400
Message-ID: <20091013145723.2424.18494.stgit@matisse.1015granger.net>
References: <20091013142257.2424.76946.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:63441 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760132AbZJMO7w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Oct 2009 10:59:52 -0400
Received: from acsinet15.oracle.com (acsinet15.oracle.com [141.146.126.227])
	by rgminet12.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9DEwqUU012780
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 14:58:53 GMT
Received: from acsmt355.oracle.com (acsmt355.oracle.com [141.146.40.155])
	by acsinet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n9D4D567014186
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2009 15:00:10 GMT
In-Reply-To: <20091013142257.2424.76946.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the near future, statd will support IPv6 but mountd/exportfs will
not.  Thus statd will need a version of matchhostname() that can deal
properly with IPv6 remotes.  To reduce the risk of breaking mountd
and exportfs, introduce a separate version of matchhostname() for
statd to use while mountd/exportfs continues to use the existing
AF_INET-only implementation.

When IPv6 support is enabled, returned IPv4 addresses are mapped v4
AF_INET6 addresses, making the address list comparison logic simpler.
Support for link-local addresses is achieved by comparing full socket
addresses, not just the in_addr portion of each address, when
comparing AF_INET6 addresses for equality.

Using getaddrinfo(3) here means matchhostname() now supports
international domain name translation.  With versions of glibc newer
than 2.3, all incoming DNS labels are converted to ASCII.  Thus we
have a stronger guarantee that any of the returned canonical
hostnames, including both ASCII hostnames and IDNA labels, can be
compared properly using strcasecmp(3).

Note that statd will never send matchhostname() a hostname string
containing export wildcards, so is_hostame() is not needed in the
statd version of matchhostname().  This saves some computational
expense when comparing hostnames.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/Makefile.am |    5 +
 utils/statd/callback.c  |    5 +
 utils/statd/hostname.c  |  165 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/monitor.c   |    5 +
 utils/statd/notlist.c   |    4 +
 utils/statd/statd.h     |    2 -
 6 files changed, 174 insertions(+), 12 deletions(-)
 create mode 100644 utils/statd/hostname.c

diff --git a/utils/statd/Makefile.am b/utils/statd/Makefile.am
index d9731b7..a94c012 100644
--- a/utils/statd/Makefile.am
+++ b/utils/statd/Makefile.am
@@ -6,14 +6,13 @@ RPCPREFIX	= rpc.
 KPREFIX		= @kprefix@
 sbin_PROGRAMS	= statd sm-notify
 dist_sbin_SCRIPTS	= start-statd
-statd_SOURCES = callback.c notlist.c misc.c monitor.c \
+statd_SOURCES = callback.c notlist.c misc.c monitor.c hostname.c \
 	        simu.c stat.c statd.c svc_run.c rmtcall.c \
 	        notlist.h statd.h system.h version.h
 sm_notify_SOURCES = sm-notify.c
 
 BUILT_SOURCES = $(GENFILES)
-statd_LDADD = ../../support/export/libexport.a \
-	      ../../support/nsm/libnsm.a \
+statd_LDADD = ../../support/nsm/libnsm.a \
 	      ../../support/nfs/libnfs.a \
 	      ../../support/misc/libmisc.a \
 	      $(LIBWRAP) $(LIBNSL)
diff --git a/utils/statd/callback.c b/utils/statd/callback.c
index 2f98aeb..56163d5 100644
--- a/utils/statd/callback.c
+++ b/utils/statd/callback.c
@@ -13,7 +13,6 @@
 #include <arpa/inet.h>
 
 #include "rpcmisc.h"
-#include "misc.h"
 #include "statd.h"
 #include "notlist.h"
 
@@ -52,8 +51,8 @@ sm_notify_1_svc(struct stat_chge *argp, struct svc_req *rqstp)
 	 */
 	for (lp = rtnl ; lp ; lp = lp->next)
 		if (NL_STATE(lp) != argp->state &&
-		    (matchhostname(argp->mon_name, lp->dns_name) ||
-		     matchhostname(ip_addr, lp->dns_name))) {
+		    (nsm_matchhostname(argp->mon_name, lp->dns_name) ||
+		     nsm_matchhostname(ip_addr, lp->dns_name))) {
 			NL_STATE(lp) = argp->state;
 			call = nlist_clone(lp);
 			nlist_insert(&notify, call);
diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
new file mode 100644
index 0000000..683c48b
--- /dev/null
+++ b/utils/statd/hostname.c
@@ -0,0 +1,165 @@
+/*
+ * Copyright 2009 Oracle.  All rights reserved.
+ *
+ * This file is part of nfs-utils.
+ *
+ * nfs-utils is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * nfs-utils is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with nfs-utils.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+/*
+ * NSM for Linux.
+ */
+
+#ifdef HAVE_CONFIG_H
+#include <config.h>
+#endif
+
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include <stdlib.h>
+#include <strings.h>
+#include <netdb.h>
+
+#include "statd.h"
+#include "xlog.h"
+
+/*
+ * Before glibc 2.3.4, these flags are not defined
+ */
+#ifndef AI_IDN
+#define AI_IDN	0
+#endif
+#ifndef AI_IDN_USE_STD3_ASCII_RULES
+#define AI_IDN_USE_STD3_ASCII_RULES	0
+#endif
+
+#ifndef NI_IDN
+#define NI_IDN	0
+#endif
+#ifndef NI_IDN_USE_STD3_ASCII_RULES
+#define NI_IDN_USE_STD3_ASCII_RULES	0
+#endif
+
+/*
+ * Look up the hostname; report exceptional errors.  Caller must
+ * call freeaddrinfo(3) if a valid addrinfo is returned.
+ */
+static struct addrinfo *
+get_addrinfo(const char *hostname, const struct addrinfo* gai_hint)
+{
+	struct addrinfo *gai_results;
+	int error;
+
+	error = getaddrinfo(hostname, NULL, gai_hint, &gai_results);
+	switch (error) {
+	case 0:
+		return gai_results;
+	case EAI_NONAME:
+		break;
+	default:
+		xlog(L_ERROR, "%s: failed to resolve host %s: %s",
+				__func__, hostname, gai_strerror(error));
+	}
+
+	return NULL;
+}
+
+#ifdef IPV6_SUPPORTED
+static int
+compare_sockaddrs(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sa1;
+	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sa2;
+
+	if ((IN6_IS_ADDR_LINKLOCAL(&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_LINKLOCAL(&sin2->sin6_addr)) ||
+	    (IN6_IS_ADDR_SITELOCAL(&sin1->sin6_addr) &&
+	     IN6_IS_ADDR_SITELOCAL(&sin2->sin6_addr)))
+		if (sin1->sin6_scope_id != sin2->sin6_scope_id)
+			return 0;
+
+	return IN6_ARE_ADDR_EQUAL(&sin1->sin6_addr, &sin2->sin6_addr);
+}
+#else	/* !IPV6_SUPPORTED */
+static int
+compare_sockaddrs(const struct sockaddr *sa1,
+				const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+#endif	/* !IPV6_SUPPORTED */
+
+/**
+ * nsm_matchhostname - check if two hostnames are equivalent
+ * @hostname1: C string containing hostname
+ * @hostname2: C string containing hostname
+ *
+ * Returns 1 if the hostnames are the same, the hostnames resolve
+ * to the same canonical name, or the hostnames resolve to at least
+ * one address that is the same.  Zero is returned if the hostnames
+ * do not match in any of these ways, if either hostname contains
+ * wildcard characters, if either hostname is a netgroup name, or
+ * if an error occurs.
+ */
+int
+nsm_matchhostname(const char *hostname1, const char *hostname2)
+{
+	struct addrinfo *ai1, *ai2, *gai_results1 = NULL, *gai_results2 = NULL;
+	static const struct addrinfo gai_hint = {
+#ifdef IPV6_SUPPORTED
+		.ai_family	= AF_INET6,
+		.ai_flags	= AI_CANONNAME | AI_V4MAPPED |
+				  AI_IDN | AI_IDN_USE_STD3_ASCII_RULES,
+#else	/* !IPV6_SUPPORTED */
+		.ai_family	= AF_INET,
+		.ai_flags	= AI_CANONNAME |
+				  AI_IDN | AI_IDN_USE_STD3_ASCII_RULES,
+#endif	/* !IPV6_SUPPORTED */
+		.ai_protocol	= IPPROTO_UDP,
+	};
+	int result = 0;
+
+	if (strcasecmp(hostname1, hostname2) == 0)
+		return 1;
+
+	gai_results1 = get_addrinfo(hostname1, &gai_hint);
+	if (gai_results1 == NULL)
+		goto out;
+	gai_results2 = get_addrinfo(hostname2, &gai_hint);
+	if (gai_results2 == NULL) {
+		freeaddrinfo(gai_results1);
+		goto out;
+	}
+
+	if (strcasecmp(gai_results1->ai_canonname,
+				gai_results2->ai_canonname) == 0) {
+		result = 1;
+		goto out;
+	}
+
+	for (ai1 = gai_results1; ai1; ai1 = ai1->ai_next)
+		for (ai2 = gai_results2; ai2; ai2 = ai2->ai_next)
+			if (compare_sockaddrs(ai1->ai_addr, ai2->ai_addr)) {
+				result = 1;
+				goto out;
+			}
+
+out:
+	freeaddrinfo(gai_results2);
+	freeaddrinfo(gai_results1);
+	return result;
+}
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 8d9f663..a70b848 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -22,7 +22,6 @@
 #include <dirent.h>
 
 #include "rpcmisc.h"
-#include "misc.h"
 #include "nsm.h"
 #include "statd.h"
 #include "notlist.h"
@@ -145,7 +144,7 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	clnt = rtnl;
 
 	while ((clnt = nlist_gethost(clnt, mon_name, 0))) {
-		if (matchhostname(NL_MY_NAME(clnt), my_name) &&
+		if (nsm_matchhostname(NL_MY_NAME(clnt), my_name) &&
 		    NL_MY_PROC(clnt) == id->my_proc &&
 		    NL_MY_PROG(clnt) == id->my_prog &&
 		    NL_MY_VERS(clnt) == id->my_vers &&
@@ -298,7 +297,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 	 * entry winds up in the list the way I'm currently handling them.)
 	 */
 	while ((clnt = nlist_gethost(clnt, mon_name, 0))) {
-		if (matchhostname(NL_MY_NAME(clnt), my_name) &&
+		if (nsm_matchhostname(NL_MY_NAME(clnt), my_name) &&
 			NL_MY_PROC(clnt) == id->my_proc &&
 			NL_MY_PROG(clnt) == id->my_prog &&
 			NL_MY_VERS(clnt) == id->my_vers) {
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index 1698c26..0ae94c8 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -17,7 +17,6 @@
 #endif
 
 #include <string.h>
-#include "misc.h"
 #include "statd.h"
 #include "notlist.h"
 
@@ -234,7 +233,8 @@ nlist_gethost(notify_list *list, char *host, int myname)
 	notify_list	*lp;
 
 	for (lp = list; lp; lp = lp->next) {
-		if (matchhostname(host, myname? NL_MY_NAME(lp) : NL_MON_NAME(lp)))
+		if (nsm_matchhostname(host,
+					myname? NL_MY_NAME(lp) : NL_MON_NAME(lp)))
 			return lp;
 	}
 
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 542a877..c53b70a 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -22,7 +22,7 @@
 /*
  * Function prototypes.
  */
-extern void	change_state(void);
+extern int	nsm_matchhostname(const char *hostname1, const char *hostname2);
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);
 extern void	shuffle_dirs(void);

