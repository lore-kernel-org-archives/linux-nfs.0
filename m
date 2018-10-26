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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 17681ECDE46
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CF67D2086B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 20:11:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GCMO6C/z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF67D2086B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728057AbeJ0Etl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 27 Oct 2018 00:49:41 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:41052 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728048AbeJ0Etk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 27 Oct 2018 00:49:40 -0400
Received: by mail-qt1-f195.google.com with SMTP id l41-v6so2673500qtl.8;
        Fri, 26 Oct 2018 13:11:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=m1iyxN3LtBf2jUYvNb+4La4oc809nYMZXgQGSp2TBFo=;
        b=GCMO6C/z4fUDyS9qDALE7h7JbDz9aJw8IKTwtLAi+X8IzH8TK1Kt5bTmr/338i7ImT
         r0Y7kbgMIEo1wgE39+wGdXo0GIHypLyQ7Ch0WuQ6ZhQrRANVo6DvI4SI2t+fvwxyNpca
         alaLuCWoA0v/l3HGyTKMzpiX4Mu/CgX895o8JApnw75+MHCA+3Dr0GeCvSubC7aSvzac
         3dKpf8O4FXOg7j/lZMCwrRhtxdu9DakAIt6YG5x2EHmFuT++qcr4vAH1vl2O4bjv17i8
         XMTQkgmAqnIzqUohlLplIVq1v9V5pzHF/IBx6Z3krsi2Wk318Jksi+StXuX6kgx3Jjyk
         I+7Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=m1iyxN3LtBf2jUYvNb+4La4oc809nYMZXgQGSp2TBFo=;
        b=g7lOwUMHMo/NqXVqlPDAOTgfEako1uLovEBiZDHztZGKc0CsZV9BMjv7/Qu7JCjphL
         caG/NqbEXFO8Wegx6fbaiAaK03CzdwIXN9wIGGclNpkUz5sGk2Q/lTSaHC8hs9pR7gYs
         8H1Z57XpNc/7dSj78sZKBlPpwE6Hi3idrM/n1gAXaIpK2fssR9ZDexEpZv29NCrbjFZI
         0yjkwBtUAZ3+YNSw/j7Pj2fl/b0oWmrVfMzHmLmzjPEnLvhqUrsCx4WFi0jCom9WBi/T
         2DsIp97XBeuO5kXg8x5pQ7Q0AIC/K+L2e0J3PBnT7WMx4qzMlw4cMCJXL0FyVHiVTwor
         HV+Q==
X-Gm-Message-State: AGRZ1gLDZ/LeQozyW1CanEB/4sW1R/SJ7uW0CG1pg7/PAweMbHjglyg3
        R9QXC8WkG9luPAALNnoAF1s=
X-Google-Smtp-Source: AJdET5eqYngn6QNPa1m8X5rPyWSxahmTeo7QWO2Ek4I+JyHhuRjB16s+vZKh0s6SnrGDj0L8Zw94dw==
X-Received: by 2002:a0c:9a4d:: with SMTP id q13mr4570349qvd.89.1540584676478;
        Fri, 26 Oct 2018 13:11:16 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id p64-v6sm8037667qkc.96.2018.10.26.13.11.15
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 26 Oct 2018 13:11:15 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v4 11/11] NFS: replace cross device check in copy_file_range
Date:   Fri, 26 Oct 2018 16:10:57 -0400
Message-Id: <20181026201057.36899-13-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
References: <20181026201057.36899-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

Add a check to disallow cross file systems copy offload, both
files are expected to be of NFS4.2+ type.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 2f31f30..344e9dd 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -139,8 +139,14 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
-	if (file_in->f_inode->i_sb != file_out->f_inode->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
 		return -EXDEV;
+	else {
+		struct nfs_client *c_in =
+			(NFS_SERVER(file_inode(file_in)))->nfs_client;
+		if (c_in->cl_minorversion < 2)
+			return -EXDEV;
+	}
 
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
-- 
1.8.3.1

