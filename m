From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 14/14] NSM: Use same helpers in nsm_get_handle() and
	nsm_lookup_rebooted()
Date: Fri, 24 Oct 2008 14:11:31 -0400
Message-ID: <20081024181131.23810.62161.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41960 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754151AbYJXSMD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:12:03 -0400
Received: from agmgw1.us.oracle.com (agmgw1.us.oracle.com [152.68.180.212])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIC1cc010683
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:12:01 -0500
Received: from acsmt354.oracle.com (acsmt354.oracle.com [141.146.40.154])
	by agmgw1.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9O7nOQ1002814
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:12:00 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIBVgJ024063
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:11:31 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

One last clean up: refactor the nsm_get_handle() function so it uses
the same lookup helpers as the newly added nsm_reboot_lookup()
function.

This also makes it easier if some day we want to use a more
sophisticated lookup algorithm than a linked list search for finding
nsm_handles.  It's likely that we would use a different data structure
for each of the different lookups (hostname, priv, or IP address) and
now these are already split into different functions.

There is an additional micro-optimization here.  This change moves the
"hostname & nsm_use_hostnames" test out of the list_for_each_entry()
clause in nsm_get_handle(), since it is loop-invariant.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   97 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 58 insertions(+), 39 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index d564b6f..3180efc 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -122,6 +122,16 @@ static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
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
  * passed to our statd via SM_MON, and returned via NLM_SM_NOTIFY,
@@ -148,6 +158,30 @@ static void nsm_init_private(struct nsm_handle *nsm)
 	*p = (unsigned long)nsm;
 }
 
+static struct nsm_handle *nsm_init_handle(const struct sockaddr *sap,
+					  const size_t salen,
+					  const char *hostname,
+					  const size_t hostname_len)
+{
+	struct nsm_handle *nsm;
+
+	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
+	if (nsm) {
+		memcpy(nsm_addr(nsm), sap, salen);
+		nsm->sm_addrlen = salen;
+		nsm->sm_name = (char *) (nsm + 1);
+		memcpy(nsm->sm_name, hostname, hostname_len);
+		nsm->sm_name[hostname_len] = '\0';
+		nsm_init_private(nsm);
+		nlm_display_address((struct sockaddr *)&nsm->sm_addr,
+					nsm->sm_addrbuf,
+					sizeof(nsm->sm_addrbuf));
+		atomic_set(&nsm->sm_count, 1);
+	}
+
+	return nsm;
+}
+
 /**
  * nsm_get_handle - Find a cached nsm_handle by name or address
  * @sap: pointer to socket address of handle to find
@@ -160,8 +194,7 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 				  const size_t salen, const char *hostname,
 				  const size_t hostname_len)
 {
-	struct nsm_handle *nsm = NULL;
-	struct nsm_handle *pos;
+	struct nsm_handle *new, *cached;
 
 	if (!sap)
 		return NULL;
@@ -175,45 +208,31 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
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
-		kfree(nsm);
-		nsm = pos;
-		goto found;
-	}
-	if (nsm) {
-		list_add(&nsm->sm_link, &nsm_handles);
-		goto found;
-	}
-	spin_unlock(&nsm_lock);
+	new = NULL;
+	do {
+		spin_lock(&nsm_lock);
 
-	nsm = kzalloc(sizeof(*nsm) + hostname_len + 1, GFP_KERNEL);
-	if (nsm == NULL)
-		return NULL;
+		if (nsm_use_hostnames && hostname)
+			cached = nsm_lookup_hostname(hostname, hostname_len);
+		else
+			cached = nsm_lookup_addr(sap);
+		if (cached) {
+			atomic_inc(&cached->sm_count);
+			spin_unlock(&nsm_lock);
+			kfree(new);
+			return cached;
+		} else if (new) {
+			list_add(&new->sm_link, &nsm_handles);
+			spin_unlock(&nsm_lock);
+			return new;
+		}
 
-	memcpy(nsm_addr(nsm), sap, salen);
-	nsm->sm_addrlen = salen;
-	nsm->sm_name = (char *) (nsm + 1);
-	memcpy(nsm->sm_name, hostname, hostname_len);
-	nsm->sm_name[hostname_len] = '\0';
-	nsm_init_private(nsm);
-	nlm_display_address((struct sockaddr *)&nsm->sm_addr,
-				nsm->sm_addrbuf, sizeof(nsm->sm_addrbuf));
-	atomic_set(&nsm->sm_count, 1);
-	goto retry;
-
-found:
-	spin_unlock(&nsm_lock);
-	return nsm;
+		spin_unlock(&nsm_lock);
+
+		new = nsm_init_handle(sap, salen, hostname, hostname_len);
+	} while (new);
+
+	return NULL;
 }
 
 /**

