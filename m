Return-Path: <SRS0=9d91=NE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13316ECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CC06920832
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Oct 2018 19:58:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="jb0CWUnp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC06920832
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727381AbeJYE2M (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Oct 2018 00:28:12 -0400
Received: from mail-qt1-f195.google.com ([209.85.160.195]:44736 "EHLO
        mail-qt1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbeJYE2L (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 25 Oct 2018 00:28:11 -0400
Received: by mail-qt1-f195.google.com with SMTP id o17-v6so1409283qtq.11;
        Wed, 24 Oct 2018 12:58:44 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=D3Oki5BmKEd8nnsyx5CzmdHvMrAIdEpQvYy6/1wa7ko=;
        b=jb0CWUnpA+Q1EPxxDQdk98QHV1OqqAEJQScocoKZMks9O2+VTMGD56MZS3Hv78yGqm
         ZheLtgj6XnlcjevVWnxydz+nBY8GSOMQw5zcQDseBBJ3Vc9JURMty2KlfIko8XEREVkZ
         zHzCxzDxvHW9UHkamJenSAEoc2X/2hBBp+BHXJCfkLJt5ka4gK7C/p1eeHcDOGGeRiSV
         POfU0BKMhbSeVk4BJYPs5r8bHPGyTcNSihG5GNaMibhzT2OsccpjcvDvnXhASekV73Fm
         x16buNRIWLNjL8jViPycQXsxF1crLDlGeMdeF56VxxtcszyB112LCRe+Mk/ayvww0d4y
         x4iw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=D3Oki5BmKEd8nnsyx5CzmdHvMrAIdEpQvYy6/1wa7ko=;
        b=HuadWFsYurlChmGyJICT9EJC5NqFkFQ4tTfzuO3pkI2Nc5LrSyAIir0ZtEWd20iYH9
         GIKRn5fYmT38skNXhgRGU2Lu0Qlc7Bkxao1AdnAkVTVFhw5BJvwScXJNZdIhFkOxXoHz
         i+I7EFAQ2FTtti7oGzNzczsK7mTDOkgJGrOdf2kbv9fFC2rUAnPRKcU2qMsvvCOM4op+
         rMhjHIKM2IEdbIRrQavYrtNCc6xllcC4F39L3+KWbILoebKXaQVwDRxYXW146Mkauob/
         KgX+zAYQkuQ+8fd+pQzgUWDiKlBzN49HA/OzUfxeRTXXG9jOuUN1M6Djj7NFL1P4x3tH
         s8AA==
X-Gm-Message-State: AGRZ1gJ6gpAT2bVgLpS9XyP95HVeCf5AZz7AnR+DhWGRLS0ij2RMAeYb
        jhCSJcZhRP2I6quRHTuVgeU=
X-Google-Smtp-Source: AJdET5eAH7+PcHTv/btAPvMM9L283QOjCm3exyEBenGY7N7+Lv6PP6xR6lN4ZArSM7wKPIVXbla5vw==
X-Received: by 2002:aed:33a7:: with SMTP id v36-v6mr3326728qtd.267.1540411124255;
        Wed, 24 Oct 2018 12:58:44 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id d124-v6sm3872380qkf.85.2018.10.24.12.58.43
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 24 Oct 2018 12:58:43 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v2 02/13] CIFS: add cross-device check for copy_file_range
Date:   Wed, 24 Oct 2018 15:58:26 -0400
Message-Id: <20181024195837.35532-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
References: <20181024195837.35532-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

VFS copy_file_range was relaxed to allow for cross-device copy.
Add a check for now, to disallow cross-device copy offload until
appropriate support is added.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/cifs/cifsfs.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 7065426..1f41e74 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -1114,6 +1114,8 @@ static ssize_t cifs_copy_file_range(struct file *src_file, loff_t off,
 	unsigned int xid = get_xid();
 	ssize_t rc;
 
+	if (src_file->f_inode->i_sb != dst_file->f_inode->i_sb)
+		return -EXDEV;
 	rc = cifs_file_copychunk_range(xid, src_file, off, dst_file, destoff,
 					len, flags);
 	free_xid(xid);
-- 
1.8.3.1

