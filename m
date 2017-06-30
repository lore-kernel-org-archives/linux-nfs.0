Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751659AbdF3NVv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 30 Jun 2017 09:21:51 -0400
From: Stefan Hajnoczi <stefanha@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Jeff Layton <jlayton@redhat.com>, Abbas Naderi <abiusx@google.com>,
        Steve Dickson <steved@redhat.com>,
        Stefan Hajnoczi <stefanha@redhat.com>
Subject: [PATCH nfs-utils v2 07/12] exportfs: introduce host_freeaddrinfo()
Date: Fri, 30 Jun 2017 14:21:15 +0100
Message-Id: <20170630132120.31578-8-stefanha@redhat.com>
In-Reply-To: <20170630132120.31578-1-stefanha@redhat.com>
References: <20170630132120.31578-1-stefanha@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The AF_VSOCK address family is not supported by the getaddrinfo(3)
family of functions so we will have to arrange our own struct addrinfo
for vsock addresses.

Different libc implementations can allocate struct addrinfo and struct
sockaddr in different ways.  Since the memory allocation details of
getaddrinfo(3) results are private to libc we cannot call freeaddrinfo()
on a struct addrinfo we allocated ourselves.

Introduce a freeaddrinfo(3) wrapper function that will be used to safely
free AF_VSOCK struct addrinfo in a later patch.  Just introduce the
wrapper function now so this patch is easy to review without
AF_VSOCK-specific changes.

Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
---
 support/include/exportfs.h |  1 +
 support/export/client.c    |  8 ++++----
 support/export/hostname.c  | 28 +++++++++++++++++++++-------
 utils/exportfs/exportfs.c  | 10 +++++-----
 utils/mountd/auth.c        |  2 +-
 utils/mountd/cache.c       | 10 +++++-----
 utils/mountd/mountd.c      |  4 ++--
 utils/mountd/rmtab.c       |  2 +-
 8 files changed, 40 insertions(+), 25 deletions(-)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 8af47a8..98d45c5 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -161,6 +161,7 @@ __attribute__((__malloc__))
 struct addrinfo *		host_reliable_addrinfo(const struct sockaddr *sap);
 __attribute__((__malloc__))
 struct addrinfo *		host_numeric_addrinfo(const struct sockaddr *sap);
+void				host_freeaddrinfo(struct addrinfo * ai);
 
 struct nfskey *			key_lookup(char *hname);
 
diff --git a/support/export/client.c b/support/export/client.c
index 2346f99..881c776 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -210,7 +210,7 @@ init_subnetwork(nfs_client *clp)
 	set_addrlist(clp, 0, ai->ai_addr);
 	family = ai->ai_addr->sa_family;
 
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 
 	switch (family) {
 	case AF_INET:
@@ -309,7 +309,7 @@ client_lookup(char *hname, int canonical)
 		init_addrlist(clp, ai);
 
 out:
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 	return clp;
 }
 
@@ -378,7 +378,7 @@ client_freeall(void)
  * @sap: pointer to socket address to resolve
  *
  * Returns an addrinfo structure, or NULL if some problem occurred.
- * Caller must free the result with freeaddrinfo(3).
+ * Caller must free the result with host_freeaddrinfo().
  */
 struct addrinfo *
 client_resolve(const struct sockaddr *sap)
@@ -673,7 +673,7 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	tmp = host_pton(hname);
 	if (tmp != NULL) {
 		char *cname = host_canonname(tmp->ai_addr);
-		freeaddrinfo(tmp);
+		host_freeaddrinfo(tmp);
 
 		/* The resulting FQDN may be in our netgroup. */
 		if (cname != NULL) {
diff --git a/support/export/hostname.c b/support/export/hostname.c
index 5c4c824..7f8a6f8 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -89,7 +89,7 @@ host_ntop(const struct sockaddr *sap, char *buf, const size_t buflen)
  *		IP presentation address
  *
  * Returns address info structure, or NULL if an error occurs.  Caller
- * must free the returned structure with freeaddrinfo(3).
+ * must free the returned structure with host_freeaddrinfo().
  */
 __attribute__((__malloc__))
 struct addrinfo *
@@ -155,7 +155,7 @@ host_pton(const char *paddr)
  *
  * Returns address info structure with ai_canonname filled in, or NULL
  * if no information is available for @hostname.  Caller must free the
- * returned structure with freeaddrinfo(3).
+ * returned structure with host_freeaddrinfo().
  */
 __attribute__((__malloc__))
 struct addrinfo *
@@ -192,6 +192,20 @@ host_addrinfo(const char *hostname)
 }
 
 /**
+ * host_freeaddrinfo - free addrinfo obtained from host_*() functions
+ * @ai: pointer to addrinfo to free
+ *
+ * The addrinfos returned by host_*() functions may not have been allocated by
+ * a call to getaddrinfo(3).  It is not safe to free them directly with
+ * freeaddrinfo(3).  Use this function instead.
+ */
+void
+host_freeaddrinfo(struct addrinfo *ai)
+{
+	freeaddrinfo(ai);
+}
+
+/**
  * host_canonname - return canonical hostname bound to an address
  * @sap: pointer to socket address to look up
  *
@@ -268,7 +282,7 @@ host_canonname(const struct sockaddr *sap)
  * ai_canonname filled in. If there is a problem with resolution or
  * the resolved records don't match up properly then it returns NULL
  *
- * Caller must free the returned structure with freeaddrinfo(3).
+ * Caller must free the returned structure with host_freeaddrinfo().
  */
 __attribute__((__malloc__))
 struct addrinfo *
@@ -290,7 +304,7 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 		if (nfs_compare_sockaddr(a->ai_addr, sap))
 			break;
 
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 	if (!a)
 		goto out_free_hostname;
 
@@ -314,7 +328,7 @@ out_free_hostname:
  * @sap: pointer to socket address
  *
  * Returns address info structure, or NULL if an error occurred.
- * Caller must free the returned structure with freeaddrinfo(3).
+ * Caller must free the returned structure with host_freeaddrinfo().
  */
 #ifdef HAVE_GETNAMEINFO
 __attribute__((__malloc__))
@@ -357,7 +371,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 		free(ai->ai_canonname);		/* just in case */
 		ai->ai_canonname = strdup(buf);
 		if (ai->ai_canonname == NULL) {
-			freeaddrinfo(ai);
+			host_freeaddrinfo(ai);
 			ai = NULL;
 		}
 	}
