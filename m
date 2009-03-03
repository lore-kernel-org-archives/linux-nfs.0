From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 26/46] NFS: define and initialize compound_hdr.replen
Date: Wed,  4 Mar 2009 01:58:18 +0200
Message-ID: <1236124698-3708-1-git-send-email-bhalevy@panasas.com>
References: <49ADBD04.2090002@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:17710
	"EHLO natasha.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754196AbZCCX6c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 18:58:32 -0500
In-Reply-To: <49ADBD04.2090002@panasas.com>
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
index 75ceb42..5d665a1 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -548,6 +548,7 @@ struct compound_hdr {
 	__be32 *	nops_p;
 	uint32_t	taglen;
 	char *		tag;
+	uint32_t	replen;		/* expected reply words */
 	u32		minorversion;
 };
 
@@ -584,9 +585,17 @@ static void encode_string(struct xdr_stream *xdr, unsigned int len, const char *
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
@@ -1365,7 +1374,7 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_access(&xdr, args->access, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1386,7 +1395,7 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_getfh(&xdr, &hdr);
@@ -1408,7 +1417,7 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_getfh(&xdr, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1429,7 +1438,7 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_remove(&xdr, &args->name, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1450,7 +1459,7 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->old_dir, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->new_dir, &hdr);
@@ -1475,7 +1484,7 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
@@ -1500,7 +1509,7 @@ static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_create(&xdr, args, &hdr);
@@ -1533,7 +1542,7 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1553,7 +1562,7 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1574,7 +1583,7 @@ static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openarg
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_open(&xdr, args, &hdr);
@@ -1597,7 +1606,7 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_confirm(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1617,7 +1626,7 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1638,7 +1647,7 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_downgrade(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1659,7 +1668,7 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1679,7 +1688,7 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1699,7 +1708,7 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -1721,7 +1730,7 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 	unsigned int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
@@ -1751,7 +1760,7 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
@@ -1784,7 +1793,7 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
@@ -1813,7 +1822,7 @@ static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_seta
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_setattr(&xdr, args, args->server, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1838,7 +1847,7 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
@@ -1863,7 +1872,7 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
@@ -1885,7 +1894,7 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_commit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1906,7 +1915,7 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1926,7 +1935,7 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
@@ -1947,7 +1956,7 @@ static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
@@ -1969,7 +1978,7 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
@@ -1990,7 +1999,7 @@ static int nfs4_xdr_enc_renew(struct rpc_rqst *req, __be32 *p, struct nfs_client
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_renew(&xdr, clp, &hdr);
 	encode_nops(&hdr);
 	return 0;
@@ -2007,7 +2016,7 @@ static int nfs4_xdr_enc_setclientid(struct rpc_rqst *req, __be32 *p, struct nfs4
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_setclientid(&xdr, sc, &hdr);
 	encode_nops(&hdr);
 	return 0;
@@ -2025,7 +2034,7 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_setclientid_confirm(&xdr, clp, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_fsinfo(&xdr, lease_bitmap, &hdr);
@@ -2046,7 +2055,7 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_delegreturn(&xdr, args->stateid, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2069,7 +2078,7 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
 	int replen;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
@@ -3963,7 +3972,7 @@ nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
-	encode_compound_hdr(&xdr, &hdr);
+	encode_compound_hdr(&xdr, req, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
 	encode_nops(&hdr);
-- 
1.6.1.3

