From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 16/18] NSM: factor nsm_handle initialization out of
	nsm_get_handle()
Date: Wed, 05 Nov 2008 12:21:19 -0500
Message-ID: <20081105172118.6773.61430.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34432 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752900AbYKERVh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:37 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: move nsm_handle initialization to a helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   39 ++++++++++++++++++++++++++++-----------
 1 files changed, 28 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 7d80c56..427d915 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -234,6 +234,33 @@ static void nsm_init_private(struct nsm_handle *nsm)
 	*p = timeval_to_ns(&tv);
 }
 
+static struct nsm_handle *nsm_init_handle(const struct sockaddr *sap,
+					  const size_t salen,
+					  const char *hostname,
+					  const size_t hostname_len)
+{
+	struct nsm_handle *nsm;
+
+	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
+	if (nsm == NULL)
+		return NULL;
+
+	atomic_set(&nsm->sm_count, 1);
+
+	nsm->sm_name = (char *)(nsm + 1);
+	memcpy(nsm->sm_name, hostname, hostname_len);
+	nsm->sm_name[hostname_len] = '\0';
+
+	memcpy(nsm_addr(nsm), sap, salen);
+	nsm->sm_addrlen = salen;
+
+	nsm_init_private(nsm);
+	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
+				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
+
+	return nsm;
+}
+
 /**
  * nsm_get_handle - Find or create a cached nsm_handle
  * @sap: pointer to socket address of handle to find
@@ -296,19 +323,9 @@ retry:
 
 	spin_unlock(&nsm_lock);
 
-	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
+	nsm = nsm_init_handle(sap, salen, hostname, hostname_len);
 	if (nsm == NULL)
 		return NULL;
-
-	memcpy(nsm_addr(nsm), sap, salen);
-	nsm->sm_addrlen = salen;
-	nsm->sm_name = (char *) (nsm + 1);
-	memcpy(nsm->sm_name, hostname, hostname_len);
-	nsm->sm_name[hostname_len] = '\0';
-	nsm_init_private(nsm);
-	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
-				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
-	atomic_set(&nsm->sm_count, 1);
 	goto retry;
 }
 

