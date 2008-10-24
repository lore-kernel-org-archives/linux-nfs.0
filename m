From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/14] NSM: Replace IP address as our nlm_reboot lookup key
Date: Fri, 24 Oct 2008 14:11:09 -0400
Message-ID: <20081024181108.23810.44591.stgit@ingres.1015granger.net>
References: <20081024180150.23810.9718.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:41801 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368AbYJXSL1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 24 Oct 2008 14:11:27 -0400
Received: from agmgw2.us.oracle.com (agmgw2.us.oracle.com [152.68.180.213])
	by agminet01.oracle.com (Switch-3.2.4/Switch-3.1.7) with ESMTP id m9OIBMru010035
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 13:11:22 -0500
Received: from acsmt357.oracle.com (acsmt357.oracle.com [141.146.40.157])
	by agmgw2.us.oracle.com (Switch-3.2.0/Switch-3.2.0) with ESMTP id m9OI6qoe026743
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 12:11:20 -0600
Received: from ingres.1015granger.net (ingres.1015granger.net [127.0.0.1])
	by ingres.1015granger.net (8.14.2/8.14.2) with ESMTP id m9OIB9l7024021
	for <linux-nfs@vger.kernel.org>; Fri, 24 Oct 2008 14:11:09 -0400
In-Reply-To: <20081024180150.23810.9718.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
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

 fs/lockd/mon.c |   20 ++++++++++++++++----
 1 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index c38ef20..9fbeca2 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -129,13 +129,25 @@ static struct nsm_handle *nsm_lookup_hostname(const char *hostname,
  * passed to our statd via SM_MON, and returned via NLM_SM_NOTIFY,
  * in the "priv" field of these requests.
  *
- * Linux provides the raw IP address of the monitored host,
- * left in network byte order.
+ * These cookies do not have to last across reboots, but they must
+ * be unique for each nsm_handle.  Uniqueness is guaranteed by
+ * using the memory address of the handle data structure.
+ * 
+ * The cookies are exposed only to local user space via loopback.
+ * They do not appear on the physical network.  If we want greater
+ * security, we could add more bits (say, by appending jiffies)
+ * then perform a one-way hash on the address.
+ *
+ * For safety, the cookie returned via NLM_SM_NOTIFY is treated as
+ * an opaque -- the address is not used directly to find its
+ * associated handle.  This also means it would be simple to change
+ * the cookie generator again at some later point without having to
+ * mess with the nsm_handle lookup code.
  */
 static void nsm_init_private(struct nsm_handle *nsm)
 {
-	__be32 *p = (__be32 *)&nsm->sm_priv.data;
-	*p = nsm_addr_in(nsm)->sin_addr.s_addr;
+	__be64 *p = (__be64 *)&nsm->sm_priv.data;
+	*p = (unsigned long)nsm;
 }
 
 /**

