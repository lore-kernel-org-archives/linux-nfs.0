Return-Path: <SRS0=hGXo=T4=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42412C072B1
	for <linux-nfs@archiver.kernel.org>; Tue, 28 May 2019 20:33:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1CD8820B7C
	for <linux-nfs@archiver.kernel.org>; Tue, 28 May 2019 20:33:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RjGBVQz6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726511AbfE1Udc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 28 May 2019 16:33:32 -0400
Received: from mail-it1-f196.google.com ([209.85.166.196]:54336 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726812AbfE1Udc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 May 2019 16:33:32 -0400
Received: by mail-it1-f196.google.com with SMTP id h20so6577528itk.4
        for <linux-nfs@vger.kernel.org>; Tue, 28 May 2019 13:33:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=0106F+OIYuqVEg46cY8S9oFV/iyDhlYutv2OgfNUAlo=;
        b=RjGBVQz6NQpznw+aHfsqdPr9Xz9oHWvf3xvIyy2anhUJCWl1lE45KaD83Z1PvUDy6K
         W8VPN6IVx9CwhExI0TMC9M1vUu2TSko3HOApaIBKcXMsdaO9oy+1K32hI0Y6fsZpfypP
         wTOd9cWD2MJBeyGjTjEXlF/tKRGjTB+lVnvQ0adn6acdjy0d7iiGLq5Dk0NHN8/IvR04
         tAOc0nQ5sN/ZMrn2lPQSChz2eZgkVJzwwaBSBOR3J3+IhgUmGqf8XKNhR+GOvZsNjnUd
         sAemyw1aqXSdY2faFV30St/ocUbMW87QBA5QK6xsmnwWiYqla3o7B9Mhb34za2F08Hr/
         mM6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0106F+OIYuqVEg46cY8S9oFV/iyDhlYutv2OgfNUAlo=;
        b=cVkmvmZkJT0HajoNgLAxXPEX03reuK6yYELobf4Ptb3TTGhXFmzd1slXNBWC1Iixf4
         dOAYEZZnHqROp/oBaKroIo6Gs1/rugn2wnpClr7qIn6wcEJZMj8HgRaulvRSh1tEHdBU
         WcPvZAam4DtmZXKQDvh8WjGqnLYXxAS2LCZve1/llvfv4Nq3sjOhWX+RYUiyGq0MXFVY
         90KGgb0/pPJdd3SCxEoga1PkFIlVmoN78OYi5LatbGnYkBtXL0fw6KGK7shvwFUtLnEI
         vHxOzD8iaqQLSUS+3RRwlU7slJ0arGPWANEsgccZcbWQNvlOoedtG33zAVLdn4SaMNvZ
         wLWQ==
X-Gm-Message-State: APjAAAX8paVGImEdpbG7FjdCdUcMcKzKse620Oxcugt7oFFQgXGFWAhl
        9rsH5+qiqUPqmqYqa1zGoPgl+jg=
X-Google-Smtp-Source: APXvYqwCQmDcMfqwTpYfJh9aJExL11azF+EB1WPCOKtpyriZx8b7cggxaq04OytGJvcrWrJxVzAsDw==
X-Received: by 2002:a24:d405:: with SMTP id x5mr4460074itg.85.1559075611356;
        Tue, 28 May 2019 13:33:31 -0700 (PDT)
Received: from localhost.localdomain (50-124-247-140.alma.mi.frontiernet.net. [50.124.247.140])
        by smtp.gmail.com with ESMTPSA id i141sm53089ite.20.2019.05.28.13.33.30
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 28 May 2019 13:33:30 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     SteveD@redhat.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 01/11] mountd: Ensure we don't share cache file descriptors among processes.
Date:   Tue, 28 May 2019 16:31:12 -0400
Message-Id: <20190528203122.11401-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190528203122.11401-1-trond.myklebust@hammerspace.com>
References: <20190528203122.11401-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Sharing cache descriptors without using locking can be very bad.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 utils/mountd/mountd.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index fb7bba4cd390..88a207b3a85a 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -836,8 +836,6 @@ main(int argc, char **argv)
 	if (!foreground)
 		closeall(3);
 
-	cache_open();
-
 	unregister_services();
 	if (version2()) {
 		listeners += nfs_svc_create("mountd", MOUNTPROG,
@@ -888,6 +886,9 @@ main(int argc, char **argv)
 	if (num_threads > 1)
 		fork_workers();
 
+	/* Open files now to avoid sharing descriptors among forked processes */
+	cache_open();
+
 	xlog(L_NOTICE, "Version " VERSION " starting");
 	my_svc_run();
 
-- 
2.21.0

