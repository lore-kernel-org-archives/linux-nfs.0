Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f42.google.com ([209.85.216.42]:35064 "EHLO
	mail-qa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753244AbaG3M2C (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Jul 2014 08:28:02 -0400
Received: by mail-qa0-f42.google.com with SMTP id j15so1178979qaq.29
        for <linux-nfs@vger.kernel.org>; Wed, 30 Jul 2014 05:28:01 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, hch@infradead.org
Subject: [PATCH 12/37] nfsd: don't destroy client if mark_client_expired_locked fails
Date: Wed, 30 Jul 2014 08:27:13 -0400
Message-Id: <1406723258-8512-13-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
References: <1406723258-8512-1-git-send-email-jlayton@primarydata.com>
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
index 56999cbe84a7..43e66fc1b90d 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2496,8 +2496,10 @@ nfsd4_create_session(struct svc_rqst *rqstp,
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
@@ -3041,8 +3043,10 @@ nfsd4_setclientid_confirm(struct svc_rqst *rqstp,
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

