From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 5/8] NFSv4: Ensure that the NFSv4 locking can recover from
 stateid errors
Date: Mon, 25 Jan 2010 16:57:35 -0500
Message-ID: <20100125215735.14716.68912.stgit@localhost.localdomain>
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:8049 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752707Ab0AYWEJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Jan 2010 17:04:09 -0500
Received: from svlrsexc1-prd.hq.netapp.com (svlrsexc1-prd.hq.netapp.com [10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o0PM49vv014281
	for <linux-nfs@vger.kernel.org>; Mon, 25 Jan 2010 14:04:09 -0800 (PST)
In-Reply-To: <20100125215734.14716.19614.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In most cases, we just want to mark the lock_stateid sequence id as being
uninitialised.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: stable@kernel.org
---

 fs/nfs/nfs4proc.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 198d51d..0b68238 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4088,6 +4088,22 @@ static const struct rpc_call_ops nfs4_recover_lock_ops = {
 	.rpc_release = nfs4_lock_release,
 };
 
+static void nfs4_handle_setlk_error(struct nfs_server *server, struct nfs4_lock_state *lsp, int new_lock_owner, int error)
+{
+	struct nfs_client *clp = server->nfs_client;
+	struct nfs4_state *state = lsp->ls_state;
+
+	switch (error) {
+	case -NFS4ERR_ADMIN_REVOKED:
+	case -NFS4ERR_BAD_STATEID:
+	case -NFS4ERR_EXPIRED:
+		if (new_lock_owner != 0 ||
+		   (lsp->ls_flags & NFS_LOCK_INITIALIZED) != 0)
+			nfs4_state_mark_reclaim_nograce(clp, state);
+		lsp->ls_seqid.flags &= ~NFS_SEQID_CONFIRMED;
+	};
+}
+
 static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *fl, int recovery_type)
 {
 	struct nfs4_lockdata *data;
@@ -4126,6 +4142,9 @@ static int _nfs4_do_setlk(struct nfs4_state *state, int cmd, struct file_lock *f
 	ret = nfs4_wait_for_completion_rpc_task(task);
 	if (ret == 0) {
 		ret = data->rpc_status;
+		if (ret)
+			nfs4_handle_setlk_error(data->server, data->lsp,
+					data->arg.new_lock_owner, ret);
 	} else
 		data->cancelled = 1;
 	rpc_put_task(task);

