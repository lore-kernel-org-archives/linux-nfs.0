Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34037 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752449AbaF2LSy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Jun 2014 07:18:54 -0400
Received: by mail-pa0-f47.google.com with SMTP id kq14so6982595pab.20
        for <linux-nfs@vger.kernel.org>; Sun, 29 Jun 2014 04:18:53 -0700 (PDT)
Message-ID: <53AFF5F9.2040401@gmail.com>
Date: Sun, 29 Jun 2014 19:18:17 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: kbuild test robot <fengguang.wu@intel.com>
CC: "J. Bruce Fields" <bfields@redhat.com>, kbuild-all@01.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com
Subject: [PATCH] NFSD: Avoid warning message when compile at i686 arch
References: <53aebf38.2Sl+piCGJ4BiEZLl%fengguang.wu@intel.com>
In-Reply-To: <53aebf38.2Sl+piCGJ4BiEZLl%fengguang.wu@intel.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

fs/nfsd/nfs4xdr.c: In function 'nfsd4_encode_readv':
>> fs/nfsd/nfs4xdr.c:3137:148: warning: comparison of distinct pointer types lacks a cast [enabled by default]
thislen = min(len, ((void *)xdr->end - (void *)xdr->p));

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ec198fa..1b61fbe 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3150,7 +3150,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	len = maxcount;
 	v = 0;
 
-	thislen = min(len, ((void *)xdr->end - (void *)xdr->p));
+	thislen = min_t(long, len, ((void *)xdr->end - (void *)xdr->p));
 	p = xdr_reserve_space(xdr, (thislen+3)&~3);
 	WARN_ON_ONCE(!p);
 	resp->rqstp->rq_vec[v].iov_base = p;
-- 
1.9.3


