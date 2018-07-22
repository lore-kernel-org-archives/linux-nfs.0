Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from szxga04-in.huawei.com ([45.249.212.190]:9663 "EHLO huawei.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1728201AbeGVKVR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 22 Jul 2018 06:21:17 -0400
From: nixiaoming <nixiaoming@huawei.com>
To: <bfields@fieldses.org>, <jlayton@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <nixiaoming@huawei.com>
Subject: [PATCH] fs/nfsd: Delete invalid assignment statements in nfsd4_decode_exchange_id
Date: Sun, 22 Jul 2018 16:50:44 +0800
Message-ID: <20180722085044.50701-1-nixiaoming@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

dummy = be32_to_cpup(p++);
dummy = be32_to_cpup(p++);
Assigning value to "dummy" here, but that stored value
is overwritten before it can be used.

delete invalid assignment statements in nfsd4_decode_exchange_id

Signed-off-by: n00202754 <nixiaoming@huawei.com>
---
 fs/nfsd/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a96843c..8e78541 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1392,8 +1392,8 @@ nfsd4_decode_exchange_id(struct nfsd4_compoundargs *argp,
 
 		/* ssp_window and ssp_num_gss_handles */
 		READ_BUF(8);
-		dummy = be32_to_cpup(p++);
-		dummy = be32_to_cpup(p++);
+		be32_to_cpup(p++);
+		be32_to_cpup(p++);
 		break;
 	default:
 		goto xdr_error;
-- 
2.10.1

