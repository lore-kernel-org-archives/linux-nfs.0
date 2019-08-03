Return-Path: <SRS0=Vt5f=V7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5638EC31E40
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 14:45:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 277C62075C
	for <linux-nfs@archiver.kernel.org>; Sat,  3 Aug 2019 14:45:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="hbfDX9OD"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726363AbfHCOp2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Aug 2019 10:45:28 -0400
Received: from mail-io1-f65.google.com ([209.85.166.65]:37845 "EHLO
        mail-io1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725844AbfHCOp2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Aug 2019 10:45:28 -0400
Received: by mail-io1-f65.google.com with SMTP id q22so38842981iog.4
        for <linux-nfs@vger.kernel.org>; Sat, 03 Aug 2019 07:45:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YS30pX18B3aa2CR0VFk8ZSOQuGrmZb4Lf3ojhHX1NEw=;
        b=hbfDX9OD/Oc+uxb0gpMxYKUw1N3zzZC6rJ5XEwX8YX6Fy+n9GXpQsA+BkwyTcTJzpM
         FKQY60B+fwhBBfczqYNdYiT1PDUcaV7PX26rC/lAgkVh/tA8QFWtC0kOYw2wtPo5E5aw
         SEuo2UmGtgw0mWtnkrmspusXutB/TSW/p8VBT9Vxh+8e+mC3/xCu2g0Q1Rek3SttLIG1
         c1sPGBvyYAsWwIY58lOX/k7w+ytHgW9h8hXgEZW76Nwx7zLA51Cb6kMJ/6kKsv2wwGdg
         m9Vhqp9QabivoYBf0ws9yvV2j1t9PoSh7W3sb1fv2hQGUA2pWYGWG/ZRnAEUbtXjSdZk
         MTKA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=YS30pX18B3aa2CR0VFk8ZSOQuGrmZb4Lf3ojhHX1NEw=;
        b=abCYx1AHUQV0h5BBVJKtXx2rUdQv8SBj74h/Qpwg60Sbj6683ZNKBWsDnoTJRW6hPj
         9Xlp/t2tVXaZkCDwxn8BqrBMjqLClJHVWbED84MPi55nBiNh9AoGX3Ne9IMe5yT76+58
         VRYjJpXaa+E8GlLAeFkIrguufSUEGwPGAgfO/oTWsqlkwsbPqjNdSVkjqJQM6XfAlgM+
         vTSIKc25tkJmuM3WwJNusOp9EIsxauvlq7EFQhsiZ2TEt4obZaZXUL9b0A9I7zXAb/N+
         Dy+UyPtgxHcRP9cBfcXclfXeZjnXV3+scCIWwg91d8i5uyOiIR/6ZbUQI4zDvYYhcbQW
         LwVg==
X-Gm-Message-State: APjAAAVU3E4SAkIoD3qEAl3DGOvCZ71YPpDWoP2luhgtwppCB7ytSH8P
        5/umL185vks+KzEH/Y8J3HBdE2w=
X-Google-Smtp-Source: APXvYqxWxmq6MnkYkmQbK8Jq0t9s6so52QdoO0Jd2P7U7AFZwnaoa3CDxfScunQ1mvKN3SNDh9nbuw==
X-Received: by 2002:a5d:964d:: with SMTP id d13mr7413447ios.224.1564843527460;
        Sat, 03 Aug 2019 07:45:27 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id n21sm55031059ioh.30.2019.08.03.07.45.26
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sat, 03 Aug 2019 07:45:26 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Olga Kornievskaia <aglo@umich.edu>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix an Oops in nfs4_do_setattr
Date:   Sat,  3 Aug 2019 10:43:20 -0400
Message-Id: <20190803144320.15276-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the user specifies an open mode of 3, then we don't have a NFSv4 state
attached to the context, and so we Oops when we try to dereference it.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Fixes: 29b59f9416937 ("NFSv4: change nfs4_do_setattr to take...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.10: 991eedb1371dc: NFSv4: Only pass the...
Cc: stable@vger.kernel.org # v4.10+
---
 fs/nfs/nfs4proc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3e0b93f2b61a..12b2b65ad8a8 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3214,7 +3214,7 @@ static int _nfs4_do_setattr(struct inode *inode,
 
 	if (nfs4_copy_delegation_stateid(inode, FMODE_WRITE, &arg->stateid, &delegation_cred)) {
 		/* Use that stateid */
-	} else if (ctx != NULL) {
+	} else if (ctx != NULL && ctx->state) {
 		struct nfs_lock_context *l_ctx;
 		if (!nfs4_valid_open_stateid(ctx->state))
 			return -EBADF;
-- 
2.21.0

