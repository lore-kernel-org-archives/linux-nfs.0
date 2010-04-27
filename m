From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/9] lockd: Add /sys/fs/lockd/nsm_handle/*
Date: Tue, 27 Apr 2010 14:59:23 -0400
Message-ID: <20100427185922.29074.59369.stgit@matisse.1015granger.net>
References: <20100427185411.29074.8889.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:50944 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756466Ab0D0S72 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Apr 2010 14:59:28 -0400
Received: by pxi17 with SMTP id 17so2365257pxi.19
        for <linux-nfs@vger.kernel.org>; Tue, 27 Apr 2010 11:59:27 -0700 (PDT)
In-Reply-To: <20100427185411.29074.8889.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Populate the new nsm_handle/ directory as nsm_handles come and go.
The entries are named by their priv cookie, which is always guaranteed
to be unique.

Like the nlm_hosts cache, the kref is fixed at one when the handle
is created, and goes to zero only when the handle is ready to be
destroyed.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/host.c             |    7 ++
 fs/lockd/mon.c              |  166 +++++++++++++++++++++++++++++++++++++++++--
 include/linux/lockd/lockd.h |    1 
 3 files changed, 166 insertions(+), 8 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index d6f3141..20dab62 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -279,6 +279,7 @@ int nlm_add_kobject(struct nlm_host *host)
 {
 	struct kobject *parent;
 	char *proto_name;
+	int ret;
 
 	parent = nlm_hosts_server_kobj;
 	if (host->h_server)
@@ -295,9 +296,13 @@ int nlm_add_kobject(struct nlm_host *host)
 		return -EPROTONOSUPPORT;
 	}
 
-	return kobject_init_and_add(&host->h_kobj, &nlm_host_ktype,
+	ret = kobject_init_and_add(&host->h_kobj, &nlm_host_ktype,
 				parent, "%s-%s-%u", host->h_addrbuf,
 				proto_name, host->h_version);
+	if (likely(ret == 0))
+		ret = sysfs_create_link(&host->h_kobj,
+				&host->h_nsmhandle->sm_kobj, "nsm_handle");
+	return ret;
 }
 
 /*
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 6e16a28..851ad59 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -59,6 +59,129 @@ int	__read_mostly		nsm_use_hostnames;
 
 static struct kobject		*nsm_handles_kobj;
 
+struct nsm_handle_attr {
+	struct attribute	attr;
+	ssize_t (*show)(struct nsm_handle *nsm, char *buf);
+	ssize_t (*store)(struct nsm_handle *nsm, const char *buf, size_t count);
+};
+
+static ssize_t nsm_kobj_show(struct kobject *kobj, struct attribute *attr,
+			     char *buf)
+{
+	struct nsm_handle_attr *nattr = container_of(attr,
+						struct nsm_handle_attr, attr);
+	struct nsm_handle *nsm = container_of(kobj, struct nsm_handle, sm_kobj);
+	if (nattr->show)
+		return nattr->show(nsm, buf);
+	return 0;
+}
+
+static ssize_t nsm_kobj_store(struct kobject *kobj, struct attribute *attr,
+			      const char *buf, size_t count)
+{
+	struct nsm_handle_attr *nattr = container_of(attr,
+						struct nsm_handle_attr, attr);
+	struct nsm_handle *nsm = container_of(kobj, struct nsm_handle, sm_kobj);
+	if (nattr->store)
+		return nattr->store(nsm, buf, count);
+	return 0;
+}
+
+static void nsm_kobj_release(struct kobject *kobj)
+{
+	struct nsm_handle *nsm = container_of(kobj,
+					struct nsm_handle, sm_kobj);
+
+	dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
+			nsm->sm_name, nsm->sm_addrbuf);
+	kfree(nsm);
+}
+
+static struct sysfs_ops nsm_kobj_sysfs_ops = {
+	.show		= nsm_kobj_show,
+	.store		= nsm_kobj_store,
+};
+
+static ssize_t mon_name_show(struct nsm_handle *nsm, char *buf)
+{
+	char *mon_name = nsm->sm_mon_name;
+
+	/* When this host is unmonitored, sm_mon_name is NULL,
+	 * so make up something reasonable. */
+	if (mon_name == NULL)
+		mon_name = nsm_use_hostnames ? nsm->sm_name : nsm->sm_addrbuf;
+
+	return snprintf(buf, PAGE_SIZE, "%s\n", mon_name);
+}
+
+static ssize_t my_name_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", utsname()->nodename);
+}
+
+static ssize_t address_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n", nsm->sm_addrbuf);
+}
+
+static ssize_t rpcparms_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%u %u %u\n",
+			NLM_PROGRAM, 3, NLMPROC_NSM_NOTIFY);
+}
+
+static ssize_t status_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%smonitored\n",
+			nsm->sm_monitored ? "" : "un" );
+}
+
+static ssize_t sticky_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%s\n",
+			nsm->sm_sticky ? "yes" : "no" );
+}
+
+static ssize_t refcount_show(struct nsm_handle *nsm, char *buf)
+{
+	return snprintf(buf, PAGE_SIZE, "%d\n",
+			atomic_read(&nsm->sm_count));
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
+static struct nsm_handle_attr mon_name_attr	= __ATTR_RO(mon_name);
+static struct nsm_handle_attr my_name_attr	= __ATTR_RO(my_name);
+static struct nsm_handle_attr address_attr	= __ATTR_RO(address);
+static struct nsm_handle_attr rpcparms_attr	= __ATTR_RO(rpcparms);
+static struct nsm_handle_attr status_attr	= __ATTR_RO(status);
+static struct nsm_handle_attr sticky_attr	= __ATTR_RO(sticky);
+static struct nsm_handle_attr refcount_attr	= __ATTR_RO(refcount);
+
+static struct attribute *nsm_kobj_attrs[] = {
+	&mon_name_attr.attr,
+	&my_name_attr.attr,
+	&address_attr.attr,
+	&rpcparms_attr.attr,
+	&status_attr.attr,
+	&sticky_attr.attr,
+	&refcount_attr.attr,
+	NULL,
+};
+
+static struct kobj_type nsm_handle_ktype = {
+	.release		= nsm_kobj_release,
+	.sysfs_ops		= &nsm_kobj_sysfs_ops,
+	.default_attrs		= nsm_kobj_attrs,
+};
+
 static inline struct sockaddr *nsm_addr(const struct nsm_handle *nsm)
 {
 	return (struct sockaddr *)&nsm->sm_addr;
@@ -190,8 +313,10 @@ void nsm_unmonitor(const struct nlm_host *host)
 		if (status < 0)
 			printk(KERN_NOTICE "lockd: cannot unmonitor %s\n",
 					nsm->sm_name);
-		else
+		else {
 			nsm->sm_monitored = 0;
+			nsm->sm_mon_name = NULL;
+		}
 	}
 }
 
