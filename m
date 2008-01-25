From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 094/112] NLM: Introduce external nlm_host set-up and
	tear-down functions
Date: Fri, 25 Jan 2008 11:37:57 -0500
Message-ID: <20080125163757.31887.8944.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35399 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756764AbYAYRBV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:01:21 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxloL019995
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:04 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

We would like to remove the per-lock-operation nlm_lookup_host() call from
nlmclnt_proc().

The new architecture pins an nlm_host structure to each NFS client
superblock that has the "lock" mount option set.  The NFS client passes
in the pinned nlm_host structure during each call to nlmclnt_proc().  NFS
client unmount processing "puts" the nlm_host so it can be garbage-
collected later.

This patch introduces externally callable NLM functions that handle
mount-time nlm_host set up and tear-down.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/clntlock.c        |   48 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/bind.h |    7 ++++++
 2 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index d070b18..9a8f4f4 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -41,6 +41,54 @@ struct nlm_wait {
 
 static LIST_HEAD(nlm_blocked);
 
+/**
+ * nlmclnt_init - Set up per-NFS mount point lockd data structures
+ * @server_name: server's hostname
+ * @server_address: server's network address
+ * @server_addrlen: length of server's address
+ * @protocol: transport protocol lockd should use
+ * @nfs_version: NFS protocol version for this mount point
+ *
+ * Returns pointer to an appropriate nlm_host struct,
+ * or an ERR_PTR value.
+ */
+struct nlm_host *nlmclnt_init(const char *server_name,
+			      const struct sockaddr *server_address,
+			      size_t server_addrlen,
+			      unsigned short protocol, u32 nfs_version)
+{
+	struct nlm_host *host;
+	u32 nlm_version = (nfs_version == 2) ? 1 : 4;
+	int status;
+
+	status = lockd_up(protocol);
+	if (status < 0)
+		return ERR_PTR(status);
+
+	host = nlmclnt_lookup_host((struct sockaddr_in *)server_address,
+				   protocol, nlm_version,
+				   server_name, strlen(server_name));
+	if (host == NULL) {
+		lockd_down();
+		return ERR_PTR(-ENOLCK);
+	}
+
+	return host;
+}
+EXPORT_SYMBOL_GPL(nlmclnt_init);
+
+/**
+ * nlmclnt_done - Release resources allocated by nlmclnt_init()
+ * @host: nlm_host structure reserved by nlmclnt_init()
+ *
+ */
+void nlmclnt_done(struct nlm_host *host)
+{
+	nlm_release_host(host);
+	lockd_down();
+}
+EXPORT_SYMBOL_GPL(nlmclnt_done);
+
 /*
  * Queue up a lock for blocking so that the GRANTED request can see it
  */
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 6f1637c..ad5402f 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -35,6 +35,13 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 /*
  * Functions exported by the lockd module
  */
+extern struct nlm_host *nlmclnt_init(const char *server_name,
+					const struct sockaddr *server_address,
+					size_t server_addrlen,
+					unsigned short protocol,
+					u32 nfs_version);
+extern void	nlmclnt_done(struct nlm_host *host);
+
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);
