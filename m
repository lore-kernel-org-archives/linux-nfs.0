From: Tao Guo <glorioustao@gmail.com>
Subject: [pnfs][PATCH 1/2]pnfs: replace lease_bitmap to length 3, instead of
	2.
Date: Mon, 29 Jun 2009 10:16:11 +0800
Message-ID: <318b7ac70906281916q317b1c4fkb50096679beebfba@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Fredric Isaman <iisaman@citi.umich.edu>, bfields@citi.umich.edu,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.226]:31563 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbZF2CQH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Jun 2009 22:16:07 -0400
Received: by rv-out-0506.google.com with SMTP id f6so1135963rvb.1
        for <linux-nfs@vger.kernel.org>; Sun, 28 Jun 2009 19:16:11 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b1e3ce2..231ad24 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2619,7 +2619,7 @@ static int
nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
        struct compound_hdr hdr = {
                .nops   = 0,
        };
-       const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+       const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };

        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
        encode_compound_hdr(&xdr, req, &hdr);
@@ -2770,7 +2770,7 @@ static int nfs4_xdr_enc_get_lease_time(struct
rpc_rqst *req, uint32_t *p,
        struct compound_hdr hdr = {
                .minorversion = clp->cl_minorversion,
        };
-       const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
+       const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0, 0 };

        xdr_init_encode(&xdr, &req->rq_snd_buf, p);
        encode_compound_hdr(&xdr, req, &hdr);

-- 
tao.
