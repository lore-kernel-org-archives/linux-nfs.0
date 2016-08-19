Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:22146 "EHLO mx144.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755458AbcHSRZu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:25:50 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version-2 07/12] NFSD add ca_source_server<> to COPY
Date: Fri, 19 Aug 2016 13:25:07 -0400
Message-ID: <1471627512-4102-8-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Note: followed conventiona and have struct nfsd4_compoundargs pointer as a
parameter even though it is unused.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 75 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h    |  4 +++
 2 files changed, 77 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 5e148d4..f601afb 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,6 +40,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1693,11 +1694,58 @@ nfsd4_decode_clone(struct nfsd4_compoundargs *argp, struct nfsd4_clone *clone)
 	DECODE_TAIL;
 }
 
+static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
+				      struct nl4_server *ns)
+{
+	DECODE_HEAD;
+	struct nfs42_netaddr *naddr;
+
+	READ_BUF(4);
+	ns->nl4_type = be32_to_cpup(p++);
+
+	/* currently support for 1 inter-server source server */
+	switch (ns->nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		READ_BUF(4);
+		ns->u.nl4_str_sz = be32_to_cpup(p++);
+		if (ns->u.nl4_str_sz > NFS4_OPAQUE_LIMIT)
+			goto xdr_error;
+
+		READ_BUF(ns->u.nl4_str_sz);
+		COPYMEM(ns->u.nl4_str,
+			ns->u.nl4_str_sz);
+		break;
+	case NL4_NETADDR:
+		naddr = &ns->u.nl4_addr;
+
+		READ_BUF(4);
+		naddr->na_netid_len = be32_to_cpup(p++);
+		if (naddr->na_netid_len > RPCBIND_MAXNETIDLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->na_netid_len + 4); /* 4 for uaddr len */
+		COPYMEM(naddr->na_netid, naddr->na_netid_len);
+
+		naddr->na_uaddr_len = be32_to_cpup(p++);
+		if (naddr->na_uaddr_len > RPCBIND_MAXUADDRLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->na_uaddr_len);
+		COPYMEM(naddr->na_uaddr, naddr->na_uaddr_len);
+		break;
+	default:
+		goto xdr_error;
+	}
+	DECODE_TAIL;
+}
+
 static __be32
 nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 {
 	DECODE_HEAD;
-	unsigned int tmp;
+	struct nl4_server *ns;
+	int i;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1712,8 +1760,29 @@ nfsd4_decode_copy(struct nfsd4_compoundargs *argp, struct nfsd4_copy *copy)
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	copy->cp_consecutive = be32_to_cpup(p++);
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */
+	copy->cp_src.nl_nsvr = be32_to_cpup(p++);
 
+	if (copy->cp_src.nl_nsvr == 0) /* intra-server copy */
+		goto intra;
+
+	/** Support NFSD4_MAX_SSC_SRC number of source servers.
+	 * freed in nfsd4_encode_copy
+	 */
+	if (copy->cp_src.nl_nsvr > NFSD4_MAX_SSC_SRC)
+		copy->cp_src.nl_nsvr = NFSD4_MAX_SSC_SRC;
+	copy->cp_src.nl_svr = kmalloc(copy->cp_src.nl_nsvr *
+					sizeof(struct nl4_server), GFP_KERNEL);
+	if (copy->cp_src.nl_svr == NULL)
+		return nfserrno(-ENOMEM);
+
+	ns = copy->cp_src.nl_svr;
+	for (i = 0; i < copy->cp_src.nl_nsvr; i++) {
+		status = nfsd4_decode_nl4_server(argp, ns);
+		if (status)
+			return status;
+		ns++;
+	}
+intra:
 	DECODE_TAIL;
 }
 
@@ -4257,6 +4326,8 @@ nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 		*p++ = cpu_to_be32(copy->cp_consecutive);
 		*p++ = cpu_to_be32(copy->cp_synchronous);
 	}
+	/* allocated in nfsd4_decode_copy */
+	kfree(copy->cp_src.nl_svr);
 	return nfserr;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 8fda4ab..6b1a61f 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -509,6 +509,9 @@ struct nfsd42_write_res {
 	nfs4_verifier		wr_verifier;
 };
 
+/*  support 1 source server for now */
+#define NFSD4_MAX_SSC_SRC       1
+
 struct nfsd4_copy {
 	/* request */
 	stateid_t	cp_src_stateid;
@@ -516,6 +519,7 @@ struct nfsd4_copy {
 	u64		cp_src_pos;
 	u64		cp_dst_pos;
 	u64		cp_count;
+	struct nl4_servers cp_src;
 
 	/* both */
 	bool		cp_consecutive;
-- 
1.8.3.1

