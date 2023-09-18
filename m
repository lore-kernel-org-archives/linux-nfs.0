Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1110CD37B0
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Sep 2023 15:25:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230100AbjIRP0D (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Sep 2023 11:26:03 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48710 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234811AbjIRPZ6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2023 11:25:58 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A49F81726
        for <linux-nfs@vger.kernel.org>; Mon, 18 Sep 2023 08:23:06 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 16313C116C9;
        Mon, 18 Sep 2023 14:00:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695045651;
        bh=8ts/dGfDn9e/PDy01qBGBPy53p+fSvaXqXeGiNNYM78=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=DW9UwFdd6mCeMb6tdVFE+1UmGSVR35WtBr0MGaajDA+N4NzDLMAEd40Gqs+n+FwhR
         /OB5nm5QcVmimNv73A10Iz6Gl72uui4C/S31HscTpFmvEoofAIDUPgBmLhGwwvxXp3
         pktPiwe3RPir4AR88hsdaPZaBAYohMg+CJiGMNwSl11wqUsXt25oN4X1SpuvKYkpGb
         nL05rh6YYsEBVJ6lKgCB18t9maP7hY3FFdJMq6HZQnwfFQGZh+JQd7fb7HpOYPWPSP
         s+hY78MboRYBWPYFn8mLXY+gl4x0v50GTxgCCFAnL+N0fVJfe3UsOdgcpotSAbqzRP
         eU5Kobg6/gM1w==
Subject: [PATCH v1 38/52] NFSD: Add nfsd4_encode_fattr4_time_access()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 18 Sep 2023 10:00:50 -0400
Message-ID: <169504565001.133720.3671879742657326384.stgit@manet.1015granger.net>
In-Reply-To: <169504501081.133720.4162400017732492854.stgit@manet.1015granger.net>
References: <169504501081.133720.4162400017732492854.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Refactor the encoder for FATTR4_TIME_ACCESS into a helper. In a
subsequent patch, this helper will be called from a bitmask loop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 80be20217402..214e2fdcbd89 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2536,16 +2536,16 @@ static __be32 nfsd4_encode_nfs_fh4(struct xdr_stream *xdr,
 	return nfsd4_encode_opaque(xdr, fh_handle->fh_raw, fh_handle->fh_size);
 }
 
+/* This is a frequently-encoded type; open-coded for speed */
 static __be32 nfsd4_encode_nfstime4(struct xdr_stream *xdr,
-				    struct timespec64 *tv)
+				    const struct timespec64 *tv)
 {
 	__be32 *p;
 
 	p = xdr_reserve_space(xdr, XDR_UNIT * 3);
 	if (!p)
 		return nfserr_resource;
-
-	p = xdr_encode_hyper(p, (s64)tv->tv_sec);
+	p = xdr_encode_hyper(p, tv->tv_sec);
 	*p = cpu_to_be32(tv->tv_nsec);
 	return nfs_ok;
 }
@@ -3254,6 +3254,12 @@ static __be32 nfsd4_encode_fattr4_space_used(struct xdr_stream *xdr,
 	return nfsd4_encode_uint64_t(xdr, (u64)args->stat.blocks << 9);
 }
 
+static __be32 nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
+					      const struct nfsd4_fattr_args *args)
+{
+	return nfsd4_encode_nfstime4(xdr, &args->stat.atime);
+}
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -3577,7 +3583,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_ACCESS) {
-		status = nfsd4_encode_nfstime4(xdr, &args.stat.atime);
+		status = nfsd4_encode_fattr4_time_access(xdr, &args);
 		if (status)
 			goto out;
 	}


