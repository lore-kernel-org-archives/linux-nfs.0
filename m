Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:33793 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751690AbdBSS7O (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 19 Feb 2017 13:59:14 -0500
Received: by mail-io0-f193.google.com with SMTP id c80so3081775iod.1
        for <linux-nfs@vger.kernel.org>; Sun, 19 Feb 2017 10:59:14 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 5/8] NFSv4: Fix the underestimation of delegation XDR space reservation
Date: Sun, 19 Feb 2017 13:59:00 -0500
Message-Id: <20170219185903.42043-6-trond.myklebust@primarydata.com>
In-Reply-To: <20170219185903.42043-5-trond.myklebust@primarydata.com>
References: <20170219185903.42043-1-trond.myklebust@primarydata.com>
 <20170219185903.42043-2-trond.myklebust@primarydata.com>
 <20170219185903.42043-3-trond.myklebust@primarydata.com>
 <20170219185903.42043-4-trond.myklebust@primarydata.com>
 <20170219185903.42043-5-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Account for the "space_limit" field in struct open_write_delegation4.

Fixes: 2cebf82883f4 ("NFSv4: Fix the underestimate of NFSv4 open request size")
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4c40098c184b..91c386c09bf3 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -169,8 +169,10 @@ static int nfs4_stat_to_errno(int);
 				open_owner_id_maxsz + \
 				encode_opentype_maxsz + \
 				encode_claim_null_maxsz)
+#define decode_space_limit_maxsz	(3)
 #define decode_ace_maxsz	(3 + nfs4_owner_maxsz)
 #define decode_delegation_maxsz	(1 + decode_stateid_maxsz + 1 + \
+				decode_space_limit_maxsz + \
 				decode_ace_maxsz)
 #define decode_change_info_maxsz	(5)
 #define decode_open_maxsz	(op_decode_hdr_maxsz + \
-- 
2.9.3

