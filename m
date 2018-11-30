Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4312C04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 568A22082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="XwmtCB+s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 568A22082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726719AbeLAHO2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:28 -0500
Received: from mail-oi1-f196.google.com ([209.85.167.196]:33236 "EHLO
        mail-oi1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHO1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:27 -0500
Received: by mail-oi1-f196.google.com with SMTP id c206so5811679oib.0;
        Fri, 30 Nov 2018 12:04:03 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=+8IjNlR4m8iNcn92mIpfB3bj3xZ7QGHHKieRRv/s0UY=;
        b=XwmtCB+sqR2JiSGjrF052Oa36SNhITLdm02m17+VOrLaTWeyO2CJ3vGuy/R5KHkezu
         ZY/7FeDmPsYU9+pFYAsp7B9u4MSWAW+SB/rDIvNwUuxyStnCbBzvw/TpLVVKJeUNcM0n
         FAJJaE5oF9WTq5eIBCLzJi3nfAROnYKkn9G3YEqIfqYJ6oH8jtejMVfagSmZ88uyVzdT
         UWE1lRt64ztxgnD+fL6vaHMMLt62XyAMJfQmatnLY3SD6PWBYWki2EBjZhjYdPh/Zdut
         FSjkq6m+r7qn7d1WCyCw0GjkHqjZxIgXWxCh/ulNir/V3C2KkCgmIMKGROXbMV6nZrLI
         C2VA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=+8IjNlR4m8iNcn92mIpfB3bj3xZ7QGHHKieRRv/s0UY=;
        b=ATMQ7dsvKxa8rzJaiZvXzcxe9W5XFLZiyExQd4IzTbJQ8/me2rfO/1P7DjTZBmtaG6
         iMFy1Znq7WfO02wnjwJwhpYizhANmtrOQf68u7okWEPvFyLi/d0PX9a78x4+dwZQNaEI
         p0HOLdQq27cpNFbWuZpQa7wItVrbAmzGqPvKXIlEmS+kVIE8nZ+eIqPxYZ/d7sH4QtYZ
         f4DfZNawDALuxuHxorWvEcCDBTAhmjFIB36yN9EIG6kWtuAYkFM3GMPDXBTyLiboSYqC
         lW261iLxNiFQzI+XQEe8Fxvhno7dBzLQYtBCC55FzBSjd5H1wMxC+yU3XbJgfP3dfXCT
         cMaQ==
X-Gm-Message-State: AA+aEWZH21cjK3oiTG60J2WDIhaqU7YIf/ONypMGcTym6vfRZ6dIfIw0
        NWpMWz/GJtJFLFmWdH7nOyxbZqFb
X-Google-Smtp-Source: AFSGD/WsqXmOLzV3lZ1eE1wACOzSVIVOiwjUZ47AHTJSopTv38gM3RVVwv7K1QxmKL0MovnynrVkHw==
X-Received: by 2002:aca:c207:: with SMTP id s7mr4297684oif.1.1543608242311;
        Fri, 30 Nov 2018 12:04:02 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.04.01
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:04:01 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 06/10] NFSD add COPY_NOTIFY operation
Date:   Fri, 30 Nov 2018 15:03:44 -0500
Message-Id: <20181130200348.59524-7-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Introducing the COPY_NOTIFY operation.

Create a new unique stateid that will keep track of the copy
state and the upcoming READs that will use that stateid. Keep
it in the list associated with parent stateid.

Return single netaddr to advertise to the copy.

Signed-off-by: Andy Adamson <andros@netapp.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c  | 72 +++++++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4state.c | 64 +++++++++++++++++++++++++++++++----
 fs/nfsd/nfs4xdr.c   | 97 +++++++++++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/state.h     | 18 ++++++++--
 fs/nfsd/xdr4.h      | 13 +++++++
 5 files changed, 248 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0152b34..51fca9e 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -37,6 +37,7 @@
 #include <linux/falloc.h>
 #include <linux/slab.h>
 #include <linux/kthread.h>
+#include <linux/sunrpc/addr.h>
 
 #include "idmap.h"
 #include "cache.h"
