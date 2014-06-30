Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:64099 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260AbaF3Pvz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:51:55 -0400
Received: by mail-qa0-f41.google.com with SMTP id cm18so6706756qab.0
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:51:54 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
        Trond Myklebust <trond.myklebust@primarydata.com>
Subject: [PATCH v3 058/114] nfsd: Migrate the stateid reference into nfs4_find_stateid_by_type()
Date: Mon, 30 Jun 2014 11:49:27 -0400
Message-Id: <1404143423-24381-59-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
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
index 9d9cb26c391c..0f30716c9093 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1678,8 +1678,12 @@ static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t
 
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
@@ -3298,8 +3302,6 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -4124,8 +4126,6 @@ nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 	*s = find_stateid_by_type(cstate->clp, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
-- 
1.9.3

