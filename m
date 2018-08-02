Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:10614 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S2387411AbeHBPAk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Aug 2018 11:00:40 -0400
From: nixiaoming <nixiaoming@huawei.com>
To: <bfields@fieldses.org>, <jlayton@kernel.org>,
        <trondmy@hammerspace.com>, <chuck.lever@oracle.com>,
        <nixiaoming@huawei.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Subject: [PATCH v3] fs/nfsd: Delete invalid assignment statements in nfsd4_decode_exchange_id
Date: Thu, 2 Aug 2018 20:32:45 +0800
Message-ID: <20180802123245.4276-1-nixiaoming@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

READ_BUF(8);
dummy = be32_to_cpup(p++);
dummy = be32_to_cpup(p++);
...
READ_BUF(4);
dummy = be32_to_cpup(p++);

Assigning value to "dummy" here, but that stored value
is overwritten before it can be used.
At the same time READ_BUF() will re-update the pointer p.

delete invalid assignment statements

Signed-off-by: nixiaoming <nixiaoming@huawei.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <trondmy@hammerspace.com>
Signed-off-by: J. Bruce Fields <bfields@fieldses.org>
---
 fs/nfsd/nfs4xdr.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a96843c..e669e20 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1390,10 +1390,8 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 			p += XDR_QUADLEN(dummy);
 		}
 
-		/* ssp_window and ssp_num_gss_handles */
+		/* ignore ssp_window and ssp_num_gss_handles */
 		READ_BUF(8);
-		dummy = be32_to_cpup(p++);
-		dummy = be32_to_cpup(p++);
 		break;
 	default:
 		goto xdr_error;
-- 
2.10.1

