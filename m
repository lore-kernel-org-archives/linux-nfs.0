Return-Path: <SRS0=Er2h=XZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05478C32792
	for <linux-nfs@archiver.kernel.org>; Mon, 30 Sep 2019 21:44:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BCD3D2168B
	for <linux-nfs@archiver.kernel.org>; Mon, 30 Sep 2019 21:44:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="MxT+mYi6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1732163AbfI3VoK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 30 Sep 2019 17:44:10 -0400
Received: from mail-io1-f51.google.com ([209.85.166.51]:36735 "EHLO
        mail-io1-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728819AbfI3VoJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Sep 2019 17:44:09 -0400
Received: by mail-io1-f51.google.com with SMTP id b136so42363689iof.3
        for <linux-nfs@vger.kernel.org>; Mon, 30 Sep 2019 14:44:09 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P2HbfR2su60CmOOSycMSh0KHtLOp0Baci4xoAHHjrh0=;
        b=MxT+mYi6VlyCMrHePOXtWR+HXnJ1sJFITguLv3RDHLbKPNaP5kSO/5pGeI+C6gt26D
         NOeg5U1YaozkhoOvKdQYTt8RI7yoW+2yUBGWPpyKqIPUAqJhaUbLquaxE2oHVGY+LOiO
         9LVLJQ7biHu7xcS5zBEXY6OqrDeeccSKGOh0bKC7acHFk6L9x4A9Ea9TaMm7ujntdZ8Y
         5Yi/ngrU2fg9S5NRxojjW8A8deUC0JGOS4ikjiV2SUrXOGDy7gqNDnB1p5X2t05reKoN
         xNiXlGnAAhPTnnH/vzj9a22kBaSwUnmqaM6L9ublaLtCoVeWIXv5lP27Kt0xlsV3WfWY
         5ipQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=P2HbfR2su60CmOOSycMSh0KHtLOp0Baci4xoAHHjrh0=;
        b=pD+sJaXrTxLhLxKX8+neG6Eu5p/RDPUHapmVPX43YlkOEjYPWTeJJxKCrilRr6NOt+
         VLubfG9eTV4NTTkUTEnIqbvYDbbflRFhoWLxmdm1V5YoN9QEI0LSS8u3S7kWttC1A2iC
         zd5SnHcQ6v+aLed4grCyGFGJ61uVrXjxxxkL+q6R8E2729dJmFBVGs0eTJY6eOQaMp0Q
         uhugkBBfR0c9aXBUWkOM/SDiabjeblOWSueTuVYOzT4f/HQMU7isUhojLSr6MCjXjYMN
         DF+97k4fbC9m2hze72TcxhtJZQCGVMCuiCpenUzH8gsKTHGJeKBrS8rJoZ55JFHAmJUx
         1ucw==
X-Gm-Message-State: APjAAAX2CQnuYOAuOInrrIIEQSOjmMDTeomd1jPe3OOA/bvz4axEdXL6
        DAZaxK2C0cDILUxyS6Nx6zZiQ+9Lig==
X-Google-Smtp-Source: APXvYqxTpKxCU9XWiqwaarf0CTQkVIc4W+YZS07K7YvNgEDp+ZTF48WGSA2ztMMr3CbyCgFpFOdt1g==
X-Received: by 2002:a92:c98f:: with SMTP id y15mr21881520iln.48.1569866704950;
        Mon, 30 Sep 2019 11:05:04 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id g68sm5153123ilh.88.2019.09.30.11.05.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 30 Sep 2019 11:05:04 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Su Yanjun <suyj.fnst@cn.fujitsu.com>,
        Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] Fix O_DIRECT error handling
Date:   Mon, 30 Sep 2019 14:02:55 -0400
Message-Id: <20190930180257.23395-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <1569834678-16117-1-git-send-email-suyj.fnst@cn.fujitsu.com>
References: <1569834678-16117-1-git-send-email-suyj.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

These patches fix issues with how O_DIRECT handles read and write
errors, and also how it handles eof.

Trond Myklebust (2):
  NFS: Fix O_DIRECT accounting of number of bytes read/written
  NFS: Remove redundant mirror tracking in O_DIRECT

 fs/nfs/direct.c | 106 ++++++++++++++++--------------------------------
 1 file changed, 36 insertions(+), 70 deletions(-)

-- 
2.21.0

