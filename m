Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:55067 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932332AbaGUPDb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jul 2014 11:03:31 -0400
Received: by mail-qc0-f182.google.com with SMTP id r5so5641836qcx.13
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jul 2014 08:03:30 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH 22/40] nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
Date: Mon, 21 Jul 2014 11:02:34 -0400
Message-Id: <1405954972-28904-23-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
References: <1405954972-28904-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Allow nfs4_find_stateid_by_type to take the stateid reference, while
still holding the &cl->cl_lock. Necessary step toward client_mutex
removal.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 92f58c36a419..8f724aa429ed 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1710,8 +1710,12 @@ static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t
 
 	spin_lock(&cl->cl_lock);
 	s = find_stateid_locked(cl, t);
-	if (s != NULL && !(typemask & s->sc_type))
-		s = NULL;
+	if (s != NULL) {
+		if (typemask & s->sc_type)
+			atomic_inc(&s->sc_count);
+		else
+			s = NULL;
+	}
 	spin_unlock(&cl->cl_lock);
 	return s;
 }
@@ -3344,8 +3348,6 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -4188,8 +4190,6 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
-- 
1.9.3

