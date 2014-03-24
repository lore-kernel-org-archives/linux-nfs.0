Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f180.google.com ([209.85.192.180]:60729 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750900AbaCXD5G (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 23 Mar 2014 23:57:06 -0400
Received: by mail-pd0-f180.google.com with SMTP id v10so4753736pde.25
        for <linux-nfs@vger.kernel.org>; Sun, 23 Mar 2014 20:57:04 -0700 (PDT)
Message-ID: <532FAD0B.50006@gmail.com>
Date: Mon, 24 Mar 2014 11:56:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/5][RESEND] NFSD: Using free_conn free connection
References: <532FAC85.20909@gmail.com>
In-Reply-To: <532FAC85.20909@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Connection from alloc_conn must be freed through free_conn,
otherwise, the reference of svc_xprt will never be put.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d5d070f..d7efc4b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2287,7 +2287,8 @@ out:
 	if (!list_empty(&clp->cl_revoked))
 		seq->status_flags |= SEQ4_STATUS_RECALLABLE_STATE_REVOKED;
 out_no_session:
-	kfree(conn);
+	if (conn)
+		free_conn(conn);
 	spin_unlock(&nn->client_lock);
 	return status;
 out_put_session:
-- 
1.8.5.3
