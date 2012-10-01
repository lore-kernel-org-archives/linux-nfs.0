Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43327 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751626Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 4/8] nfsd4: minor free_session cleanup
Date: Mon,  1 Oct 2012 13:46:48 -0400
Message-Id: <1349113612-30374-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8b7f8f8..7536a88 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -897,20 +897,21 @@ static void nfsd4_del_conns(struct nfsd4_session *s)
 	spin_unlock(&clp->cl_lock);
 }
 
+static void __free_session(struct nfsd4_session *ses)
+{
+	nfsd4_put_drc_mem(slot_bytes(&ses->se_fchannel), ses->se_fchannel.maxreqs);
+	free_session_slots(ses);
+	kfree(ses);
+}
+
 static void free_session(struct kref *kref)
 {
 	struct nfsd4_session *ses;
-	int mem;
 
 	lockdep_assert_held(&client_lock);
 	ses = container_of(kref, struct nfsd4_session, se_ref);
 	nfsd4_del_conns(ses);
-	spin_lock(&nfsd_drc_lock);
-	mem = ses->se_fchannel.maxreqs * slot_bytes(&ses->se_fchannel);
-	nfsd_drc_mem_used -= mem;
-	spin_unlock(&nfsd_drc_lock);
-	free_session_slots(ses);
-	kfree(ses);
+	__free_session(ses);
 }
 
 void nfsd4_put_session(struct nfsd4_session *ses)
@@ -966,9 +967,7 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 
 	conn = alloc_conn_from_crses(rqstp, cses);
 	if (!conn) {
-		spin_lock(&client_lock);
-		free_session(&new->se_ref);
-		spin_unlock(&client_lock);
+		__free_session(new);
 		return NULL;
 	}
 	nfsd4_init_conn(rqstp, conn, new);
-- 
1.7.9.5

