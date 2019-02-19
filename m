Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=FREEMAIL_FORGED_FROMDOMAIN,
	FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00F74C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:02:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A89B22147C
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 19:02:58 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726612AbfBSTC6 convert rfc822-to-8bit (ORCPT
        <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 14:02:58 -0500
Received: from mout.gmx.net ([212.227.17.21]:45969 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1725963AbfBSTC5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Feb 2019 14:02:57 -0500
Received: from onion.lan ([62.178.200.226]) by mail.gmx.com (mrgmx103
 [212.227.17.168]) with ESMTPSA (Nemesis) id 0MUHbK-1gWHnE1OT4-00QxTg; Tue, 19
 Feb 2019 20:02:42 +0100
Date:   Tue, 19 Feb 2019 20:03:33 +0100
From:   Peter Wagner <tripolar@gmx.at>
To:     Steve Dickson <SteveD@RedHat.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: [PATCH v2] nfs-utils: fix addrinfo usage with musl-1.1.21
Message-ID: <20190219200333.4782a656@onion.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8BIT
X-Provags-ID: V03:K1:S13ajWSU+ghUG5Bc6F6QimNLgJLbAXlhX+9WfZkNvh6e33SG2oO
 pXZRdKOr0kV9MDF9awBYuLefH6QmyjuZ5aj0JFVCUjq9Qb9E/urD9vqO+lcqjS1KWD2BQvn
 fKlzrGb85+yJuAux39DQc8kR2aakIPhvMqVIl+xeZbkiJtTdrU9MMjmPsF5FR9YdmtIE0NP
 A1Hw9FMfXzdXjsJJndlGw==
X-UI-Out-Filterresults: notjunk:1;V03:K0:KgCTVUbG3dU=:hxqV1tviZFExr+l6CAeFrJ
 /ahxQPvtDgwabkRaDbuNvtGeYITmzxR1GmuwO8hBZ572qapEO02yR+QPCrCKwl4UwbCKQwy2S
 DVB0DLMrHRqxkpk3R3N/k2iDxkgwSzLpzrMFHnpiStY2PvMNVmQFluc/Ol1gjoIk3b3vGlRRl
 KWQHRT7N39+fcyX8tBN4EspelkdxFhaCYAJ0Yef+Wkl7tMXg5juqxEeVFS3hPM01b3si8LZVi
 lRsmNmuicx2Bdy419vLUk63k0crFTQBi7W76pOjFzBzqb6whCT0rBnhlaKdSaGJ90C2SkO0tV
 cvDbkUAYi4+J+vkdp+anps87jJlO9YE1WntyPmlWEpQoXEOj6cH0iMLj/Th/31cJjG6LQ6Mqb
 TAtMg1+A2tTH5ZJ8zzC+TbI27YkGw4d50c/cRlpJQ/wCLaaEY+XVgmYsxspDUYiTdQaKK9ZMZ
 GyYIVSh/EzXiTBhQ5ps7DswTtpuXXHhaK3R1BEdlfPJp8Rzki4XX9GfcKQeAAjK4PTYS8V46/
 YwcLQjbp+UDPj7ndY3mbY2hp9zsW3V8DUOH68RqlOTzQLjiGxH5MPK+JvU+UaxR0SS726y2gk
 lAr/Rtr205qzRtAH8IeIy2kjcRht2PP0f7Mh40jvQ1QewqKM9oTEQGLzcVfUEJQglm2phwmLG
 diN3KPnzoCS5DeSt6vVhL7Zg3TU3k92FN2zlw7gQltpuEqFp/pm29yVqCA/O14jct0WLREmpC
 k7GsjsW4xdFmvs7HwAs+GaQ6PRtymOHSxmW2JkIziGKT+Zri5CrHhc5MHoIwcAybVOrrEBaAZ
 ajSWHSEVpGS7AXio+UtG59Pj5zeeZT/R/3WxBb7jjZ1dZuUEMcLyE6Vp93QYvFkkrzHVN5TIk
 02le/xkq8RQC9DF0kwYSX9maZ1m23RzgrcGQpXTfe+GPn2yY8vLNCiI1G8qNYGK9rkEuvTTOZ
 8vwtlZed4+Q==
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From 877184f733d13d7db0ec9265a53ede9c30d03ba4 Mon Sep 17 00:00:00 2001
From: Peter Wagner <tripolar@gmx.at>
Date: Tue, 19 Feb 2019 20:00:22 +0100
Subject: [PATCH] [PATCH] define and use wrapper function nfs_freeaddrinfo to
 handle freeaddrinfo versions that don't tolerate NULL pointers

Signed-off-by: Peter Wagner <tripolar@gmx.at>
---
 support/export/client.c       |  6 +++---
 support/export/hostname.c     |  4 ++--
 support/include/exportfs.h    | 11 +++++++++++
 support/nfs/getport.c         |  7 ++++---
 support/nfs/svc_create.c      |  8 +++++---
 support/nfsidmap/umich_ldap.c |  2 +-
 tests/nsm_client/nsm_client.c |  2 +-
 utils/exportfs/exportfs.c     | 10 +++++-----
 utils/gssd/gssd.c             |  4 ++--
 utils/gssd/krb5_util.c        |  2 +-
 utils/mount/network.c         |  7 ++++---
 utils/mount/stropts.c         |  3 ++-
 utils/mountd/auth.c           |  2 +-
 utils/mountd/cache.c          | 10 +++++-----
 utils/mountd/mountd.c         |  4 ++--
 utils/mountd/rmtab.c          |  2 +-
 utils/nfsd/nfssvc.c           |  4 ++--
 utils/statd/hostname.c        | 11 ++++++-----
 utils/statd/sm-notify.c       | 14 +++++++-------
 19 files changed, 65 insertions(+), 48 deletions(-)

diff --git a/support/export/client.c b/support/export/client.c
index baf59c8..a1fba01 100644
--- a/support/export/client.c
+++ b/support/export/client.c
@@ -210,7 +210,7 @@ init_subnetwork(nfs_client *clp)
 	set_addrlist(clp, 0, ai->ai_addr);
 	family = ai->ai_addr->sa_family;
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 
 	switch (family) {
 	case AF_INET:
@@ -309,7 +309,7 @@ client_lookup(char *hname, int canonical)
 		init_addrlist(clp, ai);
 
 out:
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return clp;
 }
 
@@ -674,7 +674,7 @@ check_netgroup(const nfs_client *clp, const struct addrinfo *ai)
 	tmp = host_pton(hname);
 	if (tmp != NULL) {
 		char *cname = host_canonname(tmp->ai_addr);
-		freeaddrinfo(tmp);
+		nfs_freeaddrinfo(tmp);
 
 		/* The resulting FQDN may be in our netgroup. */
 		if (cname != NULL) {
diff --git a/support/export/hostname.c b/support/export/hostname.c
index 96c5449..be4d7f6 100644
--- a/support/export/hostname.c
+++ b/support/export/hostname.c
@@ -130,7 +130,7 @@ host_pton(const char *paddr)
 		if (!inet4 && ai->ai_addr->sa_family == AF_INET) {
 			xlog(D_GENERAL, "%s: failed to convert %s",
 					__func__, paddr);
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 			break;
 		}
 		return ai;
@@ -292,7 +292,7 @@ host_reliable_addrinfo(const struct sockaddr *sap)
 		if (nfs_compare_sockaddr(a->ai_addr, sap))
 			break;
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	ai = NULL;
 	if (!a)
 		goto out;
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 4e0d9d1..b81f963 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -47,6 +47,17 @@ typedef struct mclient {
 	int			m_count;
 } nfs_client;
 
+/*
+ * Some versions of freeaddrinfo(3) do not tolerate being
+ * passed a NULL pointer.
+ */
+static inline void nfs_freeaddrinfo(struct addrinfo *ai)
+{
+	if (ai) {
+		freeaddrinfo(ai);
+	}
+}
+
 static inline const struct sockaddr *
 get_addrlist(const nfs_client *clp, const int i)
 {
diff --git a/support/nfs/getport.c b/support/nfs/getport.c
index 081594c..26ec85e 100644
--- a/support/nfs/getport.c
+++ b/support/nfs/getport.c
@@ -47,6 +47,7 @@
 
 #include "sockaddr.h"
 #include "nfsrpc.h"
+#include "exportfs.h"
 
 /*
  * Try a local socket first to access the local rpcbind daemon
@@ -109,7 +110,7 @@ static int nfs_gp_loopback_address(struct sockaddr *sap, socklen_t *salen)
 		ret = 1;
 	}
 
-	freeaddrinfo(gai_results);
+	nfs_freeaddrinfo(gai_results);
 	return ret;
 }
 
@@ -134,8 +135,8 @@ static in_port_t nfs_gp_getservbyname(const char *service,
 
 	sin = (const struct sockaddr_in *)gai_results->ai_addr;
 	port = sin->sin_port;
-	
-	freeaddrinfo(gai_results);
+
+	nfs_freeaddrinfo(gai_results);
 	return port;
 }
 
diff --git a/support/nfs/svc_create.c b/support/nfs/svc_create.c
index ef7ff05..d0b747b 100644
--- a/support/nfs/svc_create.c
+++ b/support/nfs/svc_create.c
@@ -39,6 +39,8 @@
 #include <rpc/rpc.h>
 #include <rpc/svc.h>
 
+#include "exportfs.h"
+
 #ifdef HAVE_TCP_WRAPPER
 #include "tcpwrapper.h"
 #endif
@@ -273,7 +275,7 @@ svc_create_nconf_rand_port(const char *name, const rpcprog_t program,
 	bindaddr.qlen = SOMAXCONN;
 
 	xprt = svc_tli_create(RPC_ANYFD, nconf, &bindaddr, 0, 0);
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	if (xprt == NULL) {
 		xlog(L_ERROR, "Failed to create listener xprt "
 			"(%s, %u, %s)", name, version, nconf->nc_netid);
@@ -364,11 +366,11 @@ svc_create_nconf_fixed_port(const char *name, const rpcprog_t program,
 
 	svc_create_cache_xprt(xprt);
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return 1;
 
 out_free:
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return 0;
 }
 
diff --git a/support/nfsidmap/umich_ldap.c b/support/nfsidmap/umich_ldap.c
index b661110..b8ee184 100644
--- a/support/nfsidmap/umich_ldap.c
+++ b/support/nfsidmap/umich_ldap.c
@@ -1089,7 +1089,7 @@ get_canonical_hostname(const char *inname)
 	return_name = strdup (tmphost);
 
 out_free:
-	freeaddrinfo(ap);
+	nfs_freeaddrinfo(ap);
 out_err:
 	return return_name;
 }
diff --git a/tests/nsm_client/nsm_client.c b/tests/nsm_client/nsm_client.c
index 0fa3422..8dc0591 100644
--- a/tests/nsm_client/nsm_client.c
+++ b/tests/nsm_client/nsm_client.c
@@ -243,7 +243,7 @@ nsm_client_get_rpcclient(const char *node)
 		printf("RPC client creation failed\n");
 	}
 out:
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return client;
 }
 
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index cd3c979..333eadc 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -282,7 +282,7 @@ exportfs_parsed(char *hname, char *path, char *options, int verbose)
 	validate_export(exp);
 
 out:
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 }
 
 static int exportfs_generic(char *arg, char *options, int verbose)
@@ -395,7 +395,7 @@ unexportfs_parsed(char *hname, char *path, int verbose)
 	if (!success)
 		xlog(L_ERROR, "Could not find '%s:%s' to unexport.", hname, path);
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 }
 
 static int unexportfs_generic(char *arg, int verbose)
@@ -588,7 +588,7 @@ address_list(const char *hostname)
 	if (ai != NULL) {
 		/* @hostname was a presentation address */
 		cname = host_canonname(ai->ai_addr);
-		freeaddrinfo(ai);
+		nfs_freeaddrinfo(ai);
 		if (cname != NULL)
 			goto out;
 	}
@@ -639,8 +639,8 @@ matchhostname(const char *hostname1, const char *hostname2)
 			}
 
 out:
-	freeaddrinfo(results1);
-	freeaddrinfo(results2);
+	nfs_freeaddrinfo(results1);
+	nfs_freeaddrinfo(results2);
 	return result;
 }
 
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 2e92f28..7eeb05f 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -172,14 +172,14 @@ gssd_addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port
 		if (sin6->sin6_scope_id) {
 			printerr(0, "ERROR: address %s has non-zero "
 				    "sin6_scope_id!\n", node);
-			freeaddrinfo(res);
+			nfs_freeaddrinfo(res);
 			return false;
 		}
 	}
 #endif /* IPV6_SUPPORTED */
 
 	memcpy(sa, res->ai_addr, res->ai_addrlen);
-	freeaddrinfo(res);
+	nfs_freeaddrinfo(res);
 	return true;
 }
 
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index eba1aac..adbde93 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -587,7 +587,7 @@ get_full_hostname(const char *inhost, char *outhost, int outhostlen)
 		goto out;
 	}
 	strncpy(outhost, addrs->ai_canonname, outhostlen);
