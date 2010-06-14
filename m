From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 15/15] NFSv4.1: There is no need to init the session more than once...
Date: Mon, 14 Jun 2010 17:51:39 -0400
Message-ID: <1276552299-6625-15-git-send-email-Trond.Myklebust@netapp.com>
References: <1276552299-6625-1-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-2-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-3-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-4-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-5-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-6-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-7-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-8-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-9-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-10-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-11-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-12-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-13-git-send-email-Trond.Myklebust@netapp.com>
 <1276552299-6625-14-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:22574 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756809Ab0FNVvs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 17:51:48 -0400
In-Reply-To: <1276552299-6625-14-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Set up a flag to ensure that is indeed the case.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 04eff16..a986f13 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -49,6 +49,7 @@ enum nfs4_client_state {
 };
 
 enum nfs4_session_state {
+	NFS4_SESSION_INITING,
 	NFS4_SESSION_DRAINING,
 };
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 1245939..04eff86 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4807,6 +4807,8 @@ struct nfs4_session *nfs4_alloc_session(struct nfs_client *clp)
 	spin_lock_init(&tbl->slot_tbl_lock);
 	rpc_init_wait_queue(&tbl->slot_tbl_waitq, "BackChannel Slot table");
 
+	session->session_state = 1<<NFS4_SESSION_INITING;
+
 	session->clp = clp;
 	return session;
 }
@@ -5023,6 +5025,10 @@ int nfs4_init_session(struct nfs_server *server)
 	if (!nfs4_has_session(clp))
 		return 0;
 
+	session = clp->cl_session;
+	if (!test_and_clear_bit(NFS4_SESSION_INITING, &session->session_state))
+		return 0;
+
 	rsize = server->rsize;
 	if (rsize == 0)
 		rsize = NFS_MAX_FILE_IO_SIZE;
@@ -5030,7 +5036,6 @@ int nfs4_init_session(struct nfs_server *server)
 	if (wsize == 0)
 		wsize = NFS_MAX_FILE_IO_SIZE;
 
-	session = clp->cl_session;
 	session->fc_attrs.max_rqst_sz = wsize + nfs41_maxwrite_overhead;
 	session->fc_attrs.max_resp_sz = rsize + nfs41_maxread_overhead;
 
-- 
1.7.0.1

