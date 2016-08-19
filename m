Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40471 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755079AbcHSR00 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 19 Aug 2016 13:26:26 -0400
From: <andros@netapp.com>
To: <trondmy.myklebust@primarydata.com>
CC: <anna.schumaker@netapp.com>, <bfields@fieldses.org>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version-2 08/12] NFSD add COPY_NOTIFY operation
Date: Fri, 19 Aug 2016 13:25:08 -0400
Message-ID: <1471627512-4102-9-git-send-email-andros@netapp.com>
In-Reply-To: <1471627512-4102-1-git-send-email-andros@netapp.com>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 117 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/nfs4xdr.c  | 112 +++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h     |  13 ++++++
 3 files changed, 240 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index abb09b5..0a2c23d 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,6 +35,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/slab.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "cache.h"
@@ -1100,6 +1101,101 @@ out:
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
+		  struct nfsd4_copy_notify *cn)
+{
+	__be32 status;
+	struct file *src = NULL;
+	struct nfs42_netaddr *naddr;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nl4_server *ns;
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					&cn->cpn_src_stateid, RD_STATE, &src,
+					NULL);
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
+	 * For now, only return one server address in cpn_src, the
+	 * address used by the client to connect to this server.
+	 */
+	cn->cpn_src.nl_nsvr = 1;
+
+	/* freed in nfsd4_encode_copy_notify */
+	cn->cpn_src.nl_svr = kmalloc(cn->cpn_src.nl_nsvr *
+				sizeof(struct nfsd4_copy_notify), GFP_KERNEL);
+	if (cn->cpn_src.nl_svr == NULL)
+		return nfserrno(-ENOMEM);
+
+	ns = cn->cpn_src.nl_svr;
+	ns->nl4_type = NL4_NETADDR;
+	naddr = &ns->u.nl4_addr;
+
+	status = nfsd4_set_src_nl4_netaddr(rqstp, naddr);
+	if (status != 0)
+		goto out;
+
+	cn->cpn_sec = nn->nfsd4_lease;
+	cn->cpn_nsec = 0;
+
+	dprintk("<-- %s cpn_dst %s:%s nl_nsvr %d nl_svr %s:%s\n", __func__,
+		cn->cpn_dst.u.nl4_addr.na_netid,
+		cn->cpn_dst.u.nl4_addr.na_uaddr,
+		cn->cpn_src.nl_nsvr,
+		ns->u.nl4_addr.na_netid,
+		ns->u.nl4_addr.na_uaddr);
+out:
+	return status;
+}
+
 static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
@@ -2028,6 +2124,21 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
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
 #ifdef CONFIG_NFSD_PNFS
 /*
  * At this stage we don't really know what layout driver will handle the request,
@@ -2400,6 +2511,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
 
 /**
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index f601afb..f4bb29d 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1787,6 +1787,22 @@ intra:
 }
 
 static __be32
+nfsd4_decode_copy_notify(struct nfsd4_compoundargs *argp,
+			 struct nfsd4_copy_notify *cn)
+{
+	int status;
+
+	status = nfsd4_decode_stateid(argp, &cn->cpn_src_stateid);
+	if (status)
+		return status;
+	status = nfsd4_decode_nl4_server(argp, &cn->cpn_dst);
+	if (status)
+		return status;
+
+	return status;
+}
+
+static __be32
 nfsd4_decode_seek(struct nfsd4_compoundargs *argp, struct nfsd4_seek *seek)
 {
 	DECODE_HEAD;
@@ -1887,7 +1903,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4312,6 +4328,52 @@ nfsd42_encode_write_res(struct nfsd4_compoundres *resp, struct nfsd42_write_res
 }
 
 static __be32
+nfsd42_encode_nl4_server(struct nfsd4_compoundres *resp, struct nl4_server *ns)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct nfs42_netaddr *addr;
+	__be32 *p;
+
+	p = xdr_reserve_space(xdr, 4);
+	*p++ = cpu_to_be32(ns->nl4_type);
+
+	switch (ns->nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		p = xdr_reserve_space(xdr, 4 /* url or name len */ +
+				      (XDR_QUADLEN(ns->u.nl4_str_sz) * 4));
+		if (!p)
+			return nfserr_resource;
+		*p++ = cpu_to_be32(ns->u.nl4_str_sz);
+		p = xdr_encode_opaque_fixed(p, ns->u.nl4_str, ns->u.nl4_str_sz);
+			break;
+	case NL4_NETADDR:
+		addr = &ns->u.nl4_addr;
+
+		/** netid_len, netid, uaddr_len, uaddr (port included
+		 * in RPCBIND_MAXUADDRLEN)
+		 */
+		p = xdr_reserve_space(xdr,
+			4 /* netid len */ +
+			(XDR_QUADLEN(addr->na_netid_len) * 4) +
+			4 /* uaddr len */ +
+			(XDR_QUADLEN(addr->na_uaddr_len) * 4));
+		if (!p)
+			return nfserr_resource;
+
+		*p++ = cpu_to_be32(addr->na_netid_len);
+		p = xdr_encode_opaque_fixed(p, addr->na_netid,
+					    addr->na_netid_len);
+		*p++ = cpu_to_be32(addr->na_uaddr_len);
+		p = xdr_encode_opaque_fixed(p, addr->na_uaddr,
+					addr->na_uaddr_len);
+		break;
+	}
+
+	return 0;
+}
+
+static __be32
 nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_copy *copy)
 {
@@ -4332,6 +4394,52 @@ nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 }
 
 static __be32
+nfsd4_encode_copy_notify(struct nfsd4_compoundres *resp, __be32 nfserr,
+			 struct nfsd4_copy_notify *cn)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct nl4_server *ns;
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
+	p = xdr_encode_hyper(p, cn->cpn_sec);
+	*p++ = cpu_to_be32(cn->cpn_nsec);
+
+	/* cnr_stateid */
+	nfserr = nfsd4_encode_stateid(xdr, &cn->cpn_src_stateid);
+	if (nfserr)
+		return nfserr;
+
+	/* cnr_src.nl_nsvr */
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
+
+	*p++ = cpu_to_be32(cn->cpn_src.nl_nsvr);
+
+	ns = cn->cpn_src.nl_svr;
+	for (i = 0; i < cn->cpn_src.nl_nsvr; i++) {
+		nfserr = nfsd42_encode_nl4_server(resp, ns);
+		if (nfserr)
+			return nfserr;
+		ns++;
+	}
+
+	/* allocated in nfsd4_copy_notify */
+	kfree(cn->cpn_src.nl_svr);
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4431,7 +4539,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 6b1a61f..5db7cd8 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -540,6 +540,18 @@ struct nfsd4_seek {
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
+	struct nl4_servers	cpn_src;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
@@ -595,6 +607,7 @@ struct nfsd4_op {
 		struct nfsd4_fallocate		deallocate;
 		struct nfsd4_clone		clone;
 		struct nfsd4_copy		copy;
+		struct nfsd4_copy_notify	copy_notify;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
1.8.3.1

