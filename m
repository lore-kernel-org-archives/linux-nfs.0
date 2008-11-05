From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/18] NSM: Use same helpers in nsm_get_handle() and
	nsm_lookup_rebooted()
Date: Wed, 05 Nov 2008 12:21:26 -0500
Message-ID: <20081105172126.6773.19026.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34456 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753005AbYKERVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:42 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor the nsm_get_handle() function so it uses the same lookup
helpers as the newly added nsm_reboot_lookup() function, and use
do {} while() instead of a goto; for the retry loop.

This makes it easier if some day we want to use a more sophisticated
lookup algorithm than a linked list search for finding nsm_handles
in both nsm_get_handle() and nsm_reboot_lookup().

There is an additional micro-optimization here.  This change moves the
"hostname & nsm_use_hostnames" test out of the list_for_each_entry()
clause in nsm_get_handle(), since it is loop-invariant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   70 +++++++++++++++++++++++++++++++-------------------------
 1 files changed, 39 insertions(+), 31 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 427d915..8538180 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -196,6 +196,16 @@ static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
 	return NULL;
 }
 
+static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
+{
+	struct nsm_handle *nsm;
+
+	list_for_each_entry(nsm, &nsm_handles, sm_link)
+		if (nlm_cmp_addr(nsm_addr(nsm), sap))
+			return nsm;
+	return NULL;
+}
+
 /*
  * Construct a unique cookie to identify this nsm_handle.  It is
  * passed to our statd via NSMPROC_MON, and returned via
@@ -279,8 +289,7 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 				  const size_t salen, const char *hostname,
 				  const size_t hostname_len)
 {
-	struct nsm_handle *nsm = NULL;
-	struct nsm_handle *pos;
+	struct nsm_handle *new, *cached;
 
 	if (!sap)
 		return NULL;
@@ -294,39 +303,38 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 		return NULL;
 	}
 
-retry:
-	spin_lock(&nsm_lock);
-	list_for_each_entry(pos, &nsm_handles, sm_link) {
-		if (hostname && nsm_use_hostnames) {
-			if (strlen(pos->sm_name) != hostname_len
-			 || memcmp(pos->sm_name, hostname, hostname_len))
-				continue;
-		} else if (!nlm_cmp_addr(nsm_addr(pos), sap))
-			continue;
-
-		atomic_inc(&pos->sm_count);
-		spin_unlock(&nsm_lock);
-		kfree(nsm);
-		dprintk("lockd: found nsm_handle for %s (%s), cnt %d\n",
-				pos->sm_name, pos->sm_addrbuf,
-				atomic_read(&pos->sm_count));
-		return pos;
-	}
+	new = NULL;
+	do {
+		spin_lock(&nsm_lock);
+
+		if (nsm_use_hostnames && hostname)
+			cached = nsm_lookup_hostname(hostname, hostname_len);
+		else
+			cached = nsm_lookup_addr(sap);
+
+		if (cached) {
+			atomic_inc(&cached->sm_count);
+			spin_unlock(&nsm_lock);
+			kfree(new);
+			dprintk("lockd: found nsm_handle for %s (%s), "
+					"cnt %d\n", cached->sm_name,
+					cached->sm_addrbuf,
+					atomic_read(&cached->sm_count));
+			return cached;
+		} else if (new) {
+			list_add(&new->sm_link, &nsm_handles);
+			spin_unlock(&nsm_lock);
+			dprintk("lockd: created nsm_handle for %s (%s)\n",
+					new->sm_name, new->sm_addrbuf);
+			return new;
+		}
 
-	if (nsm) {
-		list_add(&nsm->sm_link, &nsm_handles);
 		spin_unlock(&nsm_lock);
-		dprintk("lockd: created nsm_handle for %s (%s)\n",
-				nsm->sm_name, nsm->sm_addrbuf);
-		return nsm;
-	}
 
-	spin_unlock(&nsm_lock);
+		new = nsm_init_handle(sap, salen, hostname, hostname_len);
+	} while (new);
 
-	nsm = nsm_init_handle(sap, salen, hostname, hostname_len);
-	if (nsm == NULL)
-		return NULL;
-	goto retry;
+	return NULL;
 }
 
 /**

