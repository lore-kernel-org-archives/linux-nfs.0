Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:9665 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1731243AbeGWDal (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 23:30:41 -0400
From: nixiaoming <nixiaoming@huawei.com>
To: <bfields@fieldses.org>, <jlayton@kernel.org>,
        <chuck.lever@oracle.com>, <trondmy@hammerspace.com>,
        <andros@netapp.com>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <nixiaoming@huawei.com>
Subject: [PATCH v2] fs/nfsd: Delete invalid assignment statements in nfsd4_decode_exchange_id
Date: Mon, 23 Jul 2018 09:57:11 +0800
Message-ID: <20180723015711.27961-1-nixiaoming@huawei.com>
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
---
 fs/nfsd/nfs4xdr.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a96843c..375ad4b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1392,8 +1392,6 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 
 		/* ssp_window and ssp_num_gss_handles */
 		READ_BUF(8);
-		dummy = be32_to_cpup(p++);
-		dummy = be32_to_cpup(p++);
 		break;
 	default:
 		goto xdr_error;
-- 
2.10.1

