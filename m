Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:38210 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758052AbaFSOwC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:02 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so2252609qcx.36
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 044/104] NFSd: Migrate the stateid reference into nfs4_find_stateid_by_type()
Date: Thu, 19 Jun 2014 10:49:50 -0400
Message-Id: <1403189450-18729-45-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

Allow nfs4_find_stateid_by_type to take the stateid reference, while
still holding the &cl->cl_lock.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 25af8b7628ae..4ddd7ec31d6c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1590,8 +1590,12 @@ static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t
 
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
@@ -3181,8 +3185,6 @@ static struct nfs4_delegation *find_deleg_stateid(struct nfs4_client *cl, statei
 	ret = find_stateid_by_type(cl, s, NFS4_DELEG_STID);
 	if (!ret)
 		return NULL;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&ret->sc_count);
 	return delegstateid(ret);
 }
 
@@ -3998,8 +4000,6 @@ static __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 	*s = find_stateid_by_type(cl, stateid, typemask);
 	if (!*s)
 		return nfserr_bad_stateid;
-	/* FIXME: move into find_stateid_by_type */
-	atomic_inc(&(*s)->sc_count);
 	return nfs_ok;
 }
 
-- 
1.9.3

