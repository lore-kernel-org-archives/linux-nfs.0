Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qg0-f46.google.com ([209.85.192.46]:37515 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755397AbaGHSGQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:06:16 -0400
Received: by mail-qg0-f46.google.com with SMTP id q107so5330543qgd.33
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:06:16 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 075/100] nfsd: don't destroy client if mark_client_expired_locked fails
Date: Tue,  8 Jul 2014 14:04:03 -0400
Message-Id: <1404842668-22521-76-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
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
index d47359b8a84e..d11906845398 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2473,8 +2473,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -3018,8 +3020,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
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

