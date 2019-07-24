Return-Path: <SRS0=uOgE=VV=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECB8AC7618B
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Jul 2019 08:28:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B59CB206B8
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Jul 2019 08:28:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Pmja9Lry"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726043AbfGXI2N (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Jul 2019 04:28:13 -0400
Received: from mail-pg1-f195.google.com ([209.85.215.195]:36714 "EHLO
        mail-pg1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726023AbfGXI2M (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Jul 2019 04:28:12 -0400
Received: by mail-pg1-f195.google.com with SMTP id l21so20839006pgm.3;
        Wed, 24 Jul 2019 01:28:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=0C3QHUgqiz2AWGYc73OVCf2o4dWSm01USkJ0t4N3DX4=;
        b=Pmja9LryXNERq5j5QPJ7x80n1QFTUD6r3VZAiyBwmifIu8xEmifP7rxzYzadZxiI18
         Gl8jXyqQpBMvAZHAVnjtxVMM5TS1Bkv3q/lT+kG5iNft1wXvxoDtQpw3lbhdnGfWzoTl
         pkWjtfzaXv1gji8kUKy+Hews+GB0jMqtswQYfVY3bQR/WIfOTHSAnSJF1Kl0/njmYIBn
         bm6lW7FxgE/BUzJIJC1sYNq6l2Akcv7f197i0LxXkardtVnWOH7N8SnSlIowe1cSuBRZ
         By7dMPnzOGCwDR4fJSlbSMxickl78DpEYTWfbz2zdmoQJAM6k4T5MYHE5CPyhxfbpxrS
         +svg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=0C3QHUgqiz2AWGYc73OVCf2o4dWSm01USkJ0t4N3DX4=;
        b=cXkHdqO2vl5XjliU6yFXHeDmpr9scAnqi5u590uFxAsQy3np/URLwgRirmUl97KC5T
         tyuJe9reckt8LxEoz0lRfLHH5uajspUg4DfG83V/aqiIU7N8qK3khkfxxrWtxtrg/fjE
         gq9cEIBpz95joO1rFpPERIMPlos+jyNvHG89ERED6EUfPjw0guQVGI5hQJeDTfFTvMO4
         DWOdPi6Uzp8thXUYhvIdpHSKsQWUxEDO4nSQA/dKH2PQmY/zEwjnzRlXRcNZ2xZeWOmf
         zktNbIn4beCSZGPVbnJomIc4gHfodrxts3C19XLZIHwf030xfRWNq8rNB4DqV6VUUnH0
         RWSA==
X-Gm-Message-State: APjAAAXtaJunarFeNgx77yXaxNM+BAbFAEJSMbKuoRaQtWigQP/66yhm
        ic/WWkNi8IwUk7aNKAjjyqI=
X-Google-Smtp-Source: APXvYqzgSbHf37RI7NZkA4M+A6+vuXd+IQ7ciaL1Wt7vdxG4DCe7T0DTJhW1UECdpINg0jqXUs9x0A==
X-Received: by 2002:a17:90a:5887:: with SMTP id j7mr85540151pji.136.1563956892216;
        Wed, 24 Jul 2019 01:28:12 -0700 (PDT)
Received: from oslab.tsinghua.edu.cn ([2402:f000:4:72:808::3ca])
        by smtp.gmail.com with ESMTPSA id b68sm58226735pfb.149.2019.07.24.01.28.09
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 01:28:11 -0700 (PDT)
From:   Jia-Ju Bai <baijiaju1990@gmail.com>
To:     bfields@fieldses.org, chuck.lever@oracle.com
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Jia-Ju Bai <baijiaju1990@gmail.com>
Subject: [PATCH] fs: nfsd: Fix three possible null-pointer dereferences
Date:   Wed, 24 Jul 2019 16:28:03 +0800
Message-Id: <20190724082803.1077-1-baijiaju1990@gmail.com>
X-Mailer: git-send-email 2.17.0
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In nfs4_xdr_dec_cb_recall(), nfs4_xdr_dec_cb_layout() and
nfs4_xdr_dec_cb_notify_lock(), there is an if statement to check whether
cb is NULL.

When cb is NULL, the three functions all call:
    decode_cb_op_status(..., &cb->cb_status);

Thus, possible null-pointer dereferences may occur.

To fix these possible bugs, -EINVAL is returned when cb is NULL.

These bugs are found by a static analysis tool STCheck written by us.

Signed-off-by: Jia-Ju Bai <baijiaju1990@gmail.com>
---
 fs/nfsd/nfs4callback.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 397eb7820929..55949a158b6b 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -516,7 +516,8 @@ static int nfs4_xdr_dec_cb_recall(struct rpc_rqst *rqstp,
 		status = decode_cb_sequence4res(xdr, cb);
 		if (unlikely(status || cb->cb_seq_status))
 			return status;
-	}
+	} else
+		return -EINVAL;
 
 	return decode_cb_op_status(xdr, OP_CB_RECALL, &cb->cb_status);
 }
@@ -608,7 +609,9 @@ static int nfs4_xdr_dec_cb_layout(struct rpc_rqst *rqstp,
 		status = decode_cb_sequence4res(xdr, cb);
 		if (unlikely(status || cb->cb_seq_status))
 			return status;
-	}
+	} else
+		return -EINVAL;
+
 	return decode_cb_op_status(xdr, OP_CB_LAYOUTRECALL, &cb->cb_status);
 }
 #endif /* CONFIG_NFSD_PNFS */
@@ -667,7 +670,9 @@ static int nfs4_xdr_dec_cb_notify_lock(struct rpc_rqst *rqstp,
 		status = decode_cb_sequence4res(xdr, cb);
 		if (unlikely(status || cb->cb_seq_status))
 			return status;
-	}
+	} else
+		return -EINVAL;
+	
 	return decode_cb_op_status(xdr, OP_CB_NOTIFY_LOCK, &cb->cb_status);
 }
 
-- 
2.17.0

