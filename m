Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.7 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9FBD7C0018C
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Dec 2020 00:37:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6867623741
	for <linux-nfs@archiver.kernel.org>; Thu, 17 Dec 2020 00:37:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727025AbgLQAhF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 16 Dec 2020 19:37:05 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:49470 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727325AbgLQAhF (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2020 19:37:05 -0500
Received: from mail-pg1-x52c.google.com (mail-pg1-x52c.google.com [IPv6:2607:f8b0:4864:20::52c])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 2D529C061248
        for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2020 16:35:54 -0800 (PST)
Received: by mail-pg1-x52c.google.com with SMTP id w16so18986370pga.9
        for <linux-nfs@vger.kernel.org>; Wed, 16 Dec 2020 16:35:54 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=f2p4NDEjDVimhO6Yt6W7ZOCtF0nLrqNvCiwHIwoKLpI=;
        b=BfveUUfZd/sneh0dfS7tbX/O4mtFbWK0ypQakpg1DA5oqFeO+tFxV78qwZ/LciBTGy
         Azfps75ftkRlH/xtO+UrX50kPO7Bx7JcXhnBY96JkKESbclpFh6+nRHYoT0C6wNsxf0j
         C8axuhJJrouix9yce31RDFXMwSjXtZt7h4ULN7A8AHfvNGrFkFRVaF3ooCFXqxC6cQkI
         P1T3LDSiVhSpOf4JzD1XQnuXg3zK9orqRIdcRabwS8k9fMJsiI6aZsu6OJ2kH+VRVzQ+
         5xVUvm+Yb2sqZF5n8rd4T+oPvPhe04yuR8oCaN4XyYrpoIraMDndNaqa34l2rx0t0qjq
         H0dw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=f2p4NDEjDVimhO6Yt6W7ZOCtF0nLrqNvCiwHIwoKLpI=;
        b=BQlcAXlH/w7kS1Fz3/qSChbLywwcc9Qw8tPICiCklUakJVLeFmn9EeLHj/aOcAftsp
         F+WU2RFQt09tWwYQUbyTzpWMNH0ezQK3IoioCq16qpZwwZg/wAw5lI5XUvvi/rWA/Suh
         txgRCeqqhtBRASQpiQC0aX/Rapw6HJI4JEAIWn9ZnG72+UUB8to/Mc5IqoNprtydXrVy
         gmar+GUY36SaPzVHwKHFqfg71jVifk68rx+WrnRPgh+MAucdVp2aarTqWg4eV9SEhMpl
         PrjeocNwTRC4+gQ5Gmc7tDhQNtxK86osQZI9cWY2yXEdCMs2dQpsnM1lv+lgo8cNSL15
         +RuA==
X-Gm-Message-State: AOAM530PQyRPpDoa0zX7GZHbntqghw45LKP2ichxHll+0nVyKxYahIui
        OMBTHVpxv2ixzLiPAwANv9hxiga9qlFRBg==
X-Google-Smtp-Source: ABdhPJzxNBaQf/byX6DuKm7fVHHsb/wV1MOr53HFdJo+JijHqcH1sZj5jOfaTTISuUas4fEYZe0L3Q==
X-Received: by 2002:a63:550a:: with SMTP id j10mr4816591pgb.370.1608165353751;
        Wed, 16 Dec 2020 16:35:53 -0800 (PST)
Received: from garbo.localdomain (c-69-181-67-218.hsd1.ca.comcast.net. [69.181.67.218])
        by smtp.gmail.com with ESMTPSA id v24sm4011243pgi.61.2020.12.16.16.35.52
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 16 Dec 2020 16:35:53 -0800 (PST)
From:   Tom Haynes <loghyr@gmail.com>
X-Google-Original-From: Tom Haynes <loghyr@hammerspace.com>
To:     Bruce Fields <bfields@redhat.com>
Cc:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [pynfs 08/10] st_flex: Only do 100 layoutget/return in loop
Date:   Wed, 16 Dec 2020 16:35:14 -0800
Message-Id: <20201217003516.75438-9-loghyr@hammerspace.com>
X-Mailer: git-send-email 2.26.2
In-Reply-To: <20201217003516.75438-1-loghyr@hammerspace.com>
References: <20201217003516.75438-1-loghyr@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Tom Haynes <loghyr@hammerspace.com>
---
 nfs4.1/server41tests/st_flex.py | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_flex.py b/nfs4.1/server41tests/st_flex.py
index 63efdd2..596c75e 100644
--- a/nfs4.1/server41tests/st_flex.py
+++ b/nfs4.1/server41tests/st_flex.py
@@ -1074,16 +1074,16 @@ def testFlexLayoutReturnDelayWrite(t, env):
     res = close_file(sess, fh, stateid=open_stateid)
     check(res)
 
-def testFlexLayoutReturn1K(t, env):
+def testFlexLayoutReturn100(t, env):
     """
-    Perform LAYOUTGET and LAYOUTRETURN 1K times with error being returned periodically
+    Perform LAYOUTGET and LAYOUTRETURN 100 times with error being returned periodically
 
     FLAGS: flex layoutreturn
-    CODE: FFLOR1K
+    CODE: FFLOR100
     """
     name = env.testname(t)
     sess = env.c1.new_pnfs_client_session(env.testname(t))
-    count = 1000  # Repeat LAYOUTGET/LAYOUTRETURN count times
+    count = 100  # Repeat LAYOUTGET/LAYOUTRETURN count times
     layout_error_ratio = 10  # Send an error every layout_error_ratio layout returns
 
     # Create the file
-- 
2.26.2

