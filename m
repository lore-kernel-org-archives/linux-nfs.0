Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:12257 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752302AbdCBQPB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 2 Mar 2017 11:15:01 -0500
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v1 11/18] NFSD xdr callback stateid in async COPY reply
Date: Thu, 2 Mar 2017 11:01:35 -0500
Message-ID: <20170302160142.30413-12-kolga@netapp.com>
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 26630ae..a101940 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4356,15 +4356,27 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 #endif /* CONFIG_NFSD_PNFS */
 
 static __be32
-nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res *write)
+nfsd42_encode_write_res(struct nfsd4_compoundres *resp,
+		struct nfsd42_write_res *write, bool sync)
 {
 	__be32 *p;
+	p = xdr_reserve_space(&resp->xdr, 4);
+	if (!p)
+		return nfserr_resource;
 
-	p = xdr_reserve_space(&resp->xdr, 4 + 8 + 4 + NFS4_VERIFIER_SIZE);
+	if (sync)
+		*p++ = cpu_to_be32(0);
+	else {
+		__be32 nfserr;
+		*p++ = cpu_to_be32(1);
+		nfserr = nfsd4_encode_stateid(&resp->xdr, &write->cb_stateid);
+		if (nfserr)
+			return nfserr;
+	}
+	p = xdr_reserve_space(&resp->xdr, 8 + 4 + NFS4_VERIFIER_SIZE);
 	if (!p)
 		return nfserr_resource;
 
-	*p++ = cpu_to_be32(0);
 	p = xdr_encode_hyper(p, write->wr_bytes_written);
 	*p++ = cpu_to_be32(write->wr_stable_how);
 	p = xdr_encode_opaque_fixed(p, write->wr_verifier.data,
@@ -4425,7 +4437,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 *p;
 
 	if (!nfserr) {
-		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
+		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res,
+				copy->cp_synchronous);
 		if (nfserr)
 			return nfserr;
 
-- 
1.8.3.1

