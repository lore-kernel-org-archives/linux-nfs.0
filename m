Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f169.google.com ([209.85.216.169]:57033 "EHLO
	mail-qc0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570AbaFZTVm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:21:42 -0400
Received: by mail-qc0-f169.google.com with SMTP id c9so3604138qcz.28
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:21:41 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 092/117] nfsd: don't destroy client if mark_client_expired_locked fails
Date: Thu, 26 Jun 2014 15:21:00 -0400
Message-Id: <1403810485-16497-9-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
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
index 3bd24d5b973e..014849dfaa4b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2447,8 +2447,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -2992,8 +2994,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
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

