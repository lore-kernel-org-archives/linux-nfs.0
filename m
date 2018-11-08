Return-Path: <SRS0=MTBG=NT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 56F96ECDE4B
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:37:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 165E6208A3
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Nov 2018 17:37:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lUs5mC7L"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 165E6208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726922AbeKIDNe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Nov 2018 22:13:34 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:32939 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726751AbeKIDNe (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Nov 2018 22:13:34 -0500
Received: by mail-it1-f195.google.com with SMTP id p11-v6so2352956itf.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Nov 2018 09:37:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=83M9MuuyfBLXZ/YL/qV9yuohrUfZzP/MjRMpSeq4O70=;
        b=lUs5mC7LVsPisjZSPUA84ghohxM/hoJKSWr3uKEqEkvWkTb6fbPYesO7XliDCh4I/x
         zl48cPqgdG8sfGi0Gi+X8KsZB1nsG147gzVJe0Uo7BGUODPEwtV58yGzGlaBWRprSJXN
         rQEm1HqpO+KH0gIWClh817sUUSnM1CaZg6aoKn5YB+JjJng+fN7EK4hbz/1q3YRSOPoB
         FQusbRVn6Xu3sLQ7S3SIupouUCCRz1cJf2bF6jA0Vv0SeHUn63vi0MzKKBIHIGGHbWGZ
         Wj0/zB3qUy9d32Pj/IqQVvjNQPurgk9+wySFg6Hi82J3GRi6zyjZOgQ9uGH8Nv3fUzEA
         MnFw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=83M9MuuyfBLXZ/YL/qV9yuohrUfZzP/MjRMpSeq4O70=;
        b=X6ewDkhbgNvKipdRTW3lroDwbgtFwFGxFXtExD5I4zG/5hssxY0BfW3GqSWGqBN4/q
         9yP2uUUFAyf2W86E8gVRPbcDma5kB8uhN8R6nwhgmuwkriV1ihpexIBySKEHa9uP47s5
         /QoeyX60vol3VS/62izFAnOu+vWn59utd2WYY/cizr4PzQqcUH+UOyKWiZtyi/SkF3NC
         ZLV37h45rvZOTldruBgV+N44gbbx25ruTSrTcuS2uq0CB+p13hViyZ50tzrsP+FQfViA
         eo+flTWd55Ae5VFhVwqJ/6ys52+nP/JFgesSH82kvf75E+n6HPkU0vHXOq979/AhTwqJ
         nzHw==
X-Gm-Message-State: AGRZ1gIQF1/azz2tDrW3v23EhY8KfxmnxHEhtN/jvCGvBmMyyCmqIHF6
        rP2sFywb+Rkm0xmwj1vnu1X31ac=
X-Google-Smtp-Source: AJdET5er1WDFkFEPiFKvGVj9jh2O7IlQ0jChF5UYPvZDX3S/7CbSkSLity1KsAMY/YunRAg7jIyOUA==
X-Received: by 2002:a24:560a:: with SMTP id o10-v6mr1839945itb.2.1541698621051;
        Thu, 08 Nov 2018 09:37:01 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id f64-v6sm1383121ioa.54.2018.11.08.09.36.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 08 Nov 2018 09:37:00 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFSv4: Ensure that the state manager exits the loop on SIGKILL
Date:   Thu,  8 Nov 2018 12:35:56 -0500
Message-Id: <20181108173556.9295-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181108173556.9295-1-trond.myklebust@hammerspace.com>
References: <20181108173556.9295-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 98d1b6a6646a..ffea57885394 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2604,7 +2604,7 @@ static void nfs4_state_manager(struct nfs_client *clp)
 			return;
 		if (test_and_set_bit(NFS4CLNT_MANAGER_RUNNING, &clp->cl_state) != 0)
 			return;
-	} while (refcount_read(&clp->cl_count) > 1);
+	} while (refcount_read(&clp->cl_count) > 1 && !signalled());
 	goto out_drain;
 
 out_error:
-- 
2.19.1

