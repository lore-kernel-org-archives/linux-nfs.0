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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42004ECDE46
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E397C20834
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Oct 2018 21:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="axdgHdJZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E397C20834
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727600AbeJZG0S (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 02:26:18 -0400
Received: from mail-qk1-f195.google.com ([209.85.222.195]:35057 "EHLO
        mail-qk1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727578AbeJZG0R (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 02:26:17 -0400
Received: by mail-qk1-f195.google.com with SMTP id v68-v6so6728016qka.2;
        Thu, 25 Oct 2018 14:51:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=UmzhoFSi/XlLp/EenFokB0pc/jS5RPLJ6Yk/5FBSErU=;
        b=axdgHdJZjNIM7X6QAuKGfxCRVD4RvSH6gsPCJUFeYYnyvHuq5OS61VGmSOdoqqvk8A
         HTRWCvDkKu9TIfTZKAbkhYSSWIqjkKMLzdajVKu+tWd70R6Mhi1rPhOhAb3PikruLI0X
         L4y3ft1agstCW5touhGv3CYz4ti7/rfjU2fuoHpeecKMOfxNarjxdirNk8Qb6vjlpbTP
         PV3yc19hYwnARxHGWtTcZXJtxN+ky2EGHlCabNsKS82WaUqGnP82jBajd1PzW9jwJL09
         jD/n1PiqzrHWZ91XCJwbp6UwJr9KDrmI2XIMNRECj4iZXE1XyOMPKp7yNNOiqZVz2tB9
         iVSA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=UmzhoFSi/XlLp/EenFokB0pc/jS5RPLJ6Yk/5FBSErU=;
        b=kejnRKU3H3a8KLMxyAlPwQ77/TtOVAwOKP3CYlBKwzjH4eu65aqbbpPYzIeYnIri/c
         fOH2VwYYsWb9rLiCAiShQjcMANDML+6eV9Bt/SOYnObfQf8aUUYzyQUJKpItOq3Focg6
         8GUzZ52mWSOSSet0Fj7RFhQzoA/cAm92cu8tucWi+TH1QQu2csIvgdTaiPGOPn5y/NDr
         vFJJtFLZtn9peDv8NtKkWFPFbLAN6BZXmu5mMEO1mUbxQPOD+oUDEcSCCM+x6x/E9PCf
         EvOcAYbm6fIxVr4HyfE0H73KqKa9fBlOM5DQGjw5r9wRwEjXXC2J4t9OkFoWLzpmUY1I
         /pAA==
X-Gm-Message-State: AGRZ1gIfg20JIoWTdbFGvqieBrICWfqEcERKGUllVie+YsDv/an7e24D
        pq9r5cER6h22negaCnltyWM=
X-Google-Smtp-Source: AJdET5d2jmrcOqonkXIfNUerrHuZk576WIYNxbX5v7ZrMJUPufvAvAYWZ9yay2Cr6rJ8l9UDVv/6CA==
X-Received: by 2002:a37:b9c6:: with SMTP id j189-v6mr841172qkf.203.1540504312971;
        Thu, 25 Oct 2018 14:51:52 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm5895927qkc.96.2018.10.25.14.51.51
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 25 Oct 2018 14:51:52 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
Date:   Thu, 25 Oct 2018 17:51:37 -0400
Message-Id: <20181025215147.36248-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
References: <20181025215147.36248-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

A proposed VFS change removes the check for the files to reside
under the same file system. Instead, a file system driver implementation
is allowed to perform a cross-device copy_file_range() and if
the file system fails to support it instead fallback to doing
a do_splice copy. Therefore, EXDEV error code only applies to
kernel version prior to such support.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 man2/copy_file_range.2 | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
index 20374ab..2cd9fae 100644
--- a/man2/copy_file_range.2
+++ b/man2/copy_file_range.2
@@ -39,7 +39,8 @@ The
 .BR copy_file_range ()
 system call performs an in-kernel copy between two file descriptors
 without the additional cost of transferring data from the kernel to user space
-and then back into the kernel.
+and then back into the kernel. Since kernel version 4.21(???) passed in
+file descriptors are not required to be under the same mounted file system.
 It copies up to
 .I len
 bytes of data from file descriptor
@@ -131,7 +132,8 @@ There is not enough space on the target filesystem to complete the copy.
 .B EXDEV
 The files referred to by
 .IR file_in " and " file_out
-are not on the same mounted filesystem.
+are not on the same mounted filesystem when the kernel does not support
+cross device file copy.
 .SH VERSIONS
 The
 .BR copy_file_range ()
-- 
1.8.3.1