@@ -1035,7 +1036,8 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 static __be32
 nfsd4_verify_copy(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  stateid_t *src_stateid, struct file **src,
-		  stateid_t *dst_stateid, struct file **dst)
+		  stateid_t *dst_stateid, struct file **dst,
+		  struct nfs4_stid **stid)
 {
 	__be32 status;
 
@@ -1052,7 +1054,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 
 	status = nfs4_preprocess_stateid_op(rqstp, cstate, &cstate->current_fh,
 					    dst_stateid, WR_STATE, dst, NULL,
-					    NULL);
+					    stid);
 	if (status) {
 		dprintk("NFSD: %s: couldn't process dst stateid!\n", __func__);
 		goto out_put_src;
@@ -1083,7 +1085,7 @@ static __be32 nfsd4_do_lookupp(struct svc_rqst *rqstp, struct svc_fh *fh)
 	__be32 status;
 
 	status = nfsd4_verify_copy(rqstp, cstate, &clone->cl_src_stateid, &src,
-				   &clone->cl_dst_stateid, &dst);
+				   &clone->cl_dst_stateid, &dst, NULL);
 	if (status)
 		goto out;
 
@@ -1230,7 +1232,7 @@ static void dup_copy_fields(struct nfsd4_copy *src, struct nfsd4_copy *dst)
 
 static void cleanup_async_copy(struct nfsd4_copy *copy)
 {
-	nfs4_free_cp_state(copy);
+	nfs4_free_copy_state(copy);
 	fput(copy->file_dst);
 	fput(copy->file_src);
 	spin_lock(&copy->cp_clp->async_lock);
@@ -1270,7 +1272,7 @@ static int nfsd4_do_async_copy(void *data)
 
 	status = nfsd4_verify_copy(rqstp, cstate, &copy->cp_src_stateid,
 				   &copy->file_src, &copy->cp_dst_stateid,
-				   &copy->file_dst);
+				   &copy->file_dst, NULL);
 	if (status)
 		goto out;
 
@@ -1284,7 +1286,7 @@ static int nfsd4_do_async_copy(void *data)
 		async_copy = kzalloc(sizeof(struct nfsd4_copy), GFP_KERNEL);
 		if (!async_copy)
 			goto out;
-		if (!nfs4_init_cp_state(nn, copy)) {
+		if (!nfs4_init_copy_state(nn, copy)) {
 			kfree(async_copy);
 			goto out;
 		}
@@ -1348,6 +1350,43 @@ struct nfsd4_copy *
 }
 
 static __be32
+nfsd4_copy_notify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
+		  union nfsd4_op_u *u)
+{
+	struct nfsd4_copy_notify *cn = &u->copy_notify;
+	__be32 status;
+	struct nfsd_net *nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+	struct nfs4_stid *stid;
+	struct nfs4_cpntf_state *cps;
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
+	cps = nfs4_alloc_init_cpntf_state(nn, stid);
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
+	WARN_ON_ONCE(status);
+
+	return status;
+}
+
+static __be32
 nfsd4_fallocate(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		struct nfsd4_fallocate *fallocate, int flags)
 {
@@ -2299,6 +2338,21 @@ static inline u32 nfsd4_offload_status_rsize(struct svc_rqst *rqstp,
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
@@ -2723,6 +2777,12 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 		.op_name = "OP_OFFLOAD_CANCEL",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
+	[OP_COPY_NOTIFY] = {
+		.op_func = nfsd4_copy_notify,
+		.op_flags = OP_MODIFIES_SOMETHING,
+		.op_name = "OP_COPY_NOTIFY",
+		.op_rsize_bop = nfsd4_copy_notify_rsize,
+	},
 };
 
 /**
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index be3e967..eaa136f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -697,6 +697,7 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 	/* Will be incremented before return to client: */
 	refcount_set(&stid->sc_count, 1);
 	spin_lock_init(&stid->sc_lock);
+	INIT_LIST_HEAD(&stid->sc_cp_list);
 
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
@@ -716,24 +717,53 @@ struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *sla
 /*
  * Create a unique stateid_t to represent each COPY.
  */
-int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
+static int nfs4_init_cp_state(struct nfsd_net *nn, void *ptr, stateid_t *stid)
 {
 	int new_id;
 
 	idr_preload(GFP_KERNEL);
 	spin_lock(&nn->s2s_cp_lock);
-	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, copy, 0, 0, GFP_NOWAIT);
+	new_id = idr_alloc_cyclic(&nn->s2s_cp_stateids, ptr, 0, 0, GFP_NOWAIT);
 	spin_unlock(&nn->s2s_cp_lock);
 	idr_preload_end();
 	if (new_id < 0)
 		return 0;
-	copy->cp_stateid.si_opaque.so_id = new_id;
-	copy->cp_stateid.si_opaque.so_clid.cl_boot = nn->boot_time;
-	copy->cp_stateid.si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
+	stid->si_opaque.so_id = new_id;
+	stid->si_opaque.so_clid.cl_boot = nn->boot_time;
+	stid->si_opaque.so_clid.cl_id = nn->s2s_cp_cl_id;
 	return 1;
 }
 
