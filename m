Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:37435 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751208AbaFZTPR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:15:17 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so3621403qcw.31
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:15:16 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v2 067/117] nfsd: Make lock stateid take a reference to the lockowner
Date: Thu, 26 Jun 2014 15:12:47 -0400
Message-Id: <1403810017-16062-68-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

A necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3ae5a3b56a85..649b2e829981 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -904,6 +904,8 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
 	release_all_access(stp);
+	if (stp->st_stateowner && stid->sc_type == NFS4_LOCK_STID)
+		nfs4_put_stateowner(stp->st_stateowner);
 	nfs4_free_stid(stateid_slab, stid);
 }
 
@@ -4803,6 +4805,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
+	atomic_inc(&lo->lo_owner.so_count);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
 	stp->st_stid.sc_free = nfs4_free_lock_stateid;
-- 
1.9.3

