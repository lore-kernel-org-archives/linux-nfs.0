Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10939C64EB4
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C88902082F
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 20:03:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mxZKrbW/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C88902082F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726424AbeLAHOU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 02:14:20 -0500
Received: from mail-ot1-f68.google.com ([209.85.210.68]:36555 "EHLO
        mail-ot1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725790AbeLAHOT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 02:14:19 -0500
Received: by mail-ot1-f68.google.com with SMTP id k98so6237730otk.3;
        Fri, 30 Nov 2018 12:03:55 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=IvT+zChRdZmo9Z/HWpUoiYO/PRDAUFPXOTb7glWeIsY=;
        b=mxZKrbW/SPzKZzsJpxo6/N8Tk2V2GNkgU489BhLx3Qs5wdm8peAi77ouSQTl/Sr+ZY
         dVZrX+VmJwUBf6c6AQ2BkKg+BYEv/LfigNSHdJDk14PE1mKaQQYgqc9Qdlc24SpFYWw6
         gqpc35tUwLjz3O0J9CW6edRs99bF9v1UYDjBSAyAiWEwWI4/ytjYKlxr/t8LWECMZ0m0
         2he3r4s1E/+mY/LcBpatlUqEzSMCjsiE2Z3AOlCscv3kE3ESwnc5eqggm587jBTVauqr
         DiFOfZl6BM/JR7wFUpypMLtFtLwdVc+yvMWjkO6ahFJRxKzyj8fpYTthB+sczX+vE2vk
         dSJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=IvT+zChRdZmo9Z/HWpUoiYO/PRDAUFPXOTb7glWeIsY=;
        b=KuLiOKCIETCty3INgW6S+k8eMLs+kNtbHWymKrnmoSBFMue+nEyym95kkSf1jZaf6d
         QyUnC0T6BOyW25jGAAs2ZPFhcSc5ou4lz5skuOj6nKrTqrHegQ+hbW1GuYxROvDJCwut
         hwwRz8corBeftyw2bdUyg+7Z6cy5McI1gZ0vZJnFskBJ1J0UAlMzFCoYOacaJmVh+Chb
         rZ14qtla3GUf1F3YLqcR2tz/rUVBXhr0reg0O/fCr85WPndoleJHQ6o76+PemtZSCvFD
         imxpoZBIDlKhBbmsjP95DBpgVgd4TuZyiKs1OgMPKoWvRPjd7siUTwlzmyFnOzSuEzun
         WyZQ==
X-Gm-Message-State: AA+aEWbzAgp3+Yk/5vKeBTLcn31TsSENd1r13CFRTIHdimjcpGe2XbIC
        RQ8BKzWXSRj/ADUgi0a8vIY=
X-Google-Smtp-Source: AFSGD/UWZtNnYRNCiXIxJzgnFcGm9DxjXJjxP1Fv0CkPfIET1qmfeSU/sg3noloNOhuJN7LOBhvrEQ==
X-Received: by 2002:a9d:1982:: with SMTP id k2mr4138813otk.197.1543608235257;
        Fri, 30 Nov 2018 12:03:55 -0800 (PST)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id q10sm2065289otl.15.2018.11.30.12.03.52
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Nov 2018 12:03:53 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     bfields@redhat.com
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org
Subject: [PATCH v2 02/10] NFS fallback to generic_copy_file_range
Date:   Fri, 30 Nov 2018 15:03:40 -0500
Message-Id: <20181130200348.59524-3-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
References: <20181130200348.59524-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If NFS unable to handle the copy then fallback to the generic VFS
copy_file_range functionality.

Also remove the offset check, as the check was added at the VFS.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 4fe9fc1..78e163a 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -139,17 +139,16 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
 
-	if (pos_in >= i_size_read(file_inode(file_in)))
-		return -EINVAL;
-
 	if (file_in->f_op != &nfs4_file_operations)
-		return -EXDEV;
+		return generic_copy_file_range(file_in, pos_in, file_out,
+					pos_out, count, flags);
 
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 
 	if (!nfs_server_capable(file_inode(file_out), NFS_CAP_COPY))
-		return -EOPNOTSUPP;
+		return generic_copy_file_range(file_in, pos_in, file_out,
+					pos_out, count, flags);
 retry:
 	if (!nfs42_files_from_same_server(file_in, file_out)) {
 		cn_resp = kzalloc(sizeof(struct nfs42_copy_notify_res),
-- 
1.8.3.1

