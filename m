Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:40612 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752469AbdI1RaT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 28 Sep 2017 13:30:19 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <bfields@redhat.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH v4 3/8] NFSD add COPY_NOTIFY operation
Date: Thu, 28 Sep 2017 13:29:57 -0400
Message-ID: <20170928173002.50818-4-kolga@netapp.com>
In-Reply-To: <20170928173002.50818-1-kolga@netapp.com>
References: <20170928173002.50818-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Introducing the COPY_NOTIFY operation.

Create a new unique stateid that will keep track of the copy
state and the upcoming READs that will use that stateid. Keep
it in the list associated with parent stateid.

Return single netaddr to advertise to the copy.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 63 +++++++++++++++++++++++++++++++++-
 fs/nfsd/nfs4state.c |  3 ++
 fs/nfsd/nfs4xdr.c   | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/state.h     |  5 ++-
 fs/nfsd/xdr4.h      | 13 +++++++
 5 files changed, 177 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8d0c87f..0a2bab0 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -35,6 +35,7 @@
 #include <linux/file.h>
 #include <linux/falloc.h>
 #include <linux/slab.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "cache.h"
@@ -1263,7 +1264,8 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 			status = nfserrno(-ENOMEM);
 			goto out;
 		}
-		copy->cps = nfs4_alloc_init_cp_state(nn, copy->stid);
+		copy->cps = nfs4_alloc_init_cp_state(nn, nn->nfsd4_lease,
+							copy->stid);
 		if (!copy->cps) {
 			status = nfserrno(-ENOMEM);
 			kfree(async_copy);
@@ -1306,6 +1308,44 @@ static void nfsd4_do_async_copy(struct work_struct *work)
 }
 
 static __be32
+nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  union nfsd4_op_u *u)
+{
+	struct nfsd4_copy_notify *cn = &u->copy_notify;
+	__be32 status;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfs4_stid *stid;
+	struct nfs4_cp_state *cps;
+
+	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
+					&cn->cpn_src_stateid, RD_STATE, NULL,
+					NULL, &stid);
+	if (status)
+		return status;
+
+	cn->cpn_sec = nn->nfsd4_lease;
+	cn->cpn_nsec = 0;
+
+	status = nfserrno(-ENOMEM);
+	cps = nfs4_alloc_init_cp_state(nn, nn->nfsd4_lease, stid);
+	if (!cps)
+		return status;
+	memcpy(&cn->cpn_cnr_stateid, &cps->cp_stateid, sizeof(stateid_t));
+
+	/**
+	 * For now, only return one server address in cpn_src, the
+	 * address used by the client to connect to this server.
+	 */
+	cn->cpn_src.nl4_type = NL4_NETADDR;
+	status = nfsd4_set_netaddr((struct sockaddr *)&rqstp->rq_daddr,
+				 &cn->cpn_src.u.nl4_addr);
+	if (status != 0)
+		nfs4_free_cp_state(cps);
+
+	return status;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2251,6 +2291,21 @@ static inline u32 nfsd4_offload_status_rsize(struct svc_rqst *rqstp,
 		1 /* osr_complete<1> optional 0 for now */) * sizeof(__be32);
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
 static inline u32 nfsd4_getdeviceinfo_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
@@ -2674,6 +2729,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		.op_name = "OP_OFFLOAD_CANCEL",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
+	[OP_COPY_NOTIFY] = {
+		.op_func = nfsd4_copy_notify,
+		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_name = "OP_COPY_NOTIFY",
+		.op_rsize_bop = nfsd4_copy_notify_rsize,
+	},
 };
 
 /**
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f4b193e..9932d50 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -681,6 +681,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
  * the source file.
  */
 struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
