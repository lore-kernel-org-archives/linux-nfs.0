Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f180.google.com ([209.85.216.180]:56368 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757867AbaFSOww (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2014 10:52:52 -0400
Received: by mail-qc0-f180.google.com with SMTP id r5so2300202qcx.11
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2014 07:52:52 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 080/104] nfsd: don't destroy client if mark_client_expired_locked fails
Date: Thu, 19 Jun 2014 10:50:26 -0400
Message-Id: <1403189450-18729-81-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index bff26c3d306f..8f7742d3ec7b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2322,8 +2322,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (old) {
 			status = mark_client_expired_locked(old);
-			if (status)
+			if (status) {
+				old = NULL;
 				goto out_free_conn;
+			}
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
@@ -2867,8 +2869,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
 		old = find_confirmed_client_by_name(&unconf->cl_name, nn);
 		if (old) {
 			status = mark_client_expired_locked(old);
-			if (status)
+			if (status) {
+				old = NULL;
 				goto out;
+			}
 		}
 		move_to_confirmed(unconf);
 		conf = unconf;
-- 
1.9.3

