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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59756C43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 29BA82084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SaEN65ek"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726025AbfCAT1B (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:01 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:35474 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725999AbfCAT1A (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:00 -0500
Received: by mail-yw1-f67.google.com with SMTP id s204so14944361ywg.2
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:00 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=C4W/3sCZpp7GoysK9ln3EqXV3tr2VYFqrhuUgQ4jBX4=;
        b=SaEN65ek9LXd811vO73IcdDRsXWxjPwq9tKhAQUMIfOSJvETa4TJPgLEM4HqloNche
         Tm5GHbY018ewgUrEw6dIu5GZ/fL4N3LYSYZe5VJKYUURojC0Jg5cOR6u4KvBVlfZK9Mh
         RmcCcQzzBMSiMRfnIDBiJsigW0dYhlO62pLiO8dnk4R+lMXCfK0iQ4TO4SnnIlvMRlnj
         VZdRhXOOEULmush3wHJQycnsts/NjMgjA5gwhnrPAlFowrHxXQo9w7OpqN46FWUO3HLF
         yUNC/FFaTTO8/lvxxrDozCi6goQzG+0EqGKlHbYILvZqO+rOeX0+Be7TKrneB9b7/cpM
         YoFQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=C4W/3sCZpp7GoysK9ln3EqXV3tr2VYFqrhuUgQ4jBX4=;
        b=YLMEHhF7o2C6m2Qr6DFnYI2I4GpsCb6MfXwRUnmP3YPM1JBqfFe7eIinuaC+YWP06g
         LIX6fW3py6BW+rbnCwZHCEe1+eoxoV6niMSZxHusC3IriIuNCq6L0Sx7h/QlR2Dl+MiM
         K0OCQBtsUs5Mazotw/0mAtuG5ErBVYy6//xg7/QXIZqmck8GI/HGl55k061GvzcvYvbb
         4ctkvY4nUrH1JKzexHqliEeRIGBlKMN+Z8qEHJKeBQRlaYmzzgxBGhYKJG2xxHXUK1iS
         yHe0qwtcbzdZa5sB92QMdbAjRGbGlqdAcljQbgT5/8CafXmGMWtWoKu4zdME40BpjuTK
         f0yg==
X-Gm-Message-State: APjAAAXx4znf+Fl/nvt7tmGCx0BQkFA6Fo7VxWTNjfbNFMNm9jLeEO7C
        kaqVis+JJGUCR8jsX8znxWYxvNk=
X-Google-Smtp-Source: APXvYqzPspaeYWSxCXaDJD7FVGATeTX3J8kwQVoQAn28wz45Lb9gqbgEB8O6Ijv/lt0qS6O9Ws72Yg==
X-Received: by 2002:a0d:c6c5:: with SMTP id i188mr5042346ywd.320.1551468419321;
        Fri, 01 Mar 2019 11:26:59 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.58
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:58 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 07/19] NFSv4: Handle early exit in layoutget by returning an error
Date:   Fri,  1 Mar 2019 14:24:43 -0500
Message-Id: <20190301192455.104943-8-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-7-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the LAYOUTGET rpc call exits early without an error, convert it to
EAGAIN.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 73889ea7d196..4dbb0ee23432 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -8936,10 +8936,12 @@ nfs4_proc_layoutget(struct nfs4_layoutget *lgp, long *timeout)
 	if (status != 0)
 		goto out;
 
-	/* if layoutp->len is 0, nfs4_layoutget_prepare called rpc_exit */
-	if (task->tk_status < 0 || lgp->res.layoutp->len == 0) {
+	if (task->tk_status < 0) {
 		status = nfs4_layoutget_handle_exception(task, lgp, &exception);
 		*timeout = exception.timeout;
+	} else if (lgp->res.layoutp->len == 0) {
+		status = -EAGAIN;
+		*timeout = nfs4_update_delay(&exception.timeout);
 	} else
 		lseg = pnfs_layout_process(lgp);
 out:
-- 
2.20.1

