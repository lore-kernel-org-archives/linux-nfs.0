From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] mountd/exportfs: Make m_addrlist field a nfs_sockaddr
Date: Mon, 03 May 2010 15:24:25 -0400
Message-ID: <20100503192425.29316.29660.stgit@localhost.localdomain>
References: <20100503192041.29316.35846.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:36736 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756192Ab0ECTY3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 May 2010 15:24:29 -0400
Received: by gyg13 with SMTP id 13so1327562gyg.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 May 2010 12:24:28 -0700 (PDT)
In-Reply-To: <20100503192041.29316.35846.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To store non-AF_INET addresses in the nfs_client structure, we need to
use more than in_addr for the m_addrlist field.  Make m_addrlist
larger, then add a few helper functions to handle type casting and
array indexing cleanly.

We could treat the nfs_client address list as if all the addresses
in the list were the same family.  This might work for MCL_SUBNETWORK
type nfs_clients.  However, during the transition to IPv6, most hosts
will have at least one IPv4 and one IPv6 address.  For MCL_FQDN, I
think we need to have the ability to store addresses from both
families in one nfs_client.

Additionally, IPv6 scope IDs are not part of struct sin6_addr.  To
support link-local IPv6 addresses and the like, a scope ID must be
stored.

Thus, each slot in the address list needs to be capable of storing an
entire socket address, and not simply the network address part.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c    |   39 ++++++++++++++++++++++++++---------
 support/export/nfsctl.c    |   17 ++++++++++++---
 support/include/exportfs.h |   49 +++++++++++++++++++++++++++++++++++++++++++-
 utils/mountd/auth.c        |    2 +-
 utils/mountd/cache.c       |    3 ++-
 5 files changed, 93 insertions(+), 17 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 4600255..21ad272 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -37,6 +37,9 @@ nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
 static void
 init_addrlist(nfs_client *clp, const struct hostent *hp)
 {
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+	};
 	char **ap;
 	int i;
 
@@ -44,9 +47,10 @@ init_addrlist(nfs_client *clp, const struct hostent *hp)
 		return;
 
 	ap = hp->h_addr_list;
-	for (i = 0; *ap != NULL && i < NFSCLNT_ADDRMAX; i++, ap++)
-		clp->m_addrlist[i] = *(struct in_addr *)*ap;
-
+	for (i = 0; *ap != NULL && i < NFSCLNT_ADDRMAX; i++, ap++) {
+		sin.sin_addr = *(struct in_addr *)*ap;
+		set_addrlist_in(clp, i, &sin);
+	}
 	clp->m_naddr = i;
 }
 
@@ -60,17 +64,22 @@ client_free(nfs_client *clp)
 static int
 init_netmask(nfs_client *clp, const char *slash)
 {
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+	};
+
 	if (strchr(slash + 1, '.') != NULL)
-		clp->m_addrlist[1].s_addr = inet_addr(slash + 1);
+		sin.sin_addr.s_addr = inet_addr(slash + 1);
 	else {
 		int prefixlen = atoi(slash + 1);
 		if (0 < prefixlen && prefixlen <= 32)
-			clp->m_addrlist[1].s_addr =
+			sin.sin_addr.s_addr =
 					htonl((uint32_t)~0 << (32 - prefixlen));
 		else
 			goto out_badprefix;
 	}
 
+	set_addrlist_in(clp, 1, &sin);
 	return 1;
 
 out_badprefix:
