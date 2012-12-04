Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:15888 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751836Ab2LDL27 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 06:28:59 -0500
Subject: [PATCH] nfsd: make NFSv4 recovery client tracking options per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 14:29:27 +0300
Message-ID: <20121204112925.23999.28249.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Pointer to client tracking operations - client_tracking_ops - have to be
containerized, because different environment can support different trackers
(for example, legacy tracker currently is not suported in container).

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h       |    2 ++
 fs/nfsd/nfs4recover.c |   48 ++++++++++++++++++++++++++++--------------------
 2 files changed, 30 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 2c4b2e2..bca789d 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -35,6 +35,7 @@
 #define SESSION_HASH_SIZE	512
 
 struct cld_net;
+struct nfsd4_client_tracking_ops;
 
 struct nfsd_net {
 	struct cld_net *cld_net;
@@ -87,6 +88,7 @@ struct nfsd_net {
 
 	struct file *rec_file;
 	bool in_grace;
+	struct nfsd4_client_tracking_ops *client_tracking_ops;
 
 	time_t nfsd4_lease;
 	time_t nfsd4_grace;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 359793f..ba6fdd4 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -63,7 +63,6 @@ struct nfsd4_client_tracking_ops {
 
 /* Globals */
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
-static struct nfsd4_client_tracking_ops *client_tracking_ops;
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -1262,17 +1261,18 @@ nfsd4_client_tracking_init(struct net *net)
 {
 	int status;
 	struct path path;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	/* just run the init if it the method is already decided */
-	if (client_tracking_ops)
+	if (nn->client_tracking_ops)
 		goto do_init;
 
 	/*
 	 * First, try a UMH upcall. It should succeed or fail quickly, so
 	 * there's little harm in trying that first.
 	 */
-	client_tracking_ops = &nfsd4_umh_tracking_ops;
-	status = client_tracking_ops->init(net);
+	nn->client_tracking_ops = &nfsd4_umh_tracking_ops;
+	status = nn->client_tracking_ops->init(net);
 	if (!status)
 		return status;
 
@@ -1280,7 +1280,7 @@ nfsd4_client_tracking_init(struct net *net)
 	 * See if the recoverydir exists and is a directory. If it is,
 	 * then use the legacy ops.
 	 */
-	client_tracking_ops = &nfsd4_legacy_tracking_ops;
+	nn->client_tracking_ops = &nfsd4_legacy_tracking_ops;
 	status = kern_path(nfs4_recoverydir(), LOOKUP_FOLLOW, &path);
 	if (!status) {
 		status = S_ISDIR(path.dentry->d_inode->i_mode);
@@ -1290,16 +1290,16 @@ nfsd4_client_tracking_init(struct net *net)
 	}
 
 	/* Finally, try to use nfsdcld */
-	client_tracking_ops = &nfsd4_cld_tracking_ops;
+	nn->client_tracking_ops = &nfsd4_cld_tracking_ops;
 	printk(KERN_WARNING "NFSD: the nfsdcld client tracking upcall will be "
 			"removed in 3.10. Please transition to using "
 			"nfsdcltrack.\n");
 do_init:
-	status = client_tracking_ops->init(net);
+	status = nn->client_tracking_ops->init(net);
 	if (status) {
 		printk(KERN_WARNING "NFSD: Unable to initialize client "
 				    "recovery tracking! (%d)\n", status);
-		client_tracking_ops = NULL;
+		nn->client_tracking_ops = NULL;
 	}
 	return status;
 }
@@ -1307,32 +1307,40 @@ do_init:
 void
 nfsd4_client_tracking_exit(struct net *net)
 {
-	if (client_tracking_ops) {
-		if (client_tracking_ops->exit)
-			client_tracking_ops->exit(net);
-		client_tracking_ops = NULL;
+	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
+
+	if (nn->client_tracking_ops) {
+		if (nn->client_tracking_ops->exit)
+			nn->client_tracking_ops->exit(net);
+		nn->client_tracking_ops = NULL;
 	}
 }
 
 void
 nfsd4_client_record_create(struct nfs4_client *clp)
 {
-	if (client_tracking_ops)
-		client_tracking_ops->create(clp);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (nn->client_tracking_ops)
+		nn->client_tracking_ops->create(clp);
 }
 
 void
 nfsd4_client_record_remove(struct nfs4_client *clp)
 {
-	if (client_tracking_ops)
-		client_tracking_ops->remove(clp);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (nn->client_tracking_ops)
+		nn->client_tracking_ops->remove(clp);
 }
 
 int
 nfsd4_client_record_check(struct nfs4_client *clp)
 {
-	if (client_tracking_ops)
-		return client_tracking_ops->check(clp);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
+
+	if (nn->client_tracking_ops)
+		return nn->client_tracking_ops->check(clp);
 
 	return -EOPNOTSUPP;
 }
@@ -1340,8 +1348,8 @@ nfsd4_client_record_check(struct nfs4_client *clp)
 void
 nfsd4_record_grace_done(struct nfsd_net *nn, time_t boot_time)
 {
-	if (client_tracking_ops)
-		client_tracking_ops->grace_done(nn, boot_time);
+	if (nn->client_tracking_ops)
+		nn->client_tracking_ops->grace_done(nn, boot_time);
 }
 
 static int

