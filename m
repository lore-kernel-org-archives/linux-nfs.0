Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8FA70C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:13 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6042E2184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DQfdrP/d"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730358AbfC2WCM (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:12 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:55531 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730356AbfC2WCM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:12 -0400
Received: by mail-it1-f194.google.com with SMTP id z126so6167380itd.5
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:11 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=DQfdrP/dIXo226YBN0FJlIgQ2+5Lfw6CZAmzS79ha4XA+IV14dyBruSdHJPRJUH+SD
         A8qqdNlgq9k7lGnw0tJ2NCr4LFoOy37iNLuK5LxtW7uxjfkoXATzStUwZH7qsfJ9a4d7
         8bQxGmkazvSr8kFNjjw9pIC4tds7pXzTk4rM+GDtjaM5uieBApxJWR7FIn72aZuLh69c
         pONhOJaX7VlitS05FN5bDae/ZScWkUfsVY0rhld2J7JWPrcoenPGxjthDiAAgpFPIKd+
         oo9zCIu66jAtWueNlOmVZ9Fn8H1fZKfETEVmzSc7hUtWpKUibfjM5UoWqVjuUQfDs96o
         5C7g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=iod0rF4k3o26lt9yUDw0Zpt/YdbbuY3vBf5tycAuRwDQwILKI4Bx+GmBXtnMVfO7yG
         kwnVrYlKGryZ5lXJzqLrVsyQcF3me8PpxZd1mQJ+xy2QfW+aazqODWhqyo9WPrsWw1On
         d9vy79UAf03DTRjkTzHXnGJGIMjiFfHeXYrsaCGes1HgMAEH41PVnC9RAtbiXJbF2WqG
         OQtgvjxIJkEIRC33q6NHBVc1tuRrrkSlu4HC0OS5utIrWaPEbD+JvIs5nD261jKuJzKQ
         9rDDANIEUvh2DFrHCyoAGTkV8WoxIClbSQFGdj1yCBesYl4e+Dg7TEs8HLme6QZp01+y
         +YiA==
X-Gm-Message-State: APjAAAXc7uI0sQAP7up6+BulFXsjkFYzwPAM4IgU9rS316PPzQxtwCpj
        rpwG0RpNxFyuceGlndI2g/rJ13M=
X-Google-Smtp-Source: APXvYqxZqWG0+XoaEh/B+vgdC5pr6tK++BwGsnMDB+GVIdtvf3jgp/4OV09ZBeKGVf+bExrUiuBt/g==
X-Received: by 2002:a24:2b94:: with SMTP id h142mr6600297ita.13.1553896930106;
        Fri, 29 Mar 2019 15:02:10 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.09
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:09 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 16/28] NFS: Consider ETIMEDOUT to be a fatal error
Date:   Fri, 29 Mar 2019 17:59:36 -0400
Message-Id: <20190329215948.107328-17-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-16-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When we introduce the 'softerr' mount option, we will see the RPC
layer returning ETIMEDOUT errors if the server is unresponsive. We
want to consider those errors to be fatal on par with the EIO errors
that are returned by ordinary 'soft' timeouts..

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/internal.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index c7cf23ae6597..3cefd0ed01be 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -766,6 +766,7 @@ static inline bool nfs_error_is_fatal(int err)
 	case -ESTALE:
 	case -E2BIG:
 	case -ENOMEM:
+	case -ETIMEDOUT:
 		return true;
 	default:
 		return false;
-- 
2.20.1

