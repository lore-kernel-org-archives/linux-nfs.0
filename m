Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:34932 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756853Ab0E1UBQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 May 2010 16:01:16 -0400
Received: by gyg13 with SMTP id 13so1316318gyg.19
        for <linux-nfs@vger.kernel.org>; Fri, 28 May 2010 13:01:14 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] libexport.a: Add helpers to manage DNS lookups
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 28 May 2010 16:01:07 -0400
Message-ID: <20100528194908.6045.47537.stgit@localhost.localdomain>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Introduce DNS query helpers based on getaddrinfo(3) and
getnameinfo(3).  These will eventually replace the existing
hostent-based functions in support/export/hostname.c.

Put some of these new helpers to immediate use, where convenient.

As they are part of libexport.a, I've added the forward declarations
for these new functions in exportfs.h rather than misc.h, where the
hostent-based forward declarations are currently.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

Steve-

We're starting to get into the meat of the conversion from
gethostbyaddr(3) to getaddrinfo(3).  I'm sending this large one by
itself so you can see what the new DNS helper functions look like, and
get some flavor for how they will be used.

This one touches only a handful of call sites.  A bigger patch is
coming soon to convert all of mountd and exportfs to use these new DNS
helper functions, and to replace the use of struct hostent with
struct addrinfo everywhere (which is why it must be one big patch).

After that there are just a handful of clean-up patches.  Once mountd
and exportfs are fully converted to use struct addrinfo everywhere,
that would be a good time to cut a release of nfs-utils.  Then we can
get on with the actual IPv6 support.


 support/export/hostname.c  |  351 ++++++++++++++++++++++++++++++++++++++++++++
 support/include/exportfs.h |   13 ++
 utils/exportfs/exportfs.c  |   11 +
 utils/mountd/cache.c       |    6 +
 utils/mountd/rmtab.c       |   15 +-
 5 files changed, 381 insertions(+), 15 deletions(-)

diff --git a/support/export/hostname.c b/support/export/hostname.c
index 8a23a89..79b9a8c 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -18,6 +18,8 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <stdlib.h>
+#include <errno.h>
+
 #include <xlog.h>
 #ifdef TEST
 #define xmalloc malloc
@@ -26,6 +28,13 @@
 #include "misc.h"
 #endif
 
+#include "sockaddr.h"
+#include "exportfs.h"
+
+#ifndef HAVE_DECL_AI_ADDRCONFIG
+#define AI_ADDRCONFIG	0
+#endif
+
 #define ALIGNMENT	sizeof (char *)
 
 static int
@@ -158,6 +167,348 @@ hostent_dup (struct hostent *hp)
   return cp;
 }
 