-	freeaddrinfo(addrs);
+	nfs_freeaddrinfo(addrs);
 	for (c = outhost; *c != '\0'; c++)
 	    *c = tolower(*c);
 
diff --git a/utils/mount/network.c b/utils/mount/network.c
index 356f663..fcb0b9f 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -53,6 +53,7 @@
 #include <net/if.h>
 #include <ifaddrs.h>
 
+#include "exportfs.h"
 #include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
@@ -250,7 +251,7 @@ int nfs_lookup(const char *hostname, const sa_family_t family,
 		break;
 	}
 
-	freeaddrinfo(gai_results);
+	nfs_freeaddrinfo(gai_results);
 	return ret;
 }
 
@@ -307,7 +308,7 @@ int nfs_string_to_sockaddr(const char *address, struct sockaddr *sap,
 			}
 			break;
 		}
-		freeaddrinfo(gai_results);
+		nfs_freeaddrinfo(gai_results);
 	}
 
 	return ret;
@@ -1180,7 +1181,7 @@ static int nfs_ca_gai(const struct sockaddr *sap,
 	*buflen = gai_results->ai_addrlen;
 	memcpy(buf, gai_results->ai_addr, *buflen);
 
-	freeaddrinfo(gai_results);
+	nfs_freeaddrinfo(gai_results);
 
 	return 1;
 }
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 0a25b1f..b170552 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -35,6 +35,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 
+#include "exportfs.h"
 #include "sockaddr.h"
 #include "xcommon.h"
 #include "mount.h"