-void nfs4_free_cp_state(struct nfsd4_copy *copy)
+int nfs4_init_copy_state(struct nfsd_net *nn, struct nfsd4_copy *copy)
+{
+	return nfs4_init_cp_state(nn, copy, &copy->cp_stateid);
+}
+
+struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
+						     struct nfs4_stid *p_stid)
+{
+	struct nfs4_cpntf_state *cps;
+
+	cps = kzalloc(sizeof(struct nfs4_cpntf_state), GFP_KERNEL);
+	if (!cps)
+		return NULL;
+	if (!nfs4_init_cp_state(nn, cps, &cps->cp_stateid))
+		goto out_free;
+	cps->cp_p_stid = p_stid;
+	cps->cp_active = false;
+	cps->cp_timeout = jiffies + (nn->nfsd4_lease * HZ);
+	INIT_LIST_HEAD(&cps->cp_list);
+	spin_lock(&nn->s2s_cp_lock);
+	list_add(&cps->cp_list, &p_stid->sc_cp_list);
+	spin_unlock(&nn->s2s_cp_lock);
+
+	return cps;
+out_free:
+	kfree(cps);
+	return NULL;
+}
+
+void nfs4_free_copy_state(struct nfsd4_copy *copy)
 {
 	struct nfsd_net *nn;
 
@@ -743,6 +773,27 @@ void nfs4_free_cp_state(struct nfsd4_copy *copy)
 	spin_unlock(&nn->s2s_cp_lock);
 }
 
+static void nfs4_free_cpntf_statelist(struct net *net, struct nfs4_stid *stid)
+{
+	struct nfs4_cpntf_state *cps;
+	struct nfsd_net *nn;
+
+	nn = net_generic(net, nfsd_net_id);
+
+	might_sleep();
+
+	spin_lock(&nn->s2s_cp_lock);
+	while (!list_empty(&stid->sc_cp_list)) {
+		cps = list_first_entry(&stid->sc_cp_list,
+				       struct nfs4_cpntf_state, cp_list);
+		list_del(&cps->cp_list);
+		idr_remove(&nn->s2s_cp_stateids,
+			   cps->cp_stateid.si_opaque.so_id);
+		kfree(cps);
+	}
+	spin_unlock(&nn->s2s_cp_lock);
+}
+
 static struct nfs4_ol_stateid * nfs4_alloc_open_stateid(struct nfs4_client *clp)
 {
 	struct nfs4_stid *stid;
@@ -891,6 +942,7 @@ static void block_delegations(struct knfsd_fh *fh)
 	}
 	idr_remove(&clp->cl_stateids, s->sc_stateid.si_opaque.so_id);
 	spin_unlock(&clp->cl_lock);