@@ -390,7 +404,7 @@ host_numeric_addrinfo(const struct sockaddr *sap)
 	if (ai != NULL) {
 		ai->ai_canonname = strdup(buf);
 		if (ai->ai_canonname == NULL) {
-			freeaddrinfo(ai);
+			host_freeaddrinfo(ai);
 			ai = NULL;
 		}
 	}
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index beed1b3..3ded733 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -282,7 +282,7 @@ exportfs_parsed(char *hname, char *path, char *options, int verbose)
 	validate_export(exp);
 
 out:
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 }
 
 static int exportfs_generic(char *arg, char *options, int verbose)
@@ -395,7 +395,7 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 	if (!success)
 		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
 
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 }
 
 static int unexportfs_generic(char *arg, int verbose)
@@ -588,7 +588,7 @@ address_list(const char *hostname)
 	if (ai != NULL) {
 		/* @hostname was a presentation address */
 		cname = host_canonname(ai->ai_addr);
-		freeaddrinfo(ai);
+		host_freeaddrinfo(ai);
 		if (cname != NULL)
 			goto out;
 	}
@@ -639,8 +639,8 @@ matchhostname(const char *hostname1, const char *hostname2)
 			}
 
 out:
-	freeaddrinfo(results1);
-	freeaddrinfo(results2);
+	host_freeaddrinfo(results1);
+	host_freeaddrinfo(results2);
 	return result;
 }
 
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 8299256..dee0f3d 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -297,7 +297,7 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 			path, epath, error);
 	}
 
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 	return exp;
 }
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index ca6c84f..b57fef6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -112,7 +112,7 @@ static void auth_unix_ip(int f)
 		ai = client_resolve(tmp->ai_addr);
 		if (ai) {
 			client = client_compose(ai);
-			freeaddrinfo(ai);
+			host_freeaddrinfo(ai);
 		}
 	}
 	bp = buf; blen = sizeof(buf);
@@ -132,7 +132,7 @@ static void auth_unix_ip(int f)
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
 	free(client);
-	freeaddrinfo(tmp);
+	host_freeaddrinfo(tmp);
 
 }
 
@@ -666,7 +666,7 @@ static struct addrinfo *lookup_client_addr(char *dom)
 	if (tmp == NULL)
 		return NULL;
 	ret = client_resolve(tmp->ai_addr);
-	freeaddrinfo(tmp);
+	host_freeaddrinfo(tmp);
 	return ret;
 }
 
@@ -833,7 +833,7 @@ static void nfsd_fh(int f)
 out:
 	if (found_path)
 		free(found_path);
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 	free(dom);
 	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path : NULL);
 }
@@ -1363,7 +1363,7 @@ static void nfsd_export(int f)
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
 	if (dom) free(dom);
 	if (path) free(path);
-	freeaddrinfo(ai);
+	host_freeaddrinfo(ai);
 }
 
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 829f803..3193ded 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -578,10 +578,10 @@ static void prune_clients(nfs_export *exp, struct exportnode *e)
 				*cp = c->gr_next;
 				xfree(c->gr_name);
 				xfree(c);
-				freeaddrinfo(ai);
+				host_freeaddrinfo(ai);
 				continue;
 			}
-			freeaddrinfo(ai);
+			host_freeaddrinfo(ai);
 		}
 		cp = &(c->gr_next);
 	}
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index 3ae0dbb..99f7474 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -226,7 +226,7 @@ mountlist_list(void)
 				ai = host_pton(rep->r_client);
 				if (ai != NULL) {
 					m->ml_hostname = host_canonname(ai->ai_addr);
-					freeaddrinfo(ai);
+					host_freeaddrinfo(ai);
 				}
 			}
 			if (m->ml_hostname == NULL)
-- 
2.9.4

