Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f54.google.com ([209.85.160.54]:63954 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566Ab3LEClq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Dec 2013 21:41:46 -0500
Received: by mail-pb0-f54.google.com with SMTP id un15so24901171pbc.13
        for <linux-nfs@vger.kernel.org>; Wed, 04 Dec 2013 18:41:45 -0800 (PST)
Message-ID: <529FE7E4.9010000@gmail.com>
Date: Thu, 05 Dec 2013 10:41:40 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] Define op_iattr for nfsd4_open instead using macro
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/xdr4.h | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index b3ed644..e603cdd 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -228,7 +228,7 @@ struct nfsd4_open {
 	u32		op_create;     	    /* request */
 	u32		op_createmode;      /* request */
 	u32		op_bmval[3];        /* request */
-	struct iattr	iattr;              /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
+	struct iattr	op_iattr;           /* UNCHECKED4, GUARDED4, EXCLUSIVE4_1 */
 	nfs4_verifier	op_verf __attribute__((aligned(32)));
 					    /* EXCLUSIVE4 */
 	clientid_t	op_clientid;        /* request */
@@ -250,7 +250,6 @@ struct nfsd4_open {
 	struct nfs4_acl *op_acl;
 	struct xdr_netobj op_label;
 };
-#define op_iattr	iattr
 
 struct nfsd4_open_confirm {
 	stateid_t	oc_req_stateid		/* request */;
-- 
1.8.4.2
