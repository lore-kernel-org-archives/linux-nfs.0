Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:50057 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757959AbaFSOvn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:51:43 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so2286132qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:51:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 032/104] NFSd: Slight cleanup of find_stateid()
Date: Thu, 19 Jun 2014 10:49:38 -0400
Message-Id: <1403189450-18729-33-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Trond Myklebust <trond.myklebust@primarydata.com>

In preparation of reference counting...

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfsd/nfs4state.c | 26 +++++++++++++++++---------
 1 file changed, 17 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 020bc981ccd3..42ef5ecc1def 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1561,28 +1561,36 @@ static void gen_confirm(struct nfs4_client *clp)
 	memcpy(clp->cl_confirm.data, verf, sizeof(clp->cl_confirm.data));
 }
 
-static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+static struct nfs4_stid *find_stateid_locked(struct nfs4_client *cl, stateid_t *t)
 {
 	struct nfs4_stid *ret;
 
-	spin_lock(&cl->cl_lock);
 	ret = idr_find(&cl->cl_stateids, t->si_opaque.so_id);
-	spin_unlock(&cl->cl_lock);
 	if (!ret || !ret->sc_type)
 		return NULL;
 	return ret;
 }
 
+static struct nfs4_stid *find_stateid(struct nfs4_client *cl, stateid_t *t)
+{
+	struct nfs4_stid *ret;
+
+	spin_lock(&cl->cl_lock);
+	ret = find_stateid_locked(cl, t);
+	spin_unlock(&cl->cl_lock);
+	return ret;
+}
+
 static struct nfs4_stid *find_stateid_by_type(struct nfs4_client *cl, stateid_t *t, char typemask)
 {
 	struct nfs4_stid *s;
 
-	s = find_stateid(cl, t);
-	if (!s)
-		return NULL;
-	if (typemask & s->sc_type)
-		return s;
-	return NULL;
+	spin_lock(&cl->cl_lock);
+	s = find_stateid_locked(cl, t);
+	if (s != NULL && !(typemask & s->sc_type))
+		s = NULL;
+	spin_unlock(&cl->cl_lock);
+	return s;
 }
 
 static struct nfs4_client *create_client(struct xdr_netobj name,
-- 
1.9.3

