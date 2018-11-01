Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DA208C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A2BB7205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="u22ejWd2"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A2BB7205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726299AbeKBBtP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:15 -0400
Received: from mail-ot1-f68.google.com ([209.85.210.68]:46466 "EHLO
        mail-ot1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725959AbeKBBtP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:15 -0400
Received: by mail-ot1-f68.google.com with SMTP id q5so12884727otl.13;
        Thu, 01 Nov 2018 09:45:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=Cqmt+GWWK9Zf9XynZ4EBj5J0CQZ2wW9XW6OcUaOzM2A=;
        b=u22ejWd2czfdVJMd7jlXKDxweqKqIWJhs6Y5oEI1d6GuOhQrYSS8GueptwnQxcH7Ap
         1VqBIxMuhAxBPMj3VMDKyD4xg/blu3gdUPliG60X6bzt4RaHXKSqe1Q5wC4426Z6GDZ6
         fuB2kaP26E1VE8u7OCyggXK+mqxe3kMZcO3XjCXye2PhiyBcNOdB2exhnOFOMIpwSJ5A
         12h9YGakqXiB4NhvCA7def0Kvwf8BOcPivrHNp6k+fDr66tCAFfqyPhWos9Sq/Wzbwl8
         naJZ+0i3WmbsiV4+CJp0uAxATRJIcYD8nuwlVTbsG+4jrT5KIwxiOXCeD3XXca57EXGd
         3lcw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=Cqmt+GWWK9Zf9XynZ4EBj5J0CQZ2wW9XW6OcUaOzM2A=;
        b=uhsPJceUgI0EO7DMvX1EunYDgQ8jBsXIPpFVnmGeeQ3D+D7BpZh6anaBB72rA2wbjW
         yGDLXMBRx4NKc2i0WbQS2b0BEYvzHZ1hMtmHZYsYskQ5Ex8s2JXmOUkcWefidRfMRo+8
         bla8avXufCZcixdeYgTecQgJ44P9nKJ7eJ/l3SrlC/OJ5vqz3QynGRzmdC5Z5vaf6rAe
         xe9E0+7WviFYmvUsyorHIKSmB0GC1mDzSX/YqJdUo2C1rcaPgkLEDpGsj+p354mde+mr
         t5BN0UIxeOmB95xE2mNYbfdAJ5kcVxtBTHTEu3OCsGHUmeGvm6vKa7LOBwN/iZ5RtKQ7
         9PPA==
X-Gm-Message-State: AGRZ1gIDZ9dfg9B1l1GMrzH/d6yHRNFqTm3r+fyYt9jl26DQ0bKzZl08
        SOpLhkbDeDer5mqXWMkgUDc=
X-Google-Smtp-Source: AJdET5cGypp/AfQBgxRJXWl68EMqmUg8aUfCbQ7vTYJpC83x6ycyoKUr39X+SKsBQbriJYvjk0Q9LA==
X-Received: by 2002:a9d:7101:: with SMTP id n1mr4802680otj.236.1541090729888;
        Thu, 01 Nov 2018 09:45:29 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.28
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:29 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 02/11] NFS: validity check for source offset in copy_file_range
Date:   Thu,  1 Nov 2018 12:45:14 -0400
Message-Id: <20181101164523.41812-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

copy_file_range() man page mandates that EINVAL is returned
if the specified range is beyond the end of the file but
currently does not enforce it.

NFS RFC 7832 states that "if the source offset or the source
offset plus count is greater than the size of the source file,
the operation MUST fail with NFS4ERR_INVAL."

From the NFS community discussion from earlier on
https://www.spinics.net/lists/linux-nfs/msg62627.html
in was thought that offset plus count should instead be a
short read.

In this patch only proposing to enforce the offset check:
Input source offset can not be beyond the end of the file.

Future work in VFS might perform the arguments checks and
we can remove this check.

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

