From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/16] lockd: Add address family-agnostic helper for zeroing
	the port number
Date: Mon, 30 Jun 2008 18:58:38 -0400
Message-ID: <20080630225837.25407.32859.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51358 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762952AbYF3W7w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:59:52 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)


diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 618c631..f87066d 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -39,6 +39,21 @@ static struct nsm_handle *	nsm_find(const struct sockaddr_in *sin,
 					 const char *hostname,
 					 unsigned int hostname_len);
 
+static void nlm_clear_port(struct sockaddr *sap)
+{
+	struct sockaddr_in *sin = (struct sockaddr_in *)sap;
+	struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sap;
+
+	switch (sap->sa_family) {
+	case AF_INET:
+		sin->sin_port = 0;
+		break;
+	case AF_INET6:
+		sin6->sin6_port = 0;
+		break;
+	}
+}
+
 static void nlm_display_address(const struct sockaddr *sap,
 				char *buf, const size_t len)
 {
@@ -149,7 +164,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	}
 	host->h_name	   = nsm->sm_name;
 	host->h_addr       = *sin;
-	host->h_addr.sin_port = 0;	/* ouch! */
+	nlm_clear_port((struct sockaddr *)&host->h_addr);
 	host->h_saddr	   = *ssin;
 	host->h_version    = version;
 	host->h_proto      = proto;

