Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5D729C10F02
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2D6C12147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fv9xBpKy"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725767AbfBSNzV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:21 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:52533 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727529AbfBSNzV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:21 -0500
Received: by mail-it1-f196.google.com with SMTP id r11so6147222itc.2
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:20 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=199vv0g4gepwPx4tiQYhia1Qf5TXo3qVp1b0Y3gwFaQ=;
        b=fv9xBpKyYiDb9Yg7OUkG/bP5dmV+GMDiKkiX+SkC+H/3sjjOg1WCpNl+IGnINMA7Ge
         A4uVEa+dMHjvG6QmbqjuLESbil7STY0G2kapJDZDCzUebWLXurhwdX5PyH6BHhNIFRvx
         3CZQqnClILUVePDLhY6CwkKiqZ82Irf7ZbbGosUyew8IAnbVSpTKpuDVh1u8AQEJvZ1h
         9nKTBGLeCXsc5rckM2c/JpdodoCKZmi3Pi/IAqBXEBPkeoUl0d3FdcrIWCsHb2e9xOgV
         s7oV598M/kyaBz5VZVRhc8L/tU+dZfJJOL/asd6rIuWNIegSrYAcpORsNpScD1oZZhN4
         VVjQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=199vv0g4gepwPx4tiQYhia1Qf5TXo3qVp1b0Y3gwFaQ=;
        b=XDreLW2oHtrJXxBCifMXO/2ipV94oWTJjoVeHXWjI4cGstZVOdCkQ6VnP85lIAsCYT
         Ru7Tf+QJWyGmsjkKPZSCRsgTUIaYzvp+z+kLkFtJCesRy5PWRcnVLLNxHuy7RJGWWyVg
         GedAjl+SW5ou9I6wdNJuxCq++Nfk3BCjfpCHDkkUZzXU5PzlWrhRZxYVTjetYBaOcAFx
         PdGOq6im1b4lO651pKf+0JdP4f0nPrH1XahckbKTU9vCBweFcG1q6uAS7iiVjP5tRO9X
         M8Ex5Ttm5wm67hwKhREmr2Pl1CVXEkO3M2oJUOfnhH4HbZUC4pdmnyr/fV5IiAbLzM/x
         Eohg==
X-Gm-Message-State: AHQUAubV+qnoYK23GOaTs0ahmx/7bQoua7C11bW6HC8Yu3dS1OMLKJWy
        xIVYK4KArtdHS1cTlkARuj4J2vk=
X-Google-Smtp-Source: AHgI3IZ4o/sw+XFvRA1cziFOInS7yTglq97j0Ozcoc/w9/OBIfMP4RqlBHZDet4xgFUd0/VDGAzUmw==
X-Received: by 2002:a02:2303:: with SMTP id u3mr15626432jau.42.1550584520028;
        Tue, 19 Feb 2019 05:55:20 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.19
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:19 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 7/8] NFS: EINTR is also a fatal error.
Date:   Tue, 19 Feb 2019 08:53:10 -0500
Message-Id: <20190219135311.119300-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-7-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
 <20190219135311.119300-4-trond.myklebust@hammerspace.com>
 <20190219135311.119300-5-trond.myklebust@hammerspace.com>
 <20190219135311.119300-6-trond.myklebust@hammerspace.com>
 <20190219135311.119300-7-trond.myklebust@hammerspace.com>
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
index b1e577302518..1cb9670bb8b5 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -755,6 +755,7 @@ static inline bool nfs_error_is_fatal(int err)
 {
 	switch (err) {
 	case -ERESTARTSYS:
+	case -EINTR:
 	case -EACCES:
 	case -EDQUOT:
 	case -EFBIG:
-- 
2.20.1

