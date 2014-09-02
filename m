Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:49485 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbaIBOPp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Sep 2014 10:15:45 -0400
Received: by mail-pa0-f47.google.com with SMTP id hz1so14794428pad.20
        for <linux-nfs@vger.kernel.org>; Tue, 02 Sep 2014 07:15:43 -0700 (PDT)
Message-ID: <5405D0FE.70008@gmail.com>
Date: Tue, 02 Sep 2014 22:15:26 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 6/6] NFSD: Put export if prepare_creds() fail
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfsfh.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index e883a58..88026fc 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -209,8 +209,10 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 		 * fix that case easily.
 		 */
 		struct cred *new = prepare_creds();
-		if (!new)
-			return nfserrno(-ENOMEM);
+		if (!new) {
+			error =  nfserrno(-ENOMEM);
+			goto out;
+		}
 		new->cap_effective =
 			cap_raise_nfsd_set(new->cap_effective,
 					   new->cap_permitted);
-- 
1.9.3

