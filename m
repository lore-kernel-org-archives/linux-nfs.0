From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 18/27] NSM: Refactor nsm_handle creation into a helper function
Date: Fri, 05 Dec 2008 19:04:09 -0500
Message-ID: <20081206000409.24075.37859.stgit@ingres.1015granger.net>
References: <20081205235557.24075.12511.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49587 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754568AbYLFAEe (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Dec 2008 19:04:34 -0500
In-Reply-To: <20081205235557.24075.12511.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

We're about to get rid of the "goto retry" in nsm_get_handle().
To facilitate this, move the nsm_handle initialization logic to
a helper function.

Fields are initialized in increasing address order to make efficient
use of CPU caches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   41 ++++++++++++++++++++++++++++-------------
 1 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 4267a57..24857a8 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -240,6 +240,30 @@ static void nsm_init_private(struct nsm_handle *nsm)
 	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
 }
 
+static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
+					    const size_t salen,
+					    const char *hostname,
+					    const size_t hostname_len)
+{
+	struct nsm_handle *new;
+
+	new = kzalloc(sizeof(*new) + hostname_len + 1, GFP_KERNEL);
+	if (unlikely(new == NULL))
+		return NULL;
+
+	atomic_set(&new->sm_count, 1);
+	new->sm_name = (char *)(new + 1);
+	memcpy(nsm_addr(new), sap, salen);
+	new->sm_addrlen = salen;
+	nsm_init_private(new);
+	nsm_display_address((const struct sockaddr *)&new->sm_addr,
+				new->sm_addrbuf, sizeof(new->sm_addrbuf));
+	memcpy(new->sm_name, hostname, hostname_len);
+	new->sm_name[hostname_len] = '\0';
+
+	return new;
+}
+
 /**
  * nsm_get_handle - Find or create a cached nsm_handle
  * @sap: pointer to socket address of handle to find
@@ -299,20 +323,11 @@ retry:
 
 	spin_unlock(&nsm_lock);
 
-	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
-	if (nsm == NULL)
-		return NULL;
+	nsm = nsm_create_handle(sap, salen, hostname, hostname_len);
+	if (nsm != NULL)
+		goto retry;
 
-	memcpy(nsm_addr(nsm), sap, salen);
-	nsm->sm_addrlen = salen;
-	nsm->sm_name = (char *) (nsm + 1);
-	memcpy(nsm->sm_name, hostname, hostname_len);
-	nsm->sm_name[hostname_len] = '\0';
-	nsm_init_private(nsm);
-	nsm_display_address((struct sockaddr *)&nsm->sm_addr,
-				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
-	atomic_set(&nsm->sm_count, 1);
-	goto retry;
+	return NULL;
 }
 
 /**

