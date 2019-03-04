Return-Path: <SRS0=iDPq=RH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7332C43381
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 75D4320835
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Mar 2019 00:20:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oe+y9+fS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725962AbfCDAUi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 3 Mar 2019 19:20:38 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:52546 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725984AbfCDAUi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Mar 2019 19:20:38 -0500
Received: by mail-it1-f195.google.com with SMTP id g17so4894930ita.2
        for <linux-nfs@vger.kernel.org>; Sun, 03 Mar 2019 16:20:38 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iwBwAAHltJNf0W7w2LajIAFj5YrN6f2GsMXdF+iPYe4=;
        b=oe+y9+fSulE2ydG+v5mN+/q3IBWg6nofGLjdbTK8+tdT7O7ZUozQlWQdCe24fiudKw
         F5Z+FumeKEXFxFIw0GJTnwhCzWXjMiELXBfX3V8SPHWbLNa/1luyOGuJO6ILGtyPafL4
         ZWpJ/ggGSdemknWvukm2INWtiNfcnQHtfdxKkSFtOCgQEtCo5D+SKPbBTofOrgmwMhqW
         mP//o83Bs0zjA6WNsGoCVhwcFrBwvQvFoGghKToP586/U+nZA9LeLeApKcFqurs8Gsit
         XvRUMVPCRgTMLvoV2SfXsBvMfm/geDlJa46MpIzp/r/xAaIbuW/T8/aYAvhipfJAYiPS
         78ig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=iwBwAAHltJNf0W7w2LajIAFj5YrN6f2GsMXdF+iPYe4=;
        b=leJzmT57FyYNEXMI2HaTKqUpEbWHa4S4mqImB1Jdj7KhFbUazQcFNMDkb/yrYpyUHT
         BWEn3P8TDg2GBf+jCpVuLvUvOF0EbCwxckT9G5d/JmHDpqdm0yUvHAYMo0iPBv2mv6Y0
         2mUj8JiiOJ2vOsxniZdcmYI0w37lCvAwsLsjRiG9Xpsr5QGK5NqeHTlrxFdQwLLaV+sI
         SwWknhjQzo7DYzShk/2K8OwZj6nukM4W/E6aGXKb1aaUX11N9Ys3bQQhdztF7Bv6h/Q0
         CaVmUB8yhA6nG/kZobHboaBUyNNMEVm7fsc6A/1b0by6+9X+StgaPQGvhrb5Pv3YKaW2
         TTrQ==
X-Gm-Message-State: APjAAAVECkTNusRAQHeBOj7nbSlbaB9nZKCJxUlUEMiEjODWB7xvPM0a
        qfo3jxmutaxjTh8IpFT9IYx60a0=
X-Google-Smtp-Source: APXvYqyu5SGnbEhQuMaOq2RdHEJzOX7D7lMKz5nm+eOX7obapa3gPf5+5AR92jDjrfZzmgHtE7Lfrg==
X-Received: by 2002:a02:e04:: with SMTP id 4mr8824182jae.75.1551658837491;
        Sun, 03 Mar 2019 16:20:37 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id i5sm2430350itb.3.2019.03.03.16.20.36
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 03 Mar 2019 16:20:37 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] NFSv4.1: Bump the default callback session slot count to 16
Date:   Sun,  3 Mar 2019 19:19:27 -0500
Message-Id: <20190304001928.4397-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
References: <20190304001928.4397-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Users can still control this value explicitly using the
max_session_cb_slots module parameter, but let's bump the default
up to 16 for now.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4session.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4session.h b/fs/nfs/nfs4session.h
index 230509b77121..b996ee23f1ba 100644
--- a/fs/nfs/nfs4session.h
+++ b/fs/nfs/nfs4session.h
@@ -10,7 +10,7 @@
 
 /* maximum number of slots to use */
 #define NFS4_DEF_SLOT_TABLE_SIZE (64U)
-#define NFS4_DEF_CB_SLOT_TABLE_SIZE (1U)
+#define NFS4_DEF_CB_SLOT_TABLE_SIZE (16U)
 #define NFS4_MAX_SLOT_TABLE (1024U)
 #define NFS4_NO_SLOT ((u32)-1)
 
-- 
2.20.1

