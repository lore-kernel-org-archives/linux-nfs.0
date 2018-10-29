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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1804EC0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D5AE92082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="FX3waPfP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D5AE92082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729186AbeJ3DyD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:03 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:34159 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725923AbeJ3DyD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:03 -0400
Received: by mail-qk1-f193.google.com with SMTP id a132so5674850qkg.1;
        Mon, 29 Oct 2018 12:04:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=yD4MhSbMio4ftRoJ1EkJw3YdZdnXrh21EJt6A2edN1A=;
        b=FX3waPfPDuOYGENDfxhDsua8gK80fufYRdM8XB7vca2dyg8CVZvT4Q7qkk1zwBtxWZ
         j1IoYIP0/GGmp7VJViibe7j43uNe+yEFOolPwlWasYA6w/1bQJ8NZlJj2q+TRkLzAiPM
         vsM6YEMIDwjCajPoOR8tM45VmVkXabcZkHayQWt3+IoFcVlGfHKZa1qV4nAKAtsdW4oJ
         gcLozG5TR7MGkjVsWLNA02MU+2msKEIL+8FBXxdLZ09lLSI72CO//HIhVrOD+mAiTyUQ
         AFkx1QxdqtJw3sJrRiBY7DXWdoCJndwZ/LLCsjDSIfz239FkcXtHui+LxAXELeglxH1t
         VUrA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=yD4MhSbMio4ftRoJ1EkJw3YdZdnXrh21EJt6A2edN1A=;
        b=RiGieWJZgFZH8d5JdLevoJ5y1fY3QsuOlKOgKdIp9LpBguV0flUhqOlZ+Kihx5wgGv
         owMw23CVdKNNKBGTUvOlJh6Kh1oX9y6HKisFGSsLua808QHlZOecLjJRpH+BBCRjH851
         liVp7cpnly89md+IYbCDLE7ld2HXOWJIO9eL8Iflke4vRLP5kbdOXwvtnlTuyJZzaF2+
         CJZlnpS3O+mY71Hfz8UEHtJrVif6NNBLGxPuCMq4e5CHqllf0Ow1iXxnIrfRsyQc3fWx
         3nuQOgpn3ZBU5nBxqApX1CcXKspbLATazLTj8FUj9/jZnJ/sjfycMLa4P24vSIzmryLP
         Vnew==
X-Gm-Message-State: AGRZ1gLPashlbm3cIxv4jq1HdRcIXZrVth4RwMs2/pwPnECYAArUX7CW
        ebSdzzyMnLp0Vf+1H99kwJM=
X-Google-Smtp-Source: AJdET5f/YHf7E0x8WFVW5XwomSeR5gUwl58s0d76GbHjZNA5rDl28niSBBF+SqcqjH0klyL/Dncmlg==
X-Received: by 2002:a37:7d86:: with SMTP id y128-v6mr12739918qkc.310.1540839844323;
        Mon, 29 Oct 2018 12:04:04 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.02
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:03 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] man-page: copy_file_range(2) allow for cross-device copies
Date:   Mon, 29 Oct 2018 15:03:46 -0400
Message-Id: <20181029190357.38439-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Proposed VFS changes remove the check for the files to reside
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

