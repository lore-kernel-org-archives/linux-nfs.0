Return-Path: <SRS0=juBO=ON=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58E00C04EB8
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:09:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1D1382082B
	for <linux-nfs@archiver.kernel.org>; Tue,  4 Dec 2018 19:09:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OZSVqoTj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1D1382082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725899AbeLDTJY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 4 Dec 2018 14:09:24 -0500
Received: from mail-oi1-f193.google.com ([209.85.167.193]:38351 "EHLO
        mail-oi1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725865AbeLDTJY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Dec 2018 14:09:24 -0500
Received: by mail-oi1-f193.google.com with SMTP id a77so15260384oii.5
        for <linux-nfs@vger.kernel.org>; Tue, 04 Dec 2018 11:09:24 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=dmjI0R2iUIbEq2MhJsBYQVIv0RjTZlwF3dCxHi55H2w=;
        b=OZSVqoTjH45l+vvTmoIN2lkSX4BOKRuReb6BLumC8/FJlEfIsJIIRKB07Oo0Y3YhQL
         q2UCS6IO5qMTm19L+MhvL/qgCfz7lQ14IjWCiyC1jGuziqx1eOwAI2rNxEHnxiwlyuap
         rMtC0VyZVEwuGBJhtGbwKXy8FabPW3z4fHcJhW9mkrpIKsuicuJ98eqGKr3Qf1fprOg1
         Bfs/WQSMKrePFdR5Km39YlRAhy/rrNsuF2uQR+DEXxssrbps2tAeR29ay074yXJAPsSa
         cbgNrCnv5bmx5PW0nw8UM9PXA7grT2vvBmZjNaq+lOsHSYre6T/ZP496ojX/I7Dnx8DU
         f7xA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=dmjI0R2iUIbEq2MhJsBYQVIv0RjTZlwF3dCxHi55H2w=;
        b=a2aul7/9FO2tYgeBaYRZkdNgAK4vwX6TLqks3YUXo563aHROKodaki5D7REc93uaCl
         Ckvd4MgXmHC7tTCHmnFjs8VLeVADczhAQigr8U6CJCAwEXBHUvgmPiD5SbKMoDDbqxwa
         /VjREC5rN3vxfX88KdR2LAxenn9nKkqZyNn//srIHDZnCcuLVMUjbEv9fD0JbFOBlEIP
         bT9RdA3DHGX/73/DulDMvwvLLHBhKdZGCy1a3qIPExUhZeZoQ/W3e9I58HNp4wbGJ89/
         STvS+j0z60wA0PEHT4r9r3x6W1W7RUc3L2wvhfPn+jzmtfuRxBySdHUEn1i4hxOZjQQ3
         TUOg==
X-Gm-Message-State: AA+aEWazS/7G3v1/IJ69Poeg+sPDYJFE5Nd2PPszRLaePtDL+UkPYixp
        uz/jTMs4HiSd2of4hm8LXI4rowrg
X-Google-Smtp-Source: AFSGD/UVkWcRpw9O6qXSIPP4TpCyVK+gJMVq/juOwtkp6aaQD8gxH7hvLjASguGAK8PStZx5JG6dqg==
X-Received: by 2002:aca:53cd:: with SMTP id h196mr13859834oib.355.1543950563520;
        Tue, 04 Dec 2018 11:09:23 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id u19sm7964977oia.31.2018.12.04.11.09.22
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Dec 2018 11:09:22 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSD remove OP_CACHEME from 4.2 op_flags
Date:   Tue,  4 Dec 2018 14:09:21 -0500
Message-Id: <20181204190921.61662-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

OP_CACHEME is only for the 4.0 operations.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfsd/nfs4proc.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 238c4b7..60c4650 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3010,25 +3010,25 @@ static inline u32 nfsd4_seek_rsize(struct svc_rqst *rqstp, struct nfsd4_op *op)
 	/* NFSv4.2 operations */
 	[OP_ALLOCATE] = {
 		.op_func = nfsd4_allocate,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_ALLOCATE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_DEALLOCATE] = {
 		.op_func = nfsd4_deallocate,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_DEALLOCATE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_CLONE] = {
 		.op_func = nfsd4_clone,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_CLONE",
 		.op_rsize_bop = nfsd4_only_status_rsize,
 	},
 	[OP_COPY] = {
 		.op_func = nfsd4_copy,
-		.op_flags = OP_MODIFIES_SOMETHING | OP_CACHEME,
+		.op_flags = OP_MODIFIES_SOMETHING,
 		.op_name = "OP_COPY",
 		.op_rsize_bop = nfsd4_copy_rsize,
 	},
-- 
1.8.3.1

