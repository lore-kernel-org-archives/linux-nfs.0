Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f46.google.com ([209.85.220.46]:63428 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754860Ab2JBQSN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Oct 2012 12:18:13 -0400
Received: by padhz1 with SMTP id hz1so5380948pad.19
        for <linux-nfs@vger.kernel.org>; Tue, 02 Oct 2012 09:18:12 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: nfs41_walk_client_list(): re-lock before iterating
To: trond.myklebust@netapp.com
Cc: fengguang.wu@intel.com, linux-nfs@vger.kernel.org
Date: Tue, 02 Oct 2012 09:18:12 -0700
Message-ID: <20121002161742.33989.73782.stgit@oracle-71.nfsv4bat.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sparse identified an execution path in nfs41_walk_client_list()
where the nfs_client_lock is not re-acquired before taking the next
loop iteration.

fs/nfs/nfs4client.c:437:9: sparse: context imbalance in
 'nfs41_walk_client_list' - different lock contexts for basic block

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>
---

 fs/nfs/nfs4client.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 8466e60..6bacfde 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -450,6 +450,7 @@ int nfs41_walk_client_list(struct nfs_client *new,
 			error = nfs_wait_client_init_complete(pos);
 			if (error < 0) {
 				nfs_put_client(pos);
+				spin_lock(&nn->nfs_client_lock);
 				continue;
 			}
 