@@ -1268,7 +1269,7 @@ int nfsmount_string(const char *spec, const char *node, char *type,
 	} else
 		nfs_error(_("%s: internal option parsing error"), progname);
 
-	freeaddrinfo(mi.address);
+	nfs_freeaddrinfo(mi.address);
 	free(mi.hostname);
 	return retval;
 }
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index cb4848c..67627f7 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -297,7 +297,7 @@ auth_authenticate(const char *what, const struct sockaddr *caller,
 		     what, buf, nfs_get_port(caller), path, epath, error);
 	}
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return exp;
 }
 
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 7e8d403..2cb370f 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -113,7 +113,7 @@ static void auth_unix_ip(int f)
 		ai = client_resolve(tmp->ai_addr);
 		if (ai) {
 			client = client_compose(ai);
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 		}
 	}
 	bp = buf; blen = sizeof(buf);
@@ -133,7 +133,7 @@ static void auth_unix_ip(int f)
 	xlog(D_CALL, "auth_unix_ip: client %p '%s'", client, client?client: "DEFAULT");
 
 	free(client);
-	freeaddrinfo(tmp);
+	nfs_freeaddrinfo(tmp);
 
 }
 
@@ -667,7 +667,7 @@ static struct addrinfo *lookup_client_addr(char *dom)
 	if (tmp == NULL)
 		return NULL;
 	ret = client_resolve(tmp->ai_addr);
