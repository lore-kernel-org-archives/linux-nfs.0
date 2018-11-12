Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA9CCC07E85
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:13:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6DD8E223AE
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 21:13:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZsGF/FLd"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6DD8E223AE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726159AbeKMHIB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 13 Nov 2018 02:08:01 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39870 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725817AbeKMHIA (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 13 Nov 2018 02:08:00 -0500
Received: by mail-it1-f196.google.com with SMTP id m15so15307924itl.4
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 13:13:02 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=WTD+VkPZ28nUVmkZ2TcVHv4/6hx2Td6cO8/Iz09BfV0=;
        b=ZsGF/FLdVeQJ4eYM8n7GoOcqJg572Mm/q/WaF7bJXMPexwi3aaGFSRfjBeCatG88JO
         /eOKFzKPEoHqxWFp/9WAMtTUXXy91tjfj8n1wz7gAbKQKj70LW586jzsoI4Soxx+ghd8
         9zEUCpeuMU0oenV0gCEWVorTeFfSUT2NRG/V5EUIu++QQi36oABaXau+yaS0+6gn1jtu
         KYcCvWiPzbshEOeOjwOn1TI0CWU6vioIkeTzyYYUudzUG/BVb4WYE2zs73CM7ITDiXGa
         Nv+ShWUyjPHqG7bNpusfWD1lZr+ghqSl8XAdoPlo4f9cdgHb04yUx3IZva/zv8UABABE
         5o9A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=WTD+VkPZ28nUVmkZ2TcVHv4/6hx2Td6cO8/Iz09BfV0=;
        b=OPGJkIrVj4eT2cqNspIw3ALoAP54UgP+JtLoc+QDDXBwUFxDxRvbjug0DpHo9+mHqh
         urnbMD3z+XSila3hiSJJq6Ubv8yrqaInVwOOaEF/h20bIhrzbMvbwQgqr5xuoSzS2RY4
         vg3lPR87jbJuoEWmYtsznOjn3lIKzqauMFqYthytoel3xsmbNSVkS66z9p162uqti/68
         v+FqDWKKCTuAR4bYHvB4M5oVnRT8JYESfSD0Rt6Flbvofs0li0e+nggP7/MHgkaQQQIc
         NK/3tp6ztGeGwcmyixORrAMJB3fO+2rcdavEm1ymZLfzISePcev7CdtW3jwQLAl/YATw
         g20A==
X-Gm-Message-State: AGRZ1gJ/v240Wlni1iZXJIPfqhPCbIrDFIDvEGjNhBHRYfbQW7w2sCC1
        GgwI0JdJwpXDKbs82CIjKg==
X-Google-Smtp-Source: AJdET5focWpAJOPcoBQRV60Sr1tNnftUeOM0Qv3aiMA3OaovqNoPadNekikpMID8i1DYD0lQYLtWhQ==
X-Received: by 2002:a05:660c:984:: with SMTP id z4mr1250178itj.77.1542057181603;
        Mon, 12 Nov 2018 13:13:01 -0800 (PST)
Received: from localhost.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id e80-v6sm5361207itc.35.2018.11.12.13.13.00
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 12 Nov 2018 13:13:00 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Bruce Fields <bfields@fieldses.org>,
        Chuck Lever <chucklever@gmail.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] SUNRPC: Fix a bogus get/put in generic_key_to_expire()
Date:   Mon, 12 Nov 2018 16:11:51 -0500
Message-Id: <20181112211151.119201-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20181112211151.119201-1-trond.myklebust@hammerspace.com>
References: <20181112211151.119201-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/auth_generic.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/net/sunrpc/auth_generic.c b/net/sunrpc/auth_generic.c
index d8831b988b1e..ab4a3be1542a 100644
--- a/net/sunrpc/auth_generic.c
+++ b/net/sunrpc/auth_generic.c
@@ -281,13 +281,7 @@ static bool generic_key_to_expire(struct rpc_cred *cred)
 {
 	struct auth_cred *acred = &container_of(cred, struct generic_cred,
 						gc_base)->acred;
-	bool ret;
-
-	get_rpccred(cred);
-	ret = test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
-	put_rpccred(cred);
-
-	return ret;
+	return test_bit(RPC_CRED_KEY_EXPIRE_SOON, &acred->ac_flags);
 }
 
 static const struct rpc_credops generic_credops = {
-- 
2.19.1

