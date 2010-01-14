From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/24] statd: Introduce statd version of matchhostname()
Date: Thu, 14 Jan 2010 12:30:19 -0500
Message-ID: <20100114173019.26079.64844.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43105 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757341Ab0ANRaz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:30:55 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the near future, statd will support IPv6 but exportfs will not.
Thus statd will need a version of matchhostname() that can deal
properly with IPv6 remotes.  To reduce the risk of breaking exportfs,
introduce a separate version of matchhostname() for statd to use while
exportfs continues to use the existing AF_INET-only implementation.

Note that statd will never send matchhostname() a hostname string
containing export wildcards, so is_hostame() is not needed in the
statd version of matchhostname().  This saves some computational
expense when comparing hostnames.

A separate statd-specific implementation of matchhostname() allows
some flexibility in the long term, as well.  We might want to enrich
the matching heuristics of our SM_NOTIFY, for example, or replace
them entirely with a heuristic that is not dependent upon DNS.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/statd/Makefile.am |    5 +-
 utils/statd/callback.c  |    5 +-
 utils/statd/hostname.c  |  119 +++++++++++++++++++++++++++++++++++++++++++++++
 utils/statd/monitor.c   |    5 +-
 utils/statd/notlist.c   |    4 +-
 utils/statd/statd.h     |    3 +
 6 files changed, 129 insertions(+), 12 deletions(-)
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
index 2f98aeb..b1acd15 100644
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
+		    (statd_matchhostname(argp->mon_name, lp->dns_name) ||
+		     statd_matchhostname(ip_addr, lp->dns_name))) {
 			NL_STATE(lp) = argp->state;
 			call = nlist_clone(lp);
 			nlist_insert(&notify, call);
diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
new file mode 100644
index 0000000..3d10d6f
--- /dev/null
+++ b/utils/statd/hostname.c
@@ -0,0 +1,119 @@
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
+#include <stdbool.h>
+#include <strings.h>
+#include <netdb.h>
+
+#include "sockaddr.h"
+#include "statd.h"
+#include "xlog.h"
+
+/*
+ * Look up the hostname; report exceptional errors.  Caller must
+ * call freeaddrinfo(3) if a valid addrinfo is returned.
+ */
+__attribute_malloc__
+static struct addrinfo *
+get_addrinfo(const char *hostname, const struct addrinfo *hint)
+{
+	struct addrinfo *ai = NULL;
+	int error;
+
+	error = getaddrinfo(hostname, NULL, hint, &ai);
+	switch (error) {
+	case 0:
+		return ai;
+	case EAI_NONAME:
+		break;
+	default:
+		xlog(D_GENERAL, "%s: failed to resolve host %s: %s",
+				__func__, hostname, gai_strerror(error));
+	}
+
+	return NULL;
+}
+
+/**
+ * statd_matchhostname - check if two hostnames are equivalent
+ * @hostname1: C string containing hostname
+ * @hostname2: C string containing hostname
+ *
+ * Returns true if the hostnames are the same, the hostnames resolve
+ * to the same canonical name, or the hostnames resolve to at least
+ * one address that is the same.  False is returned if the hostnames
+ * do not match in any of these ways, if either hostname contains
+ * wildcard characters, if either hostname is a netgroup name, or
+ * if an error occurs.
+ */
+_Bool
+statd_matchhostname(const char *hostname1, const char *hostname2)
+{
+	struct addrinfo *ai1, *ai2, *results1 = NULL, *results2 = NULL;
+	struct addrinfo hint = {
+		.ai_family	= AF_UNSPEC,
+		.ai_flags	= AI_CANONNAME,
+		.ai_protocol	= (int)IPPROTO_UDP,
+	};
+	_Bool result = false;
+
+	if (strcasecmp(hostname1, hostname2) == 0) {
+		result = true;
+		goto out;
+	}
+
+	results1 = get_addrinfo(hostname1, &hint);
+	if (results1 == NULL)
+		goto out;
+	results2 = get_addrinfo(hostname2, &hint);
+	if (results2 == NULL)
+		goto out;
+
+	if (strcasecmp(results1->ai_canonname, results2->ai_canonname) == 0) {
+		result = true;
+		goto out;
+	}
+
+	for (ai1 = results1; ai1 != NULL; ai1 = ai1->ai_next)
+		for (ai2 = results2; ai2 != NULL; ai2 = ai2->ai_next)
+			if (nfs_compare_sockaddr(ai1->ai_addr, ai2->ai_addr)) {
+				result = true;
+				break;
+			}
+
+out:
+	freeaddrinfo(results2);
+	freeaddrinfo(results1);
+
+	xlog(D_CALL, "%s: hostnames %s", __func__,
+			(result ? "matched" : "did not match"));
+	return result;
+}
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index f818b2b..51075b5 100644
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
+		if (statd_matchhostname(NL_MY_NAME(clnt), my_name) &&
 		    NL_MY_PROC(clnt) == id->my_proc &&
 		    NL_MY_PROG(clnt) == id->my_prog &&
 		    NL_MY_VERS(clnt) == id->my_vers &&
@@ -298,7 +297,7 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 	 * entry winds up in the list the way I'm currently handling them.)
 	 */
 	while ((clnt = nlist_gethost(clnt, mon_name, 0))) {
-		if (matchhostname(NL_MY_NAME(clnt), my_name) &&
+		if (statd_matchhostname(NL_MY_NAME(clnt), my_name) &&
 			NL_MY_PROC(clnt) == id->my_proc &&
 			NL_MY_PROG(clnt) == id->my_prog &&
 			NL_MY_VERS(clnt) == id->my_vers) {
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index 1698c26..de7d046 100644
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
+		if (statd_matchhostname(host,
+				myname? NL_MY_NAME(lp) : NL_MON_NAME(lp)))
 			return lp;
 	}
 
diff --git a/utils/statd/statd.h b/utils/statd/statd.h
index 542a877..fd6a084 100644
--- a/utils/statd/statd.h
+++ b/utils/statd/statd.h
@@ -22,7 +22,8 @@
 /*
  * Function prototypes.
  */
-extern void	change_state(void);
+extern _Bool	statd_matchhostname(const char *hostname1, const char *hostname2);
+
 extern void	my_svc_run(void);
 extern void	notify_hosts(void);
 extern void	shuffle_dirs(void);

