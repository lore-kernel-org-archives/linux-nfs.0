Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9478FE784B9
	for <linux-nfs@archiver.kernel.org>; Mon,  2 Oct 2023 14:51:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237881AbjJBOvf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 2 Oct 2023 10:51:35 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:33800 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S237875AbjJBOve (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Oct 2023 10:51:34 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 3BA988E
        for <linux-nfs@vger.kernel.org>; Mon,  2 Oct 2023 07:51:32 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD702C433C8;
        Mon,  2 Oct 2023 14:51:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1696258291;
        bh=0AhSkFrOERAZoJz26CpYCs5MqqGuWmGnX5QVGhtBr8k=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=FTGX2Owwnc+3T4lMY4Fodcsg+KNbOPGs1Hdawuhv6PqG9v3cnE22UXpaZ+a3QBeXe
         KzOAcToapCfqrd4Dg5dfIyOL0IX9ig6smjMn5w6NtlwnNUdaex0zw0GXAOC5Y4D/36
         /hVrOjv8y50hZ7XB7XPGw3PYR7nvi/StzBVKzgg+BUFJuj67NB+t/8jCMAZqK4UlpG
         JPXIj0aAIzK6TAWqlYPMJ8x42FDliUUk/TpDA3+v+ZdhghJq/j4LCeVIAPJ4mNGgKg
         D3J8jy+dkC9QHvEUM+zQHor4zN0z1wgXufJBAzF7KyzXQQ+3mySVGO4Xw+FdUWrgbq
         w48XZoyX91aSA==
Subject: [PATCH v1 3/4] NFSD: Restructure nfsd4_encode_create_session()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 02 Oct 2023 10:51:30 -0400
Message-ID: <169625829068.1640.10434820352878652525.stgit@klimt.1015granger.net>
In-Reply-To: <169625819958.1640.14102064750083176117.stgit@klimt.1015granger.net>
References: <169625819958.1640.14102064750083176117.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

Convert nfsd4_encode_create_session() to use the conventional XDR
encoding utilities.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |   21 ++++++++++++---------
 fs/nfsd/xdr4.h    |    1 +
 2 files changed, 13 insertions(+), 9 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 01820492c013..505f397a6e5b 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -4822,16 +4822,19 @@ nfsd4_encode_create_session(struct nfsd4_compoundres *resp, __be32 nfserr,
 {
 	struct nfsd4_create_session *sess = &u->create_session;
 	struct xdr_stream *xdr = resp->xdr;
-	__be32 *p;
-
-	p = xdr_reserve_space(xdr, 24);
-	if (!p)
-		return nfserr_resource;
-	p = xdr_encode_opaque_fixed(p, sess->sessionid.data,
-					NFS4_MAX_SESSIONID_LEN);
-	*p++ = cpu_to_be32(sess->seqid);
-	*p++ = cpu_to_be32(sess->flags);
 
+	/* csr_sessionid */
+	nfserr = nfsd4_encode_sessionid4(xdr, &sess->sessionid);
+	if (nfserr != nfs_ok)
+		return nfserr;
+	/* csr_sequence */
+	nfserr = nfsd4_encode_sequenceid4(xdr, sess->seqid);
+	if (nfserr != nfs_ok)
+		return nfserr;
+	/* csr_flags */
+	nfserr = nfsd4_encode_uint32_t(xdr, sess->flags);
+	if (nfserr != nfs_ok)
+		return nfserr;
 	/* csr_fore_chan_attrs */
 	nfserr = nfsd4_encode_channel_attrs4(xdr, &sess->fore_channel);
 	if (nfserr != nfs_ok)
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index a9ff01034ac1..7983eb679ba7 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -96,6 +96,7 @@ nfsd4_encode_uint32_t(struct xdr_stream *xdr, u32 val)
 #define nfsd4_encode_count4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_mode4(x, v)	nfsd4_encode_uint32_t(x, v)
 #define nfsd4_encode_nfs_lease4(x, v)	nfsd4_encode_uint32_t(x, v)
+#define nfsd4_encode_sequenceid4(x, v)	nfsd4_encode_uint32_t(x, v)
 
 /**
  * nfsd4_encode_uint64_t - Encode an XDR uint64_t type result


