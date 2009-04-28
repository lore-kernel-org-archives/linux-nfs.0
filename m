From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] mount: remove legacy version of nfs_name_to_address()
Date: Tue, 28 Apr 2009 17:37:05 -0400
Message-ID: <20090428213705.16098.86151.stgit@ingres.1015granger.net>
References: <20090428213453.16098.33168.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:61211 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755399AbZD1Vie (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Apr 2009 17:38:34 -0400
In-Reply-To: <20090428213453.16098.33168.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we have two separate copies of nfs_name_to_address() since
some older glibc's don't define AI_ADDRCONFIG.  This means extra
work to build- and run-test both functions when code is changed in
this area.

It is also the case that gethostbyname(3) is deprecated, and should
not be used in new code.

Remove the legacy code in favor of always using getaddrinfo(3).

We can also get rid of nfs_name_to_address()'s @family argument as
well.

Note also this addresses a bug in nfsumount.c -- it was calling
nfs_name_to_address() with AF_UNSPEC unconditionally, even if the
legacy version of nfs_name_to_address(), which doesn't support
AF_UNSPEC, was in use.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c   |   88 ++++++++++++-----------------------------------
 utils/mount/network.h   |    3 +-
 utils/mount/nfsumount.c |    2 +
 utils/mount/stropts.c   |   16 ++-------
 4 files changed, 28 insertions(+), 81 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 72f4b84..d93e98d 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -185,39 +185,32 @@ static void nfs_set_port(struct sockaddr *sap, const unsigned short port)
 	}
 }
 
-#ifdef HAVE_DECL_AI_ADDRCONFIG
-/**
- * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
- * @hostname: pointer to C string containing DNS hostname to resolve
- * @af_hint: hint to restrict resolution to one address family
- * @sap: pointer to buffer to fill with socket address
- * @len: IN: size of buffer to fill; OUT: size of socket address
- *
- * Returns 1 and places a socket address at @sap if successful;
- * otherwise zero.
- */
-int nfs_name_to_address(const char *hostname,
-			const sa_family_t af_hint,
-			struct sockaddr *sap, socklen_t *salen)
+static int nfs_lookup(const char *hostname, const sa_family_t family,
+		      struct sockaddr *sap, socklen_t *salen)
 {
 	struct addrinfo *gai_results;
 	struct addrinfo gai_hint = {
-		.ai_family	= af_hint,
+#ifdef HAVE_DECL_AI_ADDRCONFIG
 		.ai_flags	= AI_ADDRCONFIG,
+#endif	/* HAVE_DECL_AI_ADDRCONFIG */
+		.ai_family	= family,
 	};
 	socklen_t len = *salen;
 	int error, ret = 0;
 
-	if (af_hint == AF_INET6)
-		gai_hint.ai_flags |= AI_V4MAPPED|AI_ALL;
-
 	*salen = 0;
 
 	error = getaddrinfo(hostname, NULL, &gai_hint, &gai_results);
-	if (error) {
+	switch (error) {
+	case 0:
+		break;
+	case EAI_SYSTEM:
 		nfs_error(_("%s: DNS resolution failed for %s: %s"),
-			progname, hostname, (error == EAI_SYSTEM ?
-				strerror(errno) : gai_strerror(error)));
+			progname, hostname, strerror(errno));
+		return ret;
+	default:
+		nfs_error(_("%s: DNS resolution failed for %s: %s"),
+			progname, hostname, gai_strerror(error));
 		return ret;
 	}
 
@@ -240,61 +233,25 @@ int nfs_name_to_address(const char *hostname,
 	freeaddrinfo(gai_results);
 	return ret;
 }
-#else	/* HAVE_DECL_AI_ADDRCONFIG */
+
 /**
- * nfs_name_to_address - resolve hostname to an IPv4 socket address
+ * nfs_name_to_address - resolve hostname to an IPv4 or IPv6 socket address
  * @hostname: pointer to C string containing DNS hostname to resolve
- * @af_hint: hint to restrict resolution to one address family
  * @sap: pointer to buffer to fill with socket address
  * @len: IN: size of buffer to fill; OUT: size of socket address
  *
  * Returns 1 and places a socket address at @sap if successful;
  * otherwise zero.
- *
- * Some older getaddrinfo(3) implementations don't support
- * AI_ADDRCONFIG or AI_V4MAPPED properly.  For those cases, a DNS
- * resolver based on the traditional gethostbyname(3) is provided.
  */
 int nfs_name_to_address(const char *hostname,
-			const sa_family_t af_hint,
 			struct sockaddr *sap, socklen_t *salen)
 {
-	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	socklen_t len = *salen;
-	struct hostent *hp;
-
-	*salen = 0;
-
-	if (af_hint != AF_INET) {
-		nfs_error(_("%s: address family not supported by DNS resolver\n"),
-				progname, hostname);
-		return 0;
-	}
-
-	sin->sin_family = AF_INET;
-	if (inet_aton(hostname, &sin->sin_addr)) {
-		*salen = sizeof(*sin);
-		return 1;
-	}
-
-	hp = gethostbyname(hostname);
-	if (hp == NULL) {
-		nfs_error(_("%s: DNS resolution failed for %s: %s"),
-				progname, hostname, hstrerror(h_errno));
-		return 0;
-	}
-
-	if (hp->h_length > len) {
-		nfs_error(_("%s: DNS resolution results too long for buffer\n"),
-				progname);
-		return 0;
-	}
-
-	memcpy(&sin->sin_addr, hp->h_addr, hp->h_length);
-	*salen = sizeof(struct sockaddr_in);
-	return 1;
+#ifdef IPV6_SUPPORTED
+	return nfs_lookup(hostname, AF_UNSPEC, sap, salen);
+#else	/* !IPV6_SUPPORTED */
+	return nfs_lookup(hostname, AF_INET, sap, salen);
+#endif	/* !IPV6_SUPPORTED */
 }
-#endif	/* HAVE_DECL_AI_ADDRCONFIG */
 
 /**
  * nfs_gethostbyname - resolve a hostname to an IPv4 address
@@ -307,8 +264,7 @@ int nfs_gethostbyname(const char *hostname, struct sockaddr_in *sin)
 {
 	socklen_t len = sizeof(*sin);
 
-	return nfs_name_to_address(hostname, AF_INET,
-					(struct sockaddr *)sin, &len);
+	return nfs_lookup(hostname, AF_INET, (struct sockaddr *)sin, &len);
 }
 
 /**
diff --git a/utils/mount/network.h b/utils/mount/network.h
index 0dd90f8..b3f9bd2 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -44,8 +44,7 @@ int nfs_probe_bothports(const struct sockaddr *, const socklen_t,
 			struct pmap *, const struct sockaddr *,
 			const socklen_t, struct pmap *);
 int nfs_gethostbyname(const char *, struct sockaddr_in *);
-int nfs_name_to_address(const char *, const sa_family_t,
-		struct sockaddr *, socklen_t *);
+int nfs_name_to_address(const char *, struct sockaddr *, socklen_t *);
 int nfs_string_to_sockaddr(const char *, const size_t,
 			   struct sockaddr *, socklen_t *);
 int nfs_present_sockaddr(const struct sockaddr *,
diff --git a/utils/mount/nfsumount.c b/utils/mount/nfsumount.c
index 78ebd4a..4b2e530 100644
--- a/utils/mount/nfsumount.c
+++ b/utils/mount/nfsumount.c
@@ -182,7 +182,7 @@ static int nfs_umount_do_umnt(struct mount_options *options,
 		return EX_FAIL;
 	}
 
-	if (nfs_name_to_address(*hostname, AF_UNSPEC, sap, &salen)) {
+	if (nfs_name_to_address(*hostname, sap, &salen)) {
 		if (nfs_advise_umount(sap, salen, &mnt_pmap, dirname) != 0)
 			return EX_SUCCESS;
 		else
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c369136..ec95b78 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -87,8 +87,6 @@ struct nfsmount_info {
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
-
-	sa_family_t		family;		/* supported address family */
 };
 
 /*
@@ -198,8 +196,7 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
  * Resolve the 'mounthost=' hostname and append a new option using
  * the resulting address.
  */
