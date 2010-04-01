From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/11] lockd: use sm_my_name for nsm_handle lookups
Date: Thu, 01 Apr 2010 15:03:51 -0400
Message-ID: <20100401190351.6395.70746.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758053Ab0DATDx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:03:53 -0400
Received: by mail-qy0-f173.google.com with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:03:53 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Have nsm_get_handle() distinguish between two nsm_handles that are the
same in every way except their sm_my_name field is different.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    2 +-
 fs/lockd/mon.c              |   28 +++++++++++++++++++---------
 include/linux/lockd/lockd.h |    3 ++-
 3 files changed, 22 insertions(+), 11 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 001d05b..7d3cd2e 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -366,7 +366,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	else {
 		host = NULL;
 		nsm = nsm_get_handle(ni->sap, ni->salen,
-					ni->hostname, ni->hostname_len);
+				ni->hostname, ni->hostname_len, NULL);
 		if (!nsm) {
 			dprintk("lockd: nlm_lookup_host failed; "
 				"no nsm handle\n");
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index e470038..d4b9cb3 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 
+#include <asm/string.h>
 #include <asm/unaligned.h>
 
 #define NLMDBG_FACILITY		NLMDBG_MONITOR
@@ -344,23 +345,27 @@ void nsm_unmonitor(const struct nlm_host *host)
 }
 
 static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
-					      const size_t len)
+					      const size_t len,
+					      const char *my_name)
 {
 	struct nsm_handle *nsm;
 
 	list_for_each_entry(nsm, &nsm_handles, sm_link)
 		if (strlen(nsm->sm_name) == len &&
-		    memcmp(nsm->sm_name, hostname, len) == 0)
+		    memcmp(nsm->sm_name, hostname, len) == 0 &&
+		    strcmp(my_name, nsm->sm_my_name) == 0)
 			return nsm;
 	return NULL;
 }
 
-static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
+static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap,
+					  const char *my_name)
 {
 	struct nsm_handle *nsm;
 
 	list_for_each_entry(nsm, &nsm_handles, sm_link)
-		if (rpc_cmp_addr(nsm_addr(nsm), sap))
+		if (rpc_cmp_addr(nsm_addr(nsm), sap) &&
+		    strcmp(my_name, nsm->sm_my_name) == 0)
 			return nsm;
 	return NULL;
 }
@@ -474,6 +479,8 @@ out:
  * @salen: length of socket address
  * @hostname: pointer to C string containing hostname to find
  * @hostname_len: length of C string
+ * @my_name: pointer to '\0'-terminated C string containing
+ *			hostname of local system, or NULL
  *
  * Behavior is modulated by the global nsm_use_hostnames variable.
  *
@@ -484,7 +491,8 @@ out:
  */
 struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 				  const size_t salen, const char *hostname,
-				  const size_t hostname_len)
+				  const size_t hostname_len,
+				  const char *my_name)
 {
 	struct nsm_handle *cached, *new = NULL;
 
@@ -497,13 +505,16 @@ struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 		return NULL;
 	}
 
+	if (my_name == NULL)
+		my_name = (const char *)init_utsname()->nodename;
+
 retry:
 	spin_lock(&nsm_lock);
 
 	if (nsm_use_hostnames && hostname != NULL)
-		cached = nsm_lookup_hostname(hostname, hostname_len);
+		cached = nsm_lookup_hostname(hostname, hostname_len, my_name);
 	else
-		cached = nsm_lookup_addr(sap);
+		cached = nsm_lookup_addr(sap, my_name);
 
 	if (cached != NULL) {
 		atomic_inc(&cached->sm_count);
@@ -526,8 +537,7 @@ retry:
 
 	spin_unlock(&nsm_lock);
 
-	new = nsm_create_handle(sap, salen, hostname, hostname_len,
-						init_utsname()->nodename);
+	new = nsm_create_handle(sap, salen, hostname, hostname_len, my_name);
 	if (unlikely(new == NULL))
 		return NULL;
 	goto retry;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 9e5da26..a19bdde 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -251,7 +251,8 @@ void		  nsm_unmonitor(const struct nlm_host *host);
 struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 					const size_t salen,
 					const char *hostname,
-					const size_t hostname_len);
+					const size_t hostname_len,
+					const char *my_name);
 struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 void		  nsm_release(struct nsm_handle *nsm);
 

