Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:18241 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754106Ab2CEQuh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 11:50:37 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 14/16] NFSv4: Cleanup - convert more functions to use encode_op_hdr
Date: Mon,  5 Mar 2012 11:50:19 -0500
Message-Id: <1330966221-17164-14-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1330966221-17164-13-git-send-email-Trond.Myklebust@netapp.com>
References: <1330966221-17164-1-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-2-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-3-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-4-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-5-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-6-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-7-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-8-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-9-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-10-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-11-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-12-git-send-email-Trond.Myklebust@netapp.com>
 <1330966221-17164-13-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4xdr.c |   11 ++---------
 1 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 62effaf..f958849 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1644,8 +1644,7 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 {
 	__be32 *p;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_SETCLIENTID);
+	encode_op_hdr(xdr, OP_SETCLIENTID, decode_setclientid_maxsz, hdr);
 	encode_nfs4_verifier(xdr, setclientid->sc_verifier);
 
 	encode_string(xdr, setclientid->sc_name_len, setclientid->sc_name);
@@ -1655,8 +1654,6 @@ static void encode_setclientid(struct xdr_stream *xdr, const struct nfs4_setclie
 	encode_string(xdr, setclientid->sc_uaddr_len, setclientid->sc_uaddr);
 	p = reserve_space(xdr, 4);
 	*p = cpu_to_be32(setclientid->sc_cb_ident);
-	hdr->nops++;
-	hdr->replen += decode_setclientid_maxsz;
 }
 
 static void encode_setclientid_confirm(struct xdr_stream *xdr, const struct nfs4_setclientid_res *arg, struct compound_hdr *hdr)
@@ -1709,8 +1706,7 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 	char impl_name[NFS4_OPAQUE_LIMIT];
 	int len = 0;
 
-	p = reserve_space(xdr, 4);
-	*p = cpu_to_be32(OP_EXCHANGE_ID);
+	encode_op_hdr(xdr, OP_EXCHANGE_ID, decode_exchange_id_maxsz, hdr);
 	encode_nfs4_verifier(xdr, args->verifier);
 
 	encode_string(xdr, args->id_len, args->id);
@@ -1740,9 +1736,6 @@ static void encode_exchange_id(struct xdr_stream *xdr,
 		*p = cpu_to_be32(0);
 	} else
 		*p = cpu_to_be32(0);	/* implementation id array length=0 */
-
-	hdr->nops++;
-	hdr->replen += decode_exchange_id_maxsz;
 }
 
 static void encode_create_session(struct xdr_stream *xdr,
-- 
1.7.7.6

