Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE615C00140
	for <linux-nfs@archiver.kernel.org>; Tue, 16 Aug 2022 02:06:01 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S240356AbiHPCGB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 15 Aug 2022 22:06:01 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:56972 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S241870AbiHPCFk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 15 Aug 2022 22:05:40 -0400
Received: from mail-pj1-x102c.google.com (mail-pj1-x102c.google.com [IPv6:2607:f8b0:4864:20::102c])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id A6B5D225EC7
        for <linux-nfs@vger.kernel.org>; Mon, 15 Aug 2022 14:55:25 -0700 (PDT)
Received: by mail-pj1-x102c.google.com with SMTP id w11-20020a17090a380b00b001f73f75a1feso15639090pjb.2
        for <linux-nfs@vger.kernel.org>; Mon, 15 Aug 2022 14:55:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc;
        bh=QXbu5C9yLJQGllKEerLcEUbrtkAOIoyBDTqCrJfYX5E=;
        b=RK/7kNjHQ3z/pnSdcltqVTWc7JbXu3sJe/btasd9+JJG/txQS862epE8d3dvU48C2Y
         PXpH57vO1sDhEHd+qF8c2Vs0EWvoabT5KJKLVmMw8n1lxs5VEB0Dgj6QtCvs94oIYqUs
         7rwss28l92LCE0vsBFX7UZ6r8c8QPdFZniZZ2T0bl08Fj1+g8NJ0uDk6aQ09RZNxl+Ud
         KUc/58Tmf0rNMS5PnBozN7EWmV4t0/bl+4JfKr20yhwt4F6trL+QPHjYMIrhxD+ZqISK
         SWHEbJS+fYosZKw5ooMLIkSvGfHUphn2W8eUd0eAraataUb4HmKYbC6XQMuzU1PXnIT5
         11XQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-message-state:from:to:cc;
        bh=QXbu5C9yLJQGllKEerLcEUbrtkAOIoyBDTqCrJfYX5E=;
        b=4pAScg3M9q2CD1IvSSy8GaTtvQ4T0ZBG9WzIzzFsVHnhv7JQQ83lTFQJH+8nCLiafh
         6l7z9Ba6t6H8BqjNOv2++N3js0epSd3DdCKebLl/Io3UaqaN+T3XsLtXdiX/FzjzyUV0
         jd/oEAn8/zMgFzFPSk5fvunpxhFL8nSK7GjxZH/IPP5DIafui3Aou0vSi+AHdnSBgo4a
         lQAJ3FA49Jq01qHT51CMmd813kw4BTUtVIwzv42Kr2bfyDauQ9aQnRjz/OAbKvgEb5y9
         PHGJlHXOQ7bpdzBlg9XgKQurypPujo1v2cwDSPOb3rta54FpjYv/J9e79cOdwBRceVp6
         2aVA==
X-Gm-Message-State: ACgBeo1GhbsOqqLPUoef/FLw9efkw6nYmS9ygy3DNd1YC6UlNpd9ZRsT
        P/PzVnyoqkJW1QYBnsz+D6sB0MJaU5Afkg==
X-Google-Smtp-Source: AA6agR7ldQW2Vw+cFL7nln0SRyItE6Q0rFMbWnXBpMFfVzcRTkvT93zcFY5kEALAmA6fY//xWdYUng==
X-Received: by 2002:a17:903:40cb:b0:16f:196a:2bb4 with SMTP id t11-20020a17090340cb00b0016f196a2bb4mr19079785pld.104.1660600515682;
        Mon, 15 Aug 2022 14:55:15 -0700 (PDT)
Received: from apollo.hsd1.ca.comcast.net ([2601:646:9200:a0f0::bb7a])
        by smtp.gmail.com with ESMTPSA id l65-20020a622544000000b005323a1ba20fsm7010198pfl.42.2022.08.15.14.55.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 15 Aug 2022 14:55:14 -0700 (PDT)
From:   Khem Raj <raj.khem@gmail.com>
To:     linux-nfs@vger.kernel.org
Cc:     Khem Raj <raj.khem@gmail.com>,
        Konstantin Khorenko <khorenko@virtuozzo.com>,
        Steve Dickson <steved@redhat.com>
Subject: [PATCH 2/2] mountd: Check for return of stat function
Date:   Mon, 15 Aug 2022 14:55:11 -0700
Message-Id: <20220815215511.2595236-2-raj.khem@gmail.com>
X-Mailer: git-send-email 2.37.2
In-Reply-To: <20220815215511.2595236-1-raj.khem@gmail.com>
References: <20220815215511.2595236-1-raj.khem@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

simplify the check, stat() return 0 on success -1 on failure

Fixes clang reported errors e.g.

| v4clients.c:29:6: error: logical not is only applied to the left hand side of this comparison [-Werror,-Wlogical-not-parentheses]
|         if (!stat("/proc/fs/nfsd/clients", &sb) == 0 ||
|             ^                                   ~~

Signed-off-by: Khem Raj <raj.khem@gmail.com>
Cc: Konstantin Khorenko <khorenko@virtuozzo.com>
Cc: Steve Dickson <steved@redhat.com>
Signed-off-by: Khem Raj <raj.khem@gmail.com>
---
 support/export/v4clients.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/export/v4clients.c b/support/export/v4clients.c
index 5f15b614..32302512 100644
--- a/support/export/v4clients.c
+++ b/support/export/v4clients.c
@@ -26,7 +26,7 @@ void v4clients_init(void)
 {
 	struct stat sb;
 
-	if (!stat("/proc/fs/nfsd/clients", &sb) == 0 ||
+	if (stat("/proc/fs/nfsd/clients", &sb) != 0 ||
 	    !S_ISDIR(sb.st_mode))
 		return;
 	if (clients_fd >= 0)
-- 
2.37.2

