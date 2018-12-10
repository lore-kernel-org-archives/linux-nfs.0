Return-Path: <SRS0=PHUf=OT=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A49D2C67839
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6B8C92086D
	for <linux-nfs@archiver.kernel.org>; Mon, 10 Dec 2018 16:29:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OsCnUXpW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6B8C92086D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728201AbeLJQ3c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 10 Dec 2018 11:29:32 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36826 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728163AbeLJQ3b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2018 11:29:31 -0500
Received: by mail-it1-f193.google.com with SMTP id c9so19106337itj.1;
        Mon, 10 Dec 2018 08:29:30 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=E60QTMnLzXqikTFc9PlmyxUrYkyIKen7zpq/u4yreTQ=;
        b=OsCnUXpWKwurRmJ49e5MdSkv1OReKrJ1HD5Nf9AYq8YnUAYxQ1pA+g4u3mFniVVtFB
         1Qfia9OnwYFB3VjW/51V2L/9JQzdlsy1HWmjpKokp8KJMKmOAO+k1vBwYyOMLiVP9zNt
         T1XnxdgrKcX3HTpR2jxYBn1BCBeWBjxbEExZTN0E1wvKhd6HSjYsKW/i65cJkcO1DObT
         +bgO8U41LP0q5SPvIu0wbyVFbGdozNzaKTZc3JkMTd9+XuZBSTs6DvOwUMHCqPtUHroj
         4Ch+VL7ok84eHtrzAagwusQBtDH4l7NEHcnM6y8AEsvUFooQn65k2XBOAG0li0dKhVE0
         W2qA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=E60QTMnLzXqikTFc9PlmyxUrYkyIKen7zpq/u4yreTQ=;
        b=VV6WGGFknQhNSmxXDizBd1H3zBseA7Ysw1uO4UwCQqthzZ9S8zeunyUW8y/WyUpJss
         s9rZ/vhCobcY7LZd3B/7k+8MYpbya9WAKlry+jpmCWKVzI4kYmSBzodrcq54W/EGZD8m
         dUbXnMSS4X7XHFG4LtA84ncaakgyXx2oYj4l9IjFxsAS9piiNPLH/NR6zeDVFJXNXVuo
         UFgf3AXgn/DIhKqqF6upviXZbwtkLf+CVwQAo/CXlOwxI/QO7i0tehYLhTLI6xFTssMR
         RaBPuO+j5ou8ydBnthCNjrvjCHPdp47XUa3c4xB7Y4AasbaP22u+h9h/WzDMZLdJI7n5
         toRA==
X-Gm-Message-State: AA+aEWa69E9z1gOSoDy3FMfnubF775XGlQ/sdVbSoUkJZN2s146zLq33
        8rY6zmKN1QFjtg8uS0t1vW98+uXb
X-Google-Smtp-Source: AFSGD/WiwpwMju/MG1UlpJ2pHNzXEATCGrLFF/IxKty3CzdQV5Z6zlIhAX0KZSn7r96eyC7UFyhYbA==
X-Received: by 2002:a24:8a44:: with SMTP id v65mr11415949itd.67.1544459370500;
        Mon, 10 Dec 2018 08:29:30 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id t1sm2780410iol.85.2018.12.10.08.29.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Dec 2018 08:29:29 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBAGTT2Z031017;
        Mon, 10 Dec 2018 16:29:29 GMT
Subject: [PATCH v3 02/24] IB/rxe: IB_WR_REG_MR does not capture MR's iova
 field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     anna.schumaker@netapp.com
Cc:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 10 Dec 2018 11:29:29 -0500
Message-ID: <20181210162929.4198.19503.stgit@manet.1015granger.net>
In-Reply-To: <20181210161723.4198.51071.stgit@manet.1015granger.net>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

FRWR memory registration is done with a series of calls and WRs.
1. ULP invokes ib_dma_map_sg()
2. ULP invokes ib_map_mr_sg()
3. ULP posts an IB_WR_REG_MR on the Send queue

Step 2 generates an iova. It is permissible for ULPs to change
this iova (with certain restrictions) between steps 2 and 3.

rxe_map_mr_sg captures the MR's iova but later when rxe processes
the REG_MR WR, it ignores the MR's iova field. If a ULP alters the
MR's iova after step 2 but before step 3, rxe never captures that
change.

When the remote sends an RDMA Read targeting that MR, rxe looks up
the R_key, but the altered iova does not match the iova stored in
the MR, causing the RDMA Read request to fail.

Reported-by: Anna Schumaker <schumaker.anna@gmail.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
---
 drivers/infiniband/sw/rxe/rxe_req.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/infiniband/sw/rxe/rxe_req.c b/drivers/infiniband/sw/rxe/rxe_req.c
index 6c361d7..46f62f7 100644
--- a/drivers/infiniband/sw/rxe/rxe_req.c
+++ b/drivers/infiniband/sw/rxe/rxe_req.c
@@ -643,6 +643,7 @@ int rxe_requester(void *arg)
 			rmr->access = wqe->wr.wr.reg.access;
 			rmr->lkey = wqe->wr.wr.reg.key;
 			rmr->rkey = wqe->wr.wr.reg.key;
+			rmr->iova = wqe->wr.wr.reg.mr->iova;
 			wqe->state = wqe_state_done;
 			wqe->status = IB_WC_SUCCESS;
 		} else {

