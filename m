Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:51480 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754445Ab2KHAgW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Nov 2012 19:36:22 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] nfsd4: remove unused init_session return
Date: Wed,  7 Nov 2012 19:36:10 -0500
Message-Id: <1352334972-28495-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1352334972-28495-1-git-send-email-bfields@redhat.com>
References: <1352334972-28495-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index fba2996..bc8507c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -945,7 +945,7 @@ static struct nfsd4_session *alloc_session(struct nfsd4_channel_attrs *fchan)
 	return new;
 }
 
-static struct nfsd4_session *init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
+void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, struct nfs4_client *clp, struct nfsd4_create_session *cses)
 {
 	int idx;
 
@@ -978,7 +978,6 @@ static struct nfsd4_session *init_session(struct svc_rqst *rqstp, struct nfsd4_s
 		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 	}
-	return new;
 }
 
 /* caller must hold client_lock */
-- 
1.7.9.5

