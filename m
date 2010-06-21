From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/7] mountd: Replace "struct hostent" with "struct addrinfo"
Date: Mon, 21 Jun 2010 12:54:38 -0400
Message-ID: <20100621165438.4771.3082.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757972Ab0FUQym (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:54:42 -0400
Received: by mail-iw0-f174.google.com with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:54:41 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

struct hostent can store either IPv4 or IPv6 addresses, but it can't
store both address families concurrently for the same host.  Neither
can hostent deal with parts of socket addresses that are outside of
the sin{,6}_addr field.

Replace the use of "struct hostent" everywhere in libexport.a, mountd,
and exportfs with "struct addrinfo".  This is a large change, but
there are so many strong dependencies on struct hostent that this
can't easily be broken into smaller pieces.

One benefit of this change is that hostent_dup() is no longer
required, since the results of getaddrinfo(3) are already dynamically
allocated.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/export/client.c    |  243 ++++++++++++++++++++++++--------------------
 support/export/export.c    |   46 ++++++--
 support/export/rmtab.c     |   13 +-
 support/include/exportfs.h |   17 ++-
 utils/exportfs/exportfs.c  |   25 ++---
 utils/mountd/auth.c        |   48 +++++----
 utils/mountd/cache.c       |   66 +++++++-----
 utils/mountd/mountd.c      |   11 +-
 8 files changed, 257 insertions(+), 212 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index 21ad272..9a0fc9d 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -35,22 +35,18 @@ nfs_client	*clientlist[MCL_MAXTYPES] = { NULL, };
 
 
 static void
-init_addrlist(nfs_client *clp, const struct hostent *hp)
+init_addrlist(nfs_client *clp, const struct addrinfo *ai)
 {
-	struct sockaddr_in sin = {
-		.sin_family		= AF_INET,
-	};
-	char **ap;
 	int i;
 
-	if (hp == NULL)
+	if (ai == NULL)
 		return;
 
-	ap = hp->h_addr_list;
-	for (i = 0; *ap != NULL && i < NFSCLNT_ADDRMAX; i++, ap++) {
-		sin.sin_addr = *(struct in_addr *)*ap;
-		set_addrlist_in(clp, i, &sin);
+	for (i = 0; (ai != NULL) && (i < NFSCLNT_ADDRMAX); i++) {
+		set_addrlist(clp, i, ai->ai_addr);
+		ai = ai->ai_next;
 	}
+
 	clp->m_naddr = i;
 }
 
@@ -109,7 +105,7 @@ init_subnetwork(nfs_client *clp)
 }
 
 static int
-client_init(nfs_client *clp, const char *hname, const struct hostent *hp)
+client_init(nfs_client *clp, const char *hname, const struct addrinfo *ai)
 {
 	clp->m_hostname = strdup(hname);
 	if (clp->m_hostname == NULL)
@@ -122,7 +118,7 @@ client_init(nfs_client *clp, const char *hname, const struct hostent *hp)
 	if (clp->m_type == MCL_SUBNETWORK)
 		return init_subnetwork(clp);
 
-	init_addrlist(clp, hp);
+	init_addrlist(clp, ai);
 	return 1;
 }
 
@@ -147,42 +143,21 @@ client_lookup(char *hname, int canonical)
 {
 	nfs_client	*clp = NULL;
 	int		htype;
-	struct hostent	*hp = NULL;
+	struct addrinfo	*ai = NULL;
 
 	htype = client_gettype(hname);
 
 	if (htype == MCL_FQDN && !canonical) {
-		struct hostent *hp2;
-		hp = gethostbyname(hname);
-		if (hp == NULL || hp->h_addrtype != AF_INET) {
-			xlog(L_ERROR, "%s has non-inet addr", hname);
-			return NULL;
+		ai = host_addrinfo(hname);
+		if (!ai) {
+			xlog(L_ERROR, "Failed to resolve %s", hname);
+			goto out;
 		}
-		/* make sure we have canonical name */
-		hp2 = hostent_dup(hp);
-		hp = gethostbyaddr(hp2->h_addr, hp2->h_length,
-				   hp2->h_addrtype);
-		if (hp) {
-			hp = hostent_dup(hp);
-			/* but now we might not have all addresses... */
-			if (hp2->h_addr_list[1]) {
-				struct hostent *hp3 =
-					gethostbyname(hp->h_name);
-				if (hp3) {
-					free(hp);
-					hp = hostent_dup(hp3);
-				}
-			}
-			free(hp2);
-		} else
-			hp = hp2;
-
-		hname = (char *) hp->h_name;
+		hname = ai->ai_canonname;
 
-		for (clp = clientlist[htype]; clp; clp = clp->m_next) {
-			if (client_check(clp, hp))
+		for (clp = clientlist[htype]; clp; clp = clp->m_next)
+			if (client_check(clp, ai))
 				break;
-		}
 	} else {
 		for (clp = clientlist[htype]; clp; clp = clp->m_next) {
 			if (strcasecmp(hname, clp->m_hostname)==0)
@@ -204,17 +179,24 @@ client_lookup(char *hname, int canonical)
 	}
 
 	if (htype == MCL_FQDN && clp->m_naddr == 0)
-		init_addrlist(clp, hp);
+		init_addrlist(clp, ai);
 
 out:
-	if (hp)
-		free (hp);
-
+	freeaddrinfo(ai);
 	return clp;
 }
 
+/**
+ * client_dup - create a copy of an nfs_client
+ * @clp: pointer to nfs_client to copy
+ * @ai: pointer to addrinfo used to initialize the new client's addrlist
+ *
+ * Returns a dynamically allocated nfs_client if successful, or
+ * NULL if some problem occurs.  Caller must free the returned
+ * nfs_client with free(3).
+ */
 nfs_client *
-client_dup(nfs_client *clp, struct hostent *hp)
+client_dup(const nfs_client *clp, const struct addrinfo *ai)
 {
 	nfs_client		*new;
 
@@ -225,7 +207,7 @@ client_dup(nfs_client *clp, struct hostent *hp)
 	new->m_type = MCL_FQDN;
 	new->m_hostname = NULL;
 
-	if (!client_init(new, hp->h_name, hp)) {
+	if (!client_init(new, ai->ai_canonname, ai)) {
 		client_free(new);
 		return NULL;
 	}
@@ -256,22 +238,29 @@ client_freeall(void)
 	}
 }
 
-struct hostent *
-client_resolve(struct in_addr addr)
+/**
+ * client_resolve - look up an IP address
+ * @sap: pointer to socket address to resolve
+ *
+ * Returns an addrinfo structure, or NULL if some problem occurred.
+ * Caller must free the result with freeaddrinfo(3).
+ */
+struct addrinfo *
+client_resolve(const struct sockaddr *sap)
 {
-	struct hostent *he = NULL;
+	struct addrinfo *ai = NULL;
 
 	if (clientlist[MCL_WILDCARD] || clientlist[MCL_NETGROUP])
-		he = get_reliable_hostbyaddr((const char*)&addr, sizeof(addr), AF_INET);
-	if (he == NULL)
-		he = get_hostent((const char*)&addr, sizeof(addr), AF_INET);
+		ai = host_reliable_addrinfo(sap);
+	if (ai == NULL)
+		ai = host_numeric_addrinfo(sap);
 
-	return he;
+	return ai;
 }
 
 /**
  * client_compose - Make a list of cached hostnames that match an IP address
- * @he: pointer to hostent containing IP address information to match
+ * @ai: pointer to addrinfo containing IP address information to match
  *
  * Gather all known client hostnames that match the IP address, and sort
  * the result into a comma-separated list.
@@ -282,7 +271,7 @@ client_resolve(struct in_addr addr)
  * returned string with free(3).
  */
 char *
-client_compose(struct hostent *he)
+client_compose(const struct addrinfo *ai)
 {
 	char *name = NULL;
 	int i;
@@ -290,7 +279,7 @@ client_compose(struct hostent *he)
 	for (i = 0 ; i < MCL_MAXTYPES; i++) {
 		nfs_client	*clp;
 		for (clp = clientlist[i]; clp ; clp = clp->m_next) {
-			if (!client_check(clp, he))
+			if (!client_check(clp, ai))
 				continue;
 			name = add_name(name, clp->m_hostname);
 		}
@@ -371,52 +360,83 @@ add_name(char *old, const char *add)
 	return new;
 }
 
+static _Bool
+addrs_match4(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *si1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *si2 = (const struct sockaddr_in *)sa2;
+
+	return si1->sin_addr.s_addr == si2->sin_addr.s_addr;
+}
+
+static _Bool
+addrs_match(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	if (sa1->sa_family == sa2->sa_family)
+		switch (sa1->sa_family) {
+		case AF_INET:
+			return addrs_match4(sa1, sa2);
+		}
+
+	return false;
+}
+
 /*
- * Check each address listed in @hp against each address
+ * Check each address listed in @ai against each address
  * stored in @clp.  Return 1 if a match is found, otherwise
  * zero.
  */
 static int
-check_fqdn(const nfs_client *clp, const struct hostent *hp)
+check_fqdn(const nfs_client *clp, const struct addrinfo *ai)
 {
-	const struct sockaddr_in *sin;
-	struct in_addr addr;
-	char **ap;
 	int i;
 
-	for (ap = hp->h_addr_list; *ap; ap++) {
-		addr = *(struct in_addr *)*ap;
-
-		for (i = 0; i < clp->m_naddr; i++) {
-			sin = get_addrlist_in(clp, i);
-			if (sin->sin_addr.s_addr == addr.s_addr)
+	for (; ai; ai = ai->ai_next)
+		for (i = 0; i < clp->m_naddr; i++)
+			if (addrs_match(ai->ai_addr, get_addrlist(clp, i)))
 				return 1;
-		}
+
+	return 0;
+}
+
+static _Bool
+mask_match(const uint32_t a, const uint32_t b, const uint32_t m)
+{
+	return ((a ^ b) & m) == 0;
+}
+
+static int
+check_subnet_v4(const struct sockaddr_in *address,
+		const struct sockaddr_in *mask, const struct addrinfo *ai)
+{
+	for (; ai; ai = ai->ai_next) {
+		struct sockaddr_in *sin = (struct sockaddr_in *)ai->ai_addr;
+
+		if (sin->sin_family != AF_INET)
+			continue;
+
+		if (mask_match(address->sin_addr.s_addr,
+				sin->sin_addr.s_addr,
+				mask->sin_addr.s_addr))
+			return 1;
 	}
 	return 0;
 }
 
 /*
- * Check each address listed in @hp against the subnetwork or
+ * Check each address listed in @ai against the subnetwork or
  * host address stored in @clp.  Return 1 if an address in @hp
  * matches the host address stored in @clp, otherwise zero.
  */
 static int
-check_subnetwork(const nfs_client *clp, const struct hostent *hp)
+check_subnetwork(const nfs_client *clp, const struct addrinfo *ai)
 {
-	const struct sockaddr_in *address, *mask;
-	struct in_addr addr;
-	char **ap;
-
-	for (ap = hp->h_addr_list; *ap; ap++) {
-		address = get_addrlist_in(clp, 0);
-		mask = get_addrlist_in(clp, 1);
-		addr = *(struct in_addr *)*ap;
-
-		if (!((address->sin_addr.s_addr ^ addr.s_addr) &
-		      mask->sin_addr.s_addr))
-			return 1;
+	switch (get_addrlist(clp, 0)->sa_family) {
+	case AF_INET:
+		return check_subnet_v4(get_addrlist_in(clp, 0),
+				get_addrlist_in(clp, 1), ai);
 	}
+
 	return 0;
 }
 
@@ -426,10 +446,11 @@ check_subnetwork(const nfs_client *clp, const struct hostent *hp)
  * zero.
  */
 static int
-check_wildcard(const nfs_client *clp, const struct hostent *hp)
+check_wildcard(const nfs_client *clp, const struct addrinfo *ai)
 {
 	char *cname = clp->m_hostname;
-	char *hname = hp->h_name;
+	char *hname = ai->ai_canonname;
+	struct hostent *hp;
 	char **ap;
 
 	if (wildmat(hname, cname))
@@ -437,27 +458,30 @@ check_wildcard(const nfs_client *clp, const struct hostent *hp)
 
 	/* See if hname aliases listed in /etc/hosts or nis[+]
 	 * match the requested wildcard */
-	for (ap = hp->h_aliases; *ap; ap++) {
-		if (wildmat(*ap, cname))
-			return 1;
+	hp = gethostbyname(hname);
+	if (hp != NULL) {
+		for (ap = hp->h_aliases; *ap; ap++)
+			if (wildmat(*ap, cname))
+				return 1;
 	}
 
 	return 0;
 }
 
 /*
- * Check if @hp's hostname or aliases fall in a given netgroup.
- * Return 1 if @hp represents a host in the netgroup, otherwise zero.
+ * Check if @ai's hostname or aliases fall in a given netgroup.
+ * Return 1 if @ai represents a host in the netgroup, otherwise
+ * zero.
  */
 #ifdef HAVE_INNETGR
 static int
-check_netgroup(const nfs_client *clp, const struct hostent *hp)
+check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 {
 	const char *netgroup = clp->m_hostname + 1;
-	const char *hname = hp->h_name;
-	struct hostent *nhp = NULL;
-	struct sockaddr_in addr;
-	int match, i;
+	const char *hname = ai->ai_canonname;
+	struct addrinfo *tmp = NULL;
+	struct hostent *hp;
+	int i, match;
 	char *dot;
 
 	/* First, try to match the hostname without
@@ -467,16 +491,17 @@ check_netgroup(const nfs_client *clp, const struct hostent *hp)
 
 	/* See if hname aliases listed in /etc/hosts or nis[+]
 	 * match the requested netgroup */
-	for (i = 0; hp->h_aliases[i]; i++) {
-		if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL))
-			return 1;
+	hp = gethostbyname(hname);
+	if (hp != NULL) {
+		for (i = 0; hp->h_aliases[i]; i++)
+			if (innetgr(netgroup, hp->h_aliases[i], NULL, NULL))
+				return 1;
 	}
 
 	/* If hname is ip address convert to FQDN */
-	if (inet_aton(hname, &addr.sin_addr) &&
-	   (nhp = gethostbyaddr((const char *)&(addr.sin_addr),
-	    sizeof(addr.sin_addr), AF_INET))) {
-		hname = nhp->h_name;
+	tmp = host_pton(hname);
+	if (tmp != NULL) {
+		freeaddrinfo(tmp);
 		if (innetgr(netgroup, hname, NULL, NULL))
 			return 1;
 	}
@@ -495,7 +520,7 @@ check_netgroup(const nfs_client *clp, const struct hostent *hp)
 #else	/* !HAVE_INNETGR */
 static int
 check_netgroup(__attribute__((unused)) const nfs_client *clp,
-		__attribute__((unused)) const struct hostent *hp)
+		__attribute__((unused)) const struct addrinfo *ai)
 {
 	return 0;
 }
@@ -504,23 +529,23 @@ check_netgroup(__attribute__((unused)) const nfs_client *clp,
 /**
  * client_check - check if IP address information matches a cached nfs_client
  * @clp: pointer to a cached nfs_client record
- * @hp: pointer to hostent containing host IP information
+ * @ai: pointer to addrinfo to compare it with
  *
  * Returns 1 if the address information matches the cached nfs_client,
  * otherwise zero.
  */
 int
-client_check(nfs_client *clp, struct hostent *hp)
+client_check(const nfs_client *clp, const struct addrinfo *ai)
 {
 	switch (clp->m_type) {
 	case MCL_FQDN:
-		return check_fqdn(clp, hp);
+		return check_fqdn(clp, ai);
 	case MCL_SUBNETWORK:
-		return check_subnetwork(clp, hp);
+		return check_subnetwork(clp, ai);
 	case MCL_WILDCARD:
-		return check_wildcard(clp, hp);
+		return check_wildcard(clp, ai);
 	case MCL_NETGROUP:
-		return check_netgroup(clp, hp);
+		return check_netgroup(clp, ai);
 	case MCL_ANONYMOUS:
 		return 1;
 	case MCL_GSS:
diff --git a/support/export/export.c b/support/export/export.c
index 3e4da69..919a244 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -24,9 +24,11 @@ static int export_hash(char *);
 
 static void	export_init(nfs_export *exp, nfs_client *clp,
 					struct exportent *nep);
-static int	export_check(nfs_export *, struct hostent *, char *);
+static int	export_check(const nfs_export *exp, const struct addrinfo *ai,
+				const char *path);
 static nfs_export *
-		export_allowed_internal(struct hostent *hp, char *path);
+		export_allowed_internal(const struct addrinfo *ai,
+				const char *path);
 
 static void
 export_free(nfs_export *exp)
@@ -117,8 +119,8 @@ export_init(nfs_export *exp, nfs_client *clp, struct exportent *nep)
  * original hostname from /etc/exports, while the in-core client struct
  * gets the newly found FQDN.
  */
-nfs_export *
-export_dup(nfs_export *exp, struct hostent *hp)
+static nfs_export *
+export_dup(nfs_export *exp, const struct addrinfo *ai)
 {
 	nfs_export		*new;
 	nfs_client		*clp;
@@ -128,7 +130,7 @@ export_dup(nfs_export *exp, struct hostent *hp)
 	dupexportent(&new->m_export, &exp->m_export);
 	if (exp->m_export.e_hostname)
 		new->m_export.e_hostname = xstrdup(exp->m_export.e_hostname);
-	clp = client_dup(exp->m_client, hp);
+	clp = client_dup(exp->m_client, ai);
 	if (clp == NULL) {
 		export_free(new);
 		return NULL;
@@ -176,19 +178,27 @@ export_add(nfs_export *exp)
 	}
 }
 
+/**
+ * export_find - find or create a suitable nfs_export for @ai and @path
+ * @ai: pointer to addrinfo for client
+ * @path: '\0'-terminated ASCII string containing export path
+ *
+ * Returns a pointer to nfs_export data matching @ai and @path,
+ * or NULL if an error occurs.
+ */
 nfs_export *
-export_find(struct hostent *hp, char *path)
+export_find(const struct addrinfo *ai, const char *path)
 {
 	nfs_export	*exp;
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
-			if (!export_check(exp, hp, path))
+			if (!export_check(exp, ai, path))
 				continue;
 			if (exp->m_client->m_type == MCL_FQDN)
 				return exp;
-			return export_dup(exp, hp);
+			return export_dup(exp, ai);
 		}
 	}
 
@@ -196,7 +206,7 @@ export_find(struct hostent *hp, char *path)
 }
 
 static nfs_export *
-export_allowed_internal (struct hostent *hp, char *path)
+export_allowed_internal(const struct addrinfo *ai, const char *path)
 {
 	nfs_export	*exp;
 	int		i;
@@ -204,7 +214,7 @@ export_allowed_internal (struct hostent *hp, char *path)
 	for (i = 0; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!exp->m_mayexport ||
-			    !export_check(exp, hp, path))
+			    !export_check(exp, ai, path))
 				continue;
 			return exp;
 		}
@@ -213,8 +223,16 @@ export_allowed_internal (struct hostent *hp, char *path)
 	return NULL;
 }
 
+/**
+ * export_allowed - determine if this export is allowed
+ * @ai: pointer to addrinfo for client
+ * @path: '\0'-terminated ASCII string containing export path
+ *
+ * Returns a pointer to nfs_export data matching @ai and @path,
+ * or NULL if the export is not allowed.
+ */
 nfs_export *
-export_allowed(struct hostent *hp, char *path)
+export_allowed(const struct addrinfo *ai, const char *path)
 {
 	nfs_export		*exp;
 	char			epath[MAXPATHLEN+1];
@@ -227,7 +245,7 @@ export_allowed(struct hostent *hp, char *path)
 
 	/* Try the longest matching exported pathname. */
 	while (1) {
-		exp = export_allowed_internal (hp, epath);
+		exp = export_allowed_internal(ai, epath);
 		if (exp)
 			return exp;
 		/* We have to treat the root, "/", specially. */
@@ -268,12 +286,12 @@ export_lookup(char *hname, char *path, int canonical)
 }
 
 static int
-export_check(nfs_export *exp, struct hostent *hp, char *path)
+export_check(const nfs_export *exp, const struct addrinfo *ai, const char *path)
 {
 	if (strcmp(path, exp->m_export.e_path))
 		return 0;
 
-	return client_check(exp->m_client, hp);
+	return client_check(exp->m_client, ai);
 }
 
 /**
diff --git a/support/export/rmtab.c b/support/export/rmtab.c
index 0ec495c..31c0f50 100644
--- a/support/export/rmtab.c
+++ b/support/export/rmtab.c
@@ -28,17 +28,14 @@ static void
 rmtab_read_wildcard(struct rmtabent *rep)
 {
 	nfs_export *exp, *exp2;
-	struct hostent *hp;
+	struct addrinfo *ai;
 
-	hp = gethostbyname(rep->r_client);
-	if (hp == NULL)
-		return;
-	hp = hostent_dup(hp);
-	if (hp == NULL)
+	ai = host_addrinfo(rep->r_client);
+	if (ai == NULL)
 		return;
 
-	exp = export_allowed(hp, rep->r_path);
-	free(hp);
+	exp = export_allowed(ai, rep->r_path);
+	freeaddrinfo(ai);
 	if (exp == NULL)
 		return;
 
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 97bb68e..0da8566 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -116,13 +116,15 @@ extern exp_hash_table exportlist[MCL_MAXTYPES];
 extern nfs_client *		clientlist[MCL_MAXTYPES];
 
 nfs_client *			client_lookup(char *hname, int canonical);
-nfs_client *			client_dup(nfs_client *, struct hostent *);
+nfs_client *			client_dup(const nfs_client *clp,
+						const struct addrinfo *ai);
 int				client_gettype(char *hname);
-int				client_check(nfs_client *, struct hostent *);
+int				client_check(const nfs_client *clp,
+						const struct addrinfo *ai);
 void				client_release(nfs_client *);
 void				client_freeall(void);
-char *				client_compose(struct hostent *he);
-struct hostent *		client_resolve(struct in_addr addr);
+char *				client_compose(const struct addrinfo *ai);
+struct addrinfo *		client_resolve(const struct sockaddr *sap);
 int 				client_member(const char *client,
 						const char *name);
 
@@ -130,10 +132,11 @@ int				export_read(char *fname);
 void			export_add(nfs_export *);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
-nfs_export *			export_find(struct hostent *, char *path);
-nfs_export *			export_allowed(struct hostent *, char *path);
+nfs_export *			export_find(const struct addrinfo *ai,
+						const char *path);
+nfs_export *			export_allowed(const struct addrinfo *ai,
+						const char *path);
 nfs_export *			export_create(struct exportent *, int canonical);
-nfs_export *			export_dup(nfs_export *, struct hostent *);
 void				export_freeall(void);
 int				export_export(nfs_export *);
 int				export_unexport(nfs_export *);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 50f1e34..0070b54 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -232,7 +232,7 @@ exportfs(char *arg, char *options, int verbose)
 {
 	struct exportent *eep;
 	nfs_export	*exp;
-	struct hostent	*hp = NULL;
+	struct addrinfo	*ai = NULL;
 	char		*path;
 	char		*hname = arg;
 	int		htype;
@@ -245,21 +245,14 @@ exportfs(char *arg, char *options, int verbose)
 		return;
 	}
 
-	if ((htype = client_gettype(hname)) == MCL_FQDN &&
-	    (hp = gethostbyname(hname)) != NULL) {
-		struct hostent *hp2 = hostent_dup (hp);
-		hp = gethostbyaddr(hp2->h_addr, hp2->h_length,
-				   hp2->h_addrtype);
-		if (hp) {
-			free(hp2);
-			hp = hostent_dup(hp);
-		} else
-			hp = hp2;
-		exp = export_find(hp, path);
-		hname = hp->h_name;
-	} else {
+	if ((htype = client_gettype(hname)) == MCL_FQDN) {
+		ai = host_addrinfo(hname);
+		if (ai != NULL) {
+			exp = export_find(ai, path);
+			hname = ai->ai_canonname;
+		}
+	} else
 		exp = export_lookup(hname, path, 0);
-	}
 
 	if (!exp) {
 		if (!(eep = mkexportent(hname, path, options)) ||
@@ -278,7 +271,7 @@ exportfs(char *arg, char *options, int verbose)
 	validate_export(exp);
 
 out:
-	if (hp) free (hp);
+	freeaddrinfo(ai);
 }
 
 static void
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 4b94b98..04487e5 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -110,13 +110,15 @@ auth_reload()
 	return counter;
 }
 
-static char *get_client_hostname(struct sockaddr_in *caller, struct hostent *hp, enum auth_error *error)
+static char *
+get_client_hostname(struct sockaddr_in *caller, struct addrinfo *ai,
+		enum auth_error *error)
 {
 	char *n;
 
 	if (use_ipaddr)
 		return strdup(inet_ntoa(caller->sin_addr));
-	n = client_compose(hp);
+	n = client_compose(ai);
 	*error = unknown_host;
 	if (!n)
 		return NULL;
@@ -128,8 +130,8 @@ static char *get_client_hostname(struct sockaddr_in *caller, struct hostent *hp,
 
 /* return static nfs_export with details filled in */
 static nfs_export *
-auth_authenticate_newcache(char *what, struct sockaddr_in *caller,
-			   char *path, struct hostent *hp,
+auth_authenticate_newcache(struct sockaddr_in *caller,
+			   char *path, struct addrinfo *ai,
 			   enum auth_error *error)
 {
 	nfs_export *exp;
@@ -137,7 +139,7 @@ auth_authenticate_newcache(char *what, struct sockaddr_in *caller,
 
 	free(my_client.m_hostname);
 
-	my_client.m_hostname = get_client_hostname(caller, hp, error);
+	my_client.m_hostname = get_client_hostname(caller, ai, error);
 	if (my_client.m_hostname == NULL)
 		return NULL;
 
@@ -152,7 +154,7 @@ auth_authenticate_newcache(char *what, struct sockaddr_in *caller,
 				continue;
 			if (!use_ipaddr && !client_member(my_client.m_hostname, exp->m_client->m_hostname))
 				continue;
-			if (use_ipaddr && !client_check(exp->m_client, hp))
+			if (use_ipaddr && !client_check(exp->m_client, ai))
 				continue;
 			break;
 		}
@@ -166,18 +168,19 @@ auth_authenticate_newcache(char *what, struct sockaddr_in *caller,
 }
 
 static nfs_export *
-auth_authenticate_internal(char *what, struct sockaddr_in *caller,
-			   char *path, struct hostent *hp,
+auth_authenticate_internal(struct sockaddr_in *caller,
+			   char *path, struct addrinfo *ai,
 			   enum auth_error *error)
 {
 	nfs_export *exp;
 
 	if (new_cache) {
-		exp = auth_authenticate_newcache(what, caller, path, hp, error);
+		exp = auth_authenticate_newcache(caller, path, ai, error);
 		if (!exp)
 			return NULL;
 	} else {
-		if (!(exp = export_find(hp, path))) {
+		exp = export_find(ai, path);
+		if (exp == NULL) {
 			*error = no_entry;
 			return NULL;
 		}
@@ -202,7 +205,7 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 	nfs_export	*exp = NULL;
 	char		epath[MAXPATHLEN+1];
 	char		*p = NULL;
-	struct hostent	*hp = NULL;
+	struct addrinfo *ai = NULL;
 	struct in_addr	addr = caller->sin_addr;
 	enum auth_error	error = bad_path;
 
@@ -216,14 +219,14 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 	epath[sizeof (epath) - 1] = '\0';
 	auth_fixpath(epath); /* strip duplicate '/' etc */
 
-	hp = client_resolve(caller->sin_addr);
-	if (!hp)
+	ai = client_resolve((struct sockaddr *)caller);
+	if (ai == NULL)
 		return exp;
 
 	/* Try the longest matching exported pathname. */
 	while (1) {
-		exp = auth_authenticate_internal(what, caller, epath,
-						 hp, &error);
+		exp = auth_authenticate_internal(caller, epath,
+						 ai, &error);
 		if (exp || (error != not_exported && error != no_entry))
 			break;
 		/* We have to treat the root, "/", specially. */
@@ -246,31 +249,30 @@ auth_authenticate(char *what, struct sockaddr_in *caller, char *path)
 
 	case no_entry:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): no export entry",
-		     what, hp->h_name, path, epath);
+		     what, ai->ai_canonname, path, epath);
 		break;
 
 	case not_exported:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): not exported",
-		     what, hp->h_name, path, epath);
+		     what, ai->ai_canonname, path, epath);
 		break;
 
 	case illegal_port:
 		xlog(L_WARNING, "refused %s request from %s for %s (%s): illegal port %d",
-		     what, hp->h_name, path, epath, ntohs(caller->sin_port));
+		     what, ai->ai_canonname, path, epath, ntohs(caller->sin_port));
 		break;
 
 	case success:
 		xlog(L_NOTICE, "authenticated %s request from %s:%d for %s (%s)",
-		     what, hp->h_name, ntohs(caller->sin_port), path, epath);
+		     what, ai->ai_canonname, ntohs(caller->sin_port), path, epath);
 		break;
 	default:
 		xlog(L_NOTICE, "%s request from %s:%d for %s (%s) gave %d",
-		     what, hp->h_name, ntohs(caller->sin_port), path, epath, error);
+		     what, ai->ai_canonname, ntohs(caller->sin_port),
+			path, epath, error);
 	}
 
-	if (hp)
-		free (hp);
-
+	freeaddrinfo(ai);
 	return exp;
 }
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 9f32227..4381bf6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -77,8 +77,8 @@ void auth_unix_ip(FILE *f)
 	char class[20];
 	char ipaddr[20];
 	char *client = NULL;
-	struct in_addr addr;
-	struct hostent *he = NULL;
+	struct addrinfo *tmp = NULL;
+	struct addrinfo *ai = NULL;
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
 
@@ -93,17 +93,20 @@ void auth_unix_ip(FILE *f)
 	if (qword_get(&cp, ipaddr, 20) <= 0)
 		return;
 
-	if (inet_aton(ipaddr, &addr)==0)
+	tmp = host_pton(ipaddr);
+	if (tmp == NULL)
 		return;
 
 	auth_reload();
 
 	/* addr is a valid, interesting address, find the domain name... */
 	if (!use_ipaddr) {
-		he = client_resolve(addr);
-		client = client_compose(he);
+		ai = client_resolve(tmp->ai_addr);
+		client = client_compose(ai);
+		freeaddrinfo(ai);
 	}
-	
+	freeaddrinfo(tmp);
+
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
 	qword_printint(f, time(0)+30*60);
@@ -114,8 +117,7 @@ void auth_unix_ip(FILE *f)
 	qword_eol(f);
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
-	if (client) free(client);
-	free(he);
+	free(client);
 }
 
 void auth_unix_gid(FILE *f)
@@ -294,8 +296,7 @@ void nfsd_fh(FILE *f)
 	unsigned int fsidnum=0;
 	char fsid[32];
 	struct exportent *found = NULL;
-	struct hostent *he = NULL;
-	struct in_addr addr;
+	struct addrinfo *ai = NULL;
 	char *found_path = NULL;
 	nfs_export *exp;
 	int i;
@@ -471,12 +472,15 @@ void nfsd_fh(FILE *f)
 				break;
 			}
 			if (use_ipaddr) {
-				if (he == NULL) {
-					if (!inet_aton(dom, &addr))
+				if (ai == NULL) {
+					struct addrinfo *tmp;
+					tmp = host_pton(dom);
+					if (tmp == NULL)
 						goto out;
-					he = client_resolve(addr);
+					ai = client_resolve(tmp->ai_addr);
+					freeaddrinfo(tmp);
 				}
-				if (!client_check(exp->m_client, he))
+				if (!client_check(exp->m_client, ai))
 					continue;
 			}
 			/* It's a match !! */
@@ -534,8 +538,7 @@ void nfsd_fh(FILE *f)
  out:
 	if (found_path)
 		free(found_path);
-	if (he)
-		free(he);
+	freeaddrinfo(ai);
 	free(dom);
 	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path : NULL);
 	return;		
@@ -629,19 +632,22 @@ static int path_matches(nfs_export *exp, char *path)
 	return strcmp(path, exp->m_export.e_path) == 0;
 }
 
-static int client_matches(nfs_export *exp, char *dom, struct hostent *he)
+static int
+client_matches(nfs_export *exp, char *dom, struct addrinfo *ai)
 {
 	if (use_ipaddr)
-		return client_check(exp->m_client, he);
+		return client_check(exp->m_client, ai);
 	return client_member(dom, exp->m_client->m_hostname);
 }
 
-static int export_matches(nfs_export *exp, char *dom, char *path, struct hostent *he)
+static int
+export_matches(nfs_export *exp, char *dom, char *path, struct addrinfo *ai)
 {
-	return path_matches(exp, path) && client_matches(exp, dom, he);
+	return path_matches(exp, path) && client_matches(exp, dom, ai);
 }
 
-static nfs_export *lookup_export(char *dom, char *path, struct hostent *he)
+static nfs_export *
+lookup_export(char *dom, char *path, struct addrinfo *ai)
 {
 	nfs_export *exp;
 	nfs_export *found = NULL;
@@ -650,7 +656,7 @@ static nfs_export *lookup_export(char *dom, char *path, struct hostent *he)
 
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
-			if (!export_matches(exp, dom, path, he))
+			if (!export_matches(exp, dom, path, ai))
 				continue;
 			if (!found) {
 				found = exp;
@@ -698,9 +704,7 @@ void nfsd_export(FILE *f)
 	char *cp;
 	char *dom, *path;
 	nfs_export *found = NULL;
-	struct in_addr addr;
-	struct hostent *he = NULL;
-
+	struct addrinfo *ai = NULL;
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
@@ -722,12 +726,16 @@ void nfsd_export(FILE *f)
 	auth_reload();
 
 	if (use_ipaddr) {
-		if (!inet_aton(dom, &addr))
+		struct addrinfo *tmp;
+		tmp = host_pton(dom);
+		if (tmp == NULL)
+			goto out;
+		ai = client_resolve(tmp->ai_addr);
+		freeaddrinfo(tmp);
 			goto out;
-		he = client_resolve(addr);
 	}
 
-	found = lookup_export(dom, path, he);
+	found = lookup_export(dom, path, ai);
 
 	if (found) {
 		if (dump_to_cache(f, dom, path, &found->m_export) < 0) {
@@ -743,7 +751,7 @@ void nfsd_export(FILE *f)
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
 	if (dom) free(dom);
 	if (path) free(path);
-	if (he) free(he);
+	freeaddrinfo(ai);
 }
 
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 5373d81..6571454 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -536,22 +536,21 @@ static void free_exportlist(exports *elist)
 
 static void prune_clients(nfs_export *exp, struct exportnode *e)
 {
-	struct hostent 	*hp;
+	struct addrinfo *ai = NULL;
 	struct groupnode *c, **cp;
 
 	cp = &e->ex_groups;
 	while ((c = *cp) != NULL) {
 		if (client_gettype(c->gr_name) == MCL_FQDN
-				&& (hp = gethostbyname(c->gr_name))) {
-			hp = hostent_dup(hp);
-			if (client_check(exp->m_client, hp)) {
+		    && (ai = host_addrinfo(c->gr_name))) {
+			if (client_check(exp->m_client, ai)) {
 				*cp = c->gr_next;
 				xfree(c->gr_name);
 				xfree(c);
-				xfree (hp);
+				freeaddrinfo(ai);
 				continue;
 			}
-			xfree (hp);
+			freeaddrinfo(ai);
 		}
 		cp = &(c->gr_next);
 	}

