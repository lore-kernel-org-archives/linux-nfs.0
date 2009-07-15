From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/10] lockd: Replace nsm_display_address() with rpc_ntop()
Date: Wed, 15 Jul 2009 17:37:53 -0400
Message-ID: <20090715213752.7582.69928.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38876
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754007AbZGOVhz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:55 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   44 +++++---------------------------------------
 1 files changed, 5 insertions(+), 39 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 7fce1b5..30c9331 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -61,43 +61,6 @@ static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 	return (struct sockaddr *)&nsm->sm_addr;
 }
 
-static void nsm_display_ipv4_address(const struct sockaddr *sap, char *buf,
-				     const size_t len)
-{
-	const struct sockaddr_in *sin = (struct sockaddr_in *)sap;
-	snprintf(buf, len, "%pI4", &sin->sin_addr.s_addr);
-}
-
-static void nsm_display_ipv6_address(const struct sockaddr *sap, char *buf,
-				     const size_t len)
-{
-	const struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
-
-	if (ipv6_addr_v4mapped(&sin6->sin6_addr))
-		snprintf(buf, len, "%pI4", &sin6->sin6_addr.s6_addr32[3]);
-	else if (sin6->sin6_scope_id != 0)
-		snprintf(buf, len, "%pI6%%%u", &sin6->sin6_addr,
-				sin6->sin6_scope_id);
-	else
-		snprintf(buf, len, "%pI6", &sin6->sin6_addr);
-}
-
-static void nsm_display_address(const struct sockaddr *sap,
-				char *buf, const size_t len)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		nsm_display_ipv4_address(sap, buf, len);
-		break;
-	case AF_INET6:
-		nsm_display_ipv6_address(sap, buf, len);
-		break;
-	default:
-		snprintf(buf, len, "unsupported address family");
-		break;
-	}
-}
-
 static struct rpc_clnt *nsm_create(void)
 {
 	struct sockaddr_in sin = {
@@ -307,8 +270,11 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	memcpy(nsm_addr(new), sap, salen);
 	new->sm_addrlen = salen;
 	nsm_init_private(new);
-	nsm_display_address((const struct sockaddr *)&new->sm_addr,
-				new->sm_addrbuf, sizeof(new->sm_addrbuf));
+
+	if (rpc_ntop(nsm_addr(new), new->sm_addrbuf,
+					sizeof(new->sm_addrbuf)) == 0)
+		(void)snprintf(new->sm_addrbuf, sizeof(new->sm_addrbuf),
+				"unsupported address family");
 	memcpy(new->sm_name, hostname, hostname_len);
 	new->sm_name[hostname_len] = '\0';
 

