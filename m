From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/3] NFS: Introduce external nlm_host set-up and tear-down
	functions
Date: Tue, 08 Jan 2008 10:32:07 -0500
Message-ID: <20080108153207.20097.70119.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:22560 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755974AbYAHPcQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2008 10:32:16 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We would like to remove the per-lock-operation nlm_lookup_host() call from
nlmclnt_proc().  It's plenty icky for a number of reasons.

The new architecture will pin an nlm_host structure to each NFS client
superblock that has the "lock" mount option set.  The client will pass
in the pinned nlm_host structure during each call to nlmclnt_proc().  NFS
client unmount processing will "put" the nlm_host so it can be garbage-
collected later.

This patch adds externally callable NLM functions that handle mount-time
nlm_host set up and tear-down.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c        |   55 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/lockd/bind.h |    7 ++++++
 2 files changed, 62 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index d070b18..ff1f731 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -41,6 +41,61 @@ struct nlm_wait {
 
 static LIST_HEAD(nlm_blocked);
 
+/**
+ * nlmclnt_init - Set up per-NFS mount point lockd data structures
+ * @server_address: server's network address
+ * @server_addrlen: length of server's address
+ * @server_name: server's hostname
+ * @nfs_version: NFS protocol version for this mount point
+ * @protocol: transport protocol lockd should use
+ *
+ * Returns pointer to an appropriate nlm_host struct,
+ * or an error value.
+ */
+struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
+			      size_t server_addrlen,
+			      char *server_name, u32 nfs_version,
+			      unsigned short protocol)
+{
+	struct nlm_host *host;
+	u32 nlm_version;
+	int status;
+
+	if (nfs_version == 2)
+		nlm_version = 1;
+	else if (nfs_version == 3)
+		nlm_version = 4;
+	else
+		BUG();
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
index 6f1637c..372c8df 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -35,6 +35,13 @@ extern struct nlmsvc_binding *	nlmsvc_ops;
 /*
  * Functions exported by the lockd module
  */
+extern struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
+					size_t server_addrlen,
+					char *server_name,
+					u32 nfs_version,
+					unsigned short protocol);
+extern void	nlmclnt_done(struct nlm_host *host);
+
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);
 extern void	lockd_down(void);

