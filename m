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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BB19ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:47 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 01F8520832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Al64WyJ3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01F8520832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727357AbeJYE2K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:10 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:46613 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726221AbeJYE2K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:10 -0400
Received: by mail-qk1-f194.google.com with SMTP id a193-v6so4209626qkc.13;
        Wed, 24 Oct 2018 12:58:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=OalLXzSog1uf5ATRS1HbAFJ8toxAhnJN/f8XiubBLbA=;
        b=Al64WyJ3+yyMsTNXcu7/1veAld9d0g0HyTIZECjKoYiN1LMpQj5KchudMIGqL8kzde
         bcqKMsmKHgWeizagKzcGfmnVLf/bj5+JSiW7QunT9Z1usVe4qqUO8BIrgi4SliWLG+ie
         5J9gqnkLJLL3PJw3hn3JPJTpAIA7edF33FGKX4NyBtYX40amPO6wHbP6tS78W31o296m
         g8zDopsRLT7Vh69XzWh6i3jlqui5YJEjp2Gt3kerBt5lX8pmb2aG2M4I5AebchlRpii+
         WgWZI81n1qdlJS8EmZr9bUkt5xNxxZvBcsjmjhuxSNNmGkHiGq/8RZMiCV2C9NGABH0e
         +mQA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=OalLXzSog1uf5ATRS1HbAFJ8toxAhnJN/f8XiubBLbA=;
        b=N9JjE14UXIfHm8+UeQndWRWzBUHRREgHcyPF4uJO6qippHVRXZg4JjHOMFWetjyb0p
         xJME2z0d4h1OQeSWc2Ch69XwefBEHCAAEtQJATf8u29VZ62XjrJTtaQZmMKpnMOpfEZl
         MugQmwKWxYvJxlssdymKytawbRVFyzkWyAGT8ZSZ6w9shhT8ct3jxjT7zR/hPR7rzkJo
         5q2aXGcPlOeOo06Tpqs+BDLEF47qNvGRqsv9Y6wfBN7ImDSRaz3Brht/xqKutu8eNS6s
         8Yjd+Z5rCT/08CkIDiOcLJj4813ea/ZsfQ/skyOJyL3vSpcXjiVRBnmSoN4FfHQiXJW4
         vxog==
X-Gm-Message-State: AGRZ1gLxirFQ/ICNPWuCWJ2kVG5iZilcG3sBiytJ11wwDw0GP8pJVqD0
        +ksx2IOse961ld5a8ZXCdPA=
X-Google-Smtp-Source: AJdET5dCfTz4bUm3iUVrkd0hTuIEjsr5SJ4YzkRDhuDs+NxdDoom/escgMLMcrpcE0cnCEV9PKA3kg==
X-Received: by 2002:ae9:e515:: with SMTP id w21-v6mr3724872qkf.105.1540411123023;
        Wed, 24 Oct 2018 12:58:43 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.41
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:42 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
Date:   Wed, 24 Oct 2018 15:58:25 -0400
Message-Id: <20181024195837.35532-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

A proposed VFS change removes the check for the files to reside
under the same file system. Instead, a file system driver implementation
is allowed to perform a cross-device copy_file_range() and if
the file system fails to support it instead fallback to doing
a do_splice copy. Therefore, EXDEV is no longer a possible error.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 man2/copy_file_range.2 | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
index 20374ab..723b2d0 100644
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
@@ -128,10 +129,6 @@ Out of memory.
 .B ENOSPC
 There is not enough space on the target filesystem to complete the copy.
 .TP
-.B EXDEV
-The files referred to by
-.IR file_in " and " file_out
-are not on the same mounted filesystem.
 .SH VERSIONS
 The
 .BR copy_file_range ()
-- 
1.8.3.1

