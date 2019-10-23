Return-Path: <SRS0=iyIL=YQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AAEE7CA9EB9
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 7DD3C207FD
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="F8iyvgWo"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2406375AbfJWX6U (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Oct 2019 19:58:20 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:38017 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2404828AbfJWX6T (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Oct 2019 19:58:19 -0400
Received: by mail-io1-f68.google.com with SMTP id u8so27184124iom.5
        for <linux-nfs@vger.kernel.org>; Wed, 23 Oct 2019 16:58:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0BwJqCylHLRphTfKIND1800ET172jmjuxg1et45hUiU=;
        b=F8iyvgWo8B5mXctVS7vYw92SDiKon8fG8pK63JcAwh6LXWaH7LCAIVqfuwBrnIE/KC
         doNo8hgDt3XIt86QPv4y28JnhmvXEiyhQbVcVRotBPzZHvNG18BdRPXJoxH/W2Ss+6ek
         zxXeKjZ8KcDaTC4aN92na+cQNXQEQ96auTpFQHj/Hn7fuMWM/2prQh1dpQsy+xwns5yt
         ksX5ILNgEGrLa5HRudGVc6+AkvV92RG9zD68zePooEgoQN7Rn0vv1E9pFlhLQIwN3NPZ
         YcgQvhrHzxWLPId81RUY789YNsTwa8U0vXW0C/B9MW3fQ/lqgUWfyAHLrDcOj6scVia4
         GtHA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=0BwJqCylHLRphTfKIND1800ET172jmjuxg1et45hUiU=;
        b=eJOOhacVrmlxBr7OP2avyuLfSbYuCavWvZjuSx2GnlohQ0bl13LshIr75fvKv29sUh
         Ycdyqki0Njq7tu1fTmn3aRK05+haPEjUWEXz4RSPbuykedMqPQca2HeevyWAMhxTlEGH
         946oHTRrLqYBogg0ntI9oo0Aq5edO7V8Rudr902IgK7XIUVuBZp+hzqq1bI97E3bTHAo
         c/ZvYHmy2oDESQRYQEjh6eTaH5oLq3FmTEAMku30avA6zzyrfMEZmoB9H8FgKtMs+9tL
         H0YZOr983rIV1y15dBE/EneMLKUqUhcFV1CKEI/Psu5eEjk0rw3fQyUxGjvEwVHx2KI0
         EWQQ==
X-Gm-Message-State: APjAAAXUkkxUcVrJVE9QFcWu3/T2Q+nqI2kJ5N0ra3j+WvVuxqVqQtLy
        nqd9fmm/ueQZZjyGhOQOJ2nC32A=
X-Google-Smtp-Source: APXvYqzHN2BMFhAHfpKIVsrAsPBGIMAHzBuAH0QpdRq7/plPVb3CKW1jKFyDrMe/2AkGYxzdc4vzjA==
X-Received: by 2002:a5e:c748:: with SMTP id g8mr5992094iop.149.1571875098189;
        Wed, 23 Oct 2019 16:58:18 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id z18sm2405409iob.47.2019.10.23.16.58.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Oct 2019 16:58:17 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 12/14] NFSv4: Ignore requests to return the delegation if it was revoked
Date:   Wed, 23 Oct 2019 19:55:58 -0400
Message-Id: <20191023235600.10880-13-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20191023235600.10880-12-trond.myklebust@hammerspace.com>
References: <20191023235600.10880-1-trond.myklebust@hammerspace.com>
 <20191023235600.10880-2-trond.myklebust@hammerspace.com>
 <20191023235600.10880-3-trond.myklebust@hammerspace.com>
 <20191023235600.10880-4-trond.myklebust@hammerspace.com>
 <20191023235600.10880-5-trond.myklebust@hammerspace.com>
 <20191023235600.10880-6-trond.myklebust@hammerspace.com>
 <20191023235600.10880-7-trond.myklebust@hammerspace.com>
 <20191023235600.10880-8-trond.myklebust@hammerspace.com>
 <20191023235600.10880-9-trond.myklebust@hammerspace.com>
 <20191023235600.10880-10-trond.myklebust@hammerspace.com>
 <20191023235600.10880-11-trond.myklebust@hammerspace.com>
 <20191023235600.10880-12-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the delegation was revoked, or is already being returned, just
clear the NFS_DELEGATION_RETURN and NFS_DELEGATION_RETURN_IF_CLOSED
flags and keep going.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index b214b88b35b5..150a3bf7b35c 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -465,8 +465,6 @@ static bool nfs_delegation_need_return(struct nfs_delegation *delegation)
 {
 	bool ret = false;
 
-	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags))
-		goto out;
 	if (test_and_clear_bit(NFS_DELEGATION_RETURN, &delegation->flags))
 		ret = true;
 	if (test_and_clear_bit(NFS_DELEGATION_RETURN_IF_CLOSED, &delegation->flags) && !ret) {
@@ -478,7 +476,10 @@ static bool nfs_delegation_need_return(struct nfs_delegation *delegation)
 			ret = true;
 		spin_unlock(&delegation->lock);
 	}
-out:
+	if (test_bit(NFS_DELEGATION_RETURNING, &delegation->flags) ||
+	    test_bit(NFS_DELEGATION_REVOKED, &delegation->flags))
+		ret = false;
+
 	return ret;
 }
 
-- 
2.21.0

