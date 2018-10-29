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
	by smtp.lore.kernel.org (Postfix) with ESMTP id C3212C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 86F7A2082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lGYoQrF1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 86F7A2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729512AbeJ3DyW (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:22 -0400
Received: from mail-qt1-f193.google.com ([209.85.160.193]:35153 "EHLO
        mail-qt1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725969AbeJ3DyW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:22 -0400
Received: by mail-qt1-f193.google.com with SMTP id a10-v6so10588182qtp.2;
        Mon, 29 Oct 2018 12:04:23 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=vBxFiCMdm9zwB+fNOLFFTK+4s/3BLVSMs2/+B1oAwOg=;
        b=lGYoQrF1v0lKLHUkCbGmSsgvOocbEGuK0BYHteAgaZURtDiR2M5Ly4m6neVrRU+FoV
         B1eh0Yw9+VUcpTr25G7NHCeS1r9+R8DkIoIxt5JbC8Kafd1+MJqPivCUwj64rLGU1L/U
         JJcZfls86iV+YHOEKpK5LfkoaEXpIfhTog2P4uztJMlwY/nv/uTsTtw8tK5YSBtmoof5
         uTkZozMEbbgkg7sPSgRmVH0gwpvzYlZOCDUEgyTm8GJvHqeZSDsJKFpxCT5OA6dw8Cq7
         /OB5kZesVccgXdYUAKP8hcNPXrqmqVd4orpFbAnINdpSpLTxIKQVBVN8dq+tyHOkOp+I
         ZSxw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=vBxFiCMdm9zwB+fNOLFFTK+4s/3BLVSMs2/+B1oAwOg=;
        b=Td55ILHUDCL1FscWZ4pAYHr6XqI/qIGJEaj89BjF1WIw7QZMJEcK3pzfqKrVNvvX9B
         YMQH3t7+cVs0PKaMAy24MJuK19e9rmC4CtDaC+XqlfnhyGs/d+9zq/rtE3eJDLtDoQu1
         gxpip7hsfC8HF9F6nic8d8pVqxvCoI3QKujF8WfNW/jUrG4jkYEqpaGZ6wnA/PBFqEkN
         U6Sy/69rfmh1r0HPJpPSywDm+fyZuL78bRZftCGI3MPFZXQtUzz91YSUUjMvuGYaKPrJ
         NktSdMvzkJaeeua/XDxlC2M8kOaMSzd76zh/94X88jMlXtN1t45rbyfflnVgJnnGJIXp
         4orQ==
X-Gm-Message-State: AGRZ1gLXALsAest9XdB+XEtlQH00u2F19+6H4GeOHSWgBCdqzpyJghP+
        Ea7bPVXXtOKKaERuacA0eCI=
X-Google-Smtp-Source: AJdET5fCK7pKZFbfyNmL8NJCc8a+XspA8JhfYoD/CPXIVnNa1ZBAzO7W9RTPQqB2zrf1zp4KAGwJ7w==
X-Received: by 2002:a0c:9927:: with SMTP id h36mr2825391qvd.171.1540839863448;
        Mon, 29 Oct 2018 12:04:23 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.22
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:22 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 12/12] NFS: replace cross device check in copy_file_range
Date:   Mon, 29 Oct 2018 15:03:57 -0400
Message-Id: <20181029190357.38439-14-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
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
 fs/nfs/nfs4file.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 989f174..69e2705 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -142,7 +142,10 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (pos_in >= i_size_read(file_inode(file_in)))
 		return -EINVAL;
 
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
+		return -EXDEV;
+
+	if ((NFS_SERVER(file_inode(file_in)))->nfs_client->cl_minorversion < 2)
 		return -EXDEV;
 
 	if (file_inode(file_in) == file_inode(file_out))
-- 
1.8.3.1

