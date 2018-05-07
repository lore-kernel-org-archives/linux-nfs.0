Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:54682 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752129AbeEGNBJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 7 May 2018 09:01:09 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: bfields@fieldses.org, jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: restrict rd_maxcount to svc_max_payload in nfsd_encode_readdir
Date: Mon,  7 May 2018 09:01:08 -0400
Message-Id: <20180507130108.7136-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nfsd4_readdir_rsize restricts rd_maxcount to svc_max_payload when
estimating the size of the readdir reply, but nfsd_encode_readdir
restricts it to INT_MAX when encoding the reply.  This can result in log
messages like "kernel: RPC request reserved 32896 but used 1049444".

Restrict rd_dircount similarly (no reason it should be larger than
svc_max_payload).

Signen-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1d048dd..cfe535c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3651,7 +3651,8 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 		nfserr = nfserr_resource;
 		goto err_no_verf;
 	}
-	maxcount = min_t(u32, readdir->rd_maxcount, INT_MAX);
+	maxcount = svc_max_payload(resp->rqstp);
+	maxcount = min_t(u32, readdir->rd_maxcount, maxcount);
 	/*
 	 * Note the rfc defines rd_maxcount as the size of the
 	 * READDIR4resok structure, which includes the verifier above
@@ -3665,7 +3666,7 @@ nfsd4_encode_readdir(struct nfsd4_compoundres *resp, __be32 nfserr, struct nfsd4
 
 	/* RFC 3530 14.2.24 allows us to ignore dircount when it's 0: */
 	if (!readdir->rd_dircount)
-		readdir->rd_dircount = INT_MAX;
+		readdir->rd_dircount = svc_max_payload(resp->rqstp);
 
 	readdir->xdr = xdr;
 	readdir->rd_maxcount = maxcount;
-- 
2.9.5

