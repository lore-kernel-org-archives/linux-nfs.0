Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35893 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751371Ab3LIKXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Dec 2013 05:23:51 -0500
Received: by mail-pd0-f178.google.com with SMTP id y10so4960894pdj.23
        for <linux-nfs@vger.kernel.org>; Mon, 09 Dec 2013 02:23:50 -0800 (PST)
Message-ID: <52A59A32.10500@gmail.com>
Date: Mon, 09 Dec 2013 18:23:46 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: clean up unnecessary temporary variable in nfsd4_decode_fattr
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

host_err was only used for nfs4_acl_new.
This patch delete it, and return nfserr_jukebox directly.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index fd48536..91afb1c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -252,7 +252,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 	int expected_len, len = 0;
 	u32 dummy32;
 	char *buf;
-	int host_err;
 
 	DECODE_HEAD;
 	iattr->ia_valid = 0;
@@ -279,10 +278,9 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 			return nfserr_resource;
 
 		*acl = nfs4_acl_new(nace);
-		if (*acl == NULL) {
-			host_err = -ENOMEM;
-			goto out_nfserr;
-		}
+		if (*acl == NULL)
+			return nfserr_jukebox;
+
 		defer_free(argp, kfree, *acl);
 
 		(*acl)->naces = nace;
@@ -420,10 +418,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		goto xdr_error;
 
 	DECODE_TAIL;
-
-out_nfserr:
-	status = nfserrno(host_err);
-	goto out;
 }
 
 static __be32
-- 
1.8.4.2
