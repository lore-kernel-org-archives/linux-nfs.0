Return-Path: <SRS0=7JSz=VF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B00DFC606CC
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jul 2019 19:24:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8A0482086D
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Jul 2019 19:24:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="TF8hZzb7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2403907AbfGHTYy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Jul 2019 15:24:54 -0400
Received: from mail-io1-f68.google.com ([209.85.166.68]:42563 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2403906AbfGHTYx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Jul 2019 15:24:53 -0400
Received: by mail-io1-f68.google.com with SMTP id u19so37824473ior.9
        for <linux-nfs@vger.kernel.org>; Mon, 08 Jul 2019 12:24:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=4Rti/ogp9nh8jvdF3bDZU76EXFuU1Q2Jgt4w71ZMhJw=;
        b=TF8hZzb7l4PN1zDK2ABvVYAImyKXB0dHxT5BdxweJzNcXRnMo/1eqq99e3Sb7Xd2xg
         HMAEzz1Ox8hYLA4+H6YS1t9199PeCc5RugR/KbATxWqEj0rHrbupyjXmAAG2n8jHX5Ej
         xr/sZ4JMpOJuOkpwB/AUAIfK8uOFu/c68ObXNAnsKCys2UwqbRfy77AziMT0lcb7VH+H
         ERkA2e8xKjAUxKEoEs/I86Lq9KIXzv1gucNG2nK8qxmsCj3MYUDxAqlJxqGeEYj/xaaT
         oFsb4srMgmwPuCguifVrd6E0p0f/O9KtMkMC68jrbkpAilZkIxSI6Ghs9CNBjOFb+bLG
         yxpA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=4Rti/ogp9nh8jvdF3bDZU76EXFuU1Q2Jgt4w71ZMhJw=;
        b=ivhoR8S44b9JJNcAGnBq8taqEIRBtiV7wwZDLqIqfDqJAZ16rpaI+8ZcXEVM8vhnW+
         5H/vaAFY0vJ3IXaPuYz2VRwr20pV196q4W01tOjHdorsJ2aQwOcMBr5WT+Asjk2A7D9f
         MQzW8TEPUZdOQGUrDH77ocrKC+cRr/eu65hyLBUqzlZF6zBDcPK6OVkA5hGm6Pp/13Ii
         6vxzh+GscykQ/OUUB3jkv/Y5++/u5QSEyho1/dD9dSiNhA5pHjUYILLGTOgZsex/RyKF
         ahW870KC1b+kk36NTgH3QoYWIsOiq+15aTDtjN5Ir+7vfoS5o6Vwn9ewTjznV+nHfFHm
         Yo8w==
X-Gm-Message-State: APjAAAWfuU1xmX4jejxgbJtBJV8m8KmbxOhHLPjh8gsExQ1eph0UPNKI
        uFfxalCaChmTG/8QuP09sQqWdXBoIhU=
X-Google-Smtp-Source: APXvYqy+OxXXLqLmRLTEDt9Rp1SeGPAq9nx01p4xhgp9Fc2GOxy6pPXQGH4OKoCty3Se2LOZa3BDpg==
X-Received: by 2002:a5d:9c46:: with SMTP id 6mr12841891iof.6.1562613893405;
        Mon, 08 Jul 2019 12:24:53 -0700 (PDT)
Received: from Olgas-MBP-201.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n17sm17026554iog.63.2019.07.08.12.24.52
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 08 Jul 2019 12:24:52 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v10 12/12] NFS: replace cross device check in copy_file_range
Date:   Mon,  8 Jul 2019 15:24:44 -0400
Message-Id: <20190708192444.12664-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20190708192444.12664-1-olga.kornievskaia@gmail.com>
References: <20190708192444.12664-1-olga.kornievskaia@gmail.com>
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
index 2671619a44ff..bbcc24d2d9e0 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -141,7 +141,7 @@ static ssize_t __nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	bool sync = false;
 
 	/* Only offload copy if superblock is the same */
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
 		return -EXDEV;
 	if (!nfs_server_capable(file_inode(file_out), NFS_CAP_COPY))
 		return -EOPNOTSUPP;
-- 
2.18.1

