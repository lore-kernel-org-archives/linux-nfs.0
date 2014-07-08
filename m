Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f42.google.com ([209.85.192.42]:54466 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755388AbaGHSGS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:18 -0400
Received: by mail-qg0-f42.google.com with SMTP id e89so5471072qgf.15
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:17 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 076/100] nfsd: don't destroy clients that are busy
Date: Tue,  8 Jul 2014 14:04:04 -0400
Message-Id: <1404842668-22521-77-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index d11906845398..4aa8f51f7dda 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2240,8 +2240,11 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 
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
 
@@ -2854,6 +2857,9 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *csta
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

