Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f52.google.com ([74.125.83.52]:63781 "EHLO
	mail-gw0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757463Ab1INTuh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Sep 2011 15:50:37 -0400
Received: by gwb1 with SMTP id 1so579133gwb.11
        for <linux-nfs@vger.kernel.org>; Wed, 14 Sep 2011 12:50:36 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NLM: Allow upper layers to select my_name
To: skinsbursky@parallels.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 14 Sep 2011 15:50:34 -0400
Message-ID: <20110914195033.3008.69362.stgit@matisse.1015granger.net>
In-Reply-To: <20110914194646.3008.77560.stgit@matisse.1015granger.net>
References: <20110914194646.3008.77560.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Pre-requisite to allow upper layers to specify the my_name argument of
SM_MON upcalls.  It's never a good idea to code policy decisions into
a low-level XDR function.

Record the my_name argument when an nsm_handle is created, and use
that in the XDR layer instead of simply using utsname.  This exposes
the ability to set unique my_name strings to host.c, but should result
in no behavior changes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    7 ++++++-
 fs/lockd/mon.c              |   36 +++++++++++++++++++++++++-----------
 include/linux/lockd/lockd.h |    4 +++-
 3 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index b7c99bf..cdbc633 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -16,6 +16,7 @@
 #include <linux/sunrpc/svc.h>
 #include <linux/lockd/lockd.h>
 #include <linux/mutex.h>
+#include <linux/utsname.h>
 
 #include <net/ipv6.h>
 
@@ -51,6 +52,7 @@ struct nlm_lookup_host_info {
 	const size_t		salen;		/* it's length */
 	const unsigned short	protocol;	/* transport to search for*/
 	const u32		version;	/* NLM version to search for */
+	const char		*localname;	/* local hostname */
 	const char		*hostname;	/* remote's hostname */
 	const size_t		hostname_len;	/* it's length */
 	const int		noresvport;	/* use non-priv port */
@@ -112,7 +114,8 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 	else {
 		host = NULL;
 		nsm = nsm_get_handle(ni->sap, ni->salen,
-					ni->hostname, ni->hostname_len);
+					ni->hostname, ni->hostname_len,
+					ni->localname);
 		if (unlikely(nsm == NULL)) {
 			dprintk("lockd: %s failed; no nsm handle\n",
 				__func__);
@@ -214,6 +217,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 		.salen		= salen,
 		.protocol	= protocol,
 		.version	= version,
+		.localname	= utsname()->nodename,
 		.hostname	= hostname,
 		.hostname_len	= strlen(hostname),
 		.noresvport	= noresvport,
@@ -330,6 +334,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 		.salen		= rqstp->rq_addrlen,
 		.protocol	= rqstp->rq_prot,
 		.version	= rqstp->rq_vers,
+		.localname	= utsname()->nodename,
 		.hostname	= hostname,
 		.hostname_len	= hostname_len,
 	};
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 23d7451..cc9c08b 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -7,7 +7,6 @@
  */
 
 #include <linux/types.h>
-#include <linux/utsname.h>
 #include <linux/kernel.h>
 #include <linux/ktime.h>
 #include <linux/slab.h>
@@ -40,6 +39,7 @@ struct nsm_args {
 	u32			proc;
 
 	char			*mon_name;
+	char			*my_name;
 };
 
 struct nsm_res {
@@ -93,6 +93,7 @@ static int nsm_mon_unmon(struct nsm_handle *nsm, u32 proc, struct nsm_res *res)
 		.vers		= 3,
 		.proc		= NLMPROC_NSM_NOTIFY,
 		.mon_name	= nsm->sm_mon_name,
+		.my_name	= nsm->sm_my_name,
 	};
 	struct rpc_message msg = {
 		.rpc_argp	= &args,
@@ -259,27 +260,36 @@ static void nsm_init_private(struct nsm_handle *nsm)
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 					    const size_t salen,
 					    const char *hostname,
-					    const size_t hostname_len)
+					    const size_t hostname_len,
+					    const char *my_name)
 {
 	struct nsm_handle *new;
 
-	new = kzalloc(sizeof(*new) + hostname_len + 1, GFP_KERNEL);
+	new = kzalloc(sizeof(*new), GFP_KERNEL);
 	if (unlikely(new == NULL))
 		return NULL;
 
+	new->sm_name = kstrndup(hostname, hostname_len, GFP_KERNEL);
+	if (unlikely(new->sm_name == NULL)) {
+		kfree(new);
+		return NULL;
+	}
+
+	new->sm_my_name = kstrdup(my_name, GFP_KERNEL);
+	if (unlikely(new->sm_my_name == NULL)) {
+		kfree(new->sm_name);
+		kfree(new);
+		return NULL;
+	}
+
 	atomic_set(&new->sm_count, 1);
-	new->sm_name = (char *)(new + 1);
 	memcpy(nsm_addr(new), sap, salen);
 	new->sm_addrlen = salen;
 	nsm_init_private(new);
-
 	if (rpc_ntop(nsm_addr(new), new->sm_addrbuf,
 					sizeof(new->sm_addrbuf)) == 0)
 		(void)snprintf(new->sm_addrbuf, sizeof(new->sm_addrbuf),
 				"unsupported address family");
-	memcpy(new->sm_name, hostname, hostname_len);
-	new->sm_name[hostname_len] = '\0';
-
 	return new;
 }
 
@@ -289,6 +299,7 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
  * @salen: length of socket address
  * @hostname: pointer to C string containing hostname to find
  * @hostname_len: length of C string
+ * @my_name: pointer to C string containing my_name to use for SM_MON calls
  *
  * Behavior is modulated by the global nsm_use_hostnames variable.
  *
@@ -299,7 +310,8 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
  */
 struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 				  const size_t salen, const char *hostname,
-				  const size_t hostname_len)
+				  const size_t hostname_len,
+				  const char *my_name)
 {
 	struct nsm_handle *cached, *new = NULL;
 
@@ -341,7 +353,7 @@ retry:
 
 	spin_unlock(&nsm_lock);
 
-	new = nsm_create_handle(sap, salen, hostname, hostname_len);
+	new = nsm_create_handle(sap, salen, hostname, hostname_len, my_name);
 	if (unlikely(new == NULL))
 		return NULL;
 	goto retry;
@@ -390,6 +402,8 @@ void nsm_release(struct nsm_handle *nsm)
 		spin_unlock(&nsm_lock);
 		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
 				nsm->sm_name, nsm->sm_addrbuf);
