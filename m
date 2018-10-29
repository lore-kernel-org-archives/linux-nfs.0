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
	by smtp.lore.kernel.org (Postfix) with ESMTP id A060CC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69FF52082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PkiPvVK6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 69FF52082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729412AbeJ3DyH (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:07 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:40574 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725923AbeJ3DyH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:07 -0400
Received: by mail-qt1-f196.google.com with SMTP id k12so4706149qtf.7;
        Mon, 29 Oct 2018 12:04:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=PkiPvVK6v+vRhPNZbosjBxdv90qUWk6PekiblvS37xgMfqFL9LoH2sUHeVZZZwOjla
         eG48+GNFYtJY6lQCihlAK+1SshQp4bF6z6bBuXMQua4wbVM+RpeKpUZkw3VulBHL1ewZ
         qDj4DeQO9RT/uU/rj5r8v/UUjlkNOVJui6kN1GmdMYba0cJKPWpmmmJQCj2+L1mJYW1R
         cL3RKW3TTjmTAGFLuz8JRtTu/ImlAa5XQhII2v7e7/+N9TykttmcLJ+9ZVgTLeWbYliR
         gHmWTriRAn9vG0z5tQphayIDdACO+IckklAllI1uxCiQNLVreMRVnBMflHiUgQFsmVsU
         Xmbw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=nArMGW/INjteRrujdLkp69gM/ZmeUcX82tVQQvtlFnc=;
        b=S0Y/fH4qolkLha1F3xaNCxViK1PzWJX2+xk/T/1RM7PexviVRIBkCdjV0nDe9Os59F
         V4UGavtH4vhNYncKb6ikCjN8s4kqt11lJT0ZULSx5YFi5SA4nsSzF+OaJk7pTi6crnfL
         8ERkO0vo7O5nwlB8Pnlu89jSnfUzN8R/EZu5QQCOhuO2lGioef5hIvYPrt+GvrIDL3aZ
         xYJUglkIM6x+7hlAcjz+wJaa3t3tLGaW1lcR38qURW1PqXhNqa6wCQIWmRBwxnqR6Rvn
         aS4D30GAXC0aHpIsgF3wQ9Ll2IUT+O65NG1aP1TonSpI6yo4uspOqNeqf62xKvvvKQ+I
         zW/g==
X-Gm-Message-State: AGRZ1gKdROMq//OjMOEayP8PPdMvqf0xFSUpcK7xtDMOSBXzMMAZcZ5a
        wvKKHgZbs8UKOYpa779bU2w=
X-Google-Smtp-Source: AJdET5cPTZPWikuv//UVpkUGGsjlDHuzdK36xsMoyvdCN7Hg095g+KFZFRAoU/5eOWeBzaqX/abvxA==
X-Received: by 2002:aed:20a3:: with SMTP id 32-v6mr14230345qtb.195.1540839848116;
        Mon, 29 Oct 2018 12:04:08 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.06
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:07 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 03/12] NFS: validity check for source offset in copy_file_range
Date:   Mon, 29 Oct 2018 15:03:48 -0400
Message-Id: <20181029190357.38439-5-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
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

