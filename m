Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:64308 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751138AbbAYAUS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 24 Jan 2015 19:20:18 -0500
Received: by mail-ig0-f173.google.com with SMTP id a13so3230920igq.0
        for <linux-nfs@vger.kernel.org>; Sat, 24 Jan 2015 16:20:17 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4.1: Replace usage of nfs_client->cl_addr in encode_create_session
Date: Sat, 24 Jan 2015 19:20:15 -0500
Message-Id: <1422145215-81937-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Replace the current code with something that is a little closer to what
net/sunrpc/auth_unix.c uses.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index e3018e7a316c..41253393171f 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1804,9 +1804,8 @@ static void encode_create_session(struct xdr_stream *xdr,
 				  struct compound_hdr *hdr)
 {
 	__be32 *p;
-	char machine_name[NFS4_MAX_MACHINE_NAME_LEN];
-	uint32_t len;
 	struct nfs_client *clp = args->client;
+	struct rpc_clnt *clnt = clp->cl_rpcclient;
 	struct nfs_net *nn = net_generic(clp->cl_net, nfs_net_id);
 	u32 max_resp_sz_cached;
 
@@ -1817,11 +1816,8 @@ static void encode_create_session(struct xdr_stream *xdr,
 	max_resp_sz_cached = (NFS4_dec_open_sz + RPC_REPHDRSIZE +
 			      RPC_MAX_AUTH_SIZE + 2) * XDR_UNIT;
 
-	len = scnprintf(machine_name, sizeof(machine_name), "%s",
-			clp->cl_ipaddr);
-
 	encode_op_hdr(xdr, OP_CREATE_SESSION, decode_create_session_maxsz, hdr);
-	p = reserve_space(xdr, 16 + 2*28 + 20 + len + 12);
+	p = reserve_space(xdr, 16 + 2*28 + 20 + clnt->cl_nodelen + 12);
 	p = xdr_encode_hyper(p, clp->cl_clientid);
 	*p++ = cpu_to_be32(clp->cl_seqid);			/*Sequence id */
 	*p++ = cpu_to_be32(args->flags);			/*flags */
@@ -1850,7 +1846,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 
 	/* authsys_parms rfc1831 */
 	*p++ = cpu_to_be32(nn->boot_time.tv_nsec);	/* stamp */
-	p = xdr_encode_opaque(p, machine_name, len);
+	p = xdr_encode_array(p, clnt->cl_nodename, clnt->cl_nodelen);
 	*p++ = cpu_to_be32(0);				/* UID */
 	*p++ = cpu_to_be32(0);				/* GID */
 	*p = cpu_to_be32(0);				/* No more gids */
-- 
2.1.0

