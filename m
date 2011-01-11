Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:56176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932359Ab1AKQVm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jan 2011 11:21:42 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 01/14] nfsd4: modify session list under cl_lock
Date: Tue, 11 Jan 2011 11:21:21 -0500
Message-Id: <1294762894-21371-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1294762894-21371-1-git-send-email-bfields@redhat.com>
References: <1294762894-21371-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

We want to traverse this from the callback code.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b583e4e..3cf9900 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -771,7 +771,9 @@ static struct nfsd4_session *alloc_init_session(struct svc_rqst *rqstp, struct n
 	idx = hash_sessionid(&new->se_sessionid);
 	spin_lock(&client_lock);
 	list_add(&new->se_hash, &sessionid_hashtbl[idx]);
+	spin_lock(&clp->cl_lock);
 	list_add(&new->se_perclnt, &clp->cl_sessions);
+	spin_unlock(&clp->cl_lock);
 	spin_unlock(&client_lock);
 
 	status = nfsd4_new_conn(rqstp, new);
@@ -819,7 +821,9 @@ static void
 unhash_session(struct nfsd4_session *ses)
 {
 	list_del(&ses->se_hash);
+	spin_lock(&ses->se_client->cl_lock);
 	list_del(&ses->se_perclnt);
+	spin_unlock(&ses->se_client->cl_lock);
 }
 
 /* must be called under the client_lock */
@@ -925,8 +929,10 @@ unhash_client_locked(struct nfs4_client *clp)
 
 	mark_client_expired(clp);
 	list_del(&clp->cl_lru);
+	spin_lock(&clp->cl_lock);
 	list_for_each_entry(ses, &clp->cl_sessions, se_perclnt)
 		list_del_init(&ses->se_hash);
+	spin_unlock(&clp->cl_lock);
 }
 
 static void
-- 
1.7.1

