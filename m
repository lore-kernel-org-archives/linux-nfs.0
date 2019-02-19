Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3EBBC43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1E8E2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fpg0bBxI"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728751AbfBSNzW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:22 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:36447 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727529AbfBSNzW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:22 -0500
Received: by mail-it1-f193.google.com with SMTP id h6so6317394itl.1
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:21 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Hho1BGvKZPnwDF52YjAEi9f0bBIjWXPu4U6fGS0pZxA=;
        b=fpg0bBxIofaAZUWy3Qs8MnGtgzNr2I9kZkNMpUDs5GLRZNP7plUroFP60v3cN1DHVn
         l4jMrmUhqzn9RLtqfgN2+E3Ra1IPFDF5k1m2vi6c+S+xLKf6yriaNJ3B80ooC/2bmVwj
         hku3HjqLe99Zzi/NoaMpzluZ7Se+2fl7XKYQYUNAbGje3Ys3ytg5XaUjLt8F9f2SCTv6
         v86gnqYXGbrvzybvj6jLvnpnIK5xY1a/8EOlUJ+ZAeMiXz133poDUT74+Q7RK80HXFtO
         vDuv9avIynYC/IVEYwB6hwGYIKsiwp9bzIaXx+Qadmbc1ZZuu7m3tcEIUoUnliOcHVpB
         z9qA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Hho1BGvKZPnwDF52YjAEi9f0bBIjWXPu4U6fGS0pZxA=;
        b=AiWCZkSLOiRpY4WbcbXEL3sMgfZlcuH06ZrXTMyGe7jIt2wN+P2SF+Pt5VIy8sA0O9
         WN2ZVca/XH6N4TkzVoARvDjPLpGkqiJ7gn8/m/wK4zwWwTfIO+0PRM5xBfVSRYhYP1SP
         vU/PO5S2tb/jqr5uRPIzT3vbiAuPb1x5D7IR429PuU8smZsC81FnFwn2RqUSPBhKfhBa
         qx5JXU6FyRua1uCkDon6D1u/cB6WHJkvUZRFbFclodzEgR65POuSXJvt9RBYyDkS9RU1
         HKs62fZe5gN791LZCoKrScv+CO1yrulvjkhAdEIT7XSYA9k1jw8Fu7zs8yzB7aI3Upub
         8Taw==
X-Gm-Message-State: AHQUAuYxzkHyiOD+vipLnYS8l+nhwcgWQBp2ftiAjRx6Qv0pWfyqw65w
        JjAE67h/b6IZpSsTBjLtVm/3Ons=
X-Google-Smtp-Source: AHgI3IYYGNYrkAsX9A35qG4yYcHN8CoicJamAyudekxQZhkYlXN3Atxdn1+/siTh1EXJN/hYeFa2aQ==
X-Received: by 2002:a05:660c:741:: with SMTP id a1mr2032529itl.100.1550584520939;
        Tue, 19 Feb 2019 05:55:20 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.20
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:20 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 8/8] NFS: ENOMEM should also be a fatal error.
Date:   Tue, 19 Feb 2019 08:53:11 -0500
Message-Id: <20190219135311.119300-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-8-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
 <20190219135311.119300-4-trond.myklebust@hammerspace.com>
 <20190219135311.119300-5-trond.myklebust@hammerspace.com>
 <20190219135311.119300-6-trond.myklebust@hammerspace.com>
 <20190219135311.119300-7-trond.myklebust@hammerspace.com>
 <20190219135311.119300-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/internal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 1cb9670bb8b5..b26622d9686f 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -764,6 +764,7 @@ static inline bool nfs_error_is_fatal(int err)
 	case -EROFS:
 	case -ESTALE:
 	case -E2BIG:
+	case -ENOMEM:
 		return true;
 	default:
 		return false;
-- 
2.20.1

