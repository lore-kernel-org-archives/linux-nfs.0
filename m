Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:33147 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751366AbdBEB5x (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 4 Feb 2017 20:57:53 -0500
Received: by mail-io0-f194.google.com with SMTP id 101so5991676iom.0
        for <linux-nfs@vger.kernel.org>; Sat, 04 Feb 2017 17:57:53 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 3/3] nfsd/callback: Drop an useless data copy when comparing
 sessionid
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <dd77a6cd-c269-e326-ced6-d91a858d389b@gmail.com>
Date: Sun, 5 Feb 2017 09:57:48 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4callback.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index ea74149..0274db6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -397,13 +397,10 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 				    struct nfsd4_callback *cb)
 {
 	struct nfsd4_session *session = cb->cb_clp->cl_cb_session;
-	struct nfs4_sessionid id;
-	int status;
+	int status = -ESERVERFAULT;
 	__be32 *p;
 	u32 dummy;
 
-	status = -ESERVERFAULT;
-
 	/*
 	 * If the server returns different values for sessionID, slotID or
 	 * sequence number, the server is looney tunes.
@@ -411,9 +408,8 @@ static int decode_cb_sequence4resok(struct xdr_stream *xdr,
 	p = xdr_inline_decode(xdr, NFS4_MAX_SESSIONID_LEN + 4 + 4 + 4 + 4);
 	if (unlikely(p == NULL))
 		goto out_overflow;
-	memcpy(id.data, p, NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, session->se_sessionid.data,
-					NFS4_MAX_SESSIONID_LEN) != 0) {
+
+	if (memcmp(p, session->se_sessionid.data, NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("NFS: %s Invalid session id\n", __func__);
 		goto out;
 	}
-- 
2.9.3

