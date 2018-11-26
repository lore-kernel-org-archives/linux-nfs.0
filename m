Return-Path: <SRS0=idK9=OF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 63F89C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:05:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28EA120672
	for <linux-nfs@archiver.kernel.org>; Mon, 26 Nov 2018 20:05:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZAvjISGz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28EA120672
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727066AbeK0HBJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 27 Nov 2018 02:01:09 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:51543 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726296AbeK0HBI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Nov 2018 02:01:08 -0500
Received: by mail-it1-f196.google.com with SMTP id x19so30400088itl.1;
        Mon, 26 Nov 2018 12:05:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=uT6jEWL4mnrHEcGZwU8zyYilxoPb6PHeVnKW0oSOv6k=;
        b=ZAvjISGzRXNojOBnwdv7wDjvxKdR9RMVLyvXvr7SJDx9bdFMvMwJFqVakdzA0sXO/H
         L84g1KCxq/UlRBSTGsKS9NoLVTEvwuRTgritvVEDqS6JORK/6Js7VaqAMiLukUSc5Y5K
         BnvK7jAGsFkbqs0EMeHAw522mxd6d6l4E0viNceRA6uJr2/6b2lYs++9VFIQC/CQPCM1
         0Rx5lL5vfqt0yRmBRJeiUAMv/10TEpluh1AcOdTfeY/fDF8/5Bo7uO8cm42wdiTvd4gl
         MDSzCrvbrsa5piIFdYJVNHNJ3PhSbH6FIDpG2fOfyaHeDQAux50WszcnN3lLOuYDEe/9
         +O6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:cc:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=uT6jEWL4mnrHEcGZwU8zyYilxoPb6PHeVnKW0oSOv6k=;
        b=N0Arvi2JbrjMCfGcrDF3FzsusSQvTVD8ZGztGUroZaGW8/VuqFRhOKN6FFvXeatZ2B
         w5bnNrdGtJgWC+euNb+UaNlwTjzs7j1eyofGxGVZ5nMzW17CHA4aLbQ3rPWF+gzm5gX6
         Lc6roZC2AwjDsM1oSrWK6y9k40ENuFTFnDmuum3znH0IWyu9nVbVCFzdAWftpZFevU72
         LuZg5NcbR4xFLnmzwvC7hQUTlCmzy+ExkGzFxmZtpaVoKSUp+Fuz/V6ZPRA/rxvB65od
         FRNqifubnTNdBgyRum+BG3OvIKWKg5OuslxX0RY9kISJSv55+1GP8+AHWVPkjsW2MSyR
         hV2w==
X-Gm-Message-State: AA+aEWYJXHrUf7uM0H8Le0gw/785inkTKvh6olMoP6o/IolDoZmqRUuq
        9GGBTMm2TtRSLEBuT0OpKSk=
X-Google-Smtp-Source: AFSGD/Vztp8kKAQjUg85p64IvO1kd9nt0fMZj5bU+LWRad4IhV/yREk8tZxZyt2mdF6ss+Tpy8BKrA==
X-Received: by 2002:a05:660c:283:: with SMTP id s3mr16233745itl.135.1543262754259;
        Mon, 26 Nov 2018 12:05:54 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id w8-v6sm751564ita.18.2018.11.26.12.05.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Nov 2018 12:05:53 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wAQK5qF4010644;
        Mon, 26 Nov 2018 20:05:52 GMT
Subject: [PATCH v2 01/20] rxe: IB_WR_REG_MR does not capture MR's iova field
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Cc:     Moni Shoua <monis@mellanox.com>,
        Anna Schumaker <schumaker.anna@gmail.com>
Date:   Mon, 26 Nov 2018 15:05:52 -0500
Message-ID: <20181126200552.10321.73218.stgit@manet.1015granger.net>
In-Reply-To: <20181126194611.10321.71714.stgit@manet.1015granger.net>
References: <20181126194611.10321.71714.stgit@manet.1015granger.net>
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
Cc: Moni Shoua <monis@mellanox.com>
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

