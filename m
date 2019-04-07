Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73898C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:39 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4C30420896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hHK7sFxi"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726465AbfDGSBi (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:38 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:37826 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726457AbfDGSBi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:38 -0400
Received: by mail-it1-f194.google.com with SMTP id u65so17358242itc.2
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:37 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=hHK7sFxi5g84YmzNC/pSxdknoh01cPuDAmSbjvrGNv1bBzq20faIzZspA4fuZYDO+Z
         JDlW5Hgw6HEJVKULjBstPn6ZlQqjZa/kD0RMFgXe5joOrpMcAlAPLaCXsSOxTHFGkPBZ
         Sm0lVMclu5PNiHesZL2zFvFL2YyJh6BVExdgDDRGDHqWsSy9zsPWJVOi1z75FGm1Msmv
         sAUXFk6Hv1Jd0w5ONj1to9X9QCxx9891mia0OTtegqmDt9oOTpNtTy051tqFl5T9s8K+
         R6+eJjN8/WmCwmKjCTY3OrRPnwaq/eUA1ZugMZfjwi1qRXnY0S0iYCKPt2PcV348q4Fp
         Ef8g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=b6G+C8SO9TL5MeUKf+3KSVuLgQ+ThPmE5k1NYTZSeVo=;
        b=Iz9SkYvao5r/L9qUajQ0QammKf5pj1xDqhSFWx/d+qjsRd8ffsO/Fn8G9pftKoiGJT
         tBOkWDmHLd7BqnuA0+5SB3nkOsZE/L4ZH2sASXxV/QdkX2hy8Vl7t0Y2tPIMnva2VUVv
         tM4GCSMd4fDSeelHp0uOJ9cF0Dh/17yClF7CMS0Pq2NPZzn5RgcIhjyB/fGW4nwPQEkz
         bj6D40caYZ+xUW5c03n+KEJeWtIkBmcNCO27XHSps0Tmxf+ef2gVvzcWcB1kpbpq3Bm5
         XaJB9PLGQ6hAXIHwERZCtCeI3he8TSxoH0fKWL+Hg/G+H/73LZ0+yHJBbchf7EGQ/rLb
         POUA==
X-Gm-Message-State: APjAAAVDqul4z60x3ilfmxBa9kH5yxOP+718djDubj+6M3cQfBP8Q/pX
        ETr2B/gRciJtMIZ/pqWgdW09lXI=
X-Google-Smtp-Source: APXvYqxdoDA98HILgFT5BaRNXMbtO+2oq+PCz6kv+iVKHfhNy+vH+lt1shI108kPk1HftlWFlLXJGA==
X-Received: by 2002:a24:1749:: with SMTP id 70mr17848235ith.50.1554660097047;
        Sun, 07 Apr 2019 11:01:37 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:36 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 16/29] NFS: Consider ETIMEDOUT to be a fatal error
Date:   Sun,  7 Apr 2019 13:58:59 -0400
Message-Id: <20190407175912.23528-17-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-16-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
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

