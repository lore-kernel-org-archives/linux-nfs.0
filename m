Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:45076 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755356AbaGHSFo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:05:44 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so5540459qgf.1
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:05:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 050/100] nfsd: Make lock stateid take a reference to the lockowner
Date: Tue,  8 Jul 2014 14:03:38 -0400
Message-Id: <1404842668-22521-51-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

A necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a008dd08ee77..078ca6a6a132 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -919,6 +919,8 @@ static void nfs4_free_generic_stateid(struct nfs4_stid *stid)
 	struct nfs4_ol_stateid *stp = openlockstateid(stid);
 
 	release_all_access(stp);
+	if (stp->st_stateowner && stid->sc_type == NFS4_LOCK_STID)
+		nfs4_put_stateowner(stp->st_stateowner);
 	nfs4_free_stid(stateid_slab, stid);
 }
 
@@ -4817,6 +4819,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
+	atomic_inc(&lo->lo_owner.so_count);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
 	stp->st_stid.sc_free = nfs4_free_lock_stateid;
-- 
1.9.3

