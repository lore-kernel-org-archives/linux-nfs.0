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
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED8B8C6786F
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B2D66205F4
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 16:45:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="sBQvl11x"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B2D66205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726752AbeKBBt1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 21:49:27 -0400
Received: from mail-ot1-f50.google.com ([209.85.210.50]:39692 "EHLO
        mail-ot1-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726712AbeKBBt1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Nov 2018 21:49:27 -0400
Received: by mail-ot1-f50.google.com with SMTP id g27so5448597oth.6;
        Thu, 01 Nov 2018 09:45:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=T6NY1ZqMpMDP9hCYA0jR0CNHkfUq1OpC1PqHK6+EhwM=;
        b=sBQvl11x2RC5w7LBcUNJk90xfTMf1k7yGrdy3P0JmP18U2D/yaQ0KHasvyGQcf9yiL
         2Kq3b4iICSrZpy9PEeMWhaouEeNPI8yi9e2ESlD353FVNIESOoghLq9YPv2DNt8LK9U1
         nRljgslRZvsiJgSl9aAwf7X8jTIUfuKpLnu0HPKWFn560F9yix15ncXgUEktT4ittvL+
         8Rt5dOkcH4+Z9n+wLxxcj79jE8Dsf7ypr2a7VdiaUhAf6CENLNG/biS/w/LwYFv6oeCq
         lo0rYVXVhxTxP8cd7wEWV3+zcfYoqy+HeOD07Yo6JaqYiRIhGtsFJUJlPC3QSssT2+xK
         iJRQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=T6NY1ZqMpMDP9hCYA0jR0CNHkfUq1OpC1PqHK6+EhwM=;
        b=QWPiV/GFZ7g9a6w7jR0xDV4HaBuwtSW0KiZckPb5bAmpv1YsPn9kfGrpyTLYuUDagZ
         Sholbzt5vJrUmjXSVyd/1E3mVYhS3ciB75g5YAX8O2uhVwvHIm8A38DZswvYNgddwib4
         2drVE2uJ3Tt8Cx4txso0LBvngJlSjg8OJ+SyIpMHDgyfsZHsssBAJtaKQLHAZMzGX8hO
         54IGwdKnE4HKkVkkyzlRcuGwqgjuAHLp/FkT3/fyhLOv/2uZST6SPTieShLDRTGkqpDQ
         gj7AfDawxM+dXFVVkZ6D3eTqRcLpiXCnEEH6+EJwmqaCALtknOXXQ+yWdRciEumwBI7P
         hx3A==
X-Gm-Message-State: AGRZ1gITYrPVq4UmnKOIW/kgDdyKDClypZFz/m1BiL1HwfduWeewGapD
        54A/l8VLIfPL2A788i+udw8=
X-Google-Smtp-Source: AJdET5dQZYvGZNcXkqTaqJ58n/YCjNZoCXdcGbh5eR6DHNBoXy3wl06r/EN/mWBXceIkcVPkTa0OiA==
X-Received: by 2002:a9d:2c46:: with SMTP id f64mr1685949otb.192.1541090742283;
        Thu, 01 Nov 2018 09:45:42 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id r62-v6sm1834301oig.14.2018.11.01.09.45.40
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Nov 2018 09:45:41 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org
Subject: [PATCH v8 11/11] NFS: replace cross device check in copy_file_range
Date:   Thu,  1 Nov 2018 12:45:23 -0400
Message-Id: <20181101164523.41812-12-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
References: <20181101164523.41812-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Add a check to disallow cross file systems copy offload, both
files are expected to be of NFS4.2+ type.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 12c34b3..ceab66a 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -142,7 +142,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (pos_in >= i_size_read(file_inode(file_in)))
 		return -EINVAL;
 
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
 		return -EXDEV;
 
 	if (file_inode(file_in) == file_inode(file_out))
-- 
1.8.3.1

