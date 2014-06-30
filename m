Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:64231 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbaF3PwC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:02 -0400
Received: by mail-qg0-f47.google.com with SMTP id q108so2123767qgd.20
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 063/114] nfsd: Make lock stateid take a reference to the lockowner
Date: Mon, 30 Jun 2014 11:49:32 -0400
Message-Id: <1404143423-24381-64-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

A necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index effce92b54de..9a760aac6ef2 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -882,6 +882,8 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
 	release_all_access(stp);
+	if (stp->st_stateowner && stid->sc_type == NFS4_LOCK_STID)
+		nfs4_put_stateowner(stp->st_stateowner);
 	nfs4_free_stid(stateid_slab, stid);
 }
 
@@ -4775,6 +4777,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
+	atomic_inc(&lo->lo_owner.so_count);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
 	stp->st_stid.sc_free = nfs4_free_lock_stateid;
-- 
1.9.3