-	freeaddrinfo(tmp);
+	nfs_freeaddrinfo(tmp);
 	return ret;
 }
 
@@ -834,7 +834,7 @@ static void nfsd_fh(int f)
 out:
 	if (found_path)
 		free(found_path);
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	free(dom);
 	xlog(D_CALL, "nfsd_fh: found %p path %s", found, found ? found->e_path : NULL);
 }
@@ -1355,7 +1355,7 @@ static void nfsd_export(int f)
 	xlog(D_CALL, "nfsd_export: found %p path %s", found, path ? path : NULL);
 	if (dom) free(dom);
 	if (path) free(path);
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 }
 
 
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 086c39b..fb7bba4 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -578,10 +578,10 @@ static void prune_clients(nfs_export *exp, struct exportnode *e)
 				*cp = c->gr_next;
 				xfree(c->gr_name);
 				xfree(c);
-				freeaddrinfo(ai);
+				nfs_freeaddrinfo(ai);
 				continue;
 			}
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 		}
 		cp = &(c->gr_next);
 	}
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index 3ae0dbb..c896243 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -226,7 +226,7 @@ mountlist_list(void)
 				ai = host_pton(rep->r_client);
 				if (ai != NULL) {
 					m->ml_hostname = host_canonname(ai->ai_addr);
-					freeaddrinfo(ai);
+					nfs_freeaddrinfo(ai);
 				}
 			}
 			if (m->ml_hostname == NULL)
diff --git a/utils/nfsd/nfssvc.c b/utils/nfsd/nfssvc.c
index 1e6ffd6..47b1882 100644
--- a/utils/nfsd/nfssvc.c
+++ b/utils/nfsd/nfssvc.c
@@ -25,6 +25,7 @@
 #include "nfslib.h"
 #include "xlog.h"
 #include "nfssvc.h"
