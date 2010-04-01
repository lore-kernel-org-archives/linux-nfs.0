From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/11] lockd: Add attributes to /sys/fs/lockd/hosts/*/
Date: Thu, 01 Apr 2010 15:02:57 -0400
Message-ID: <20100401190257.6395.49271.stgit@localhost.localdomain>
References: <20100401183724.6395.60353.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qy0-f173.google.com ([209.85.221.173]:62450 "EHLO
	mail-qy0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755486Ab0DATC7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Apr 2010 15:02:59 -0400
Received: by mail-qy0-f173.google.com with SMTP id 4so1698690qyk.24
        for <linux-nfs@vger.kernel.org>; Thu, 01 Apr 2010 12:02:59 -0700 (PDT)
In-Reply-To: <20100401183724.6395.60353.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Expose fields in each nlm_host cache entry via files under
/sys/fs/lockd/hosts/{client,server}/*/.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c |  137 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 137 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 2414ef7..b15579b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -83,7 +83,144 @@ static struct sysfs_ops nlm_kobj_sysfs_ops = {
 	.store		= nlm_kobj_store,
 };
 
+static ssize_t address_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", host->h_addrbuf);
+}
+
+static ssize_t source_address_show(struct nlm_host *host, char *buf)
+{
+	struct sockaddr *sap = (struct sockaddr *)(char *)&host->h_srcaddr;
+	switch (sap->sa_family) {
+	case AF_UNSPEC:
+		return snprintf(buf, PAGE_SIZE, "unspecified address\n");
+	case AF_INET:
+		return snprintf(buf, PAGE_SIZE, "%pI4\n", sap);
+	case AF_INET6:
+		return snprintf(buf, PAGE_SIZE, "%pI6c\n", sap);
+	}
+	return snprintf(buf, PAGE_SIZE, "unrecognized address\n");
+}
+
+static ssize_t name_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", host->h_name);
+}
+
+static ssize_t nlm_version_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u\n", host->h_version);
+}
+
+static ssize_t transport_show(struct nlm_host *host, char *buf)
+{
+	switch (host->h_proto) {
+	case IPPROTO_UDP:
+		return snprintf(buf, PAGE_SIZE, "udp\n");
+	case IPPROTO_TCP:
+		return snprintf(buf, PAGE_SIZE, "tcp\n");
+	}
+	return snprintf(buf, PAGE_SIZE, "unknown\n");
+}
+
+static ssize_t reclaiming_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+				host->h_reclaiming ? "in progress" : "no");
+}
+
+static ssize_t peer_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+				host->h_server ? "client" : "server");
+}
+
+static ssize_t resvport_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+				host->h_noresvport ? "no" : "yes");
+}
+
+static ssize_t in_use_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+				host->h_inuse ? "yes" : "no");
+}
+
+static ssize_t pseudo_state_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u\n", host->h_state);
+}
+
+static ssize_t nsm_state_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u\n", host->h_nsmstate);
+}
+
+static ssize_t pidcount_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u\n", host->h_pidcount);
+}
+
+static ssize_t refcount_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n", atomic_read(&host->h_count));
+}
+
+static ssize_t nextrebind_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%lu seconds \n",
+				(host->h_nextrebind - jiffies) / HZ);
+}
+
+static ssize_t expires_show(struct nlm_host *host, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%lu seconds\n",
+				(host->h_expires - jiffies) / HZ);
+}
+
+#ifdef __ATTR_RO
+#undef __ATTR_RO
+#endif
+
+#define __ATTR_RO(_name) { \
+	.attr	= { .name = __stringify(_name), .mode = S_IRUSR, }, \
+ 	.show	= _name##_show,                                 \
+}
+
+static struct nlm_host_attr address_attr	= __ATTR_RO(address);
+static struct nlm_host_attr source_address_attr	= __ATTR_RO(source_address);
+static struct nlm_host_attr name_attr		= __ATTR_RO(name);
+static struct nlm_host_attr nlm_version_attr	= __ATTR_RO(nlm_version);
+static struct nlm_host_attr transport_attr	= __ATTR_RO(transport);
+static struct nlm_host_attr reclaiming_attr	= __ATTR_RO(reclaiming);
+static struct nlm_host_attr peer_attr		= __ATTR_RO(peer);
+static struct nlm_host_attr resvport_attr	= __ATTR_RO(resvport);
+static struct nlm_host_attr in_use_attr		= __ATTR_RO(in_use);
+static struct nlm_host_attr pseudo_state_attr	= __ATTR_RO(pseudo_state);
+static struct nlm_host_attr nsm_state_attr	= __ATTR_RO(nsm_state);
+static struct nlm_host_attr pidcount_attr	= __ATTR_RO(pidcount);
+static struct nlm_host_attr refcount_attr	= __ATTR_RO(refcount);
+static struct nlm_host_attr nextrebind_attr	= __ATTR_RO(nextrebind);
+static struct nlm_host_attr expires_attr	= __ATTR_RO(expires);
+
 static struct attribute *nlm_kobj_attrs[] = {
+	&address_attr.attr,
+	&source_address_attr.attr,
+	&name_attr.attr,
+	&nlm_version_attr.attr,
+	&transport_attr.attr,
+	&reclaiming_attr.attr,
+	&peer_attr.attr,
+	&resvport_attr.attr,
+	&in_use_attr.attr,
+	&pseudo_state_attr.attr,
+	&nsm_state_attr.attr,
+	&pidcount_attr.attr,
+	&refcount_attr.attr,
+	&nextrebind_attr.attr,
+	&expires_attr.attr,
+	NULL,
 };
 
 static struct kobj_type nlm_host_ktype = {

