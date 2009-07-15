From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/10] lockd: Replace nlm_clear_port()
Date: Wed, 15 Jul 2009 17:37:45 -0400
Message-ID: <20090715213745.7582.92888.stgit@matisse.1015granger.net>
References: <20090715212628.7582.98251.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net ([76.241.169.38]:38873
	"EHLO matisse.1015granger.net" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753693AbZGOVhs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 15 Jul 2009 17:37:48 -0400
In-Reply-To: <20090715212628.7582.98251.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Use shared rpc_set_port() function instead of nlm_clear_port().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   14 +-------------
 1 files changed, 1 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 99d737b..7cb076a 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -87,18 +87,6 @@ static unsigned int nlm_hash_address(const struct sockaddr *sap)
 	return hash & (NLM_HOST_NRHASH - 1);
 }
 
-static void nlm_clear_port(struct sockaddr *sap)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = 0;
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = 0;
-		break;
-	}
-}
-
 /*
  * Common host lookup routine for server & client
  */
@@ -177,7 +165,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	host->h_addrbuf    = nsm->sm_addrbuf;
 	memcpy(nlm_addr(host), ni->sap, ni->salen);
 	host->h_addrlen = ni->salen;
-	nlm_clear_port(nlm_addr(host));
+	rpc_set_port(nlm_addr(host), 0);
 	memcpy(nlm_srcaddr(host), ni->src_sap, ni->src_len);
 	host->h_version    = ni->version;
 	host->h_proto      = ni->protocol;

