Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:58107 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932498AbaE3NJz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 30 May 2014 09:09:55 -0400
Received: by mail-qg0-f51.google.com with SMTP id q107so5102967qgd.38
        for <linux-nfs@vger.kernel.org>; Fri, 30 May 2014 06:09:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: [PATCH 7/9] nfsd4: hash deleg stateid only on successful nfs4_set_delegation
Date: Fri, 30 May 2014 09:09:31 -0400
Message-Id: <1401455373-18207-8-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@primarydata.com>

We don't want the stateid to be found in the hash table before the delegation
is granted.

Currently this is protected by the client_mutex, but we want to break that
up and this is a necessary step toward that goal.

Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 040000de3732..a500033a2f87 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -375,7 +375,6 @@ alloc_init_deleg(struct nfs4_client *clp, struct nfs4_ol_stateid *stp, struct sv
 	dp = delegstateid(nfs4_alloc_stid(clp, deleg_slab));
 	if (dp == NULL)
 		return dp;
-	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	/*
 	 * delegation seqid's are never incremented.  The 4.1 special
 	 * meaning of seqid 0 isn't meaningful, really, but let's avoid
@@ -438,6 +437,7 @@ hash_delegation_locked(struct nfs4_delegation *dp, struct nfs4_file *fp)
 {
 	lockdep_assert_held(&state_lock);
 
+	dp->dl_stid.sc_type = NFS4_DELEG_STID;
 	list_add(&dp->dl_perfile, &fp->fi_delegations);
 	list_add(&dp->dl_perclnt, &dp->dl_stid.sc_client->cl_delegations);
 }
-- 
1.9.3

