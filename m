Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:64213 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965013Ab2B2Xei (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Feb 2012 18:34:38 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4.1: Get rid of NFS4CLNT_LAYOUTRECALL
Date: Wed, 29 Feb 2012 18:34:05 -0500
Message-Id: <1330558445-4583-2-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330558445-4583-1-git-send-email-Trond.Myklebust@netapp.com>
References: <1330558445-4583-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The NFS4CLNT_LAYOUTRECALL bit is a long-term impediment to scalability. It
basically stops all other recalls by a given server once any layout recall
is requested.

If the recall is for a different file, then we don't care.
If the recall applies to the same file, then we're in one of two situations:
Either we are in the case of a replay of an existing request, in which case
the session is supposed to deal with matters, or we are dealing with a
completely different request, in which case we should just try to process
it.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/callback_proc.c |    6 +-----
 fs/nfs/nfs4_fs.h       |    1 -
 2 files changed, 1 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index f71978d..0e0865e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -233,17 +233,13 @@ static u32 initiate_bulk_draining(struct nfs_client *clp,
 static u32 do_callback_layoutrecall(struct nfs_client *clp,
 				    struct cb_layoutrecallargs *args)
 {
-	u32 res = NFS4ERR_DELAY;
+	u32 res;
 
 	dprintk("%s enter, type=%i\n", __func__, args->cbl_recall_type);
-	if (test_and_set_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state))
-		goto out;
 	if (args->cbl_recall_type == RETURN_FILE)
 		res = initiate_file_draining(clp, args);
 	else
 		res = initiate_bulk_draining(clp, args);
-	clear_bit(NFS4CLNT_LAYOUTRECALL, &clp->cl_state);
-out:
 	dprintk("%s returning %i\n", __func__, res);
 	return res;
 
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b133b50..19079ec 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -20,7 +20,6 @@ enum nfs4_client_state {
 	NFS4CLNT_RECLAIM_REBOOT,
 	NFS4CLNT_RECLAIM_NOGRACE,
 	NFS4CLNT_DELEGRETURN,
-	NFS4CLNT_LAYOUTRECALL,
 	NFS4CLNT_SESSION_RESET,
 	NFS4CLNT_RECALL_SLOT,
 	NFS4CLNT_LEASE_CONFIRM,
-- 
1.7.7.6