-static int nfs_fix_mounthost_option(const sa_family_t family,
-				    struct mount_options *options)
+static int nfs_fix_mounthost_option(struct mount_options *options)
 {
 	struct sockaddr_storage dummy;
 	struct sockaddr *sap = (struct sockaddr *)&dummy;
@@ -210,7 +207,7 @@ static int nfs_fix_mounthost_option(const sa_family_t family,
 	if (!mounthost)
 		return 1;
 
-	if (!nfs_name_to_address(mounthost, family, sap, &salen)) {
+	if (!nfs_name_to_address(mounthost, sap, &salen)) {
 		nfs_error(_("%s: unable to determine mount server's address"),
 				progname);
 		return 0;
@@ -270,14 +267,14 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
-	if (!nfs_name_to_address(mi->hostname, mi->family, sap, &salen))
+	if (!nfs_name_to_address(mi->hostname, sap, &salen))
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
 		if (!nfs_append_clientaddr_option(sap, salen, mi->options))
 			return 0;
 	} else {
-		if (!nfs_fix_mounthost_option(mi->family, mi->options))
+		if (!nfs_fix_mounthost_option(mi->options))
 			return 0;
 		if (!mi->fake && !nfs_verify_lock_option(mi->options))
 			return 0;
@@ -785,11 +782,6 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		.flags		= flags,
 		.fake		= fake,
 		.child		= child,
-#ifdef IPV6_SUPPORTED
-		.family		= AF_UNSPEC,	/* either IPv4 or v6 */
-#else
-		.family		= AF_INET,	/* only IPv4 */
-#endif
 	};
 	int retval = EX_FAIL;
 

