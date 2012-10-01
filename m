Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751639Ab2JARqz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Oct 2012 13:46:55 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 5/8] nfsd4: clean up session allocation
Date: Mon,  1 Oct 2012 13:46:49 -0400
Message-Id: <1349113612-30374-6-git-send-email-bfields@redhat.com>
In-Reply-To: <1349113612-30374-1-git-send-email-bfields@redhat.com>
References: <1349113612-30374-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   32 ++++++++++++++++++++------------
 1 file changed, 20 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7536a88..79f1fdb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -758,7 +758,7 @@ static void nfsd4_put_drc_mem(int slotsize, int num)
 	spin_unlock(&nfsd_drc_lock);
 }
 
-static struct nfsd4_session *alloc_session(int slotsize, int numslots)
+static struct nfsd4_session *__alloc_session(int slotsize, int numslots)
 {
 	struct nfsd4_session *new;
 	int mem, i;
@@ -921,14 +921,10 @@ void nfsd4_put_session(struct nfsd4_session *ses)
 	spin_unlock(&client_lock);
 }
 
-static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 {
 	struct nfsd4_session *new;
-	struct nfsd4_conn *conn;
-	struct nfsd4_channel_attrs *fchan = &cses->fore_channel;
 	int numslots, slotsize;
-	int idx;
-
 	/*
 	 * Note decreasing slot size below client's request may
 	 * make it difficult for client to function correctly, whereas
@@ -941,13 +937,30 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	if (numslots < 1)
 		return NULL;
 
-	new = alloc_session(slotsize, numslots);
+	new = __alloc_session(slotsize, numslots);
 	if (!new) {
 		nfsd4_put_drc_mem(slotsize, fchan->maxreqs);
 		return NULL;
 	}
 	init_forechannel_attrs(&new->se_fchannel, fchan, numslots, slotsize);
+	return new;
+}
 
+static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+{
+	struct nfsd4_session *new;
+	struct nfsd4_conn *conn;
+	int idx;
+
+	new = alloc_session(&cses->fore_channel);
+	if (!new)
+		return NULL;
+
+	conn = alloc_conn_from_crses(rqstp, cses);
+	if (!conn) {
+		__free_session(new);
+		return NULL;
+	}
 	new->se_client = clp;
 	gen_sessionid(new);
 
@@ -965,11 +978,6 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	spin_unlock(&clp->cl_lock);
 	spin_unlock(&client_lock);
 
-	conn = alloc_conn_from_crses(rqstp, cses);
-	if (!conn) {
-		__free_session(new);
-		return NULL;
-	}
 	nfsd4_init_conn(rqstp, conn, new);
 	if (cses->flags & SESSION4_BACK_CHAN) {
 		struct sockaddr *sa = svc_addr(rqstp);
-- 
1.7.9.5

