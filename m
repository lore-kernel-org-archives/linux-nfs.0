Return-Path: <SRS0=GOsY=O2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C41EDC43387
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:00 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 92F3E2133F
	for <linux-nfs@archiver.kernel.org>; Mon, 17 Dec 2018 16:41:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ODHGSyqi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388281AbeLQQlA (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 17 Dec 2018 11:41:00 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:38564 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388240AbeLQQk7 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Dec 2018 11:40:59 -0500
Received: by mail-it1-f193.google.com with SMTP id h65so20906374ith.3;
        Mon, 17 Dec 2018 08:40:59 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:subject:from:to:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=H0aZ9IKNvgEE1Hf9G52xNkiw9LXd9hc7toVK3qV8SUQ=;
        b=ODHGSyqi8ggRhFvypHusH3tmEo+bU/Pga5RVFK019zK5MoMFmajxoL9NLPCRmrYLc/
         SXn6H33l2ZIVuP8QN4k6ffW4Y5FzRpTUGTfJTbCF8kQri7MNfbrktIytCU90i/DIXJjL
         K8HzZ5UBxG4f1C+jFfl1oTt7thN3B/Pk6/y2GvgI4YVUM949z6qNiOt7k/Ls46I43pIh
         ihbM1NfBAMliFAVK7KoiMsxLaRWjQ0x24JdaNTakuzME+zI56GffeCInDNc6EPqBaXVb
         P4rzQ9wc7ZJ8rYJBTeNamks8RmXv+IjheFSLpPV1TvWt7mNblW7ivBxtGtabTiMReJ5e
         8VVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:subject:from:to:date:message-id
         :in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=H0aZ9IKNvgEE1Hf9G52xNkiw9LXd9hc7toVK3qV8SUQ=;
        b=T1gjiZdwZo1ouN3tVMvmd/jV8HcIlPlxoVRQv2x8EpoQIRX0OwI6wI5PmkxsfHyiyW
         58gjfZ2+xtpEMDDN+FHD71NxCj6cARnAk5mbSNWR8okTaYFGh/SthFzrBB8oXPK1c9Sa
         ug45Ynjgx3syE7YkEl9rMbpyiEhwlC3P+/eRRjNt88937x1k4c5pv+NFXewdU3nabZdp
         hpjTkuZqrxLWI3RDPSPoWP4wVkfZ0r7SnQwGOau7cTOsOyDE8ry5Wkc1CmRrJU0B9jND
         alXjajZfNYXRaPe1y/WZDGgFBLXjP1FQswKK1IYhAr53f7et7pqEGBAZaG88lWo6y0me
         PZUA==
X-Gm-Message-State: AA+aEWbukbxSUTuq8t1qr61n08CvUidX/kG5B4h4ulv4W7gNfzPNaZQu
        ju8wwPPKfbl91bUa9330l1d6jytg
X-Google-Smtp-Source: AFSGD/XvPc2mjGNDqO5mUGpW4SYu2xL57wW/da906F6SRoOiivcbY3NvOTCi6LS1csURjBVz+gV5sg==
X-Received: by 2002:a24:76d0:: with SMTP id z199mr11916542itb.165.1545064858753;
        Mon, 17 Dec 2018 08:40:58 -0800 (PST)
Received: from gateway.1015granger.net (c-68-61-232-219.hsd1.mi.comcast.net. [68.61.232.219])
        by smtp.gmail.com with ESMTPSA id o63sm7894960ita.8.2018.12.17.08.40.58
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Dec 2018 08:40:58 -0800 (PST)
Received: from manet.1015granger.net (manet.1015granger.net [192.168.1.51])
        by gateway.1015granger.net (8.14.7/8.14.7) with ESMTP id wBHGevg9018633;
        Mon, 17 Dec 2018 16:40:57 GMT
Subject: [PATCH v4 18/30] xprtrdma: Remove unused fields from rpcrdma_ia
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date:   Mon, 17 Dec 2018 11:40:57 -0500
Message-ID: <20181217164057.24133.75935.stgit@manet.1015granger.net>
In-Reply-To: <20181217162406.24133.27356.stgit@manet.1015granger.net>
References: <20181217162406.24133.27356.stgit@manet.1015granger.net>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Clean up. The last use of these fields was in commit 173b8f49b3af
("xprtrdma: Demote "connect" log messages") .

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/xprt_rdma.h |    2 --
 1 file changed, 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 6e104cd..375c7be 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -80,8 +80,6 @@ struct rpcrdma_ia {
 	bool			ri_implicit_roundup;
 	enum ib_mr_type		ri_mrtype;
 	unsigned long		ri_flags;
-	struct ib_qp_attr	ri_qp_attr;
-	struct ib_qp_init_attr	ri_qp_init_attr;
 };
 
 enum {

