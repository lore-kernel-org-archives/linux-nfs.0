Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx142.netapp.com ([216.240.21.19]:37069 "EHLO mx142.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932425AbbCQWlR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Mar 2015 18:41:17 -0400
From: <andros@netapp.com>
To: <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <anna.schumaker@netapp.com>,
        <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH RFC 05/10] NFSD add COPY_NOTIFY operation
Date: Tue, 17 Mar 2015 18:31:33 -0400
Message-ID: <1426631498-14772-6-git-send-email-andros@netapp.com>
In-Reply-To: <1426631498-14772-1-git-send-email-andros@netapp.com>
References: <1426631498-14772-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfsd/nfs4proc.c | 106 +++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4xdr.c  | 109 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 fs/nfsd/xdr4.h     |  14 +++++++
 3 files changed, 223 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 89cb664..82240b6 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1077,6 +1077,93 @@ nfsd4_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	return status;
 }
 
+static int
+nfsd4_set_src_nl4_netaddr(struct svc_rqst *rqstp, struct nfsd4_addr *naddr)
+{
+	const struct sockaddr *addr = (struct sockaddr *)&rqstp->rq_daddr;
+	const struct sockaddr_in *sin = (const struct sockaddr_in *)addr;
+	const struct sockaddr_in6 *sin6 = (const struct sockaddr_in6 *)addr;
+	int uaddr_len = rqstp->rq_daddrlen + 4 + 1; /* port (4) and '\0' (1) */
+	unsigned short port;
+
+	switch (addr->sa_family) {
+	case AF_INET:
+		port = ntohs(sin->sin_port);
+		snprintf(naddr->na_uaddr_val, uaddr_len, "%pI4.%u.%u",
+		&sin->sin_addr, port >> 8, port & 255);
+		naddr->na_uaddr_len = strlen(naddr->na_uaddr_val);
+		dprintk("%s na_uaddr_val %s na_uaddr_len %d\n", __func__,
+			naddr->na_uaddr_val, naddr->na_uaddr_len);
+
+		/* note: buf size has room for trailing null space but
+		 * netid_len does not include the trailing null space */
+		snprintf(naddr->na_netid_val, 4, "%s", "tcp");
+			naddr->na_netid_len = 3;
+		dprintk("%s na_netid %s na_netid_len %d\n", __func__,
+			naddr->na_netid_val, naddr->na_netid_len);
+		break;
+	case AF_INET6:
+		/* XXX check this case - never tested */
+		port = ntohs(sin6->sin6_port);
+		snprintf(naddr->na_uaddr_val, naddr->na_uaddr_len,
+			"%pI6.%u.%u", &sin6->sin6_addr, port >> 8, port & 255);
+		snprintf(naddr->na_netid_val, 5, "%s", "tcp6");
+			naddr->na_netid_len = 4;
+	break;
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
+	struct nfsd4_addr *naddr;
+
+	status = nfs4_preprocess_stateid_op(SVC_NET(rqstp), cstate,
+					&cstate->current_fh,
+					&cp_notify->cpn_src_stateid,
+					RD_STATE, &src);
+	if (status)
+		return status;
+
+	/* XXX Set lease time in cp_notify cpn_sec and cpn_nsec */
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
+	cp_notify->cpn_src.nl4_type = NL4_NETADDR;
+	naddr = &cp_notify->cpn_src.nl4_addr;
+
+	status = nfsd4_set_src_nl4_netaddr(rqstp, naddr);
+	if (status != 0)
+		goto out;
+
+	cp_notify->cpn_nsrc = 1;
+
+	dprintk("<-- %s cpn_dst %s:%s cpn_src %s:%s\n", __func__,
+		cp_notify->cpn_dst.nl4_addr.na_netid_val,
+		cp_notify->cpn_dst.nl4_addr.na_uaddr_val,
+		cp_notify->cpn_src.nl4_addr.na_netid_val,
+		cp_notify->cpn_src.nl4_addr.na_uaddr_val);
+out:
+	return status;
+}
+
 static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
@@ -1826,10 +1913,6 @@ out:
 					 op_encode_ace_maxsz)
 
 #define op_encode_channel_attrs_maxsz	(6 + 1 + 1)
-#define op_encode_nfsd4_addr_maxsz	(2 /* the two lengths */ + \
-					 XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
-					 XDR_QUADLEN(RPCBIND_MAXUADDRLEN))
-
 
 static inline u32 nfsd4_only_status_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 {
@@ -2049,6 +2132,15 @@ static inline u32 nfsd4_copy_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1); /*nl4_loc + nl4_loc_sz */
 }
 
