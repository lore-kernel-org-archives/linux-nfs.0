Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:28539 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbbCQWlX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:23 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 04/10] NFSD add ca_source_server<> to COPY
Date: Tue, 17 Mar 2015 18:31:32 -0400
Message-ID: <1426631498-14772-5-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 12 ++++++++++++
 fs/nfsd/nfs4xdr.c  | 45 +++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h     | 16 ++++++++++++++++
 3 files changed, 71 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c0340df..89cb664 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1826,6 +1826,10 @@ out:
 					 op_encode_ace_maxsz)
 
 #define op_encode_channel_attrs_maxsz	(6 + 1 + 1)
+#define op_encode_nfsd4_addr_maxsz	(2 /* the two lengths */ + \
+					 XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
+					 XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
+
 
 static inline u32 nfsd4_only_status_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
@@ -2037,6 +2041,14 @@ static inline u32 nfsd4_layoutreturn_rsize(struct svc_rqst *rqstp, struct nfsd4_
 }
 #endif /* CONFIG_NFSD_PNFS */
 
+static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + op_encode_verifier_maxsz + \
+		1 + /* One cnr_source_server */\
+		1 + /* nl4_type */\
+		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1); /*nl4_loc + nl4_loc_sz */
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 201a88e..d2d5e7f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -39,6 +39,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1665,7 +1666,7 @@ static __be32
 nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 {
 	DECODE_HEAD;
-	unsigned int tmp;
+	struct nfsd4_addr *naddr;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1680,8 +1681,48 @@ nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	copy->cp_consecutive = be32_to_cpup(p++);
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = *p++; /* Source server list not supported */
+	copy->cp_nsrc = be32_to_cpup(p++);
 
+	if (copy->cp_nsrc == 0) /* intra-server copy */
+		goto intra;
+
+	READ_BUF(4);
+	copy->cp_src.nl4_type = be32_to_cpup(p++);
+
+	/* currently support for 1 inter-server source server */
+	switch (copy->cp_src.nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		READ_BUF(4);
+		copy->cp_src.nl4_loc_sz = be32_to_cpup(p++);
+		if (copy->cp_src.nl4_loc_sz > NFS4_OPAQUE_LIMIT + 1)
+			goto xdr_error;
+
+		READ_BUF(copy->cp_src.nl4_loc_sz);
+		COPYMEM(copy->cp_src.nl4_loc, copy->cp_src.nl4_loc_sz);
+		break;
+	case NL4_NETADDR:
+		naddr = &copy->cp_src.nl4_addr;
+
+		READ_BUF(4);
+		naddr->na_netid_len = be32_to_cpup(p++);
+		if (naddr->na_netid_len > RPCBIND_MAXNETIDLEN + 1)
+			goto xdr_error;
+
+		READ_BUF(naddr->na_netid_len + 4); /* 4 for uaddr len */
+		COPYMEM(naddr->na_netid_val, naddr->na_netid_len);
+
+		naddr->na_uaddr_len = be32_to_cpup(p++);
+		if (naddr->na_uaddr_len > RPCBIND_MAXUADDRLEN + 1)
+			goto xdr_error;
+
+		READ_BUF(naddr->na_uaddr_len);
+		COPYMEM(naddr->na_uaddr_val, naddr->na_uaddr_len);
+		break;
+	default:
+		goto xdr_error;
+	}
+intra:
 	DECODE_TAIL;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0e54e56..be39051 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -496,6 +496,20 @@ struct nfsd42_write_res {
 	nfs4_verifier		wr_verifier;
 };
 
+struct nfsd4_addr {
+	u32	na_netid_len;
+	char	na_netid_val[RPCBIND_MAXNETIDLEN];
+	u32 	na_uaddr_len;
+	char	na_uaddr_val[RPCBIND_MAXUADDRLEN];
+};
+
+struct nfsd4_nl4 {
+	u32	nl4_type;
+	u32	nl4_loc_sz;
+	char	*nl4_loc;		/* NL4_NAME, NL4_URL */
+	struct nfsd4_addr nl4_addr;	/* NL4_NETADDR */
+};
+
 struct nfsd4_copy {
 	/* request */
 	stateid_t	cp_src_stateid;
@@ -503,6 +517,8 @@ struct nfsd4_copy {
 	u64		cp_src_pos;
 	u64		cp_dst_pos;
 	u64		cp_count;
+	int		cp_nsrc;
+	struct nfsd4_nl4 cp_src;
 
 	/* both */
 	bool		cp_consecutive;
-- 
1.8.3.1

