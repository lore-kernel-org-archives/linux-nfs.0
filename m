Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:59939 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759513Ab3BKTar (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Feb 2013 14:30:47 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 6/6] NFSv4: Fix a reboot recovery race when opening a file
Date: Mon, 11 Feb 2013 14:29:26 -0500
Message-Id: <1360610966-15398-7-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1360610966-15398-6-git-send-email-Trond.Myklebust@netapp.com>
References: <1360610966-15398-1-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-2-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-3-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-4-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-5-git-send-email-Trond.Myklebust@netapp.com>
 <1360610966-15398-6-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the server reboots after it has replied to our OPEN, but before we
call nfs4_opendata_to_nfs4_state(), then the reboot recovery thread
will not see a stateid for this open, and so will fail to recover it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4proc.c | 50 ++++++++++++++++++++++++++++++++++++++------------
 1 file changed, 38 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d512273..7cbf7aa 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1848,6 +1848,43 @@ static inline void nfs4_exclusive_attrset(struct nfs4_opendata *opendata, struct
 		sattr->ia_valid |= ATTR_MTIME;
 }
 
+static int _nfs4_open_and_get_state(struct nfs4_opendata *opendata,
+		fmode_t fmode,
+		int flags,
+		struct nfs4_state **res)
+{
+	struct nfs4_state_owner *sp = opendata->owner;
+	struct nfs_server *server = sp->so_server;
+	struct nfs4_state *state;
+	unsigned int seq;
+	int ret;
+
+	seq = raw_seqcount_begin(&sp->so_reclaim_seqcount);
+
+	ret = _nfs4_proc_open(opendata);
+	if (ret != 0)
+		goto out;
+
+	state = nfs4_opendata_to_nfs4_state(opendata);
+	ret = PTR_ERR(state);
+	if (IS_ERR(state))
+		goto out;
+	if (server->caps & NFS_CAP_POSIX_LOCK)
+		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
+
+	ret = nfs4_opendata_access(sp->so_cred, opendata, state, fmode, flags);
+	if (ret != 0)
+		goto out;
+
+	if (read_seqcount_retry(&sp->so_reclaim_seqcount, seq)) {
+		nfs4_schedule_stateid_recovery(server, state);
+		nfs4_wait_clnt_recover(server->nfs_client);
+	}
+	*res = state;
+out:
+	return ret;
+}
+
 /*
  * Returns a referenced nfs4_state
  */
@@ -1892,18 +1929,7 @@ static int _nfs4_do_open(struct inode *dir,
 	if (dentry->d_inode != NULL)
 		opendata->state = nfs4_get_open_state(dentry->d_inode, sp);
 
-	status = _nfs4_proc_open(opendata);
-	if (status != 0)
-		goto err_opendata_put;
-
-	state = nfs4_opendata_to_nfs4_state(opendata);
-	status = PTR_ERR(state);
-	if (IS_ERR(state))
-		goto err_opendata_put;
-	if (server->caps & NFS_CAP_POSIX_LOCK)
-		set_bit(NFS_STATE_POSIX_LOCKS, &state->flags);
-
-	status = nfs4_opendata_access(cred, opendata, state, fmode, flags);
+	status = _nfs4_open_and_get_state(opendata, fmode, flags, &state);
 	if (status != 0)
 		goto err_opendata_put;
 
-- 
1.8.1.2