+#ifdef HAVE_GETNAMEINFO
+static socklen_t
+sockaddr_size(const struct sockaddr *sap)
+{
+	if (sap->sa_family != AF_INET)
+		return 0;
+	return (socklen_t)sizeof(struct sockaddr_in);
+}
+#endif	/* HAVE_GETNAMEINFO */
+
+/**
+ * host_ntop - generate presentation address given a sockaddr
+ * @sap: pointer to socket address
+ * @buf: working storage
+ * @buflen: size of @buf in bytes
+ *
+ * Returns a pointer to a @buf.
+ */
+#ifdef HAVE_GETNAMEINFO
+char *
+host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	socklen_t salen = sockaddr_size(sap);
+	int error;
+
+	memset(buf, 0, buflen);
+
+	if (salen == 0) {
+		(void)strncpy(buf, "bad family", buflen - 1);
+		return buf;
+	}
+
+	error = getnameinfo(sap, salen, buf, (socklen_t)buflen,
+						NULL, 0, NI_NUMERICHOST);
+	if (error != 0) {
+		buf[0] = '\0';
+		(void)strncpy(buf, "bad address", buflen - 1);
+	}
+
+	return buf;
+}
+#else	/* !HAVE_GETNAMEINFO */
+char *
+host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)(char *)sap;
+
+	memset(buf, 0, buflen);
+
+	if (sin->sin_family != AF_INET)
+		(void)strncpy(buf, "bad family", buflen - 1);
+		return buf;
+	}
+
+	if (inet_ntop(AF_INET, &sin->sin_addr.s_addr, buf, buflen) != NULL)
+		return buf;
+
+	buf[0] = '\0';
+	(void)strncpy(buf, "bad address", buflen - 1);
+	return buf;
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
+/**
+ * host_pton - return addrinfo for a given presentation address
+ * @paddr: pointer to a '\0'-terminated ASCII string containing an
+ *		IP presentation address
+ *
+ * Returns address info structure, or NULL if an error occurs.  Caller
+ * must free the returned structure with freeaddrinfo(3).
+ */
+__attribute_malloc__
+struct addrinfo *
+host_pton(const char *paddr)
+{
+	struct addrinfo *ai = NULL;
+	struct addrinfo hint = {
+		/* don't return duplicates */
+		.ai_protocol	= (int)IPPROTO_UDP,
+		.ai_flags	= AI_NUMERICHOST,
+		.ai_family	= AF_UNSPEC,
+	};
+	struct sockaddr_in sin;
+	int error;
+
+	/*
+	 * Although getaddrinfo(3) is easier to use and supports
+	 * IPv6, it recognizes incomplete addresses like "10.4"
+	 * as valid AF_INET addresses.  It also accepts presentation
+	 * addresses that end with a blank.
+	 *
+	 * inet_pton(3) is much stricter.  Use it to be certain we
+	 * have a real AF_INET presentation address, before invoking
+	 * getaddrinfo(3) to generate the full addrinfo list.
+	 */
+	if (inet_pton(AF_INET, paddr, &sin.sin_addr) == 0)
+		return NULL;
+
+	error = getaddrinfo(paddr, NULL, &hint, &ai);
+	switch (error) {
+	case 0:
+		return ai;
+	case EAI_NONAME:
+		if (paddr == NULL)
+			xlog(D_GENERAL, "%s: passed a NULL presentation address",
+				__func__);
+		break;
+	case EAI_SYSTEM:
+		xlog(D_GENERAL, "%s: failed to convert %s: (%d) %m",
+				__func__, paddr, errno);
+		break;
+	default:
+		xlog(D_GENERAL, "%s: failed to convert %s: %s",
+				__func__, paddr, gai_strerror(error));
+		break;
+	}
+
+	return NULL;
+}
+
+/**
+ * host_addrinfo - return addrinfo for a given hostname
+ * @hostname: pointer to a '\0'-terminated ASCII string containing a hostname
+ *
+ * Returns address info structure with ai_canonname filled in, or NULL
+ * if no information is available for @hostname.  Caller must free the
+ * returned structure with freeaddrinfo(3).
+ */
+__attribute_malloc__
+struct addrinfo *
+host_addrinfo(const char *hostname)
+{
+	struct addrinfo *ai = NULL;
+	struct addrinfo hint = {
+		.ai_family	= AF_INET,
+		/* don't return duplicates */
+		.ai_protocol	= (int)IPPROTO_UDP,
+		.ai_flags	= AI_ADDRCONFIG | AI_CANONNAME,
+	};
+	int error;
+
+	error = getaddrinfo(hostname, NULL, &hint, &ai);
+	switch (error) {
+	case 0:
+		return ai;
+	case EAI_SYSTEM:
+		xlog(D_GENERAL, "%s: failed to resolve %s: (%d) %m",
+				__func__, hostname, errno);
+		break;
+	default:
+		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+				__func__, hostname, gai_strerror(error));
+		break;
+	}
+
+	return NULL;
+}
+
+/**
+ * host_canonname - return canonical hostname bound to an address
+ * @sap: pointer to socket address to look up
+ *
+ * Discover the canonical hostname associated with the given socket
+ * address.  The host's reverse mapping is verified in the process.
+ *
+ * Returns a '\0'-terminated ASCII string containing a hostname, or
+ * NULL if no hostname can be found for @sap.  Caller must free
+ * the string.
+ */
+#ifdef HAVE_GETNAMEINFO
+__attribute_malloc__
+char *
+host_canonname(const struct sockaddr *sap)
+{
+	socklen_t salen = sockaddr_size(sap);
+	char buf[NI_MAXHOST];
+	int error;
+
+	if (salen == 0) {
+		xlog(D_GENERAL, "%s: unsupported address family %d",
+				__func__, sap->sa_family);
+		return NULL;
+	}
+
+	memset(buf, 0, sizeof(buf));
+	error = getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
+							NULL, 0, NI_NAMEREQD);
+	switch (error) {
+	case 0:
+		break;
+	case EAI_SYSTEM:
+		xlog(D_GENERAL, "%s: getnameinfo(3) failed: (%d) %m",
+				__func__, errno);
+		return NULL;
+	default:
+		(void)getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
+							NULL, 0, NI_NUMERICHOST);
+		xlog(D_GENERAL, "%s: failed to resolve %s: %s",
+				__func__, buf, gai_strerror(error));
+		return NULL;
+	}
+
+	return strdup(buf);
+}
+#else	/* !HAVE_GETNAMEINFO */
+__attribute_malloc__
+char *
+host_canonname(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)(char *)sap;
+	const struct in_addr *addr = &sin->sin_addr;
+	struct hostent *hp;
+
+	if (sap->sa_family != AF_INET)
+		return NULL;
+
+	hp = gethostbyaddr(addr, (socklen_t)sizeof(addr), AF_INET);
+	if (hp == NULL)
+		return NULL;
+
+	return strdup(hp->h_name);
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
+/**
+ * host_reliable_addrinfo - return addrinfo for a given address
+ * @sap: pointer to socket address to look up
+ *
+ * Reverse and forward lookups are performed to ensure the address has
+ * proper forward and reverse mappings.
+ *
+ * Returns address info structure with ai_canonname filled in, or NULL
+ * if no information is available for @sap.  Caller must free the returned
+ * structure with freeaddrinfo(3).
+ */
+__attribute_malloc__
+struct addrinfo *
+host_reliable_addrinfo(const struct sockaddr *sap)
+{
+	struct addrinfo *ai;
+	char *hostname;
+
+	hostname = host_canonname(sap);
+	if (hostname == NULL)
+		return NULL;
+
+	ai = host_addrinfo(hostname);
+
+	free(hostname);
+	return ai;
+}
+
+/**
+ * host_numeric_addrinfo - return addrinfo without doing DNS queries
+ * @sap: pointer to socket address
+ *
+ * Returns address info structure, or NULL if an error occurred.
+ * Caller must free the returned structure with freeaddrinfo(3).
+ */
+#ifdef HAVE_GETNAMEINFO
+__attribute_malloc__
+struct addrinfo *
+host_numeric_addrinfo(const struct sockaddr *sap)
+{
+	socklen_t salen = sockaddr_size(sap);
+	char buf[INET_ADDRSTRLEN];
+	struct addrinfo *ai;
+	int error;
+
+	if (salen == 0) {
+		xlog(D_GENERAL, "%s: unsupported address family %d",
+				__func__, sap->sa_family);
+		return NULL;
+	}
+
+	memset(buf, 0, sizeof(buf));
+	error = getnameinfo(sap, salen, buf, (socklen_t)sizeof(buf),
+						NULL, 0, NI_NUMERICHOST);
+	switch (error) {
+	case 0:
+		break;
+	case EAI_SYSTEM:
+		xlog(D_GENERAL, "%s: getnameinfo(3) failed: (%d) %m",
+				__func__, errno);
+		return NULL;
+	default:
+		xlog(D_GENERAL, "%s: getnameinfo(3) failed: %s",
+				__func__, gai_strerror(error));
+		return NULL;
+	}
+
+	ai = host_pton(buf);
+
+	/*
+	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
+	 */
+	if (ai != NULL) {
+		free(ai->ai_canonname);		/* just in case */
+		ai->ai_canonname = strdup(buf);
+		if (ai->ai_canonname == NULL) {
+			freeaddrinfo(ai);
+			ai = NULL;
+		}
+	}
+
+	return ai;
+}
+#else	/* !HAVE_GETNAMEINFO */
+__attribute_malloc__
+struct addrinfo *
+host_numeric_addrinfo(const struct sockaddr *sap)
+{
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)sap;
+	const struct in_addr *addr = &sin->sin_addr;
+	char buf[INET_ADDRSTRLEN];
+	struct addrinfo *ai;
+
+	if (sap->sa_family != AF_INET)
+		return NULL;
+
+	memset(buf, 0, sizeof(buf));
+	if (inet_ntop(AF_INET, (char *)addr, buf,
+					(socklen_t)sizeof(buf)) == NULL)
+		return NULL;
+
+	ai = host_pton(buf);
+
+	/*
+	 * getaddrinfo(AI_NUMERICHOST) never fills in ai_canonname
+	 */
+	if (ai != NULL) {
+		ai->ai_canonname = strdup(buf);
+		if (ai->ai_canonname == NULL) {
+			freeaddrinfo(ai);
+			ai = NULL;
+		}
+	}
+
+	return ai;
+}
+#endif	/* !HAVE_GETNAMEINFO */
+
 static int
 is_hostname(const char *sp)
 {
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 70bdd57..97bb68e 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -146,6 +146,19 @@ void				xtab_append(nfs_export *);
 
 int				secinfo_addflavor(struct flav_info *, struct exportent *);
 
+char *				host_ntop(const struct sockaddr *sap,
+						char *buf, const size_t buflen);
+__attribute_malloc__
+struct addrinfo *		host_pton(const char *paddr);
+__attribute_malloc__
+struct addrinfo *		host_addrinfo(const char *hostname);
+__attribute_malloc__
+char *				host_canonname(const struct sockaddr *sap);
+__attribute_malloc__
+struct addrinfo *		host_reliable_addrinfo(const struct sockaddr *sap);
+__attribute_malloc__
+struct addrinfo *		host_numeric_addrinfo(const struct sockaddr *sap);
+
 int				rmtab_read(void);
 
 struct nfskey *			key_lookup(char *hname);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 331e57e..83d00a0 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -287,7 +287,7 @@ static void
 unexportfs(char *arg, int verbose)
 {
 	nfs_export	*exp;
-	struct hostent	*hp = NULL;
+	struct addrinfo *ai = NULL;
 	char		*path;
 	char		*hname = arg;
 	int		htype;
@@ -302,10 +302,9 @@ unexportfs(char *arg, int verbose)
 	}
 
 	if ((htype = client_gettype(hname)) == MCL_FQDN) {
-		if ((hp = gethostbyname(hname)) != 0) {
-			hp = hostent_dup (hp);
-			hname = (char *) hp->h_name;
-		}
+		ai = host_addrinfo(hname);
+		if (ai)
+			hname = ai->ai_canonname;
 	}
 
 	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
@@ -341,7 +340,7 @@ unexportfs(char *arg, int verbose)
 		exp->m_mayexport = 0;
 	}
 
