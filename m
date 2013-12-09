Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f175.google.com ([209.85.192.175]:37685 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759895Ab3LILEb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 06:04:31 -0500
Received: by mail-pd0-f175.google.com with SMTP id w10so5039678pde.34
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 03:04:30 -0800 (PST)
Message-ID: <52A5A3B7.2000303@gmail.com>
Date: Mon, 09 Dec 2013 19:04:23 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: using nfsd4_encode_noop for encoding destroy_session/free_stateid
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Get rid of the extra code, using nfsd4_encode_noop for encoding destroy_session and free_stateid.
And, delete unused argument (fr_status) int nfsd4_free_stateid.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 26 ++------------------------
 fs/nfsd/xdr4.h    |  1 -
 2 files changed, 2 insertions(+), 25 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 91afb1c..b0b886e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3463,28 +3463,6 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
-nfsd4_encode_destroy_session(struct nfsd4_compoundres *resp, __be32 nfserr,
-			     struct nfsd4_destroy_session *destroy_session)
-{
-	return nfserr;
-}
-
-static __be32
-nfsd4_encode_free_stateid(struct nfsd4_compoundres *resp, __be32 nfserr,
-			  struct nfsd4_free_stateid *free_stateid)
-{
-	__be32 *p;
-
-	if (nfserr)
-		return nfserr;
-
-	RESERVE_SPACE(4);
-	*p++ = nfserr;
-	ADJUST_ARGS();
-	return nfserr;
-}
-
-static __be32
 nfsd4_encode_sequence(struct nfsd4_compoundres *resp, __be32 nfserr,
 		      struct nfsd4_sequence *seq)
 {
@@ -3582,8 +3560,8 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	[OP_BIND_CONN_TO_SESSION] = (nfsd4_enc)nfsd4_encode_bind_conn_to_session,
 	[OP_EXCHANGE_ID]	= (nfsd4_enc)nfsd4_encode_exchange_id,
 	[OP_CREATE_SESSION]	= (nfsd4_enc)nfsd4_encode_create_session,
-	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_destroy_session,
-	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_free_stateid,
+	[OP_DESTROY_SESSION]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_FREE_STATEID]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GET_DIR_DELEGATION]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICEINFO]	= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_GETDEVICELIST]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..916a407 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -374,7 +374,6 @@ struct nfsd4_test_stateid {
 
 struct nfsd4_free_stateid {
 	stateid_t	fr_stateid;         /* request */
-	__be32		fr_status;          /* response */
 };
 
 /* also used for NVERIFY */
-- 
1.8.4.2
