Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:19310 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932596AbbIDRaB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:01 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 08/16] NFSD add ca_source_server<> to COPY
Date: Fri, 4 Sep 2015 13:29:30 -0400
Message-ID: <1441387778-16465-9-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 14 +++++++++++++-
 fs/nfsd/nfs4xdr.c  | 49 +++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h     |  6 ++++++
 3 files changed, 66 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index fbfb509..2198e0a 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2014,6 +2014,18 @@ static inline u32 nfsd4_layoutreturn_rsize(struct svc_rqst *rqstp, struct nfsd4_
 }
 #endif /* CONFIG_NFSD_PNFS */
 
+static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size +
+		1 /* wr_callback */ +
+		op_encode_stateid_maxsz /* wr_callback */ +
+		2 /* wr_count */ +
+		1 /* wr_committed */ +
+		op_encode_verifier_maxsz +
+		1 /* cr_consecutive */ +
+		1 /* cr_synchronous */) * sizeof(__be32);
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
@@ -2344,7 +2356,7 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_copy,
 		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
 		.op_name = "OP_COPY",
-		.op_rsize_bop = (nfsd4op_rsize)nfsd4_write_rsize,
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_rsize,
 	},
 	[OP_SEEK] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3a78c7f..26df40e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,6 +40,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1678,7 +1679,8 @@ static __be32
 nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 {
 	DECODE_HEAD;
-	unsigned int tmp;
+	struct nfs42_netaddr *naddr;
+	int i;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1693,8 +1695,51 @@ nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	copy->cp_consecutive = be32_to_cpup(p++);
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */
+	copy->cp_nsrc = be32_to_cpup(p++);
+
+	if (copy->cp_nsrc == 0) /* intra-server copy */
+		goto intra;
+
+	for (i = 0; i < NFSD4_MAX_SSC_SRC; i++) {
+		READ_BUF(4);
+		copy->cp_src[i].nl4_type = be32_to_cpup(p++);
+
+		/* currently support for 1 inter-server source server */
+		switch (copy->cp_src[i].nl4_type) {
+		case NL4_NAME:
+		case NL4_URL:
+			READ_BUF(4);
+			copy->cp_src[i].u.nl4_str_sz = be32_to_cpup(p++);
+			if (copy->cp_src[i].u.nl4_str_sz > NFS4_OPAQUE_LIMIT)
+				goto xdr_error;
+
+			READ_BUF(copy->cp_src[i].u.nl4_str_sz);
+			COPYMEM(copy->cp_src[i].u.nl4_str,
+				copy->cp_src[i].u.nl4_str_sz);
+			break;
+		case NL4_NETADDR:
+			naddr = &copy->cp_src[i].u.nl4_addr;
+
+			READ_BUF(4);
+			naddr->na_netid_len = be32_to_cpup(p++);
+			if (naddr->na_netid_len > RPCBIND_MAXNETIDLEN)
+				goto xdr_error;
+
+			READ_BUF(naddr->na_netid_len + 4); /* 4 for uaddr len */
+			COPYMEM(naddr->na_netid, naddr->na_netid_len);
+
+			naddr->na_uaddr_len = be32_to_cpup(p++);
+			if (naddr->na_uaddr_len > RPCBIND_MAXUADDRLEN)
+				goto xdr_error;
 
+			READ_BUF(naddr->na_uaddr_len);
+			COPYMEM(naddr->na_uaddr, naddr->na_uaddr_len);
+			break;
+		default:
+			goto xdr_error;
+		}
+	}
+intra:
 	DECODE_TAIL;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 9e83f95..a018c3d 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -37,6 +37,7 @@
 #ifndef _LINUX_NFSD_XDR4_H
 #define _LINUX_NFSD_XDR4_H
 
+#include <linux/nfs4intercopy.h>
 #include "state.h"
 #include "nfsd.h"
 
@@ -497,6 +498,9 @@ struct nfsd42_write_res {
 	nfs4_verifier		wr_verifier;
 };
 
+/*  support 1 source server for now */
+#define NFSD4_MAX_SSC_SRC       1
+
 struct nfsd4_copy {
 	/* request */
 	stateid_t	cp_src_stateid;
@@ -504,6 +508,8 @@ struct nfsd4_copy {
 	u64		cp_src_pos;
 	u64		cp_dst_pos;
 	u64		cp_count;
+	int		cp_nsrc;
+	struct nl4_server cp_src[NFSD4_MAX_SSC_SRC];
 
 	/* both */
 	bool		cp_consecutive;
-- 
1.8.3.1

