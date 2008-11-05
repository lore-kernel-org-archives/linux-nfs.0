From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 13/18] NSM: Replace IP address as our nlm_reboot lookup key
Date: Wed, 05 Nov 2008 12:20:57 -0500
Message-ID: <20081105172056.6773.89970.stgit@ingres.1015granger.net>
References: <20081105171300.6773.40121.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:34279 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbYKERVY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2008 12:21:24 -0500
In-Reply-To: <20081105171300.6773.40121.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NLM provides file locking services for NFS files.  Part of this
service includes a second protocol, known as NSM, which monitors host
reboots.  NLM uses this service to determine when to release locks or
enter a grace period after a client or server reboots.

The NLM service (lockd in the Linux kernel) contacts its local NSM
service (rpc.statd in Linux user space) via a special protocol to
request a callback when a particular remote peer reboots.  To identify
the remote peer, the NLM service constructs a cookie that it passes in
the request.  The NSM service passes that cookie back to the NLM
service when it is notified that the given remote peer has indeed
rebooted.

Currently on Linux, the cookie is the raw 32-bit IPv4 address of the
remote peer.  To support IPv6 addresses, which are larger, we could
use all 16 bytes of the cookie to represent a full IPv6 address,
although we still can't represent an IPv6 address with a scope ID in
just 16 bytes.

Instead, to avoid the need for future changes to support additional
address types, we'll use a manufactured value for the cookie, and use
that to find the corresponding nsm_handle struct in the kernel during
the notification callback.

This should provide complete support in the kernel's NSM
implementation for IPv6 hosts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   32 ++++++++++++++++++++++++++++----
 1 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 612f0ea..692edad 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -203,13 +203,37 @@ static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
  * passed to our statd via NSMPROC_MON, and returned via
  * NLMPROC_SM_NOTIFY, in the "priv" field of these requests.
  *
- * Linux provides the raw IP address of the monitored host,
- * left in network byte order.
+ * These cookies are not required to last across reboots, but they
+ * must be unique for each nsm_handle during the same boot.
+ * Uniqueness is guaranteed by using the memory address of the
+ * handle data structure.  Such memory addresses are only reused if
+ * the nsm_handle is destroyed by an NSMPROC_UNMON.
+ *
+ * For safety, the cookie returned via NLM_SM_NOTIFY is treated as
+ * an opaque -- the address is not used directly to access the
+ * associated nsm_handle.  This also means it would be simple to
+ * change the cookie generator again at some later point without
+ * having to mess with the nsm_handle lookup code.
+ *
+ * A time stamp is added in case rpc.statd returns a stale cookie.
+ * That would be a bug in rpc.statd, but it would result in some
+ * client losing its locks inappropriately, which we would like to
+ * avoid.
+ *
+ * The cookies are exposed only to local user space via loopback.
+ * They do not appear on the physical network.  If we want greater
+ * security, however, nsm_init_private() could perform a one-way
+ * hash to obscure the contents of the cookie.
  */
 static void nsm_init_private(struct nsm_handle *nsm)
 {
-	__be32 *p = (__be32 *)&nsm->sm_priv.data;
-	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
+	u64 *p = (u64 *)&nsm->sm_priv.data;
+	struct timeval tv;
+
+	do_gettimeofday(&tv);
+
+	*p++ = (unsigned long)nsm;
+	*p = timeval_to_ns(&tv);
 }
 
 /**

