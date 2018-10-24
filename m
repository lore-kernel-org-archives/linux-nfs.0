Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A4924ECDE46
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 662CC20832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="djl1mQAj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 662CC20832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727417AbeJYE2O (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:14 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:40158 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbeJYE2N (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:13 -0400
Received: by mail-qt1-f194.google.com with SMTP id z9-v6so7097058qto.7;
        Wed, 24 Oct 2018 12:58:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=XkCvx+hgMC4KAXjFXC+q8/hinOBCjkRD+CDTi9Non44=;
        b=djl1mQAjmlY2jlzKOytCKVVWxSJxcGhGfV4H2GqrFEwONHv+InSHZ1v+KXaGR9/LXg
         HzB+qwGw12Boms0fEK3JvVh6grEz3jHMdv79QDAtajPUed/u8lgJtmscGYEk8YFjUdE1
         H7dJhNqkxjmOYnr6k1IuozT/M603RMQtGD/DlGlSOCAgsHlH3jIf7ujmA4TS6+5WykHz
         4+ooUq5IN2F9Jqns77z+HrkNCRaedNS4twn0Ft++J68K+opMY5Ou+uwyWJ4jwVYItBT5
         AS/HobcT5enAVxRB0FqiYKkUktL9mKaC6rBVyD2JdSkT3pSAbb1aHSEFLOaELDXXW7Ic
         dj+Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=XkCvx+hgMC4KAXjFXC+q8/hinOBCjkRD+CDTi9Non44=;
        b=hjXGXkMcaRvFkguUtWQZ+pf/SmbPLcE2r5usmVfPhQ6/o/hzACq7rAo1gVYZnd5QWr
         1BOtbZj/MzMkvvFzutDJvcEJROoGExLsH00nIf9FjuEQsB49i6cjz3GV7bbB+jvxPAot
         MVZhB+s5lHi3kFed9KMr8/ylab6Ldeggp0rj0XwcJuCGeD5yCC+xKAWPJdcRrtGV/b0M
         XFvpDpdNCS7uIlBdHjBqOWzMMkG/UL3IHKqQET8OmnISTvQmGnv1SgQHrvQSYCYaDqqz
         bZrna1M7ecDzVmYiMTnq3CooKrUhXjs52ef9uIzJBuzsZaW/xhoRTZcQxqy+2LOpTd4H
         i3gg==
X-Gm-Message-State: AGRZ1gID0F8e1MW86azQrCvfNmF3s5/Mm8UeCm32JvLfKj5Zy+d20M6G
        lCIruZa6LW45VH5ablwo+7M=
X-Google-Smtp-Source: AJdET5faYI4cJ7ltYOUvpgsxdMUq0VcmiMg4BBZeW5mYa62wsXj0QXikBr0ShL5gH5kbBD0wC6jYIg==
X-Received: by 2002:aed:2a0b:: with SMTP id c11-v6mr3824826qtd.147.1540411126914;
        Wed, 24 Oct 2018 12:58:46 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.45
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:46 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 04/13] NFS: add cross file system check for copy_file_range
Date:   Wed, 24 Oct 2018 15:58:28 -0400
Message-Id: <20181024195837.35532-6-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

VFS copy_file_range was relaxed to allow for cross-device copy.
Add a check to disallow cross file systems copy offload, both
files are expected to be of NFS type.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4288a6e..7137e7b 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -135,6 +135,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 {
 	ssize_t ret;
 
+	if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
+		return -EXDEV;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 retry:
-- 
1.8.3.1

