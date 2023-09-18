Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8808DCD37B0
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Sep 2023 15:22:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S238243AbjIRPWG (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Sep 2023 11:22:06 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33416 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239467AbjIRPWF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2023 11:22:05 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 380901707
        for <linux-nfs@vger.kernel.org>; Mon, 18 Sep 2023 08:20:03 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4EE32C4167D;
        Mon, 18 Sep 2023 13:58:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695045498;
        bh=aDSeXCSL7SZoK6/Ot3WLqq53MCPrOBsCDGMyJ1Ik22g=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=T7ciIjQdbuy251hZSF9/QcOP7Bcw/+HgudAKk5t/VOjJvrXWFFk/XKZOdMbXBH2nk
         dWM3glDDKRQrxFhBT9FIjHfQTACavIaFdxMExUk0RnIul8+EQkhKupzb7iYVrIxoDA
         KLmW85GkvPvyfevdJQwZ30XufFLdhoBiSRm0ittzOEXNRl6oD3dMNYCHVPi6209hV4
         mmYpvmUzO9rxaNEaBHROD10ZVWC3O22bNQc0W0kdGGEsJj3QOOPWxkhrPbX+z/5tfW
         SE0bfm+/IsykbUa115HmoPP6vubMqeLJMIE/HlgZwqQYWotUPCQvcLcSAQrNipjC4u
         jwhEDJIXGjq2w==
Subject: [PATCH v1 14/52] NFSD: Add nfsd4_encode_fattr4_rdattr_error()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 18 Sep 2023 09:58:17 -0400
Message-ID: <169504549733.133720.7851563488445082802.stgit@manet.1015granger.net>
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

Refactor the encoder for FATTR4_RDATTR_ERROR into a helper. In a
subsequent patch, this helper will be called from a bitmask loop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 15a07f7d9b38..c67b5d942390 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3071,6 +3071,12 @@ static __be32 nfsd4_encode_fattr4_lease_time(struct xdr_stream *xdr,
 	return nfsd4_encode_nfs_lease4(xdr, nn->nfsd4_lease);
 }
 
+static __be32 nfsd4_encode_fattr4_rdattr_error(struct xdr_stream *xdr,
+					       const struct nfsd4_fattr_args *args)
+{
+	return nfsd4_encode_uint32_t(xdr, args->rdattr_err);
+}
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -3250,10 +3256,9 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			goto out;
 	}
 	if (bmval0 & FATTR4_WORD0_RDATTR_ERROR) {
-		p = xdr_reserve_space(xdr, 4);
-		if (!p)
-			goto out_resource;
-		*p++ = cpu_to_be32(args.rdattr_err);
+		status = nfsd4_encode_fattr4_rdattr_error(xdr, &args);
+		if (status != nfs_ok)
+			goto out;
 	}
 	if (bmval0 & FATTR4_WORD0_ACL) {
 		struct nfs4_ace *ace;


