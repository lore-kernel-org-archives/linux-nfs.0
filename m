Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EEAE8C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BCB532070B
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iQf5Rivf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726121AbfCAT1L (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:11 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:45916 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbfCAT1K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:10 -0500
Received: by mail-yw1-f68.google.com with SMTP id r188so14784727ywb.12
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:10 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nUfnWvgdUYzkHJQMu3yUvrwZ11VXYIukfKkwsBcywZs=;
        b=iQf5RivfnM7HVmc8AtKqqu6I4qeCrDsFTuCyc7hGssXy9ovLDLhlb/oc9Bzpk1ZjOP
         4P8CQKxgTvQiVAQ3BQGRQKoVoE/KF9ui5dCylvdpMzhORoMZP0TbR9BWR6Me74tUfJJh
         ojuZTiSMAri3ytKqPQf6Cm5Ly10SFZK+JIqtl/yft58bxpD3hWUx0OP1/HmFz/tM+Mdt
         JXntMSKlN/wbP0RcdqeeTES76/24gwwcrIUd6UG5LF1+l7scnb3JaZw2V9FDi3+3GcqT
         EakS2lRKcoaVdmY46cHzqXn7Q2bVMHF2m4yo3WK8j56kpZAgHxmhpJiNejhp5IKCPLW+
         tN5g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=nUfnWvgdUYzkHJQMu3yUvrwZ11VXYIukfKkwsBcywZs=;
        b=clprXqVySxbcirC4VTEHJlrTo+Yvyn3D+STHH5dTe1kPik5tOai9cu1d05EeP5fsRV
         5zi4XE18l2Tbrk/2PEvDCHgAZfbqCPNRn+wppzcRCDGu29Rj6Dw3PSHMMFypfsIit8Y0
         Vc8o+NVhtcwr+ZM22nZo1REcV+WbZZpjU2ZJO39tnTVHakKvPEIbJ4STfXpWc232W9rl
         MmiR0LxzmEqazdnL1GS8tqjQ2j7sXCIQlMCoB0m3WBCam51PIsKj1sdsQJqZP9mmc90+
         058eFNihxwSVC83y3s7gNlhRaMvR8ERh3RQbMu7zzQoTseFwRk3WVP7hRvi+X2Bc7JgL
         K71Q==
X-Gm-Message-State: APjAAAXQWPdwjNuMP+mi1eijmTmTdLP2mYITY1GjeqmCFDI0DPnHJuAC
        VJgF6+S+jwsWnoz0bu7FAbF5VKE=
X-Google-Smtp-Source: APXvYqx4poqLmkfnd3nwKTUaYytCwM9Yq5h3cBFRjPrGrXSIj+Jav6IjHk8O7AzGuH1VY12nB580VA==
X-Received: by 2002:a5b:544:: with SMTP id r4mr5496843ybp.235.1551468429201;
        Fri, 01 Mar 2019 11:27:09 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.08
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:08 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 18/19] NFS/flexfiles: Remove dead code in ff_layout_mirror_valid()
Date:   Fri,  1 Mar 2019 14:24:54 -0500
Message-Id: <20190301192455.104943-19-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-18-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
 <20190301192455.104943-10-trond.myklebust@hammerspace.com>
 <20190301192455.104943-11-trond.myklebust@hammerspace.com>
 <20190301192455.104943-12-trond.myklebust@hammerspace.com>
 <20190301192455.104943-13-trond.myklebust@hammerspace.com>
 <20190301192455.104943-14-trond.myklebust@hammerspace.com>
 <20190301192455.104943-15-trond.myklebust@hammerspace.com>
 <20190301192455.104943-16-trond.myklebust@hammerspace.com>
 <20190301192455.104943-17-trond.myklebust@hammerspace.com>
 <20190301192455.104943-18-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfs4_ff_alloc_deviceid_node() guarantees that if mirror->mirror_ds is
a valid pointer, then so is mirror->mirror_ds->ds.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 15 ---------------
 1 file changed, 15 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 9348a4588f55..da3b65373db1 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -183,15 +183,6 @@ nfs4_ff_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
 	return NULL;
 }
 
-static void ff_layout_mark_devid_invalid(struct pnfs_layout_segment *lseg,
-		struct nfs4_deviceid_node *devid)
-{
-	nfs4_mark_deviceid_unavailable(devid);
-	if (!ff_layout_has_available_ds(lseg))
-		pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode,
-				lseg);
-}
-
 static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 				   struct nfs4_ff_layout_mirror *mirror,
 				   bool create)
@@ -221,12 +212,6 @@ static bool ff_layout_mirror_valid(struct pnfs_layout_segment *lseg,
 	if (IS_ERR(mirror->mirror_ds))
 		goto outerr;
 
-	if (mirror->mirror_ds->ds == NULL) {
-		struct nfs4_deviceid_node *devid;
-		devid = &mirror->mirror_ds->id_node;
-		ff_layout_mark_devid_invalid(lseg, devid);
-		return false;
-	}
 	return true;
 outerr:
 	return false;
-- 
2.20.1

