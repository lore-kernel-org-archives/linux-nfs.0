From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NLM: Introduce completion function to match nlmclnt_init
Date: Thu, 20 Dec 2007 15:04:05 -0500
Message-ID: <20071220200405.3358.54150.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:1337 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754489AbXLTUET (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Dec 2007 15:04:19 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introduce the other book-end for nlmclnt_init(). This function is invoked
by the NFS client during unmount processing to release the nlm_host struct
that was pinned by nlmclnt_init() during mount processing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c        |   12 ++++++++++++
 include/linux/lockd/bind.h |    1 +
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 9aeea53..0c99aee 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -86,6 +86,18 @@ struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
 }
 EXPORT_SYMBOL(nlmclnt_init);
 
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
+EXPORT_SYMBOL(nlmclnt_done);
+
 /*
  * Queue up a lock for blocking so that the GRANTED request can see it
  */
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index d8b7149..372c8df 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -40,6 +40,7 @@ extern struct nlm_host *nlmclnt_init(struct sockaddr *server_address,
 					char *server_name,
 					u32 nfs_version,
 					unsigned short protocol);
+extern void	nlmclnt_done(struct nlm_host *host);
 
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(int proto);

