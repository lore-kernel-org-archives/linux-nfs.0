From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/11] lockd: Add "reboot" attribute to nsm_handles
Date: Thu, 01 Apr 2010 15:03:33 -0400
Message-ID: <20100401190333.6395.58790.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044Ab0DATDg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:03:36 -0400
Received: by mail-qy0-f173.google.com with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:03:35 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
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
index dc185e1..690c236 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -147,6 +147,23 @@ static ssize_t refcount_show(struct nsm_handle *nsm, char *buf)
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
@@ -163,6 +180,8 @@ static struct nsm_handle_attr rpcparms_attr	= __ATTR_RO(rpcparms);
 static struct nsm_handle_attr status_attr	= __ATTR_RO(status);
 static struct nsm_handle_attr sticky_attr	= __ATTR_RO(sticky);
 static struct nsm_handle_attr refcount_attr	= __ATTR_RO(refcount);
+static struct nsm_handle_attr reboot_attr	= __ATTR(reboot,
+			S_IWUSR | S_IRUSR, reboot_show, reboot_store);
 
 static struct attribute *nsm_kobj_attrs[] = {
 	&mon_name_attr.attr,
@@ -172,6 +191,7 @@ static struct attribute *nsm_kobj_attrs[] = {
 	&status_attr.attr,
 	&sticky_attr.attr,
 	&refcount_attr.attr,
+	&reboot_attr.attr,
 	NULL,
 };
 

