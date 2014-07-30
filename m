Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:36319 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754725AbaG3BfU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Jul 2014 21:35:20 -0400
Received: by mail-qg0-f47.google.com with SMTP id i50so650544qgf.20
        for <linux-nfs@vger.kernel.org>; Tue, 29 Jul 2014 18:35:20 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 20/38] nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
Date: Tue, 29 Jul 2014 21:34:25 -0400
Message-Id: <1406684083-19736-21-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
References: <1406684083-19736-1-git-send-email-jlayton@primarydata.com>
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
index a4a49a3b464c..653de6b14665 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1696,8 +1696,12 @@ find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 
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
@@ -3326,8 +3330,6 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -4170,8 +4172,6 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
-- 
1.9.3

