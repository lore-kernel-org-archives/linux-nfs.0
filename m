Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FFD5CE7A94
	for <linux-nfs@archiver.kernel.org>; Mon, 25 Sep 2023 13:27:47 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231537AbjIYN1u (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 25 Sep 2023 09:27:50 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59084 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S231615AbjIYN1t (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Sep 2023 09:27:49 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 856BF11D
        for <linux-nfs@vger.kernel.org>; Mon, 25 Sep 2023 06:27:40 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3A98C433C8;
        Mon, 25 Sep 2023 13:27:39 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695648460;
        bh=XKYbn3+oFkvQmfmcaZJt0QnJKjTwoXQBRD8QhYLaoEM=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=VhEEkhxMEp19yHn3UgN/b5030yN9YKCwQK57680Z/oDXEZZZkxFuLK83Qd++mVPp7
         J6/YAUztVefYWtJjO8i5QUUtevvJBRcvG1Hqtx//eX3cUvQ2VMCdRKkup+D8HMcgG1
         f/ptWsYFMNYV1Md6BSVs1dlKYVtXEMwuSQZrY2xCiiNsOpWgHVgveUG05bqoVSHtjk
         ThYuTYh62+7aCOJKTULLhZxqIjzWNLvRb5Bvwelumqd3lh+P+bALC9e3QpC4gG8E7c
         FMItkszO+BINhSdgM57efigGTIyTHAefOt55hB5ev6nHoliROTYhVhoJGKZqFA+1pC
         ov1B2BqNKZkwg==
Subject: [PATCH v1 1/8] NFSD: Add nfsd4_encode_count4()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 25 Sep 2023 09:27:38 -0400
Message-ID: <169564845894.6013.1502101691833380449.stgit@klimt.1015granger.net>
In-Reply-To: <169564827064.6013.5014460767978657478.stgit@klimt.1015granger.net>
References: <169564827064.6013.5014460767978657478.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

This is a synonym for nfsd4_encode_uint32_t() that matches the
name of the XDR type. It will get at least one more use in a
subsequent patch.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   13 +++++++++----
 fs/nfsd/xdr4.h    |    1 +
 2 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2356c56ef4c4..bc802f187c63 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4615,12 +4615,17 @@ nfsd4_encode_write(struct nfsd4_compoundres *resp, __be32 nfserr,
 		   union nfsd4_op_u *u)
 {
 	struct nfsd4_write *write = &u->write;
+	struct xdr_stream *xdr = resp->xdr;
 
-	if (xdr_stream_encode_u32(resp->xdr, write->wr_bytes_written) < 0)
-		return nfserr_resource;
-	if (xdr_stream_encode_u32(resp->xdr, write->wr_how_written) < 0)
+	/* count */
+	nfserr = nfsd4_encode_count4(xdr, write->wr_bytes_written);
+	if (nfserr)
+		return nfserr;
+	/* committed */
+	if (xdr_stream_encode_u32(xdr, write->wr_how_written) != XDR_UNIT)
 		return nfserr_resource;
-	return nfsd4_encode_verifier4(resp->xdr, &write->wr_verifier);
+	/* writeverf */
+	return nfsd4_encode_verifier4(xdr, &write->wr_verifier);
 }
 
 static __be32
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index 52322acc1e9f..43b9c53b7795 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -93,6 +93,7 @@ nfsd4_encode_uint32_t(struct xdr_stream *xdr, u32 val)
 #define nfsd4_encode_aceflag4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_acemask4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_acetype4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_count4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_mode4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_nfs_lease4(x, v)	nfsd4_encode_uint32_t(x, v)
 


