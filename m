Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34108ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:29 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E787120869
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="I6Pz2Uoc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E787120869
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727809AbeJ0Et2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:28 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:39344 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727791AbeJ0Et1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:27 -0400
Received: by mail-qt1-f196.google.com with SMTP id g10-v6so2682867qtq.6;
        Fri, 26 Oct 2018 13:11:04 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=jckMbbglVyva0XyY5iohIXxhrEgE4I2NcNIaaOsdqKc=;
        b=I6Pz2UocpkODXjxdQnTciOazN4XjH+YwxRr1fQIrsO0xNBZP5HSfmLjvIxxz9hIM9L
         7nws8COJpM8EbHW4T+CK75157WiRwexjpuaimsc8f5UwIajDJBlqjxQoUD3HtngQ9KNq
         gpHJR3yl6Gl+bLhg2VbF69j7xFWVTFmfPa3mHApqY6v+clsIOQTBcIk7hrJ2cG2ITdxX
         jC0QWlEreN3Bj+sTJV1bwqCEHFHvjV1KR18c2fhdUToMPJlnH/SlVsqsN+RgsbAXEE5+
         74uG4EwLCaOaPMAOphmVOquwRhnRt4Fk3UXA2lTNfku7D8KwyL60jhMh7qLr0523RczT
         R2tg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=jckMbbglVyva0XyY5iohIXxhrEgE4I2NcNIaaOsdqKc=;
        b=HzGNyI+nFxX1+gWaZT38xMeKZXBiaIsLRszLH8b6LBiHpEbA1wSdexXxwbFFY5b2ba
         DmlT0wxHwpkILDV8j/oJjI3wd6enpQzmzQlzhLumYX5Vr9Qx6+P6zJeurWGKZ3nNTXSE
         nhK3lrruMavb4BFIezAiYnBpqxLttOCudctI8MnPIYfWfZ7P4HfHe1Cul41QOEg/RKlP
         GT1uFh/ikPAQvAwsmAbYnvEoXrKEjLlGNEELAxE7sdUODKRiSw2mgstCAhI5X3C+uuwL
         Ac5byoCpEE2qg5AUBUOCGZJ87eUPwHjAcdvNtF8M+RCkJsYmFKAdRacaY7vMF5OMlM0i
         4zLw==
X-Gm-Message-State: AGRZ1gKG40TYqfRgzUhtJliL/roreqfR9OGXjJTAQcu92zrl7I/dfnIy
        DmuJbkTm/7r3M4n73nkEY2Y=
X-Google-Smtp-Source: AJdET5f0b9nbfG5zXdUNRVOEajTs9CVPpkgrY7KPjfz5idrCnpSyyunx2zzRDMaddqOakJCLO68IyQ==
X-Received: by 2002:aed:366a:: with SMTP id e97-v6mr4657485qtb.75.1540584663684;
        Fri, 26 Oct 2018 13:11:03 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.02
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:03 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 02/11] VFS: copy_file_range check validity of input source offset
Date:   Fri, 26 Oct 2018 16:10:48 -0400
Message-Id: <20181026201057.36899-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Input source offset can't be beyond the end of the file.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/read_write.c b/fs/read_write.c
index fb4ffca..b3b304e 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1594,6 +1594,9 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
+	if (pos_in >= i_size_read(inode_in))
+		return -EINVAL;
+
 	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-- 
1.8.3.1

