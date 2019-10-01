Return-Path: <SRS0=EkhZ=X2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 095ADECE587
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:50:59 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C687020842
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:50:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569948658;
	bh=M/1L9r3hm2HcfToilF464yUmkijmVjpQx5kooM31p+Y=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=bQuKdnpPfADuBjnmob6Lxf3i8Q/m4QgZ5LhtrfcnrrkYW0Z8dfCtbIpDpxrZbPJFn
	 lZZ9FRBurezCNwGYqaKWn8WhZBIMngJi8vJbLqp+USygIni4j56X8Cd8Ic50IiVRnJ
	 3ECnSQfIz1i/HywTOeGcmrik4pycoakDN/LHqiPM=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726034AbfJAQuy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Oct 2019 12:50:54 -0400
Received: from mail.kernel.org ([198.145.29.99]:56696 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2387808AbfJAQo0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Oct 2019 12:44:26 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 8141F21906;
        Tue,  1 Oct 2019 16:44:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569948266;
        bh=M/1L9r3hm2HcfToilF464yUmkijmVjpQx5kooM31p+Y=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Bak8BMtf5SW9tpwXA9B39X5au7JBA/iDAckyKeNZjXsEQ+SiOgRy3roI+AN/j3hxk
         GtlpF6c0GwQ6LlTmEIrc5cBWmLJ+1BS2eOCb2FFAtim1QI+HCXx1MnudA2lzRyDdAK
         RzVFbWjq7/319UmmcBJOI1EV7VWuYRUOsDcWIjdU=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Jia-Ju Bai <baijiaju1990@gmail.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 02/29] fs: nfs: Fix possible null-pointer dereferences in encode_attrs()
Date:   Tue,  1 Oct 2019 12:43:56 -0400
Message-Id: <20191001164423.16406-2-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191001164423.16406-1-sashal@kernel.org>
References: <20191001164423.16406-1-sashal@kernel.org>
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
index 549c916d28599..525684b0056fc 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1132,7 +1132,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
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

