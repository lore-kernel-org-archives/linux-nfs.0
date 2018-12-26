Return-Path: <SRS0=jCTp=PD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA055C43387
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 03:18:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9177321720
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Dec 2018 03:18:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=umn.edu header.i=@umn.edu header.b="FkFoimry"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725970AbeLZDSx (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 Dec 2018 22:18:53 -0500
Received: from mta-p5.oit.umn.edu ([134.84.196.205]:40768 "EHLO
        mta-p5.oit.umn.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725889AbeLZDSx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Dec 2018 22:18:53 -0500
Received: from localhost (unknown [127.0.0.1])
        by mta-p5.oit.umn.edu (Postfix) with ESMTP id 833AB5D7
        for <linux-nfs@vger.kernel.org>; Wed, 26 Dec 2018 03:18:51 +0000 (UTC)
X-Virus-Scanned: amavisd-new at umn.edu
Received: from mta-p5.oit.umn.edu ([127.0.0.1])
        by localhost (mta-p5.oit.umn.edu [127.0.0.1]) (amavisd-new, port 10024)
        with ESMTP id iRW1Y1zfKS2S for <linux-nfs@vger.kernel.org>;
        Tue, 25 Dec 2018 21:18:51 -0600 (CST)
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
        (using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mta-p5.oit.umn.edu (Postfix) with ESMTPS id 5C49E11E
        for <linux-nfs@vger.kernel.org>; Tue, 25 Dec 2018 21:18:51 -0600 (CST)
Received: by mail-io1-f70.google.com with SMTP id s3so12484238iob.15
        for <linux-nfs@vger.kernel.org>; Tue, 25 Dec 2018 19:18:51 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=umn.edu; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=0a6iLoxA6wF1DJBskZp4QRnRWZSuMAttZm8XTbt55IE=;
        b=FkFoimry8UcgsFXwRsAaWHzFwxmQlw82uqijmsUSMqYtQ2+oIjqOFoaTjbXv7yK7RT
         f8xzcOouYTLg8U7l1NIooXGlCT24AkkYdc5c4zK42t3GqXyYc2dxKOpOk+CEcb8HD09j
         lGRNUKooNby8FKMzM0PMQhTnqN6O1S7SzD+566aEoGq92IgPi1I+KzDwsr5sicLEgRhr
         lXlvOEnnaLVeksPuxZsfXE28GWT17cPOXfh0wXE8d8iX596kEcBZKhb13HPTG39uEfCs
         2tYjMk1VJxWkPqC85P7eeyH+HOCbaAZcCiUQ3vcPKiROhBV6XnUI9crraVt0ncU8fueY
         pDLA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=0a6iLoxA6wF1DJBskZp4QRnRWZSuMAttZm8XTbt55IE=;
        b=WL3QJlXfy78HK+55dPUklnirtCzKZGybbFjanEEGduvkmYFPGGxoOa5jvh4ixN5fBG
         lwglJA+rdRvp0kRCQMCGwuxqWOa9T+BelVXf5IVWd/bbWfCG8Ust6zNDYxDpedBmGbN1
         /OD+WkXvjSucRl+FpH8Axl/jJJVu8Ufj2A+If/Ala4EMQUZIkTZc/OSK/LU32T1iLdes
         mbQTlV3Obo0OVrSfj0OB3On6YY8ZA7EfSB6s0t9aFXr/pcNbf9Gqfd27SLr9ly1hXpQ7
         M836+8niD1+pZRhJviMCex5gyaYNqbpzxp2bozobCzYJEK8yJjKSJ6/7EWXy4Of21r9c
         a4Kg==
X-Gm-Message-State: AA+aEWan34MpROHLnZYip+iIgG+t5BOlBq/rzX55SORx6VKC9NmAYCrQ
        acdXWyd/NRY9S7sTo5gNS0w+AKBEDKvwNk1wzJu/L1fdC/44j5/RdYz3cm1TtdVbwAH1O7e6yR6
        I80RatZODwkJtR/BuK2ln9tOc
X-Received: by 2002:a24:3282:: with SMTP id j124mr11757068ita.173.1545794330952;
        Tue, 25 Dec 2018 19:18:50 -0800 (PST)
X-Google-Smtp-Source: AFSGD/WftqB9KCTFRY9ZyUZ6oBd5zjtWRNPWRRNttOps53AenS3SuGmlhIEQDMoTrZAAVPRKCpLScw==
X-Received: by 2002:a24:3282:: with SMTP id j124mr11757065ita.173.1545794330743;
        Tue, 25 Dec 2018 19:18:50 -0800 (PST)
Received: from localhost.localdomain (host-173-230-104-22.mnmigsc.mn.minneapolis.us.clients.pavlovmedia.net. [173.230.104.22])
        by smtp.gmail.com with ESMTPSA id m37sm12241104iti.6.2018.12.25.19.18.49
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 25 Dec 2018 19:18:49 -0800 (PST)
From:   Kangjie Lu <kjlu@umn.edu>
To:     kjlu@umn.edu
Cc:     pakki001@umn.edu, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Chuck Lever <chuck.lever@oracle.com>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH] sunrpc: fix a missing check of xdr_inline_decode
Date:   Tue, 25 Dec 2018 21:18:21 -0600
Message-Id: <20181226031823.72962-1-kjlu@umn.edu>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

xdr_inline_decode() could fail. When it fails, the return value is NULL
and should not be dereferenced.
The fix checks if xdr_inline_decode fails, and if so, returns.

Signed-off-by: Kangjie Lu <kjlu@umn.edu>
---
 net/sunrpc/xprtrdma/backchannel.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/backchannel.c b/net/sunrpc/xprtrdma/backchannel.c
index e5b367a3e517..bd9be5272ef4 100644
--- a/net/sunrpc/xprtrdma/backchannel.c
+++ b/net/sunrpc/xprtrdma/backchannel.c
@@ -285,6 +285,8 @@ void rpcrdma_bc_receive_call(struct rpcrdma_xprt *r_xprt,
 	__be32 *p;
 
 	p = xdr_inline_decode(&rep->rr_stream, 0);
+	if (unlikely(!p))
+		goto out_overflow;
 	size = xdr_stream_remaining(&rep->rr_stream);
 
 #ifdef RPCRDMA_BACKCHANNEL_DEBUG
-- 
2.17.2 (Apple Git-113)

