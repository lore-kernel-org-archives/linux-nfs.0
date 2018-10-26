Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08F50ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C1A7220824
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qg53i5Xr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1A7220824
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727792AbeJ0Et0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:26 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:42282 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726393AbeJ0Et0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:26 -0400
Received: by mail-qt1-f196.google.com with SMTP id z20-v6so2669355qti.9;
        Fri, 26 Oct 2018 13:11:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=KNz7GFJSWp1t2j+KQVntbZiAqixh0mnCFHH9hTdr1Hk=;
        b=qg53i5XrscT/VSDXthD2lNwfKmcbUxWejoeLvMlJwFTQJPiV1qtGqsn+nY7WmKD7wl
         op0nfSPTI7KQKPH/C/qkHAa2KAitVSz7MJ8j+OOIQYRBguKBbmivJuY6RMoKONXsvQ3T
         KC+F23O42hJE/rpfQevNxgwIAmrfbDZt5yWR3PkANyEXZu8pbh0LpbessrJQqOFHVzie
         rmACdI5JThvxwP33YbwYacqjesfQFj0JgJlAPlruo6hClAMe1cp4kqcyoH6vIDdczthR
         cR4XmIxBGFIwmz3YQwJuB+YpGKo6VnpYfRqWhdn1ys/HbskFwhwmhomflh+L+pUS+Jkw
         oHBg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=KNz7GFJSWp1t2j+KQVntbZiAqixh0mnCFHH9hTdr1Hk=;
        b=Bz+OQjdWoMqbzYF4zyFGuiZ70jUbNGuHHJCyf/upqzlBG2018SUTVux8dRq55kn7ch
         rQ+lf+Iw8zdf+uwOipZ6rq0PpJFFdymnz7i+1a7cKKDadSifbEPd03oPbrYsQ5hDLmzZ
         Wvbg1m04A7kdAB1W1OFDMc8TZ5ZxHWQHh54rPOFypSr3dtA0aMUnCWb/JS6h1NaU5cC0
         dGI/V7Dgk2nvC2KDv6Qm4HZHHjVPKFOzQPye991tRdq/4viAmQItNJS86adV2/g5KfLN
         oiD4XnVOf01RcbIVs8ne7XpnyZab4M5sICxpftGjdXsY0Vd4dPR0Joe7YyBhWYmKHvAV
         +Dmw==
X-Gm-Message-State: AGRZ1gIP+NFjVZsa5skW43IzPfeN4tnno7hdT+qoBqTkKd2Fm8ykPsYk
        WaFgbwe8dkrSuXrjIMcM05Y=
X-Google-Smtp-Source: AJdET5fi1c3wSbBr8KRVgjApo7RBdtCmk02LDxFlV6n1FwS9OxqLNbYGy1AF0ShLuTTis0+bQWRhzQ==
X-Received: by 2002:ac8:2932:: with SMTP id y47-v6mr4489378qty.42.1540584662350;
        Fri, 26 Oct 2018 13:11:02 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.01
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:01 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
Date:   Fri, 26 Oct 2018 16:10:47 -0400
Message-Id: <20181026201057.36899-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
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
index 20374ab..88b40bb 100644
--- a/man2/copy_file_range.2
+++ b/man2/copy_file_range.2
@@ -39,7 +39,8 @@ The
 .BR copy_file_range ()
 system call performs an in-kernel copy between two file descriptors
 without the additional cost of transferring data from the kernel to user space
-and then back into the kernel.
+and then back into the kernel. Starting kernel version 4.21 passed in
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

