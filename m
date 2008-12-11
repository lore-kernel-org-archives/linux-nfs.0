From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 02/11] NSM: Refactor nsm_handle creation into a helper function
Date: Thu, 11 Dec 2008 17:55:52 -0500
Message-ID: <20081211225551.21468.5542.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:17386 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759584AbYLKW4v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:51 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.  Refactor the creation of nsm_handles into a helper.  Fields
are initialized in increasing address order to make efficient use of
CPU caches.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   38 ++++++++++++++++++++++++++------------
 1 files changed, 26 insertions(+), 12 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 0dd309d..f4a201b 100644
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
@@ -296,19 +320,9 @@ retry:
 	}
 	spin_unlock(&nsm_lock);
 
-	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
-	if (nsm == NULL)
+	nsm = nsm_create_handle(sap, salen, hostname, hostname_len);
+	if (unlikely(nsm == NULL))
 		return NULL;
-
-	memcpy(nsm_addr(nsm), sap, salen);
-	nsm->sm_addrlen = salen;
-	nsm->sm_name = (char *) (nsm + 1);
-	memcpy(nsm->sm_name, hostname, hostname_len);
-	nsm->sm_name[hostname_len] = '\0';
-	nsm_init_private(nsm);
-	nsm_display_address((struct sockaddr *)&nsm->sm_addr,
-				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
-	atomic_set(&nsm->sm_count, 1);
 	goto retry;
 
 found:

