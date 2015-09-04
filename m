Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx144.netapp.com ([216.240.21.25]:6800 "EHLO mx144.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932849AbbIDRaC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Sep 2015 13:30:02 -0400
From: <andros@netapp.com>
To: <trond.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 2 09/16] NFSD add COPY_NOTIFY operation
Date: Fri, 4 Sep 2015 13:29:31 -0400
Message-ID: <1441387778-16465-10-git-send-email-andros@netapp.com>
In-Reply-To: <1441387778-16465-1-git-send-email-andros@netapp.com>
References: <1441387778-16465-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 110 +++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 128 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h     |  13 ++++++
 3 files changed, 249 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 2198e0a..ef6409e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,6 +35,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/slab.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "cache.h"
@@ -1070,6 +1071,94 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+static int
+nfsd4_set_src_nl4_netaddr(struct svc_rqst *rqstp, struct nfs42_netaddr *naddr)
+{
+	const struct sockaddr *addr = (struct sockaddr *)&rqstp->rq_daddr;
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+	int uaddr_len = rqstp->rq_daddrlen + 4 + 1; /* port (4) and '\0' (1) */
+	size_t ret;
+	unsigned short port;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		port = ntohs(sin->sin_port);
+		ret = rpc_ntop(addr, naddr->na_uaddr, sizeof(naddr->na_uaddr));
+		snprintf(naddr->na_uaddr + ret, uaddr_len, ".%u.%u",
+			 port >> 8, port & 255);
+		naddr->na_uaddr_len = strlen(naddr->na_uaddr);
+
+		snprintf(naddr->na_netid, 4, "%s", "tcp");
+			naddr->na_netid_len = 3;
+		break;
+	case AF_INET6:
+		port = ntohs(sin6->sin6_port);
+		ret = rpc_ntop(addr, naddr->na_uaddr, sizeof(naddr->na_uaddr));
+		snprintf(naddr->na_uaddr + ret, uaddr_len, ".%u.%u",
+			 port >> 8, port & 255);
+		naddr->na_uaddr_len = strlen(naddr->na_uaddr);
+
+		snprintf(naddr->na_netid, 5, "%s", "tcp6");
+			naddr->na_netid_len = 4;
+		break;
+	default:
+		dprintk("NFSD  nfsd4_set_notify_src: unknown address type: %d",
+			addr->sa_family);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static __be32
+nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  struct nfsd4_copy_notify *cp_notify)
+{
+	__be32 status;
+	struct file *src = NULL;
+	struct nfs42_netaddr *naddr;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate,
+					&cstate->current_fh,
+					&cp_notify->cpn_src_stateid,
+					RD_STATE, &src, NULL);
+	if (status)
+		return status;
+
+
+	/** XXX Save cpn_src_statid, cpn_src, and any other returned source
+	 * server addresses on which the source server is williing to accept
+	 * connections from the destination e.g. what is returned in cpn_src,
+	 * to verify READ from dest server.
+	 */
+
+	/**
+	 * For now, only return one source server address, the address used
+	 * by the client in the static cpn_src.
+	 */
+	cp_notify->cpn_nsrc = 1;
+	cp_notify->cpn_src[0].nl4_type = NL4_NETADDR;
+	naddr = &cp_notify->cpn_src[0].u.nl4_addr;
+
+	status = nfsd4_set_src_nl4_netaddr(rqstp, naddr);
+	if (status != 0)
+		goto out;
+
+	cp_notify->cpn_nsrc = 1;
+	cp_notify->cpn_sec = nn->nfsd4_lease;
+	cp_notify->cpn_nsec = 0;
+
+	dprintk("<-- %s cpn_dst %s:%s cpn_nsrc %d cpn_src %s:%s\n", __func__,
+		cp_notify->cpn_dst.u.nl4_addr.na_netid,
+		cp_notify->cpn_dst.u.nl4_addr.na_uaddr,
+		cp_notify->cpn_nsrc,
+		cp_notify->cpn_src[0].u.nl4_addr.na_netid,
+		cp_notify->cpn_src[0].u.nl4_addr.na_uaddr);
+out:
+	return status;
+}
+
 static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
@@ -2026,6 +2115,21 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		1 /* cr_synchronous */) * sizeof(__be32);
 }
 
+static inline u32 nfsd4_copy_notify_rsize(struct svc_rqst *rqstp,
+					struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size +
+		3 /* cnr_lease_time */ +
+		1 /* We support one cnr_source_server */ +
+		1 /* cnr_stateid seq */ +
+		op_encode_stateid_maxsz /* cnr_stateid */ +
+		1 /* num cnr_source_server*/ +
+		1 /* nl4_type */ +
+		1 /* nl4 size */ +
+		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) /*nl4_loc + nl4_loc_sz */)
+		* sizeof(__be32);
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
@@ -2362,6 +2466,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_func = (nfsd4op_func)nfsd4_seek,
 		.op_name = "OP_SEEK",
 	},
+	[OP_COPY_NOTIFY] = {
+		.op_func = (nfsd4op_func)nfsd4_copy_notify,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_COPY_NOTIFY",
+		.op_rsize_bop = (nfsd4op_rsize)nfsd4_copy_notify_rsize,
+	},
 };
 
 int nfsd4_max_reply(struct svc_rqst *rqstp, struct nfsd4_op *op)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 26df40e..2bcaeab 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1744,6 +1744,54 @@ intra:
 }
 
 static __be32
