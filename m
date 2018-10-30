Return-Path: <SRS0=cX4g=NK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B7D24C6786F
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:34 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 574C82082B
	for <linux-nfs@archiver.kernel.org>; Tue, 30 Oct 2018 20:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kBeMOwfV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 574C82082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727969AbeJaFvh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 31 Oct 2018 01:51:37 -0400
Received: from mail-qt1-f194.google.com ([209.85.160.194]:43936 "EHLO
        mail-qt1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727879AbeJaFvg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Oct 2018 01:51:36 -0400
Received: by mail-qt1-f194.google.com with SMTP id q41-v6so15245743qtq.10;
        Tue, 30 Oct 2018 13:56:31 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zRRMAOPAYc5adc3KLz9Q0Nr5H4iqpq1Ya3zwGX5y5X0=;
        b=kBeMOwfVjJDJ2G4yxy6MlhSkT9V+kbN4ckRjkCcw1HvYo55q4vLqYD2/S7++1O0hoq
         2VXX21gul3qJUYNpTJEM8tiNKE0E1cFPDntq1aCpFIH3YaqzFOy1OmBK2Hu+/AJrT8HL
         TuzuJ/btQsYotNNawcU+Ui71aBx8MTmdHtlNft+lUqHZePpgVUg5m7T4QD1f7spb59FD
         /hWeecQw03IWqaZhRf1CddWyCrPAjhxo9LlSpoMEgb2oJSDducUTQI8D4Ags5qsNKhsd
         Rcn+8jhyn7BYKk8HJhm/PFb5G52JEMdqcM6VGtwzD+SQBfyy7lHsnFhsgGBV4OTWMpWo
         BuZw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=zRRMAOPAYc5adc3KLz9Q0Nr5H4iqpq1Ya3zwGX5y5X0=;
        b=auVdvQlI/s37xnkWxul0KyHh1XcuTzMhzxN7U8TQkNEd3colrsVniLW0rZLZHNfY9N
         b2uNz0QMKNUnpAD2wm6hRW/WrVCe8z7AnDBY61m6ToxM6L7o2EKppXI4iYxHG1wBlu6k
         HL4kRmvzuHS/zgdt9U1uvYR07eJA+waDHTaSqsOO4ZuKb7dSbzQ7gWydxIDo1Cs3QR2z
         S1kMKPOvt3dte3I2ib040kla7Y/ZMY5+Wm1EqW7zcSSpiY2aeBF8gyGH3ifACjAR7Ktt
         /u/0Bl/6q7wdfJOnEHEqJRjESijYYrma0bzuTUSidNs9fn0i69JSFagLlL3N5aZUH7Ct
         s4WQ==
X-Gm-Message-State: AGRZ1gI2hPhHJAkekpAs4vMOQlmN3/eB+k/ohsp1MvZDPN2daPdXq2xY
        UPuD+0DL6nyxw+DjfSrXFkNYuzMT
X-Google-Smtp-Source: AJdET5deN+PBs64Pt3+cjwdysSh6meD6SNCWVdSJKRRZ0UelJkZuOmsAufu1TTSFyd49X7v+xs8d4Q==
X-Received: by 2002:a0c:98a6:: with SMTP id f35mr278059qvd.224.1540932987336;
        Tue, 30 Oct 2018 13:56:27 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id i11-v6sm23478157qtc.96.2018.10.30.13.56.25
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Oct 2018 13:56:26 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
Date:   Tue, 30 Oct 2018 16:56:04 -0400
Message-Id: <20181030205614.40754-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
References: <20181030205614.40754-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

A proposed VFS change removes the check for the files to reside
under the same file system prior to attempting a copy. Instead,
a file system driver implementation of the destination file
is allowed to perform a cross-device copy_file_range(). If
that filesystem does not support cross device copy, it returns
-EXDEV.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 man2/copy_file_range.2 | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/man2/copy_file_range.2 b/man2/copy_file_range.2
index 20374ab..03750c5 100644
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
@@ -129,9 +130,9 @@ Out of memory.
 There is not enough space on the target filesystem to complete the copy.
 .TP
 .B EXDEV
-The files referred to by
-.IR file_in " and " file_out
-are not on the same mounted filesystem.
+The file system of the 
+.I file_out
+does not support cross device file copy.
 .SH VERSIONS
 The
 .BR copy_file_range ()
-- 
1.8.3.1

