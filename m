Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CE21C63697
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Nov 2020 02:45:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C10EA22202
	for <linux-nfs@archiver.kernel.org>; Fri, 27 Nov 2020 02:45:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TsXFEtf/"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2392231AbgK0Cou (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 26 Nov 2020 21:44:50 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:37994 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728340AbgK0Cou (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Nov 2020 21:44:50 -0500
Received: from mail-pl1-x644.google.com (mail-pl1-x644.google.com [IPv6:2607:f8b0:4864:20::644])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 04881C0613D4
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2020 18:44:48 -0800 (PST)
Received: by mail-pl1-x644.google.com with SMTP id l1so1995104pld.5
        for <linux-nfs@vger.kernel.org>; Thu, 26 Nov 2020 18:44:48 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=XO6KlSjUi7E5C0/Bld/ZNsk17pOV0FAtPKGKxUDPzxU=;
        b=TsXFEtf/4SiUkAMgp/p6lfN+h7ABAjnghaZxdTfZ9fhmfS1Oi6xixfFkR53Yjo94iZ
         Om733y3GSfJFph5TK22lpsENpFyJpMcGviHZbgu4uaR5C/lgtd/KDjhFnCO2ZqXEa0Zz
         4x6mDzNz4xAfNZMqZkMD2ssXhAyNJIiTVG8iBD+evK2I74CHHqf2MoSr5cC7mTwtwQDs
         UZfCPcyhYBHCNoDphK0OGGP2IUfRjZjqSTGUlywUIu79HBp0uLeBZRt11BLKmhDlONsF
         TYPzkdZDUBciI2HLTmtwcs1LiECrXFz7e9O3dh7ubsv/eu4BI5wYXAGnHi0xA6FIHKux
         7v4A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=XO6KlSjUi7E5C0/Bld/ZNsk17pOV0FAtPKGKxUDPzxU=;
        b=WOdW+pX1L7C4/icTrbFzF2zuTQBdz5PQWsn7oU/A4EPa4RZ48Rj3Aiz8SbRTtfXvbq
         Sy58ebPXzrmSp3Urld/6htyXnJ++Sfg2X9vYlURrO9oGnxGoa+MLLElFxkyPUvfHpTao
         jMVVALGDhTgRakcWICaUuCZGA6Ls92YEVN424UEyW/vpzyECPGMoJdmKvtvF3sOmxhW8
         benwr02Gpc6RZGVcaX5JSiNS/qYWdP5vYes5Y/2hgYsZ10SIoFmNiSBIVpbWTOStzMg6
         SKHuJdeXqRwectN4aUOnEpUWPGyubFLcyT3LSKhbxBDrGePcu+pToLZ5qelzJIv7eFI3
         JJzg==
X-Gm-Message-State: AOAM530duLpoPezP0teMI42FN3htmddunovGrYTmsdQGfObhb5mQOlQf
        MEtNdXhxPv9r8oxMlz3Fg8Q=
X-Google-Smtp-Source: ABdhPJz229KZprPCrKXyKT5QtA1zaSz4GeEAHiFYojYZMqLo+DNqbdXh5besdzCJtlvgyIzceIF1sg==
X-Received: by 2002:a17:902:e9cc:b029:da:1d7a:f5fa with SMTP id 12-20020a170902e9ccb02900da1d7af5famr5120377plk.38.1606445088321;
        Thu, 26 Nov 2020 18:44:48 -0800 (PST)
Received: from localhost.localdomain (af234189.ppp.asahi-net.or.jp. [116.70.234.189])
        by smtp.gmail.com with ESMTPSA id iq11sm4469675pjb.39.2020.11.26.18.44.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 26 Nov 2020 18:44:47 -0800 (PST)
From:   kazuo ito <kzpn200@gmail.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Cc:     kazuo ito <kzpn200@gmail.com>, Jeff Layton <jlayton@kernel.org>
Subject: [PATCH] nfsd: Fix message level for normal termination
Date:   Fri, 27 Nov 2020 11:44:39 +0900
Message-Id: <20201127024439.32297-1-kzpn200@gmail.com>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

A warning message from nfsd terminating normally
can confuse system adminstrators or monitoring software.

Though it's not exactly fair to pin-point a commit where it
originated, the current form in the current place started
to appear in:

Fixes: e096bbc6488d ("knfsd: remove special handling for SIGHUP")
Signed-off-by: kazuo ito <kzpn200@gmail.com>
---
 fs/nfsd/nfssvc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index f7f6473578af..b08cccb71787 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -527,8 +527,8 @@ static void nfsd_last_thread(struct svc_serv *serv, struct net *net)
 		return;
 
 	nfsd_shutdown_net(net);
-	printk(KERN_WARNING "nfsd: last server has exited, flushing export "
-			    "cache\n");
+	printk(KERN_INFO "nfsd: last server has exited, flushing export "
+			 "cache\n");
 	nfsd_export_flush(net);
 }
 
-- 
2.20.1

