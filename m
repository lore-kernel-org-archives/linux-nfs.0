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
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0E91C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BA67C2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Ye7eYx1A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA67C2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728141AbeJ3Ca7 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:59 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:33945 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1728129AbeJ3Ca6 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:58 -0400
Received: by mail-qt1-f196.google.com with SMTP id z2-v6so10273762qts.1;
        Mon, 29 Oct 2018 10:41:22 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=lJ465V0VE4A4er/zz+WqgIGq+JkN4aV47yHUTEvfu9c=;
        b=Ye7eYx1Au4cdqnNXHvvwHa+1lgk+EnVVJwLEr8erT3gHOuXgTwF77SnQzObuQrx412
         R/szSCTUfPonYIBqSIup6UepwImG4tKABhX5QhOYE92a0b1o8rVCKLMvi9Qchl3Pdk+B
         HscHNA1FL76cB5+qqQg/pYcVRJz7pEC8+i5RWcnxTcNC7321TK50HR+I8YRh8oSs5utZ
         N8QlUm8D8uEclzofWs4wTiASq3i47zZO21hENmnL+YNBauncr6+CvXdPZW1OcxbYowV/
         4/kwu/XLBHHz9+dDLksuptnd8L9Hx1Kn1MSWf6HRzVPJq3/Q/jLSN2hg205k3zSeXHFj
         8SQg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=lJ465V0VE4A4er/zz+WqgIGq+JkN4aV47yHUTEvfu9c=;
        b=eN0x1u7EbPNC3OhBL9rWiAkejroEoTz6Ys6IhSvzUIEp3qxJju+u0mcZjAAEfLm76Q
         yGwll1pc/tvzbDsc0nOPY/x4YD9ag737mCO9YBAWM1Wsm++DjsPDkI6w6CCptl8VYw9S
         JpF39/S9I46y50JtNjzrk+hPac+c+2qaXmdWSVsDxpfgKidWzWeiG6ZqbZc0jriHl8Zz
         h86EIPkboaG77EAn322aDXXn7xXBHujpmFN6zGeXoQtOEXvhYjDFGYBtZkCJZMoG0TnU
         H/7aYAiD44JgHQ+oZeDPnctxJyCzW1NwDduMZasdYr83oTjYJ7vZIB/6smjMDJRjo2ts
         8Kow==
X-Gm-Message-State: AGRZ1gJ3/ZwknoWytXXAu8xzevEqx0oAj/BzX76Zs09Jqet05Y3k4ZU9
        KqLgsLJ6V0saW5Z4uaZazts=
X-Google-Smtp-Source: AJdET5eFCpUGEyckPjYWnyhRWKOxDc75uzQ9Wq6sKZOhIFw5S6OOA7GulYt29Ip3r5r+QpYhQhGmuw==
X-Received: by 2002:ac8:2729:: with SMTP id g38-v6mr14148691qtg.168.1540834881642;
        Mon, 29 Oct 2018 10:41:21 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.20
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:21 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 12/12] NFS: replace cross device check in copy_file_range
Date:   Mon, 29 Oct 2018 13:40:59 -0400
Message-Id: <20181029174059.38326-14-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
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
 fs/nfs/nfs4file.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 989f174..fde4465 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -138,11 +138,16 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 	struct nl4_server *nss = NULL;
 	nfs4_stateid *cnrs = NULL;
 	ssize_t ret;
+	struct nfs_client *c_in;
 
 	if (pos_in >= i_size_read(file_inode(file_in)))
 		return -EINVAL;
 
-	if (file_inode(file_in)->i_sb != file_inode(file_out)->i_sb)
+	if (file_in->f_op != &nfs4_file_operations)
+		return -EXDEV;
+
+	c_in = (NFS_SERVER(file_inode(file_in)))->nfs_client;
+	if (c_in->cl_minorversion < 2)
 		return -EXDEV;
 
 	if (file_inode(file_in) == file_inode(file_out))
-- 
1.8.3.1

