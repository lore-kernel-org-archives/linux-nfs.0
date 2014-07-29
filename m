Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:58971 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754376AbaG2Ues (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 16:34:48 -0400
Received: by mail-qg0-f51.google.com with SMTP id a108so271556qge.38
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 13:34:48 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 12/38] nfsd: Ensure that nfs4_open_delegation() references the delegation stateid
Date: Tue, 29 Jul 2014 16:33:55 -0400
Message-Id: <1406666061-14175-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
References: <1406666061-14175-1-git-send-email-jlayton@primarydata.com>
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
index 65e20c4bc257..ddb6706e2046 100644
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

