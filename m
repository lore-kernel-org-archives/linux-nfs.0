From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] lockd: Add address family-agnostic helper for zeroing the
	port number
Date: Fri, 22 Aug 2008 12:42:33 -0400
Message-ID: <20080822164232.20488.11685.stgit@manray.1015granger.net>
References: <20080822163939.20488.92983.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34123 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752314AbYHVQom (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Aug 2008 12:44:42 -0400
In-Reply-To: <20080822163939.20488.92983.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 55ef751..3f0c1a8 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -39,6 +39,18 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
 					 unsigned int hostname_len);
 
+static void nlm_clear_port(struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET:
+		((struct sockaddr_in *)sap)->sin_port = 0;
+		break;
+	case AF_INET6:
+		((struct sockaddr_in6 *)sap)->sin6_port = 0;
+		break;
+	}
+}
+
 static void nlm_display_address(const struct sockaddr *sap,
 				char *buf, const size_t len)
 {
@@ -149,7 +161,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	}
 	host->h_name	   = nsm->sm_name;
 	host->h_addr       = *sin;
-	host->h_addr.sin_port = 0;	/* ouch! */
+	nlm_clear_port((struct sockaddr *)&host->h_addr);
 	host->h_saddr	   = *ssin;
 	host->h_version    = version;
 	host->h_proto      = proto;

