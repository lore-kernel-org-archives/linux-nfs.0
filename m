Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f50.google.com ([209.85.192.50]:64444 "EHLO
	mail-qg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895AbaG3BfI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:08 -0400
Received: by mail-qg0-f50.google.com with SMTP id q108so631437qgd.37
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:07 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 12/38] nfsd: Ensure that nfs4_open_delegation() references the delegation stateid
Date: Tue, 29 Jul 2014 21:34:17 -0400
Message-Id: <1406684083-19736-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Ensure that nfs4_open_delegation() keeps a reference to the delegation
stateid until it is done working with it. Necessary step toward
client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 4f191456d737..2df6af93120e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -674,6 +674,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 	lockdep_assert_held(&state_lock);
 	lockdep_assert_held(&fp->fi_lock);
 
+	atomic_inc(&dp->dl_stid.sc_count);
 	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
@@ -3704,6 +3705,7 @@ nfs4_open_delegation(struct svc_fh *fh, struct nfsd4_open *open,
 	dprintk("NFSD: delegation stateid=" STATEID_FMT "\n",
 		STATEID_VAL(&dp->dl_stid.sc_stateid));
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_READ;
+	nfs4_put_stid(&dp->dl_stid);
 	return;
 out_no_deleg:
 	open->op_delegate_type = NFS4_OPEN_DELEGATE_NONE;
-- 
1.9.3

