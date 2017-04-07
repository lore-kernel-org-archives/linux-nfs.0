Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:2540 "EHLO mx141.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932731AbdDGSPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 7 Apr 2017 14:15:52 -0400
From: <Anna.Schumaker@Netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 09/34] NFS: Clean up encode_cb_sequence_res()
Date: Fri, 7 Apr 2017 14:15:03 -0400
Message-ID: <20170407181528.2832-10-Anna.Schumaker@Netapp.com>
In-Reply-To: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
References: <20170407181528.2832-1-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/callback_xdr.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 4cf70dc59933..e54e697340a4 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -692,11 +692,11 @@ static __be32 encode_cb_sequence_res(struct svc_rqst *rqstp,
 	__be32 status = res->csr_status;
 
 	if (unlikely(status != 0))
-		goto out;
+		return status;
 
 	status = encode_sessionid(xdr, &res->csr_sessionid);
 	if (status)
-		goto out;
+		return status;
 
 	p = xdr_reserve_space(xdr, 4 * sizeof(uint32_t));
 	if (unlikely(p == NULL))
@@ -706,9 +706,7 @@ static __be32 encode_cb_sequence_res(struct svc_rqst *rqstp,
 	*p++ = htonl(res->csr_slotid);
 	*p++ = htonl(res->csr_highestslotid);
 	*p++ = htonl(res->csr_target_highestslotid);
-out:
-	dprintk("%s: exit with status = %d\n", __func__, ntohl(status));
-	return status;
+	return 0;
 }
 
 static __be32
-- 
2.12.2

