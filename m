Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D96ECDE44
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 964DA2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b9bbIPLf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 964DA2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728021AbeJ3Cap (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:45 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:40944 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728018AbeJ3Cap (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:45 -0400
Received: by mail-qk1-f194.google.com with SMTP id f18-v6so5459694qkm.7;
        Mon, 29 Oct 2018 10:41:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=b9bbIPLfQkJBvd/RAAj15xtNYr8QT6E7nNx3lEbpJgpN1RDAJdjdTk+dtbh9tgXAcG
         hkd1WyLUd++HUj2mweK4uq4xVuk950rWSoo6sbI55Zqgwo3HamzC67OUitiqeBctKi0F
         ZqJAy20RurB/Uw/4q6CF1k866V11sF2mZ8tswI+VzuKxgyTE1f3via6UXAEgtb8Gel1s
         qdmYk/1oVKU55d6Excyh8mbbTPogjwCKQn5XMhvucC2iiTyQlxu5sO+0pdVJPXG6hdw5
         Hb6oMsvJqOWaZG5Yh97RG3re942YAfIigZl1ahxbWsepLCNbVXmghSXs6jeV4fSSKc1C
         zzQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=Wd7RN5LNlistnCUkUDFPnXwnyQFvs8FOFHjr943qPF0RQQroBT3vkdFKeL3+Ux2sDv
         3jOSBmXdQ1xpZkBguYu4ySsfnYcNYvM5wfckyt9jQ7w5R7o01LIwJdksXOJaFTQfQplB
         Kp9c1DRv1ZlzfokfZXYq/H8lJqlEXogDmvLCLWmdHJdoh0YC4KeI0aSPkVcBvxSWZgsE
         wuquyr9pyhut0jvC7JOeWoRyBzQD3AjU4fvUzJBt3iL+EKz3LspCTLHuYVmDr/u3AOsi
         r9y+eCCbxOSgsdLgwEcuugbwE6uYb0+PdQIf3Pmmpli1TtgAKAeeHQbHJnj/8WBqFuh1
         gXTw==
X-Gm-Message-State: AGRZ1gLmSM4QzOSpf2HCfSR3N/fuO0EfdE7xCz3mAcJOri5KNYO+R2MM
        3uK9NW4YqG2Ii3F7bUOTCBE=
X-Google-Smtp-Source: AJdET5cpn12/Q++l067RcI17lUG5zlz6VtUP3DY9G9bsTYZlouZf3x8YtHE5Fcvr08cxFKo3lIysIA==
X-Received: by 2002:a37:1b46:: with SMTP id b67mr13210824qkb.144.1540834867889;
        Mon, 29 Oct 2018 10:41:07 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.06
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:07 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 03/12] NFS: validity check for source offset in copy_file_range
Date:   Mon, 29 Oct 2018 13:40:50 -0400
Message-Id: <20181029174059.38326-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Input source offset can not be beyond the end of the file.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 5a73c90..7838bdf 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (pos_in >= i_size_read(file_inode(file_in)))
+		return -EINVAL;
+
 	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
 		return -EXDEV;
 
-- 
1.8.3.1

