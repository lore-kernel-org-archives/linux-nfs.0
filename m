From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 9/9] lockd: Add "reboot" attribute to nsm_handles
Date: Tue, 27 Apr 2010 14:59:42 -0400
Message-ID: <20100427185941.29074.85779.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:65293 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756157Ab0D0S7s (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:59:48 -0400
Received: by pwj9 with SMTP id 9so9705055pwj.19
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:59:47 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There can be multiple nlm_host cache entries associated with one
remote peer, but there is only one nsm_handle per peer.  So the
right place to add an API to trigger lock recovery for a particular
remote peer is with the nsm_handle cache entry for that remote.

Add a "reboot" attribute to each subdirectory in nsm_handles/.

Writing the new NSM state into the peer's nsm_handles "reboot"
attribute invokes the kernel's lock recovery for that peer.  A user
space tool, for example, could be constructed so an administrator
can remove stale locks on an NFS server.

Note that this new API can replace statd's NLM downcalls as well.
Instead of calling a specified RPC program/version/procedure with
the new state number and the priv cookie, statd can walk through
/sys/fs/lockd looking for a directory named after the priv cookie,
and write the new state number into its "reboot" attribute.

Using this API instead of an RPC downcall would eliminate one lockd
dependency on IPv4 loopback.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 851ad59..80dccb6 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -148,6 +148,23 @@ static ssize_t refcount_show(struct nsm_handle *nsm, char *buf)
 			atomic_read(&nsm->sm_count));
 }
 
+static ssize_t reboot_show(struct nsm_handle *nsm, char *buf)
+{
+	return 0;
+}
+
+static ssize_t reboot_store(struct nsm_handle *nsm, 
+				const char *buf, size_t count)
+{
+	int state;
+
+	if (sscanf(buf, "%d", &state) != 1)
+		return -EINVAL;
+
+	nlm_host_rebooted_nsm(nsm, state);
+	return count;
+}
+
 #ifdef __ATTR_RO
 #undef __ATTR_RO
 #endif
@@ -164,6 +181,8 @@ static struct nsm_handle_attr rpcparms_attr	= __ATTR_RO(rpcparms);
 static struct nsm_handle_attr status_attr	= __ATTR_RO(status);
 static struct nsm_handle_attr sticky_attr	= __ATTR_RO(sticky);
 static struct nsm_handle_attr refcount_attr	= __ATTR_RO(refcount);
+static struct nsm_handle_attr reboot_attr	= __ATTR(reboot,
+			S_IWUSR | S_IRUSR, reboot_show, reboot_store);
 
 static struct attribute *nsm_kobj_attrs[] = {
 	&mon_name_attr.attr,
@@ -173,6 +192,7 @@ static struct attribute *nsm_kobj_attrs[] = {
 	&status_attr.attr,
 	&sticky_attr.attr,
 	&refcount_attr.attr,
+	&reboot_attr.attr,
 	NULL,
 };
 

