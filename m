Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:38884 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754323AbaDPET6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Apr 2014 00:19:58 -0400
From: NeilBrown <neilb@suse.de>
To: linux-mm@kvack.org, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Date: Wed, 16 Apr 2014 14:03:37 +1000
Subject: [PATCH 18/19] nfsd: set PF_FSTRANS during nfsd4_do_callback_rpc.
Cc: xfs@oss.sgi.com
Message-ID: <20140416040337.10604.52860.stgit@notabene.brown>
In-Reply-To: <20140416033623.10604.69237.stgit@notabene.brown>
References: <20140416033623.10604.69237.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd will sometimes call flush_workqueue on the workqueue running
nfsd4_do_callback_rpc, so we must ensure that it doesn't block in
filesystem reclaim.
So set PF_FSTRANS.

Signed-off-by: NeilBrown <neilb@suse.de>
---
 fs/nfsd/nfs4callback.c |    5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd140de3..7784b5d4edf0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -997,6 +997,9 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 	struct nfsd4_callback *cb = container_of(w, struct nfsd4_callback, cb_work);
 	struct nfs4_client *clp = cb->cb_clp;
 	struct rpc_clnt *clnt;
+	unsigned int pflags;
+
+	current_set_flags_nested(&pflags, PF_FSTRANS);
 
 	if (clp->cl_flags & NFSD4_CLIENT_CB_FLAG_MASK)
 		nfsd4_process_cb_update(cb);
@@ -1005,11 +1008,13 @@ static void nfsd4_do_callback_rpc(struct work_struct *w)
 	if (!clnt) {
 		/* Callback channel broken, or client killed; give up: */
 		nfsd4_release_cb(cb);
+		current_restore_flags_nested(&pflags, PF_FSTRANS);
 		return;
 	}
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
 	rpc_call_async(clnt, &cb->cb_msg, RPC_TASK_SOFT | RPC_TASK_SOFTCONN,
 			cb->cb_ops, cb);
+	current_restore_flags_nested(&pflags, PF_FSTRANS);
 }
 
 void nfsd4_init_callback(struct nfsd4_callback *cb)


