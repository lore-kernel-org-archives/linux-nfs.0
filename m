From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/6] lockd: Add address family-agnostic helper for zeroing the
	port number
Date: Wed, 27 Aug 2008 16:57:38 -0400
Message-ID: <20080827205738.17837.24021.stgit@manray.1015granger.net>
References: <20080827204852.17837.38361.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:44769 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbYH0U57 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Aug 2008 16:57:59 -0400
In-Reply-To: <20080827204852.17837.38361.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 22423ab..008e402 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -40,6 +40,18 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
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
@@ -154,7 +166,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	}
 	host->h_name	   = nsm->sm_name;
 	host->h_addr       = *sin;
-	host->h_addr.sin_port = 0;	/* ouch! */
+	nlm_clear_port((struct sockaddr *)&host->h_addr);
 	host->h_saddr	   = *ssin;
 	host->h_version    = version;
 	host->h_proto      = proto;

