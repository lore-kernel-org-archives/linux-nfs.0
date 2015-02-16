Return-Path: linux-kernel-owner@vger.kernel.org
From: Daniel Thompson <daniel.thompson@linaro.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Daniel Thompson <daniel.thompson@linaro.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, patches@linaro.org,
        linaro-kernel@lists.linaro.org, John Stultz <john.stultz@linaro.org>,
        Sumit Semwal <sumit.semwal@linaro.org>,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH] nfsd: Fix v2-only build regression
Date: Mon, 16 Feb 2015 11:36:03 +0000
Message-Id: <1424086563-25570-1-git-send-email-daniel.thompson@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently if nfsd is configured as v2 only then the kernel fails to build.
This is a regression introduced by 9cf514ccfacb("nfsd: implement pNFS
operations"). It occurs because inline code from the xdr4.h header is
now included from generic nfsd code (via pnfs.h).

This patch takes the simplest route and makes conditional the problematic
inline function.

Note: I also tried extending the #ifdef CONFIG_NFSD_PNFS to cover almost
      all of the pnfs.h header file. That works great too but feels more
      invasive. However I can dust this off if that were preferable for
      any reason.

Signed-off-by: Daniel Thompson <daniel.thompson@linaro.org>
Cc: Christoph Hellwig <hch@lst.de>
Cc: J. Bruce Fields <bfields@fieldses.org>
---
 fs/nfsd/xdr4.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 0bda93e58e1b..960a75d921c0 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -627,6 +627,7 @@ void warn_on_nonidempotent_op(struct nfsd4_op *op);

 #define NFS4_SVC_XDRSIZE		sizeof(struct nfsd4_compoundargs)

+#ifdef CONFIG_NFSD_V3
 static inline void
 set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 {
@@ -642,6 +643,7 @@ set_change_info(struct nfsd4_change_info *cinfo, struct svc_fh *fhp)
 	cinfo->after_ctime_nsec = fhp->fh_post_attr.ctime.tv_nsec;

 }
+#endif

 int nfs4svc_encode_voidres(struct svc_rqst *, __be32 *, void *);
 int nfs4svc_decode_compoundargs(struct svc_rqst *, __be32 *,
--
1.9.3

