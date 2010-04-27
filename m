From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/9] lockd: Add /sys/fs/lockd/hosts/*
Date: Tue, 27 Apr 2010 14:58:51 -0400
Message-ID: <20100427185850.29074.45668.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f204.google.com ([209.85.222.204]:55014 "EHLO
	mail-pz0-f204.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755996Ab0D0S6w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:58:52 -0400
Received: by mail-pz0-f204.google.com with SMTP id 42so9187550pzk.4
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:58:52 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Populate the new hosts/ directory as nlm_hosts come and go.
The new subdirectories are named after the IP address, transport
protocol, and NLM protocol version of each entry in the nlm_hosts
cache.

Introduce a simple-minded approach to managing the kref in the
nlm_host's kobject.  Unfortunately the existing nlm_host reference
counting is more complex than other typical kref usage in the kernel,
so we retain the h_count field.  The kref is always 1 until the
nlm_host is ready to be destroyed.


Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |   89 ++++++++++++++++++++++++++++++++++++++++++-
 include/linux/lockd/lockd.h |    1 
 2 files changed, 87 insertions(+), 3 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index be3f87c..2dce492 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -30,6 +30,7 @@ static unsigned long		next_gc;
 static int			nrhosts;
 static DEFINE_MUTEX(nlm_host_mutex);
 
+static void			nlm_kobj_release(struct kobject *kobj);
 static void			nlm_gc_hosts(void);
 
 struct nlm_lookup_host_info {
@@ -49,6 +50,48 @@ static struct kobject		*nlm_hosts_kobj;
 static struct kobject		*nlm_hosts_client_kobj;
 static struct kobject		*nlm_hosts_server_kobj;
 
+struct nlm_host_attr {
+	struct attribute	attr;
+	ssize_t (*show)(struct nlm_host *host, char *buf);
+	ssize_t (*store)(struct nlm_host *host, const char *buf, size_t count);
+};
+
+static ssize_t nlm_kobj_show(struct kobject *kobj, struct attribute *attr,
+			     char *buf)
+{
+	struct nlm_host_attr *hattr = container_of(attr,
+						struct nlm_host_attr, attr);
+	struct nlm_host *host = container_of(kobj, struct nlm_host, h_kobj);
+	if (hattr->show)
+		return hattr->show(host, buf);
+	return 0;
+}
+
+static ssize_t nlm_kobj_store(struct kobject *kobj, struct attribute *attr,
+			      const char *buf, size_t count)
+{
+	struct nlm_host_attr *hattr = container_of(attr,
+						struct nlm_host_attr, attr);
+	struct nlm_host *host = container_of(kobj, struct nlm_host, h_kobj);
+	if (hattr->store)
+		return hattr->store(host, buf, count);
+	return 0;
+}
+
+static struct sysfs_ops nlm_kobj_sysfs_ops = {
+	.show		= nlm_kobj_show,
+	.store		= nlm_kobj_store,
+};
+
+static struct attribute *nlm_kobj_attrs[] = {
+};
+
+static struct kobj_type nlm_host_ktype = {
+	.release		= nlm_kobj_release,
+	.sysfs_ops		= &nlm_kobj_sysfs_ops,
+	.default_attrs		= nlm_kobj_attrs,
+};
+
 /*
  * Hash function must work well on big- and little-endian platforms
  */
@@ -92,6 +135,35 @@ static unsigned int nlm_hash_address(const struct sockaddr *sap)
 }
 
 /*
+ * New kobjects are placed in either client/ or server/
+ * subdirectory and are named "ip-proto-vers".
+ */
+int nlm_add_kobject(struct nlm_host *host)
+{
+	struct kobject *parent;
+	char *proto_name;
+
+	parent = nlm_hosts_server_kobj;
+	if (host->h_server)
+		parent = nlm_hosts_client_kobj;
+
+	switch (host->h_proto) {
+	case IPPROTO_UDP:
+		proto_name = "udp";
+		break;
+	case IPPROTO_TCP:
+		proto_name = "tcp";
+		break;
+	default:
+		return -EPROTONOSUPPORT;
+	}
+
+	return kobject_init_and_add(&host->h_kobj, &nlm_host_ktype,
+				parent, "%s-%s-%u", host->h_addrbuf,
+				proto_name, host->h_version);
+}
+
+/*
  * Common host lookup routine for server & client
  */
 static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
@@ -100,6 +172,7 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 	struct nsm_handle *nsm = NULL;
+	int ret;
 
 	mutex_lock(&nlm_host_mutex);
 
@@ -191,6 +264,16 @@ static struct nlm_host *nlm_lookup_host(struct nlm_lookup_host_info *ni)
 	INIT_LIST_HEAD(&host->h_granted);
 	INIT_LIST_HEAD(&host->h_reclaim);
 
+	ret = nlm_add_kobject(host);
+	if (unlikely(ret != 0)) {
+		atomic_set(&host->h_count, 0);
+		kobject_put(&host->h_kobj);	/* releases nsm too */
+		dprintk("lockd: nlm_lookup_host "
+				"could not add nlm_host kobject\n");
+		host = NULL;
+		goto out;
+	}
+
 	nrhosts++;
 
 	dprintk("lockd: nlm_lookup_host created host %s\n",
@@ -204,9 +287,9 @@ out:
 /*
  * Destroy a host
  */
-static void
-nlm_destroy_host(struct nlm_host *host)
+static void nlm_kobj_release(struct kobject *kobj)
 {
+	struct nlm_host *host = container_of(kobj, struct nlm_host, h_kobj);
 	struct rpc_clnt	*clnt;
 
 	BUG_ON(!list_empty(&host->h_lockowners));
@@ -564,7 +647,7 @@ nlm_gc_hosts(void)
 			dprintk("lockd: delete host %s\n", host->h_name);
 			hlist_del_init(&host->h_hash);
 
-			nlm_destroy_host(host);
+			kobject_put(&host->h_kobj);
 			nrhosts--;
 		}
 	}
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 2d89cdb..bdb87a6 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -39,6 +39,7 @@
  * Lockd host handle (used both by the client and server personality).
  */
 struct nlm_host {
+	struct kobject		h_kobj;
 	struct hlist_node	h_hash;		/* doubly linked list */
 	struct sockaddr_storage	h_addr;		/* peer address */
 	size_t			h_addrlen;