-	if (hp) free (hp);
+	freeaddrinfo(ai);
 }
 
 static int can_test(void)
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index caef5b2..9f32227 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -863,7 +863,7 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 
 int cache_export(nfs_export *exp, char *path)
 {
-	struct sockaddr_in *sin = get_addrlist_in(exp->m_client, 0);
+	char buf[INET_ADDRSTRLEN];
 	int err;
 	FILE *f;
 
@@ -871,8 +871,10 @@ int cache_export(nfs_export *exp, char *path)
 	if (!f)
 		return -1;
 
+
 	qword_print(f, "nfsd");
-	qword_print(f, inet_ntoa(sin->sin_addr));
+	qword_print(f, 
+		host_ntop(get_addrlist(exp->m_client, 0), buf, sizeof(buf)));
 	qword_printint(f, time(0)+30*60);
 	qword_print(f, exp->m_client->m_hostname);
 	err = qword_eol(f);
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index 19b22ee..ba0fcf6 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -133,8 +133,7 @@ mountlist_del(char *hname, const char *path)
 void
 mountlist_del_all(struct sockaddr_in *sin)
 {
-	struct in_addr	addr = sin->sin_addr;
-	struct hostent	*hp;
+	char		*hostname;
 	struct rmtabent	*rep;
 	nfs_export	*exp;
 	FILE		*fp;
@@ -142,11 +141,13 @@ mountlist_del_all(struct sockaddr_in *sin)
 
 	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
 		return;
-	if (!(hp = gethostbyaddr((char *)&addr, sizeof(addr), AF_INET))) {
-		xlog(L_ERROR, "can't get hostname of %s", inet_ntoa(addr));
+	hostname = host_canonname((struct sockaddr *)sin);
+	if (hostname == NULL) {
+		char buf[INET_ADDRSTRLEN];
+		xlog(L_ERROR, "can't get hostname of %s",
+			host_ntop((struct sockaddr *)sin, buf, sizeof(buf)));
 		goto out_unlock;
 	}
-	hp = hostent_dup (hp);
 
 	if (!setrmtabent("r"))
 		goto out_free;
@@ -155,7 +156,7 @@ mountlist_del_all(struct sockaddr_in *sin)
 		goto out_close;
 
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
-		if (strcmp(rep->r_client, hp->h_name) == 0 &&
+		if (strcmp(rep->r_client, hostname) == 0 &&
 		    (exp = auth_authenticate("umountall", sin, rep->r_path)))
 			continue;
 		fputrmtabent(fp, rep, NULL);
@@ -168,7 +169,7 @@ mountlist_del_all(struct sockaddr_in *sin)
 out_close:
 	endrmtabent();	/* close & unlink */
 out_free:
-	free (hp);
+	free(hostname);
 out_unlock:
 	xfunlock(lockid);
 }