+nfsd4_decode_copy_notify(struct nfsd4_compoundargs *argp,
+			 struct nfsd4_copy_notify *cp_notify)
+{
+	DECODE_HEAD;
+	struct nfs42_netaddr *naddr;
+
+	status = nfsd4_decode_stateid(argp, &cp_notify->cpn_src_stateid);
+	if (status)
+		return status;
+
+	READ_BUF(4);
+	cp_notify->cpn_dst.nl4_type = be32_to_cpup(p++);
+	switch (cp_notify->cpn_dst.nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		READ_BUF(4);
+		cp_notify->cpn_dst.u.nl4_str_sz = be32_to_cpup(p++);
+		if (cp_notify->cpn_dst.u.nl4_str_sz > NFS4_OPAQUE_LIMIT)
+			goto xdr_error;
+		READ_BUF(cp_notify->cpn_dst.u.nl4_str_sz);
+		COPYMEM(cp_notify->cpn_dst.u.nl4_str,
+			cp_notify->cpn_dst.u.nl4_str_sz);
+		break;
+	case NL4_NETADDR:
+		naddr = &cp_notify->cpn_dst.u.nl4_addr;
+
+		READ_BUF(4);
+		naddr->na_netid_len = be32_to_cpup(p++);
+		if (naddr->na_netid_len > RPCBIND_MAXNETIDLEN)
+			goto xdr_error;
+		/* 4 for uaddr len */
+		READ_BUF(naddr->na_netid_len + 4);
+		COPYMEM(naddr->na_netid, naddr->na_netid_len);
+
+		naddr->na_uaddr_len = be32_to_cpup(p++);
+		if (naddr->na_uaddr_len > RPCBIND_MAXUADDRLEN)
+			goto xdr_error;
+		READ_BUF(naddr->na_uaddr_len);
+		COPYMEM(naddr->na_uaddr, naddr->na_uaddr_len);
+		break;
+	default:
+		goto xdr_error;
+	}
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1844,7 +1892,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4243,6 +4291,82 @@ nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
+nfsd4_encode_copy_notify(struct nfsd4_compoundres *resp, __be32 nfserr,
+			 struct nfsd4_copy_notify *cp_notify)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct nfs42_netaddr *addr;
+	__be32 *p;
+	int i;
+
+	if (nfserr)
+		return nfserr;
+
+	/* 8 sec, 4 nsec */
+	p = xdr_reserve_space(xdr, 12);
+	if (!p)
+		return nfserr_resource;
+
+	/* cnr_lease_time */
+	p = xdr_encode_hyper(p, cp_notify->cpn_sec);
+	*p++ = cpu_to_be32(cp_notify->cpn_nsec);
+
+	/* cnr_stateid */
+	nfserr = nfsd4_encode_stateid(xdr, &cp_notify->cpn_src_stateid);
+	if (nfserr)
+		return nfserr;
+
+	/* cnr_nsrc */
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
+
+	/* support a single NL4_NETADDR src address for now */
+	*p++ = cpu_to_be32(cp_notify->cpn_nsrc); /* set to 1 */
+	for (i = 0; i < cp_notify->cpn_nsrc; i++) {
+		p = xdr_reserve_space(xdr, 4);
+		*p++ = cpu_to_be32(cp_notify->cpn_src[i].nl4_type);
+
+		switch (cp_notify->cpn_src[i].nl4_type) {
+		case NL4_NAME:
+		case NL4_URL:
+			p = xdr_reserve_space(xdr,
+				4 /* url or name len */ +
+				(XDR_QUADLEN(cp_notify->cpn_src[i].u.nl4_str_sz) * 4));
+			if (!p)
+				return nfserr_resource;
+			*p++ = cpu_to_be32(cp_notify->cpn_src[i].u.nl4_str_sz);
+			p = xdr_encode_opaque_fixed(p,
+					cp_notify->cpn_src[i].u.nl4_str,
+					cp_notify->cpn_src[i].u.nl4_str_sz);
+			break;
+		case NL4_NETADDR:
+			addr = &cp_notify->cpn_src[i].u.nl4_addr;
+
+			/* netid_len, netid, uaddr_len, uaddr (port included
+			 * in RPCBIND_MAXUADDRLEN) */
+			p = xdr_reserve_space(xdr,
+				4 /* netid len */ +
+				(XDR_QUADLEN(addr->na_netid_len) * 4) +
+				4 /* uaddr len */ +
+				(XDR_QUADLEN(addr->na_uaddr_len) * 4));
+			if (!p)
+				return nfserr_resource;
+
+			*p++ = cpu_to_be32(addr->na_netid_len);
+			p = xdr_encode_opaque_fixed(p, addr->na_netid,
+						    addr->na_netid_len);
+			*p++ = cpu_to_be32(addr->na_uaddr_len);
+			p = xdr_encode_opaque_fixed(p, addr->na_uaddr,
+						    addr->na_uaddr_len);
+			break;
+		}
+	}
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4342,7 +4466,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index a018c3d..e4461f1 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -530,6 +530,19 @@ struct nfsd4_seek {
 	loff_t		seek_pos;
 };
 
+struct nfsd4_copy_notify {
+	/* request */
+	stateid_t		cpn_src_stateid;
+	struct nl4_server	cpn_dst;
+
+	/* response */
+	/* Note: cpn_src_stateid is used for cnr_stateid */
+	u64			cpn_sec;
+	u32			cpn_nsec;
+	u32			cpn_nsrc;
+	struct nl4_server	cpn_src[NFSD4_MAX_SSC_SRC];
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
-- 
1.8.3.1