+static inline u32 nfsd4_copy_notify_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
+{
+	return (op_encode_hdr_size + 3 + /* cnr_lease_time */\
+		1 + /* We support one cnr_source_server */\
+		XDR_QUADLEN(NFS4_STATEID_SIZE) + /* cnr_stateid */ \
+		1 + /* nl4_type */\
+		XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + 1); /*nl4_loc + nl4_loc_sz */
+}
+
 static struct nfsd4_operation nfsd4_ops[] = {
 	[OP_ACCESS] = {
 		.op_func = (nfsd4op_func)nfsd4_access,
@@ -2391,6 +2483,12 @@ static struct nfsd4_operation nfsd4_ops[] = {
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
index d2d5e7f..afcb6c4 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1727,6 +1727,49 @@ intra:
 }
 
 static __be32
+nfsd4_decode_copy_notify(struct nfsd4_compoundargs *argp,
+			 struct nfsd4_copy_notify *cp_notify)
+{
+	DECODE_HEAD;
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
+		cp_notify->cpn_dst.nl4_loc_sz = be32_to_cpup(p++);
+		SAVEMEM(cp_notify->cpn_dst.nl4_loc, cp_notify->cpn_dst.nl4_loc_sz);
+		break;
+	case NL4_NETADDR:
+		READ_BUF(4);
+		cp_notify->cpn_dst.nl4_addr.na_netid_len = be32_to_cpup(p++);
+		if (cp_notify->cpn_dst.nl4_addr.na_netid_len > RPCBIND_MAXNETIDLEN + 1)
+			goto xdr_error;
+		/* 4 for uaddr len */
+		READ_BUF(cp_notify->cpn_dst.nl4_addr.na_netid_len + 4);
+		COPYMEM(cp_notify->cpn_dst.nl4_addr.na_netid_val,
+			cp_notify->cpn_dst.nl4_addr.na_netid_len);
+
+		cp_notify->cpn_dst.nl4_addr.na_uaddr_len = be32_to_cpup(p++);
+		if (cp_notify->cpn_dst.nl4_addr.na_uaddr_len > RPCBIND_MAXUADDRLEN + 1)
+			goto xdr_error;
+		READ_BUF(cp_notify->cpn_dst.nl4_addr.na_uaddr_len);
+		COPYMEM(cp_notify->cpn_dst.nl4_addr.na_uaddr_val,
+			cp_notify->cpn_dst.nl4_addr.na_uaddr_len);
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
@@ -1827,7 +1870,7 @@ static nfsd4_dec nfsd4_dec_ops[] = {
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4331,6 +4374,68 @@ err_truncate:
 }
 
 static __be32
+nfsd4_encode_copy_notify(struct nfsd4_compoundres *resp, __be32 nfserr,
+			 struct nfsd4_copy_notify *cp_notify)
+{
+	struct xdr_stream *xdr = &resp->xdr;
+	struct nfsd4_addr *addr;
+	__be32 *p;
+
+	if (nfserr)
+		return nfserr;
+
+	/* 8 sec, 4 nsec, 4 cpn_num_src */
+	p = xdr_reserve_space(xdr, 16);
+	if (!p)
+		return nfserr_resource;
+
+	/* cnr_lease_time */
+	p = xdr_encode_hyper(p, cp_notify->cpn_sec);
+	*p++ = cpu_to_be32(cp_notify->cpn_nsec);
+
+	/* cnr_stateid */
+	nfserr = nfsd4_encode_stateid(xdr, &cp_notify->cp_stateid);
+	if (nfserr)
+		return nfserr;
+
+	*p++ = cpu_to_be32(cp_notify->cpn_nsrc); /* set to 1 */
+
+	/* cnr_source_servers <>: encode a single NL4_NETADDR src address */
+	p = xdr_reserve_space(xdr, 4);
+	*p++ = cpu_to_be32(cp_notify->cpn_src.nl4_type);
+
+	switch (cp_notify->cpn_src.nl4_type) {
+	case NL4_NAME:
+	case NL4_URL:
+		p = xdr_reserve_space(xdr, 4 + XDR_QUADLEN(cp_notify->cpn_src.nl4_loc_sz));
+		if (!p)
+			return nfserr_resource;
+		*p++ = cpu_to_be32(cp_notify->cpn_src.nl4_loc_sz);
+		p = xdr_encode_opaque_fixed(p, cp_notify->cpn_src.nl4_loc,
+					cp_notify->cpn_src.nl4_loc_sz);
+		break;
+	case NL4_NETADDR:
+		addr = &cp_notify->cpn_src.nl4_addr;
+
+		/* netid_len, max netid, uaddr_len, max uaddr + 4(port) */
+		p = xdr_reserve_space(xdr, 4 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN)
+				+ 4 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + 4);
+		if (!p)
+			return nfserr_resource;
+
+		*p++ = cpu_to_be32(addr->na_netid_len);
+		p = xdr_encode_opaque_fixed(p, addr->na_netid_val, addr->na_netid_len);
+		*p++ = cpu_to_be32(addr->na_uaddr_len);
+		p = xdr_encode_opaque_fixed(p, addr->na_uaddr_val, addr->na_uaddr_len);
+		break;
+	default:
+		nfserr = nfserr_bad_xdr;
+	}
+
+	return nfserr;
+}
+
+static __be32
 nfsd4_encode_seek(struct nfsd4_compoundres *resp, __be32 nfserr,
 		  struct nfsd4_seek *seek)
 {
@@ -4430,7 +4535,7 @@ static nfsd4_enc nfsd4_enc_ops[] = {
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index be39051..97d80a6 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -539,6 +539,20 @@ struct nfsd4_seek {
 	loff_t		seek_pos;
 };
 
+struct nfsd4_copy_notify {
+	/* request */
+	stateid_t		cpn_src_stateid;
+	struct nfsd4_nl4	cpn_dst;
+
+	/* response */
+	stateid_t		cp_stateid;
+	u64			cpn_sec;
+	u32			cpn_nsec;
+	u32			cpn_nsrc;
+	/* one src sever address for now */
+	struct nfsd4_nl4	cpn_src;
+};
+
 struct nfsd4_op {
 	int					opnum;
 	__be32					status;
-- 
1.8.3.1