+#include "exportfs.h"
 #include "../mount/version.h"
 
 #ifndef NFSD_FS_DIR
@@ -246,8 +247,7 @@ error:
 		close(fd);
 	if (sockfd >= 0)
 		close(sockfd);
-	if (addrhead)
-		freeaddrinfo(addrhead);
+	nfs_freeaddrinfo(addrhead);
 	return (bounded ? 0 : rc);
 }
 
diff --git a/utils/statd/hostname.c b/utils/statd/hostname.c
index 8cccdb8..c9e22d3 100644
--- a/utils/statd/hostname.c
+++ b/utils/statd/hostname.c
@@ -35,6 +35,7 @@
 #include <netdb.h>
 #include <arpa/inet.h>
 
+#include "exportfs.h"
 #include "sockaddr.h"
 #include "statd.h"
 #include "xlog.h"
@@ -203,7 +204,7 @@ statd_canonical_name(const char *hostname)
 		_Bool result;
 		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
 					buf, (socklen_t)sizeof(buf));
-		freeaddrinfo(ai);
+		nfs_freeaddrinfo(ai);
 		if (!result || buf[0] == '\0')
 			/* OK to use presentation address,
 			 * if no reverse map exists */
@@ -217,7 +218,7 @@ statd_canonical_name(const char *hostname)
 	if (ai == NULL)
 		return NULL;
 	strcpy(buf, ai->ai_canonname);
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 
 	return strdup(buf);
 }
@@ -253,7 +254,7 @@ statd_canonical_list(const char *hostname)
 		_Bool result;
 		result = get_nameinfo(ai->ai_addr, ai->ai_addrlen,
 					buf, (socklen_t)sizeof(buf));
-		freeaddrinfo(ai);
+		nfs_freeaddrinfo(ai);
 		if (result)
 			goto out;
 	}
@@ -308,8 +309,8 @@ statd_matchhostname(const char *hostname1, const char *hostname2)
 			}
 
 out:
-	freeaddrinfo(results2);
-	freeaddrinfo(results1);
+	nfs_freeaddrinfo(results2);
+	nfs_freeaddrinfo(results1);
 
 	xlog(D_CALL, "%s: hostnames %s and %s %s", __func__,
 			hostname1, hostname2,
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 29dad38..05d72a3 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -37,6 +37,7 @@
 #include "xlog.h"
 #include "nsm.h"
 #include "nfsrpc.h"
+#include "exportfs.h"
 
 /* glibc before 2.3.4 */
 #ifndef AI_NUMERICSERV
@@ -179,7 +180,7 @@ smn_verify_my_name(const char *name)
 	case 0:
 		/* @name was a presentation address */
 		retval = smn_get_hostname(ai->ai_addr, ai->ai_addrlen, name);
-		freeaddrinfo(ai);
+		nfs_freeaddrinfo(ai);
 		if (retval == NULL)
 			return NULL;
 		break;
@@ -253,8 +254,7 @@ static void smn_forget_host(struct nsm_host *host)
 	free((void *)host->my_name);
 	free((void *)host->mon_name);
 	free(host->name);
-	if (host->ai)
-		freeaddrinfo(host->ai);
+	nfs_freeaddrinfo(host->ai);
 
 	free(host);
 }
@@ -430,7 +430,7 @@ retry:
 	if (srcport) {
 		if (bind(sock, ai->ai_addr, ai->ai_addrlen) == -1) {
 			xlog(L_ERROR, "Failed to bind RPC socket: %m");
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 			(void)close(sock);
 			return -1;
 		}
@@ -440,7 +440,7 @@ retry:
 		if (smn_bindresvport(sock, ai->ai_addr) == -1) {
 			xlog(L_ERROR,
 				"bindresvport on RPC socket failed: %m");
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 			(void)close(sock);
 			return -1;
 		}
@@ -449,13 +449,13 @@ retry:
 		se = getservbyport((int)nfs_get_port(ai->ai_addr), "udp");
 		if (se != NULL && retry_cnt < 100) {
 			retry_cnt++;
-			freeaddrinfo(ai);
+			nfs_freeaddrinfo(ai);
 			(void)close(sock);
 			goto retry;
 		}
 	}
 
-	freeaddrinfo(ai);
+	nfs_freeaddrinfo(ai);
 	return sock;
 }
 
-- 
2.20.1

