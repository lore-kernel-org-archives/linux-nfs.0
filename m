Return-Path: <SRS0=qZqD=7Z=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E7FF5C433DF
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Jun 2020 22:46:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id C57AE206DC
	for <linux-nfs@archiver.kernel.org>; Fri, 12 Jun 2020 22:46:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="W6hJE3pE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726371AbgFLWqF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 12 Jun 2020 18:46:05 -0400
Received: from us-smtp-2.mimecast.com ([205.139.110.61]:55774 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1726268AbgFLWqE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2020 18:46:04 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1592001963;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc; bh=XngKIHoPUzwowSFibg7u3t/oC1rcUf+BN/K3UuWtgcw=;
        b=W6hJE3pEjI/zWSQ1fFe4hB6PGqvlCMKEKChorvuOn3a7z2kMFTbDigr/38CammlDY52FOo
        lbGZYKH5jVtptmrF2GDzTFIiNVM56kB2j9g52iPa5aZ94yOz7k4cy2ALt6cQrktkuZdF8z
        +nTPyy9HBCc1B4j0NKDnuHCf8Vhj6VE=
Received: from mail-qv1-f72.google.com (mail-qv1-f72.google.com
 [209.85.219.72]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-272-zp9t8VXQMN6q8LXlVyKeRA-1; Fri, 12 Jun 2020 18:45:56 -0400
X-MC-Unique: zp9t8VXQMN6q8LXlVyKeRA-1
Received: by mail-qv1-f72.google.com with SMTP id p18so8164238qvy.11
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2020 15:45:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=XngKIHoPUzwowSFibg7u3t/oC1rcUf+BN/K3UuWtgcw=;
        b=gXsiqdpcAaicvu9HgRiOZamzzKO5XdkkZLlAoCrK63/9AwediHk28ZUv2kjoa98eBg
         y5kSf0Jh+CqFSFrTfPH3SPc7SCR8i/dDypIshO/4JX06ftCrvD00smr00NPsc+zvq0oW
         dlqyP6alfFsXI5STT+V2jFPMDPndZFzMQUTJmI/ZPUowOXlhBPT7Uk2RTMCOHu2E6zkb
         7Mw+qdo1gvLOUQlhcKVH70tZPHVPFutkWXb8brCpPUVrVW7CksYMdOrKLgbNpTGS9Lwb
         N1anIb9/lpsJJw/G7qtJ/bvu9sIy9CBeQsKHLnyTS8tqZRIo0S/jbktGe/ZY9ZMJfwmP
         YbCQ==
X-Gm-Message-State: AOAM531waHzFmo5mXfV1K8bEc/eFlsVk/ZRdSZlIoIe3h4Sg861nVL/t
        6+NCumnA53XaC2D2tG0iYEBgoF5kHroaGjpYKjsZmkHPfHDrqlnkpKV3jDwy7W845ax1iPFfuoR
        Ci6ULRYbySlPKZgtrGk7w
X-Received: by 2002:ac8:1772:: with SMTP id u47mr5424184qtk.177.1592001956429;
        Fri, 12 Jun 2020 15:45:56 -0700 (PDT)
X-Google-Smtp-Source: ABdhPJxR9cLLTPkn/jtykSo+mxzD0t8ZanXXWaoMvTV6nL402rGN/D4wMGRjb3u9WJx6uVmzbqjYig==
X-Received: by 2002:ac8:1772:: with SMTP id u47mr5424170qtk.177.1592001956155;
        Fri, 12 Jun 2020 15:45:56 -0700 (PDT)
Received: from trix.remote.csb (075-142-250-213.res.spectrum.com. [75.142.250.213])
        by smtp.gmail.com with ESMTPSA id z77sm5761451qka.59.2020.06.12.15.45.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 12 Jun 2020 15:45:55 -0700 (PDT)
From:   trix@redhat.com
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tom Rix <trix@redhat.com>
Subject: [PATCH] nfs: Fix memory leak of export_path
Date:   Fri, 12 Jun 2020 15:45:49 -0700
Message-Id: <20200612224549.11762-1-trix@redhat.com>
X-Mailer: git-send-email 2.18.1
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Tom Rix <trix@redhat.com>

The try_location function is called within a loop by nfs_follow_referral.
try_location calls nfs4_pathname_string to created the export_path.
nfs4_pathname_string allocates the memory. export_path is stored in the
nfs_fs_context/fs_context structure similarly as hostname and source.
But whereas the ctx hostname and source are freed before assignment,
export_path is not.  So if there are multiple loops, the new export_path
will overwrite the old without the old being freed.

So call kfree for export_path.

Signed-off-by: Tom Rix <trix@redhat.com>
---
 fs/nfs/nfs4namespace.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index a3ab6e219061..873342308dc0 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -308,6 +308,7 @@ static int try_location(struct fs_context *fc,
 	if (IS_ERR(export_path))
 		return PTR_ERR(export_path);
 
+	kfree(ctx->nfs_server.export_path);
 	ctx->nfs_server.export_path = export_path;
 
 	source = kmalloc(len + 1 + ctx->nfs_server.export_path_len + 1,
-- 
2.18.1

