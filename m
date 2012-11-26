Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:42064 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754303Ab2KZNOU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 08:14:20 -0500
Subject: [PATCH 2/2] nfsd: recovery - make in_grace per net
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Mon, 26 Nov 2012 16:16:30 +0300
Message-ID: <20121126131630.8822.81210.stgit@localhost.localdomain>
In-Reply-To: <20121126131404.8822.65870.stgit@localhost.localdomain>
References: <20121126131404.8822.65870.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Flag in_grace is a part of client tracking state, which is network namesapce
aware. So let'a replace global static variable with per-net one.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h       |    1 +
 fs/nfsd/nfs4recover.c |    9 ++++-----
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 1305632..9047706 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -86,6 +86,7 @@ struct nfsd_net {
 	spinlock_t client_lock;
 
 	struct file *rec_file;
+	bool in_grace;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index 3e76d28..359793f 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -64,7 +64,6 @@ struct nfsd4_client_tracking_ops {
 /* Globals */
 static char user_recovery_dirname[PATH_MAX] = "/var/lib/nfs/v4recovery";
 static struct nfsd4_client_tracking_ops *client_tracking_ops;
-static bool in_grace;
 
 static int
 nfs4_save_creds(const struct cred **original_creds)
@@ -221,7 +220,7 @@ out_put:
 out_unlock:
 	mutex_unlock(&dir->d_inode->i_mutex);
 	if (status == 0) {
-		if (in_grace) {
+		if (nn->in_grace) {
 			crp = nfs4_client_to_reclaim(dname, nn);
 			if (crp)
 				crp->cr_clp = clp;
@@ -358,7 +357,7 @@ nfsd4_remove_clid_dir(struct nfs4_client *clp)
 	nfs4_reset_creds(original_cred);
 	if (status == 0) {
 		vfs_fsync(nn->rec_file, 0);
-		if (in_grace) {
+		if (nn->in_grace) {
 			/* remove reclaim record */
 			crp = nfsd4_find_reclaim_client(dname, nn);
 			if (crp)
@@ -394,7 +393,7 @@ nfsd4_recdir_purge_old(struct nfsd_net *nn, time_t boot_time)
 {
 	int status;
 
-	in_grace = false;
+	nn->in_grace = false;
 	if (!nn->rec_file)
 		return;
 	status = mnt_want_write_file(nn->rec_file);
@@ -473,7 +472,7 @@ nfsd4_init_recdir(struct net *net)
 
 	nfs4_reset_creds(original_cred);
 	if (!status)
-		in_grace = true;
+		nn->in_grace = true;
 	return status;
 }
 

