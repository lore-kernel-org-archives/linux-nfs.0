Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:31185 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934016AbdGKQov (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 11 Jul 2017 12:44:51 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [RFC v3 33/42] NFSD OFFLOAD_CANCEL xdr
Date: Tue, 11 Jul 2017 12:44:07 -0400
Message-ID: <20170711164416.1982-34-kolga@netapp.com>
In-Reply-To: <20170711164416.1982-1-kolga@netapp.com>
References: <20170711164416.1982-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 13 +++++++++++++
 fs/nfsd/nfs4xdr.c  |  2 +-
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 6d20ee1..5dd8278 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1447,6 +1447,14 @@ extern struct file *nfs42_ssc_open(struct vfsmount *ss_mnt,
 }
 
 static __be32
+nfsd4_offload_cancel(struct svc_rqst *rqstp,
+		     struct nfsd4_compound_state *cstate,
+		     struct nfsd4_offload_status *os)
+{
+	return 0;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2866,6 +2874,11 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		.op_name = "OP_OFFLOAD_STATUS",
 		.op_rsize_bop = (nfsd4op_rsize)nfsd4_offload_status_rsize,
 	},
+	[OP_OFFLOAD_CANCEL] = {
+		.op_func = (nfsd4op_func)nfsd4_offload_cancel,
+		.op_name = "OP_OFFLOAD_CANCEL",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_only_status_rsize,
+	},
 };
 
 /**
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f032178..745ad17 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1948,7 +1948,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
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

