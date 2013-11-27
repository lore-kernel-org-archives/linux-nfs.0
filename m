Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:58133 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873Ab3K0K3Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Nov 2013 05:29:25 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so9653671pdj.31
        for <linux-nfs@vger.kernel.org>; Wed, 27 Nov 2013 02:29:25 -0800 (PST)
Message-ID: <5295C982.1030904@gmail.com>
Date: Wed, 27 Nov 2013 18:29:22 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: [PATCH] Do not enter setup_callback_client when finding backchannel
 failed
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If finding backchannel failed, nfsd should not enter setup_callback_client.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd1..755d6d6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -664,7 +664,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		args.authflavor = clp->cl_cred.cr_flavor;
 		clp->cl_cb_ident = conn->cb_ident;
 	} else {
-		if (!conn->cb_xprt)
+		if (!conn->cb_xprt || !ses)
 			return -EINVAL;
 		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
 		clp->cl_cb_session = ses;
@@ -982,7 +982,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	}
 	spin_unlock(&clp->cl_lock);
 
-	err = setup_callback_client(clp, &conn, ses);
+	err = c ? setup_callback_client(clp, &conn, ses) : -ENOENT;
 	if (err) {
 		nfsd4_mark_cb_down(clp, err);
 		return;
-- 
1.8.4.2
