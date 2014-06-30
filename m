Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f47.google.com ([209.85.192.47]:40271 "EHLO
	mail-qg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753669AbaF3Pwi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2014 11:52:38 -0400
Received: by mail-qg0-f47.google.com with SMTP id q108so2138091qgd.6
        for <linux-nfs@vger.kernel.org>; Mon, 30 Jun 2014 08:52:37 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 089/114] nfsd: don't destroy client if mark_client_expired_locked fails
Date: Mon, 30 Jun 2014 11:49:58 -0400
Message-Id: <1404143423-24381-90-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If it fails, it means that the client is in use and so destroying it
would be bad. Currently, the client_mutex prevents this from happening
but once we remove it, we won't be able to do this.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 75d0f5cec1b1..4c7b1326046e 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2440,8 +2440,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -2985,8 +2987,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
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

