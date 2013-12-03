Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f50.google.com ([209.85.220.50]:63843 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752026Ab3LCDk7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Dec 2013 22:40:59 -0500
Received: by mail-pa0-f50.google.com with SMTP id kl14so2294984pab.23
        for <linux-nfs@vger.kernel.org>; Mon, 02 Dec 2013 19:40:59 -0800 (PST)
Message-ID: <529D52C5.6050404@gmail.com>
Date: Tue, 03 Dec 2013 11:40:53 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH v2] Do not enter setup_callback_client when finding backchannel
 failed
References: <5295C982.1030904@gmail.com> <20131202145917.GF1960@fieldses.org>
In-Reply-To: <20131202145917.GF1960@fieldses.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Finding backchannel failed, nfsd should not enter setup_callback_client.

v2. drop ses checking in setup_callback_client and make code more clearer.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7f05cd1..44d33ce 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -975,11 +975,15 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
 	clear_bit(NFSD4_CLIENT_CB_UPDATE, &clp->cl_flags);
 	memcpy(&conn, &cb->cb_clp->cl_cb_conn, sizeof(struct nfs4_cb_conn));
 	c = __nfsd4_find_backchannel(clp);
-	if (c) {
-		svc_xprt_get(c->cn_xprt);
-		conn.cb_xprt = c->cn_xprt;
-		ses = c->cn_session;
+	if (!c) {
+		spin_unlock(&clp->cl_lock);
+		nfsd4_mark_cb_down(clp, -ENOTCONN);
+		return;
 	}
+
+	svc_xprt_get(c->cn_xprt);
+	conn.cb_xprt = c->cn_xprt;
+	ses = c->cn_session;
 	spin_unlock(&clp->cl_lock);
 
 	err = setup_callback_client(clp, &conn, ses);
-- 
1.8.4.2