+					       u64 cpn_sec,
 					       struct nfs4_stid *p_stid)
 {
 	struct nfs4_cp_state *cps;
@@ -700,6 +701,8 @@ struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn,
 	cps->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
 	cps->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
 	cps->cp_p_stid = p_stid;
+	cps->cp_active = false;
+	cps->cp_timeout = jiffies + (cpn_sec * HZ);
 	INIT_LIST_HEAD(&cps->cp_list);
 	list_add(&cps->cp_list, &p_stid->sc_cp_list);
 
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index ea3a231..a2d5238 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1839,6 +1839,22 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
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
@@ -1939,7 +1955,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4283,6 +4299,45 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
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
+	case NL4_NETADDR:
+		addr = &ns->u.nl4_addr;
+
+		/** netid_len, netid, uaddr_len, uaddr (port included
+		 * in RPCBIND_MAXUADDRLEN)
+		 */
+		p = xdr_reserve_space(xdr,
+			4 /* netid len */ +
+			(XDR_QUADLEN(addr->netid_len) * 4) +
+			4 /* uaddr len */ +
+			(XDR_QUADLEN(addr->addr_len) * 4));
+		if (!p)
+			return nfserr_resource;
+
+		*p++ = cpu_to_be32(addr->netid_len);
+		p = xdr_encode_opaque_fixed(p, addr->netid,
+					    addr->netid_len);
+		*p++ = cpu_to_be32(addr->addr_len);
+		p = xdr_encode_opaque_fixed(p, addr->addr,
+					addr->addr_len);
+		break;
+	default:
+		WARN_ON(ns->nl4_type != NL4_NETADDR);
+	}
+
+	return 0;
+}
+
+static __be32
 nfsd4_encode_copy(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_copy *copy)
 {
@@ -4322,6 +4377,44 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 }
 
 static __be32
+nfsd4_encode_copy_notify(struct nfsd4_compoundres *resp, __be32 nfserr,
+			 struct nfsd4_copy_notify *cn)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	__be32 *p;
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
+	nfserr = nfsd4_encode_stateid(xdr, &cn->cpn_cnr_stateid);
+	if (nfserr)
+		return nfserr;
+
+	/* cnr_src.nl_nsvr */
+	p = xdr_reserve_space(xdr, 4);
+	if (!p)
+		return nfserr_resource;
+
+	*p++ = cpu_to_be32(1);
+
+	nfserr = nfsd42_encode_nl4_server(resp, &cn->cpn_src);
+	if (nfserr)
+		return nfserr;
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4418,7 +4511,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 55f09a9..85b2d8b 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -114,6 +114,8 @@ struct nfs4_cp_state {
 	bool                    cp_cancelled;   /* copy cancelled */
 	spinlock_t              cp_lock;
 	ssize_t                 cp_bytes_copied;/* copy progress */
+	bool			cp_active;	/* has the copy started */
+	unsigned long		cp_timeout;	/* copy timeout */
 };
 
 /*
@@ -623,7 +625,8 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
-struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn, struct nfs4_stid *p_stid);
+struct nfs4_cp_state *nfs4_alloc_init_cp_state(struct nfsd_net *nn, u64 cpn_sec,
+					       struct nfs4_stid *p_stid);
 void nfs4_free_cp_state(struct nfs4_cp_state *cps);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ac01bc6..79f8ed4 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -561,6 +561,18 @@ struct nfsd4_offload_status {
 	u32		status;
 };
 
+struct nfsd4_copy_notify {
+	/* request */
+	stateid_t		cpn_src_stateid;
+	struct nl4_server	cpn_dst;
+
+	/* response */
+	stateid_t		cpn_cnr_stateid;
+	u64			cpn_sec;
+	u32			cpn_nsec;
+	struct nl4_server	cpn_src;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	const struct nfsd4_operation *		opdesc;
@@ -620,6 +632,7 @@ struct nfsd4_op {
 		struct nfsd4_clone		clone;
 		struct nfsd4_copy		copy;
 		struct nfsd4_offload_status	offload_status;
+		struct nfsd4_copy_notify	copy_notify;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
1.8.3.1