@@ -262,7 +387,10 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 					    const char *hostname,
 					    const size_t hostname_len)
 {
+	char *p, buf[SM_PRIV_SIZE * 2 + 1];
 	struct nsm_handle *new;
+	size_t remaining;
+	int i, len, ret;
 
 	new = kzalloc(sizeof(*new) + hostname_len + 1, GFP_KERNEL);
 	if (unlikely(new == NULL))
@@ -281,7 +409,33 @@ static struct nsm_handle *nsm_create_handle(const struct sockaddr *sap,
 	memcpy(new->sm_name, hostname, hostname_len);
 	new->sm_name[hostname_len] = '\0';
 
+	p = buf;
+	remaining = sizeof(buf);
+	for (i = 0; i < SM_PRIV_SIZE; i++) {
+		len = snprintf(p, remaining, "%02x",
+				(u32)(new->sm_priv.data[i]) & 0xff);
+		if (len != 2)
+			goto out;
+		p += len; 
+		remaining -= (size_t)len;
+	}
+	if (remaining < 1)
+		goto out;
+	strcat(buf, "\0");
+
+	/* Named after "priv" cookie, which is guaranteed unique */
+	ret = kobject_init_and_add(&new->sm_kobj, &nsm_handle_ktype,
+					nsm_handles_kobj, "%s", buf);
+	if (ret != 0)
+		goto out;
+
 	return new;
+
+out:
+	kobject_put(&new->sm_kobj);
+	dprintk("lockd: %s failed; could not add kobject\n",
+			__func__);
+	return NULL;
 }
 
 /**
@@ -324,7 +478,7 @@ retry:
 	if (cached != NULL) {
 		atomic_inc(&cached->sm_count);
 		spin_unlock(&nsm_lock);
-		kfree(new);
+		kobject_put(&new->sm_kobj);
 		dprintk("lockd: found nsm_handle for %s (%s), "
 				"cnt %d\n", cached->sm_name,
 				cached->sm_addrbuf,
@@ -387,11 +541,9 @@ struct nsm_handle *nsm_reboot_lookup(const struct nlm_reboot *info)
 void nsm_release(struct nsm_handle *nsm)
 {
 	if (atomic_dec_and_lock(&nsm->sm_count, &nsm_lock)) {
-		list_del(&nsm->sm_link);
+		list_del(&nsm->sm_link);	/* kobject_del ? */
 		spin_unlock(&nsm_lock);
-		dprintk("lockd: destroyed nsm_handle for %s (%s)\n",
-				nsm->sm_name, nsm->sm_addrbuf);
-		kfree(nsm);
+		kobject_put(&nsm->sm_kobj);
 	}
 }
 
@@ -401,7 +553,7 @@ void nsm_release(struct nsm_handle *nsm)
  */
 int nsm_init(void)
 {
-	nsm_handles_kobj = kobject_create_and_add("monitor", nlm_kobj);
+	nsm_handles_kobj = kobject_create_and_add("nsm_handles", nlm_kobj);
 	if (nsm_handles_kobj == NULL)
 		return -ENOMEM;
 	return 0;
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 8622a28..3d1c594 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -78,6 +78,7 @@ struct nlm_host {
 #define NSM_ADDRBUF		((8 * 4 + 7) + (1 + 10) + 1)
 
 struct nsm_handle {
+	struct kobject		sm_kobj;
 	struct list_head	sm_link;
 	atomic_t		sm_count;
 	char			*sm_mon_name;

