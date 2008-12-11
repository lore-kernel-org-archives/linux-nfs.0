From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/11] NSM: Replace IP address as our nlm_reboot lookup key
Date: Thu, 11 Dec 2008 17:56:07 -0500
Message-ID: <20081211225606.21468.6706.stgit@ingres.1015granger.net>
References: <20081211224543.21468.8939.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:40058 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932066AbYLKW4y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2008 17:56:54 -0500
In-Reply-To: <20081211224543.21468.8939.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NLM provides file locking services for NFS files.  Part of this service
includes a second protocol, known as NSM, which is a reboot
notification service.  NLM uses this service to determine when to
reclaim locks or enter a grace period after a client or server reboots.

The NLM service (implemented by lockd in the Linux kernel) contacts
the local NSM service (implemented by rpc.statd in Linux user space)
via NSM protocol upcalls to register a callback when a particular
remote peer reboots.

To match the callback to the correct remote peer, the NLM service
constructs a cookie that it passes in the request.  The NSM service
passes that cookie back to the NLM service when it is notified that
the given remote peer has indeed rebooted.

Currently on Linux, the cookie is the raw 32-bit IPv4 address of the
remote peer.  To support IPv6 addresses, which are larger, we could
use all 16 bytes of the cookie to represent a full IPv6 address,
although we still can't represent an IPv6 address with a scope ID in
just 16 bytes.

Instead, to avoid the need for future changes to support additional
address types, we'll use a manufactured value for the cookie, and use
that to find the corresponding nsm_handle struct in the kernel during
the NLMPROC_SM_NOTIFY callback.

This should provide complete support in the kernel's NSM
implementation for IPv6 hosts, while remaining backwards compatible
with older rpc.statd implementations.

Note we also deal with another case where nsm_use_hostnames can change
while there are outstanding notifications, possibly resulting in the
loss of reboot notifications.  After this patch, the priv cookie is
always used to lookup rebooted hosts in the kernel.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   28 +++++++++++++++++++---------
 1 files changed, 19 insertions(+), 9 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 6a48b3c..e3fe6d7 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -9,6 +9,8 @@
 #include <linux/types.h>
 #include <linux/utsname.h>
 #include <linux/kernel.h>
+#include <linux/ktime.h>
+
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/xprtsock.h>
 #include <linux/sunrpc/svc.h>
@@ -241,13 +243,25 @@ static struct nsm_handle *nsm_lookup_priv(const struct nsm_private *priv)
  * returned via NLMPROC_SM_NOTIFY, in the "priv" field of these
  * requests.
  *
- * Linux provides the raw IP address of the monitored host,
- * left in network byte order.
+ * The NSM protocol requires that these cookies be unique while the
+ * system is running.  We prefer a stronger requirement of making them
+ * unique across reboots.  If user space bugs cause a stale cookie to
+ * be sent to the kernel, it could cause the wrong host to lose its
+ * lock state if cookies were not unique across reboots.
+ *
+ * The cookies are exposed only to local user space via loopback.  They
+ * do not appear on the physical network.  If we want greater security
+ * for some reason, nsm_init_private() could perform a one-way hash to
+ * obscure the contents of the cookie.
  */
 static void nsm_init_private(struct nsm_handle *nsm)
 {
-	__be32 *p = (__be32 *)&nsm->sm_priv.data;
-	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
+	u64 *p = (u64 *)&nsm->sm_priv.data;
+	struct timespec ts;
+
+	ktime_get_ts(&ts);
+	*p++ = timespec_to_ns(&ts);
+	*p = (unsigned long)nsm;
 }
 
 static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
@@ -352,11 +366,7 @@ struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
 
 	spin_lock(&nsm_lock);
 
-	if (nsm_use_hostnames && info->mon != NULL)
-		cached = nsm_lookup_hostname(info->mon, info->len);
-	else
-		cached = nsm_lookup_priv(&info->priv);
-
+	cached = nsm_lookup_priv(&info->priv);
 	if (unlikely(cached == NULL)) {
 		spin_unlock(&nsm_lock);
 		dprintk("lockd: never saw rebooted peer '%.*s' before\n",

