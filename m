Return-Path: <SRS0=/Mrm=SR=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FE3FC10F13
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 02:11:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5305820645
	for <linux-nfs@archiver.kernel.org>; Mon, 15 Apr 2019 02:11:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WmVaChhV"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726201AbfDOCLm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 14 Apr 2019 22:11:42 -0400
Received: from mail-pg1-f194.google.com ([209.85.215.194]:41547 "EHLO
        mail-pg1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725975AbfDOCLm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Apr 2019 22:11:42 -0400
Received: by mail-pg1-f194.google.com with SMTP id f6so7792764pgs.8
        for <linux-nfs@vger.kernel.org>; Sun, 14 Apr 2019 19:11:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=KgUDnxMhlk9mMQ2pEKDSklqTS0g+cr/3614GyQDPklw=;
        b=WmVaChhVkwj45gKkRTdXzdeIfvdiB0RbB9VQbojz3F8jQixQgbi3al9DTUFMndfvOt
         nWsiVicnBkZNF+2QrjL72vr19UVPBGUEEqmsl4rhz55M2gJZWZfBw5IK3tthyIX2CZm4
         Kx9/iABqaVeZM+einaReUzg6wme/VVBKKgzWc6t3soYE5b6LbbxuplbZ+iV8c3DBo3YO
         z2JjA334Y13Px7+oSCjVBvDg9Y3pjcaPo8D+3Kj+SzHRgsLqN7t1rlcbHqRLEuDPdXX+
         bQWb5elWEVFXUv5c6WUJDg3yIWaRjTTHngHKD9cSNOkRSGOxEbY/K1N/Q+em6jmGwFyy
         h9yw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id;
        bh=KgUDnxMhlk9mMQ2pEKDSklqTS0g+cr/3614GyQDPklw=;
        b=nE841mXbQNmNCNo0PRzYl+sGN/UpNymQPoebpgEZqygeHc4AEde0E7g34I8N27afVG
         8gcFtvD/02UmVyo1MfQwuvHuFAYiXszfIFER0mJFD9FuhCg3+nP4qk9C3QyRs30R4cIi
         sHYh7AHSJ2A0hDhKwtfc7l7lIAL4y+3FeD362wJDc7dZ5oWy5f32cAote1eCpwxmE7+c
         k7Rkn1U10fNxJqMpvQH16epQpQL/zj2G5tRHoCorIXjAVALhH8B7eTw9cd9uAjhO7Z4E
         YMch2ppRgb1cS4h1byLKBS0drSJ3x1LkWxeHHft1QFjIbihMMHG2r288rxjgPOeH71Hy
         +Czg==
X-Gm-Message-State: APjAAAXF2sFj/UK+FwCPyfhYdyfRhqkyqvU4bzuSfPpN/U6q32mDc/TY
        UaYwWrb5x/ifY8aH82zAlLD8vJg5yXA=
X-Google-Smtp-Source: APXvYqxUZc+GU0maMnmyAJtNGxQesVDWtfMph4ZR382ftYunRrTKZW8c7tA7mroP0l9xEktI3GwNww==
X-Received: by 2002:a62:ed16:: with SMTP id u22mr72720981pfh.47.1555294301656;
        Sun, 14 Apr 2019 19:11:41 -0700 (PDT)
Received: from mangix-pc.lan (76-14-106-140.rk.wavecable.com. [76.14.106.140])
        by smtp.gmail.com with ESMTPSA id 6sm35180283pfp.143.2019.04.14.19.11.40
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Apr 2019 19:11:41 -0700 (PDT)
From:   Rosen Penev <rosenp@gmail.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH] idmapd: Add missing libgen header
Date:   Sun, 14 Apr 2019 19:11:40 -0700
Message-Id: <20190415021140.1388-1-rosenp@gmail.com>
X-Mailer: git-send-email 2.17.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Otherwise compilation can fail with an implicit declaration of basename.

Signed-off-by: Rosen Penev <rosenp@gmail.com>
---
 utils/idmapd/idmapd.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 91c0253..62e37b8 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -59,6 +59,7 @@
 #include <grp.h>
 #include <limits.h>
 #include <ctype.h>
+#include <libgen.h>
 #include <nfsidmap.h>
 
 #ifdef HAVE_CONFIG_H
-- 
2.17.1

