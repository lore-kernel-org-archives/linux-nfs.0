Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f51.google.com ([209.85.192.51]:61492 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751675AbaFZTVn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:21:43 -0400
Received: by mail-qg0-f51.google.com with SMTP id z60so3445902qgd.24
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:21:43 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 093/117] nfsd: don't destroy clients that are busy
Date: Thu, 26 Jun 2014 15:21:01 -0400
Message-Id: <1403810485-16497-10-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible that we'll have an in-progress call on some of the clients
while a rogue EXCHANGE_ID or DESTROY_CLIENTID call comes in. Be sure to
try and mark the client expired first, so that the refcount is
respected.

This will only be a problem once the client_mutex is removed.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 014849dfaa4b..02cb3f4e27d5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2214,8 +2214,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
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
 
@@ -2828,6 +2831,9 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
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

