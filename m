Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6005DC46CA1
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Sep 2023 15:25:27 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S235107AbjIRPZa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Sep 2023 11:25:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60400 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234376AbjIRPZ0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2023 11:25:26 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 45324E5F
        for <linux-nfs@vger.kernel.org>; Mon, 18 Sep 2023 08:22:15 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 724FDC116CA;
        Mon, 18 Sep 2023 14:00:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695045657;
        bh=PM4YplbX7xYRY5Wfe94JDDlv5/9Zg7S4w6N+tWUQf8U=;
        h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
        b=ndsDrwOjVQHHTEEtXr7Os7jCdpB0pJngw84gfV+hjLZ+M24YVmMbNLpIgBpmg7m0E
         ElyNzw/lvkKun1kNnc1VrA6TtjJBeujCKACiB6CmvXkrOO5bmDeh7nOX5rUqbcsv+I
         CqgByY8Zq7SYy1P7cOO7MTSXg9faUA5oCFQ121PZkEtXSLM/jPudcuWHEXcPwv26y/
         m7SqFcQfE3UhZOtQd8wUJSDP1UDqxdtQlqPDflLYd3Zy49+CKYbDFkKd+eidQp8D0F
         M7Ekb4YdKQYirgVgPvt27jnWxsxqj9h7/FgqQkcRzq1nPIyoUQK28gdW7r0avAa62c
         L4qpzuV/PADRQ==
Subject: [PATCH v1 39/52] NFSD: Add nfsd4_encode_fattr4_time_create()
From:   Chuck Lever <cel@kernel.org>
To:     linux-nfs@vger.kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>
Date:   Mon, 18 Sep 2023 10:00:56 -0400
Message-ID: <169504565646.133720.8387408052195832855.stgit@manet.1015granger.net>
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

Refactor the encoder for FATTR4_TIME_CREATE into a helper. In a
subsequent patch, this helper will be called from a bitmask loop.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4xdr.c |    8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 214e2fdcbd89..5a98dc3910ef 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -3260,6 +3260,12 @@ static __be32 nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
 	return nfsd4_encode_nfstime4(xdr, &args->stat.atime);
 }
 
+static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *xdr,
+					      const struct nfsd4_fattr_args *args)
+{
+	return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
+}
+
 /*
  * Note: @fhp can be NULL; in this case, we might have to compose the filehandle
  * ourselves.
@@ -3588,7 +3594,7 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			goto out;
 	}
 	if (bmval1 & FATTR4_WORD1_TIME_CREATE) {
-		status = nfsd4_encode_nfstime4(xdr, &args.stat.btime);
+		status = nfsd4_encode_fattr4_time_create(xdr, &args);
 		if (status)
 			goto out;
 	}