+	nfs4_free_cpntf_statelist(clp->net, s);
 	s->sc_free(s);
 	if (fp)
 		put_nfs4_file(fp);
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 879ddc6..c9fb625 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1840,6 +1840,22 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
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
@@ -1940,7 +1956,7 @@ static __be32 nfsd4_decode_nl4_server(struct nfsd4_compoundargs *argp,
 	/* new operations for NFSv4.2 */
 	[OP_ALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_COPY]		= (nfsd4_dec)nfsd4_decode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_notsupp,
+	[OP_COPY_NOTIFY]	= (nfsd4_dec)nfsd4_decode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_dec)nfsd4_decode_fallocate,
 	[OP_IO_ADVISE]		= (nfsd4_dec)nfsd4_decode_notsupp,
 	[OP_LAYOUTERROR]	= (nfsd4_dec)nfsd4_decode_notsupp,
@@ -4325,6 +4341,45 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
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
@@ -4358,6 +4413,44 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
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
@@ -4454,7 +4547,7 @@ static __be32 nfsd4_encode_readv(struct nfsd4_compoundres *resp,
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_COPY]		= (nfsd4_enc)nfsd4_encode_copy,
-	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_noop,
+	[OP_COPY_NOTIFY]	= (nfsd4_enc)nfsd4_encode_copy_notify,
 	[OP_DEALLOCATE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_IO_ADVISE]		= (nfsd4_enc)nfsd4_encode_noop,
 	[OP_LAYOUTERROR]	= (nfsd4_enc)nfsd4_encode_noop,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 304de3b..31b12b1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -94,6 +94,7 @@ struct nfs4_stid {
 #define NFS4_REVOKED_DELEG_STID 16
 #define NFS4_CLOSED_DELEG_STID 32
 #define NFS4_LAYOUT_STID 64
+	struct list_head	sc_cp_list;
 	unsigned char		sc_type;
 	stateid_t		sc_stateid;
 	spinlock_t		sc_lock;
@@ -102,6 +103,17 @@ struct nfs4_stid {
 	void			(*sc_free)(struct nfs4_stid *);
 };
 
+/* Keep a list of stateids issued by the COPY_NOTIFY, associate it with the
+ * parent OPEN/LOCK/DELEG stateid.
+ */
+struct nfs4_cpntf_state {
+	stateid_t		cp_stateid;
+	struct list_head	cp_list;	/* per parent nfs4_stid */
+	struct nfs4_stid	*cp_p_stid;	/* pointer to parent */
+	bool			cp_active;	/* has the copy started */
+	unsigned long		cp_timeout;	/* copy timeout */
+};
+
 /*
  * Represents a delegation stateid. The nfs4_client holds references to these
  * and they are put when it is being destroyed or when the delegation is
@@ -613,8 +625,10 @@ __be32 nfsd4_lookup_stateid(struct nfsd4_compound_state *cstate,
 		     struct nfs4_stid **s, struct nfsd_net *nn);
 struct nfs4_stid *nfs4_alloc_stid(struct nfs4_client *cl, struct kmem_cache *slab,
 				  void (*sc_free)(struct nfs4_stid *));
-int nfs4_init_cp_state(struct nfsd_net *nn, struct nfsd4_copy *copy);
-void nfs4_free_cp_state(struct nfsd4_copy *copy);
+int nfs4_init_copy_state(struct nfsd_net *nn, struct nfsd4_copy *copy);
+void nfs4_free_copy_state(struct nfsd4_copy *copy);
+struct nfs4_cpntf_state *nfs4_alloc_init_cpntf_state(struct nfsd_net *nn,
+			struct nfs4_stid *p_stid);
 void nfs4_unhash_stid(struct nfs4_stid *s);
 void nfs4_put_stid(struct nfs4_stid *s);
 void nfs4_inc_and_copy_stateid(stateid_t *dst, struct nfs4_stid *stid);
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 513c9ff..bade8e5 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -568,6 +568,18 @@ struct nfsd4_offload_status {
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
@@ -627,6 +639,7 @@ struct nfsd4_op {
 		struct nfsd4_clone		clone;
 		struct nfsd4_copy		copy;
 		struct nfsd4_offload_status	offload_status;
+		struct nfsd4_copy_notify	copy_notify;
 		struct nfsd4_seek		seek;
 	} u;
 	struct nfs4_replay *			replay;
-- 
1.8.3.1

