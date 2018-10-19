Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt1-f196.google.com ([209.85.160.196]:38499 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726860AbeJSXfy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 19 Oct 2018 19:35:54 -0400
Received: by mail-qt1-f196.google.com with SMTP id r22-v6so2160861qtm.5
        for <linux-nfs@vger.kernel.org>; Fri, 19 Oct 2018 08:29:18 -0700 (PDT)
From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v1 07/13] NFSD add ca_source_server<> to COPY
Date: Fri, 19 Oct 2018 11:28:59 -0400
Message-Id: <20181019152905.32418-8-olga.kornievskaia@gmail.com>
In-Reply-To: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
References: <20181019152905.32418-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Note: followed conventions and have struct nfsd4_compoundargs pointer as a
parameter even though it is unused.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4xdr.c | 71 +++++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/xdr4.h    |  1 +
 2 files changed, 70 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 3de42a7..9f6886f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -40,6 +40,7 @@
 #include <linux/utsname.h>
 #include <linux/pagemap.h>
 #include <linux/sunrpc/svcauth_gss.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "acl.h"
@@ -1743,11 +1744,58 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
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
+		naddr->netid_len = be32_to_cpup(p++);
+		if (naddr->netid_len > RPCBIND_MAXNETIDLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->netid_len + 4); /* 4 for uaddr len */
+		COPYMEM(naddr->netid, naddr->netid_len);
+
+		naddr->addr_len = be32_to_cpup(p++);
+		if (naddr->addr_len > RPCBIND_MAXUADDRLEN)
+			goto xdr_error;
+
+		READ_BUF(naddr->addr_len);
+		COPYMEM(naddr->addr, naddr->addr_len);
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
+	int i, count;
 
 	status = nfsd4_decode_stateid(argp, &copy->cp_src_stateid);
 	if (status)
@@ -1762,8 +1810,24 @@ static __be32 nfsd4_decode_reclaim_complete(struct nfsd4_compoundargs *argp, str
 	p = xdr_decode_hyper(p, &copy->cp_count);
 	p++; /* ca_consecutive: we always do consecutive copies */
 	copy->cp_synchronous = be32_to_cpup(p++);
-	tmp = be32_to_cpup(p); /* Source server list not supported */
+	count = be32_to_cpup(p++);
+
+	if (count == 0) /* intra-server copy */
+		goto intra;
 
+	/* decode all the supplied server addresses but use first */
+	copy->cp_src = kmalloc(count * sizeof(struct nl4_server), GFP_KERNEL);
+	if (copy->cp_src == NULL)
+		return nfserrno(-ENOMEM);
+
+	ns = copy->cp_src;
+	for (i = 0; i < count; i++) {
+		status = nfsd4_decode_nl4_server(argp, ns);
+		if (status)
+			return status;
+		ns++;
+	}
+intra:
 	DECODE_TAIL;
 }
 
@@ -4273,6 +4337,9 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	p = xdr_reserve_space(&resp->xdr, 4 + 4);
 	*p++ = xdr_one; /* cr_consecutive */
 	*p++ = cpu_to_be32(copy->cp_synchronous);
+
+	/* allocated in nfsd4_decode_copy */
+	kfree(copy->cp_src);
 	return 0;
 }
 
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index feeb6d4..b4d1140 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -521,6 +521,7 @@ struct nfsd4_copy {
 	u64		cp_src_pos;
 	u64		cp_dst_pos;
 	u64		cp_count;
+	struct nl4_server *cp_src;
 
 	/* both */
 	bool		cp_synchronous;
-- 
1.8.3.1
