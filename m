Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:4446 "EHLO mx142.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933218AbeGIT03 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 9 Jul 2018 15:26:29 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v9 3/9] NFSD OFFLOAD_CANCEL xdr
Date: Mon, 9 Jul 2018 15:26:32 -0400
Message-ID: <20180709192638.44799-4-kolga@netapp.com>
In-Reply-To: <20180709192638.44799-1-kolga@netapp.com>
References: <20180709192638.44799-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 14 ++++++++++++++
 fs/nfsd/nfs4xdr.c  |  2 +-
 2 files changed, 15 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 15089b2..07ff6d0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1134,6 +1134,14 @@ static int fill_in_write_vector(struct kvec *vec, struct nfsd4_write *write)
 }
 
 static __be32
+nfsd4_offload_cancel(struct svc_rqst *rqstp,
+		     struct nfsd4_compound_state *cstate,
+		     union nfsd4_op_u *u)
+{
+	return 0;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2485,6 +2493,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		.op_name = "OP_OFFLOAD_STATUS",
 		.op_rsize_bop = nfsd4_offload_status_rsize,
 	},
+	[OP_OFFLOAD_CANCEL] = {
+		.op_func = nfsd4_offload_cancel,
+		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_name = "OP_OFFLOAD_CANCEL",
+		.op_rsize_bop = nfsd4_only_status_rsize,
+	},
 };
 
 /**
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3f2a620..54b9b64 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1882,7 +1882,7 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTSTATS]	= (nfsd4_dec)nfsd4_decode_notsupp,
-	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_OFFLOAD_CANCEL]	= (nfsd4_dec)nfsd4_decode_offload_status,
 	[OP_OFFLOAD_STATUS]	= (nfsd4_dec)nfsd4_decode_offload_status,
 	[OP_READ_PLUS]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_SEEK]		= (nfsd4_dec)nfsd4_decode_seek,
-- 
1.8.3.1

