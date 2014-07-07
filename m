Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pd0-f172.google.com ([209.85.192.172]:55562 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753503AbaGGOL4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 7 Jul 2014 10:11:56 -0400
Received: by mail-pd0-f172.google.com with SMTP id w10so5433364pde.17
        for <linux-nfs@vger.kernel.org>; Mon, 07 Jul 2014 07:11:55 -0700 (PDT)
Message-ID: <53BAAA70.1030602@gmail.com>
Date: Mon, 07 Jul 2014 22:10:56 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>, kinglongmee@gmail.com
Subject: [PATCH 1/4] NFSD: Fix memory leak in encoding denied lock
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 8c7424cff6 (nfsd4: don't try to encode conflicting owner if low on space)
forgot free conf->data in nfsd4_encode_lockt and before sign conf->data to NULL
in nfsd4_encode_lock_denied.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5a1d088..007e322 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2884,6 +2884,7 @@ again:
 		 * return the conflicting open:
 		 */
 		if (conf->len) {
+			kfree(conf->data);
 			conf->len = 0;
 			conf->data = NULL;
 			goto again;
@@ -2896,6 +2897,7 @@ again:
 	if (conf->len) {
 		p = xdr_encode_opaque_fixed(p, &ld->ld_clientid, 8);
 		p = xdr_encode_opaque(p, conf->data, conf->len);
+		kfree(conf->data);
 	}  else {  /* non - nfsv4 lock in conflict, no clientid nor owner */
 		p = xdr_encode_hyper(p, (u64)0); /* clientid */
 		*p++ = cpu_to_be32(0); /* length of owner name */
@@ -2912,7 +2914,7 @@ nfsd4_encode_lock(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4_lo
 		nfserr = nfsd4_encode_stateid(xdr, &lock->lk_resp_stateid);
 	else if (nfserr == nfserr_denied)
 		nfserr = nfsd4_encode_lock_denied(xdr, &lock->lk_denied);
-	kfree(lock->lk_denied.ld_owner.data);
+
 	return nfserr;
 }
 
-- 
1.9.3

