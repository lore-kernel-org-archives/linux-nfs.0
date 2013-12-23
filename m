Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:34672 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753285Ab3LWKLI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Dec 2013 05:11:08 -0500
Received: by mail-pd0-f172.google.com with SMTP id g10so5004145pdj.3
        for <linux-nfs@vger.kernel.org>; Mon, 23 Dec 2013 02:11:07 -0800 (PST)
Message-ID: <52B80C36.8020000@gmail.com>
Date: Mon, 23 Dec 2013 18:11:02 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: fix bad length checking for backchannel
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

the length for backchannel checking should be multiplied by sizeof(__be32).

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 105d6fa..05f4db8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1851,6 +1851,11 @@ static __be32 check_forechannel_attrs(struct nfsd4_channel_attrs *ca, struct nfs
 	return nfs_ok;
 }
 
+#define NFSD_CB_MAX_REQ_SZ	((NFS4_enc_cb_recall_sz + \
+				 RPC_MAX_HEADER_WITH_AUTH) * sizeof(__be32))
+#define NFSD_CB_MAX_RESP_SZ	((NFS4_dec_cb_recall_sz + \
+				 RPC_MAX_REPHEADER_WITH_AUTH) * sizeof(__be32))
+
 static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
 {
 	ca->headerpadsz = 0;
@@ -1861,9 +1866,9 @@ static __be32 check_backchannel_attrs(struct nfsd4_channel_attrs *ca)
 	 * less than 1k.  Tighten up this estimate in the unlikely event
 	 * it turns out to be a problem for some client:
 	 */
-	if (ca->maxreq_sz < NFS4_enc_cb_recall_sz + RPC_MAX_HEADER_WITH_AUTH)
+	if (ca->maxreq_sz < NFSD_CB_MAX_REQ_SZ)
 		return nfserr_toosmall;
-	if (ca->maxresp_sz < NFS4_dec_cb_recall_sz + RPC_MAX_REPHEADER_WITH_AUTH)
+	if (ca->maxresp_sz < NFSD_CB_MAX_RESP_SZ)
 		return nfserr_toosmall;
 	ca->maxresp_cached = 0;
 	if (ca->maxops < 2)
-- 
1.8.4.2
