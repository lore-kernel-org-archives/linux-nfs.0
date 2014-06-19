Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f45.google.com ([209.85.192.45]:56141 "EHLO
	mail-qg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932295AbaFSOwy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:54 -0400
Received: by mail-qg0-f45.google.com with SMTP id 63so2152657qgz.4
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 081/104] nfsd: don't destroy clients that are busy
Date: Thu, 19 Jun 2014 10:50:27 -0400
Message-Id: <1403189450-18729-82-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that we'll have an in-progress call on some of the clients
while we may be destroying the thing. Be sure to try and mark the client
expired first, so that the refcount is respected.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 8f7742d3ec7b..17fd48561cf8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2089,8 +2089,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
 	/* case 1 (normal case) */
 out_new:
-	if (conf)
-		unhash_client_locked(conf);
+	if (conf) {
+		status = mark_client_expired_locked(conf);
+		if (status)
+			goto out;
+	}
 	new->cl_minorversion = cstate->minorversion;
 	new->cl_mach_cred = (exid->spa_how == SP4_MACH_CRED);
 
@@ -2703,6 +2706,9 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
 			status = nfserr_clientid_busy;
 			goto out;
 		}
+		status = mark_client_expired_locked(conf);
+		if (status)
+			goto out;
 		clp = conf;
 	} else if (unconf)
 		clp = unconf;
-- 
1.9.3