+		kfree(nsm->sm_my_name);
+		kfree(nsm->sm_name);
 		kfree(nsm);
 	}
 }
@@ -429,7 +443,7 @@ static void encode_my_id(struct xdr_stream *xdr, const struct nsm_args *argp)
 {
 	__be32 *p;
 
-	encode_nsm_string(xdr, utsname()->nodename);
+	encode_nsm_string(xdr, argp->my_name);
 	p = xdr_reserve_space(xdr, 4 + 4 + 4);
 	*p++ = cpu_to_be32(argp->prog);
 	*p++ = cpu_to_be32(argp->vers);
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index ff9abff..daf1195 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -81,6 +81,7 @@ struct nsm_handle {
 	struct list_head	sm_link;
 	atomic_t		sm_count;
 	char			*sm_mon_name;
+	char			*sm_my_name;
 	char			*sm_name;
 	struct sockaddr_storage	sm_addr;
 	size_t			sm_addrlen;
@@ -243,7 +244,8 @@ void		  nsm_unmonitor(const struct nlm_host *host);
 struct nsm_handle *nsm_get_handle(const struct sockaddr *sap,
 					const size_t salen,
 					const char *hostname,
-					const size_t hostname_len);
+					const size_t hostname_len,
+					const char *my_name);
 struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info);
 void		  nsm_release(struct nsm_handle *nsm);
 

