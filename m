Return-Path: <SRS0=EkhZ=X2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FDE0C352AA
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:54:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0B61F2168B
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:54:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569948846;
	bh=Psok01rb9VQ9VEznPEyjc5+rXwjlQFDg2BvagxWZhyU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=c+6j+x0YwPSSvsOmkP89ZbQRETVdnaId8upz3k+l103IyfnZeKUomko7kGsfu/VqA
	 S/PmWespZ0dnPy6HmvkDTqXm2d0haCYaYZun8sr26BjCAxVo8q1Dh0Nnh2faNn+D1p
	 w6j+nbvzL8EsChiVaHaCNMAU8AwQgXa1Jpv8kWSM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732535AbfJAQnQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Oct 2019 12:43:16 -0400
Received: from mail.kernel.org ([198.145.29.99]:55268 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1732527AbfJAQnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Oct 2019 12:43:16 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id F104421906;
        Tue,  1 Oct 2019 16:43:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569948195;
        bh=Psok01rb9VQ9VEznPEyjc5+rXwjlQFDg2BvagxWZhyU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=z6mvd+zK0sqrFMmvytAZSqGVaZbYdMsq0G63JusNNldTLSwNJevIbKEyynO84LWep
         6i5g0cnyRO2GW1x95aEf1LtZBFAUwt8TowRnMDs7XvHeM47UDd8kfuHiEOn859FJyo
         cNN5w3b6n2X1wMio2I+CxWMlWzm1p9T9Hn9llmro=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Jia-Ju Bai <baijiaju1990@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 03/43] fs: nfs: Fix possible null-pointer dereferences in encode_attrs()
Date:   Tue,  1 Oct 2019 12:42:31 -0400
Message-Id: <20191001164311.15993-3-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191001164311.15993-1-sashal@kernel.org>
References: <20191001164311.15993-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Jia-Ju Bai <baijiaju1990@gmail.com>

[ Upstream commit e2751463eaa6f9fec8fea80abbdc62dbc487b3c5 ]

In encode_attrs(), there is an if statement on line 1145 to check
whether label is NULL:
    if (label && (attrmask[2] & FATTR4_WORD2_SECURITY_LABEL))

When label is NULL, it is used on lines 1178-1181:
    *p++ = cpu_to_be32(label->lfs);
    *p++ = cpu_to_be32(label->pi);
    *p++ = cpu_to_be32(label->len);
    p = xdr_encode_opaque_fixed(p, label->label, label->len);

To fix these bugs, label is checked before being used.

These bugs are found by a static analysis tool STCheck written by us.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4xdr.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index b7bde12d8cd51..1c0227c78a7bc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1171,7 +1171,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		} else
 			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
-	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+	if (label && (bmval[2] & FATTR4_WORD2_SECURITY_LABEL)) {
 		*p++ = cpu_to_be32(label->lfs);
 		*p++ = cpu_to_be32(label->pi);
 		*p++ = cpu_to_be32(label->len);
-- 
2.20.1

