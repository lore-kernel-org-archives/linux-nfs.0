Return-Path: <SRS0=HHNt=NF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A881C46475
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0BC1C2082E
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:52:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="k8efXc3n"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0BC1C2082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727690AbeJZG0c (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:32 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:38581 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727661AbeJZG0c (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:32 -0400
Received: by mail-qk1-f194.google.com with SMTP id p3-v6so6721863qkb.5;
        Thu, 25 Oct 2018 14:52:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=RCATKYmSySPh3wulAG3OcdB8f12GbuEHg1zruy7+w0I=;
        b=k8efXc3nhdvT95o3pjW54QtABl2SuxEQwnOKSTYVsMqjS6dcsLAcLX0Y9reFaKXD+D
         KW6NS+hoCN9GYtek/U7FLiiFps5PNT1WZ3YtU2KseK6pOEINPeQHNUSGui2SDn/TV2V8
         LsmpSnvk4f+WxhkQKQggjU28hpAnXFXtRHSAYZ3jzx2/5FsPSR73GgC+zu0rUp9KRIeD
         NHgKf7hfH74CLaHcDuWjAwdRKStB/XCfrzbNJmSBJSGKte8pFeq2IJaiF5q+utJ031Py
         IuRyt8+6SmP7etpDWO62R74vNXs5btAwHRc/spOSIiGhy3EMAgkedlohjmYIR3+0Dj1k
         /1cw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=RCATKYmSySPh3wulAG3OcdB8f12GbuEHg1zruy7+w0I=;
        b=Pp7IQaJxDJD4x93aFncl1VAuCLAj2GGtxsagXkuS9+0W8YyOguXnyQRSH4Fs3IeKW0
         Pt2r9UJ8EjmNCQNQMArXg3fLCiHxgm1HIUrABb22cFXhJ6IYlO2kPdb5x7pk1ArSww+7
         x/E8IOQkdES44V6/KpXgbWiem90SEOL+DqX6AZsPyYGnY6s54gPoMQzTulALF6QbHScb
         yJpZEZ6syqHynC1RKaZvGnNm3qRMqahECXj1hUR++WGMp7pcSOGZAAeiO++LPtd85P+f
         nXxMaH1OhIYcyQjbVq28hjrESwwLdRiUnUA/YHx6/277oniMfXM1jnEJwmBAM+vZP7Dc
         uvlg==
X-Gm-Message-State: AGRZ1gLsvPdnWgQJfg7uxnTA+no1qrPFoO+sjz+BWKob5kIO1RaTlub9
        hAoNZyexARE9ezV9aQCh8e8=
X-Google-Smtp-Source: AJdET5fslguW2PXXjgjdhDStTd9AZL2s8O1hkIWEVqRv/IwlKHO666d/PX20BH8xSRpjrMyp6Q8jFQ==
X-Received: by 2002:a37:2f87:: with SMTP id v129-v6mr875761qkh.342.1540504327494;
        Thu, 25 Oct 2018 14:52:07 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.52.06
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:52:06 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v3 11/11] NFS replace cross device with cross filesystem check in copy_file_range
Date:   Thu, 25 Oct 2018 17:51:47 -0400
Message-Id: <20181025215147.36248-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

VFS copy_file_range was relaxed to allow for cross-device copy.
NFS code was added to support for server to server copy offload.
Add a check to disallow cross file systems copy offload, both
files are expected to be of NFS type.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4f142db..aab3720 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -139,7 +139,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
-	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
+	if (file_in->f_inode->i_sb->s_type != file_out->f_inode->i_sb->s_type)
 		return -EXDEV;
 
 	if (file_inode(file_in) == file_inode(file_out))
-- 
1.8.3.1