@@ -81,6 +90,9 @@ out_badprefix:
 static int
 init_subnetwork(nfs_client *clp)
 {
+	struct sockaddr_in sin = {
+		.sin_family		= AF_INET,
+	};
 	static char slash32[] = "/32";
 	char *cp;
 
@@ -89,7 +101,8 @@ init_subnetwork(nfs_client *clp)
 		cp = slash32;
 
 	*cp = '\0';
-	clp->m_addrlist[0].s_addr = inet_addr(clp->m_hostname);
+	sin.sin_addr.s_addr = inet_addr(clp->m_hostname);
+	set_addrlist_in(clp, 0, &sin);
 	*cp = '/';
 
 	return init_netmask(clp, cp);
@@ -366,6 +379,7 @@ add_name(char *old, const char *add)
 static int
 check_fqdn(const nfs_client *clp, const struct hostent *hp)
 {
+	const struct sockaddr_in *sin;
 	struct in_addr addr;
 	char **ap;
 	int i;
@@ -373,9 +387,11 @@ check_fqdn(const nfs_client *clp, const struct hostent *hp)
 	for (ap = hp->h_addr_list; *ap; ap++) {
 		addr = *(struct in_addr *)*ap;
 
-		for (i = 0; i < clp->m_naddr; i++)
-			if (clp->m_addrlist[i].s_addr == addr.s_addr)
+		for (i = 0; i < clp->m_naddr; i++) {
+			sin = get_addrlist_in(clp, i);
+			if (sin->sin_addr.s_addr == addr.s_addr)
 				return 1;
+		}
 	}
 	return 0;
 }
@@ -388,14 +404,17 @@ check_fqdn(const nfs_client *clp, const struct hostent *hp)
 static int
 check_subnetwork(const nfs_client *clp, const struct hostent *hp)
 {
+	const struct sockaddr_in *address, *mask;
 	struct in_addr addr;
 	char **ap;
 
 	for (ap = hp->h_addr_list; *ap; ap++) {
+		address = get_addrlist_in(clp, 0);
+		mask = get_addrlist_in(clp, 1);
 		addr = *(struct in_addr *)*ap;
 
-		if (!((clp->m_addrlist[0].s_addr ^ addr.s_addr) &
-		      clp->m_addrlist[1].s_addr))
+		if (!((address->sin_addr.s_addr ^ addr.s_addr) &
+		      mask->sin_addr.s_addr))
 			return 1;
 	}
 	return 0;
diff --git a/support/export/nfsctl.c b/support/export/nfsctl.c
index e2877b9..ae357c7 100644
--- a/support/export/nfsctl.c
+++ b/support/export/nfsctl.c
@@ -66,7 +66,7 @@ str_tolower(char *s)
 static int
 cltsetup(struct nfsctl_client *cltarg, nfs_client *clp)
 {
-	int	i;
+	int i, j;
 
 	if (clp->m_type != MCL_FQDN) {
 		xlog(L_ERROR, "internal: can't export non-FQDN host");
@@ -76,10 +76,19 @@ cltsetup(struct nfsctl_client *cltarg, nfs_client *clp)
 	strncpy(cltarg->cl_ident, clp->m_hostname,
 		sizeof (cltarg->cl_ident) - 1);
 	str_tolower(cltarg->cl_ident);
-	cltarg->cl_naddr = clp->m_naddr;
-	for (i = 0; i < cltarg->cl_naddr && i < NFSCLNT_ADDRMAX; i++)
-		cltarg->cl_addrlist[i] = clp->m_addrlist[i];
 
+	j = 0;
+	for (i = 0; i < cltarg->cl_naddr && i < NFSCLNT_ADDRMAX; i++) {
+		struct sockaddr_in *sin = get_addrlist_in(clp, i);
+		if (sin->sin_family == AF_INET)
+			cltarg->cl_addrlist[j++] = sin->sin_addr;
+	}
+	if (j == 0) {
+		xlog(L_ERROR, "internal: no supported addresses in nfs_client");
+		return 0;
+	}
+
+	cltarg->cl_naddr = j;
 	return 1;
 }
 
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 05891c5..70bdd57 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -10,6 +10,8 @@
 #define EXPORTFS_H
 
 #include <netdb.h>
+
+#include "sockaddr.h"
 #include "nfslib.h"
 
 enum {
@@ -35,11 +37,56 @@ typedef struct mclient {
 	char *			m_hostname;
 	int			m_type;
 	int			m_naddr;
-	struct in_addr		m_addrlist[NFSCLNT_ADDRMAX];
+	union nfs_sockaddr	m_addrlist[NFSCLNT_ADDRMAX];
 	int			m_exported;	/* exported to nfsd */
 	int			m_count;
 } nfs_client;
 
+static inline const struct sockaddr *
+get_addrlist(const nfs_client *clp, const int i)
+{
+	return &clp->m_addrlist[i].sa;
+}
+
+static inline const struct sockaddr_in *
+get_addrlist_in(const nfs_client *clp, const int i)
+{
+	return &clp->m_addrlist[i].s4;
+}
+
+static inline const struct sockaddr_in6 *
+get_addrlist_in6(const nfs_client *clp, const int i)
+{
+	return &clp->m_addrlist[i].s6;
+}
+
+static inline void
+set_addrlist_in(nfs_client *clp, const int i, const struct sockaddr_in *sin)
+{
+	memcpy(&clp->m_addrlist[i].s4, sin, sizeof(*sin));
+}
+
+static inline void
+set_addrlist_in6(nfs_client *clp, const int i, const struct sockaddr_in6 *sin6)
+{
+	memcpy(&clp->m_addrlist[i].s6, sin6, sizeof(*sin6));
+}
+
+static inline void
+set_addrlist(nfs_client *clp, const int i, const struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		memcpy(&clp->m_addrlist[i].s4, sap, sizeof(struct sockaddr_in));
+		break;
+#ifdef IPV6_SUPPORTED
+	case AF_INET6:
+		memcpy(&clp->m_addrlist[i].s6, sap, sizeof(struct sockaddr_in6));
+		break;
+#endif
+	}
+}
+
 typedef struct mexport {
 	struct mexport *	m_next;
 	struct mclient *	m_client;
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 13eba70..4b94b98 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -142,7 +142,7 @@ auth_authenticate_newcache(char *what, struct sockaddr_in *caller,
 		return NULL;
 
 	my_client.m_naddr = 1;
-	my_client.m_addrlist[0] = caller->sin_addr;
+	set_addrlist_in(&my_client, 0, caller);
 	my_exp.m_client = &my_client;
 
 	exp = NULL;
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6343325..caef5b2 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -863,6 +863,7 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 
 int cache_export(nfs_export *exp, char *path)
 {
+	struct sockaddr_in *sin = get_addrlist_in(exp->m_client, 0);
 	int err;
 	FILE *f;
 
@@ -871,7 +872,7 @@ int cache_export(nfs_export *exp, char *path)
 		return -1;
 
 	qword_print(f, "nfsd");
-	qword_print(f, inet_ntoa(exp->m_client->m_addrlist[0]));
+	qword_print(f, inet_ntoa(sin->sin_addr));
 	qword_printint(f, time(0)+30*60);
 	qword_print(f, exp->m_client->m_hostname);
 	err = qword_eol(f);

