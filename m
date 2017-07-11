Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:58566 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934055AbdGKQow (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:52 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 34/42] NFSD xdr callback stateid in async COPY reply
Date: Tue, 11 Jul 2017 12:44:08 -0400
Message-ID: <20170711164416.1982-35-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 21 +++++++++++++++++----
 1 file changed, 17 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 745ad17..3211838 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4361,15 +4361,27 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
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
@@ -4430,7 +4442,8 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	__be32 *p;
 
 	if (!nfserr) {
-		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res);
+		nfserr = nfsd42_encode_write_res(resp, &copy->cp_res,
+				copy->cp_synchronous);
 		if (nfserr)
 			return nfserr;
 
-- 
1.8.3.1

