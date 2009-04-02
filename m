From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 23/67] NFS: define and initialize compound_hdr.replen
Date: Thu,  2 Apr 2009 16:53:24 +0300
Message-ID: <1238680404-14119-1-git-send-email-bhalevy@panasas.com>
References: <49D4C1A9.5060900@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:29065 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755793AbZDBNxc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Apr 2009 09:53:32 -0400
In-Reply-To: <49D4C1A9.5060900@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

replen holds the running count of expected reply bytes.
repl will then be used by encoding routines for xdr_inline_pages offset
after which data bytes are to be received directly into the xdr
buffer pages.

NOTE: According to the nfsv4 and v4.1 RFCs, the replied tag SHOULD be the same
is the one sent, but this is not required as a MUST for the server to do so.
The server may screw us if it replies a tag of a different length in the
compound result.

[NFS: cb_compoundhdr.replen is in words not bytes]
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4xdr.c |   77 ++++++++++++++++++++++++++++++------------------------
 1 files changed, 43 insertions(+), 34 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 487a197..c85dbee 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -545,6 +545,7 @@ struct compound_hdr {
 	__be32 *	nops_p;
 	uint32_t	taglen;
 	char *		tag;
+	uint32_t	replen;		/* expected reply words */
 };
 
 /*
@@ -580,9 +581,17 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
 	xdr_encode_opaque(p, str, len);
 }
 
-static void encode_compound_hdr(struct xdr_stream *xdr, struct compound_hdr *hdr)
+static void encode_compound_hdr(struct xdr_stream *xdr,
+				struct rpc_rqst *req,
+				struct compound_hdr *hdr)
 {
 	__be32 *p;
+	struct rpc_auth *auth = req->rq_task->tk_msg.rpc_cred->cr_auth;
+
+	/* initialize running count of expected bytes in reply.
+	 * NOTE: the replied tag SHOULD be the same is the one sent,
+	 * but this is not required as a MUST for the server to do so. */
+	hdr->replen = RPC_REPHDRSIZE + auth->au_rslack + 3 + hdr->taglen;
 
 	dprintk("encode_compound: tag=%.*s\n", (int)hdr->taglen, hdr->tag);
 	BUG_ON(hdr->taglen > NFS4_MAXTAGLEN);
@@ -1359,7 +1368,7 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_access(&xdr, args->access, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1378,7 +1387,7 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_getfh(&xdr, &hdr);
@@ -1398,7 +1407,7 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_getfh(&xdr, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1417,7 +1426,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_remove(&xdr, &args->name, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1436,7 +1445,7 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->old_dir, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->new_dir, &hdr);
@@ -1459,7 +1468,7 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
@@ -1482,7 +1491,7 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_create(&xdr, args, &hdr);
@@ -1513,7 +1522,7 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1531,7 +1540,7 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1550,7 +1559,7 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_open(&xdr, args, &hdr);
@@ -1573,7 +1582,7 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_confirm(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1591,7 +1600,7 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1610,7 +1619,7 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_downgrade(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1629,7 +1638,7 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1647,7 +1656,7 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1665,7 +1674,7 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1685,7 +1694,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	unsigned int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
@@ -1713,7 +1722,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
@@ -1744,7 +1753,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
@@ -1771,7 +1780,7 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_setattr(&xdr, args, args->server, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1794,7 +1803,7 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
@@ -1817,7 +1826,7 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
@@ -1837,7 +1846,7 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_commit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1856,7 +1865,7 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1874,7 +1883,7 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
@@ -1893,7 +1902,7 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
@@ -1913,7 +1922,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
@@ -1934,7 +1943,7 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_renew(&xdr, clp, &hdr);
 	encode_nops(&hdr);
 	return 0;
@@ -1951,7 +1960,7 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_setclientid(&xdr, sc, &hdr);
 	encode_nops(&hdr);
 	return 0;
@@ -1969,7 +1978,7 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_setclientid_confirm(&xdr, clp, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_fsinfo(&xdr, lease_bitmap, &hdr);
@@ -1988,7 +1997,7 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_delegreturn(&xdr, args->stateid, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2009,7 +2018,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
@@ -3989,7 +3998,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
 	encode_nops(&hdr);
-- 
1.6.2.1

