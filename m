Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:62212 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbaG3Bf2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:28 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so579363qaq.29
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:27 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 25/38] nfsd: Make lock stateid take a reference to the lockowner
Date: Tue, 29 Jul 2014 21:34:30 -0400
Message-Id: <1406684083-19736-26-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

A necessary step toward client_mutex removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 906c8604de30..88225f0bbc12 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -928,6 +928,8 @@ static void nfs4_free_lock_stateid(struct nfs4_stid *stid)
 	file = find_any_file(stp->st_stid.sc_file);
 	if (file)
 		filp_close(file, (fl_owner_t)lo);
+	if (stp->st_stateowner)
+		nfs4_put_stateowner(stp->st_stateowner);
 	nfs4_free_ol_stateid(stid);
 }
 
@@ -4831,6 +4833,7 @@ init_lock_stateid(struct nfs4_ol_stateid *stp, struct nfs4_lockowner *lo,
 	atomic_inc(&stp->st_stid.sc_count);
 	stp->st_stid.sc_type = NFS4_LOCK_STID;
 	stp->st_stateowner = &lo->lo_owner;
+	atomic_inc(&lo->lo_owner.so_count);
 	get_nfs4_file(fp);
 	stp->st_stid.sc_file = fp;
 	stp->st_stid.sc_free = nfs4_free_lock_stateid;
-- 
1.9.3

