From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd4: remove unused dl_trunc
Date: Sun,  3 May 2009 14:16:37 -0400
Message-ID: <1241374599-20348-12-git-send-email-bfields@fieldses.org>
References: <1241374599-20348-1-git-send-email-bfields@fieldses.org>
 <1241374599-20348-2-git-send-email-bfields@fieldses.org>
 <1241374599-20348-3-git-send-email-bfields@fieldses.org>
 <1241374599-20348-4-git-send-email-bfields@fieldses.org>
 <1241374599-20348-5-git-send-email-bfields@fieldses.org>
 <1241374599-20348-6-git-send-email-bfields@fieldses.org>
 <1241374599-20348-7-git-send-email-bfields@fieldses.org>
 <1241374599-20348-8-git-send-email-bfields@fieldses.org>
 <1241374599-20348-9-git-send-email-bfields@fieldses.org>
 <1241374599-20348-10-git-send-email-bfields@fieldses.org>
 <1241374599-20348-11-git-send-email-bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:58615 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754201AbZECSQj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 May 2009 14:16:39 -0400
In-Reply-To: <1241374599-20348-11-git-send-email-bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

There's no point in keeping this field around--it's always zero.

(Background: the protocol allows you to tell the client that the file is
about to be truncated, as an optimization to save the client from
writing back dirty pages that will just be discarded.  We don't
implement this hint.  If we do some day, adding this field back in will
be the least of the work involved.)

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4callback.c     |    4 +---
 fs/nfsd/nfs4state.c        |    1 -
 include/linux/nfsd/state.h |    1 -
 3 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 2509305..0420b5e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -224,7 +224,7 @@ encode_cb_recall(struct xdr_stream *xdr, struct nfs4_delegation *dp)
 	WRITE32(OP_CB_RECALL);
 	WRITE32(dp->dl_stateid.si_generation);
 	WRITEMEM(&dp->dl_stateid.si_opaque, sizeof(stateid_opaque_t));
-	WRITE32(dp->dl_trunc);
+	WRITE32(0); /* truncate optimization not implemented */
 	WRITE32(len);
 	WRITEMEM(&dp->dl_fh.fh_base, len);
 	return 0;
@@ -510,8 +510,6 @@ nfsd4_cb_recall(struct nfs4_delegation *dp)
 	int retries = 1;
 	int status = 0;
 
-	dp->dl_trunc = 0; /* XXX need to implement truncate optimization */
-
 	status = rpc_call_sync(clnt, &msg, RPC_TASK_SOFT);
 	while (retries--) {
 		switch (status) {
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e5345e..cbb16e1 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -204,7 +204,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_stateid *stp, struct svc_f
 	dp->dl_vfs_file = stp->st_vfs_file;
 	dp->dl_type = type;
 	dp->dl_ident = cb->cb_ident;
-	dp->dl_trunc = 0;
 	dp->dl_stateid.si_boot = get_seconds();
 	dp->dl_stateid.si_stateownerid = current_delegid++;
 	dp->dl_stateid.si_fileid = 0;
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 233b60d..346b603 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -74,7 +74,6 @@ struct nfs4_delegation {
 	time_t			dl_time;
 /* For recall: */
 	u32			dl_ident;
-	int			dl_trunc;
 	stateid_t		dl_stateid;
 	struct knfsd_fh		dl_fh;
 };
-- 
1.6.0.4

