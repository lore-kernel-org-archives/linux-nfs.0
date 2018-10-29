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
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8696C2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8617D2082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ceA7t9Hx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8617D2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727727AbeJ3Cao (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:44 -0400
Received: from mail-qk1-f194.google.com ([209.85.222.194]:34909 "EHLO
        mail-qk1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726330AbeJ3Can (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:43 -0400
Received: by mail-qk1-f194.google.com with SMTP id v68-v6so5476548qka.2;
        Mon, 29 Oct 2018 10:41:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=zRxwbIgi/nx4F/08g2W9WJaMoLvFn8Iu27inV//7XF0=;
        b=ceA7t9HxW4jDusqAbre11zG+DExfHQckhjpqyIrPyYLKB5PTzHG5HHDP1CHOcMe1dU
         wxmf/ONl57Po59DZK6rhEK6amKU9R1ewN71Mtl5g/snNJ3RVloGU4xJq7yqK8VCE6wk6
         qshENUnrKH/I5CRUbf11+ZvpbV0hBeKrxoyVSYkmsBmK+R0B3zNer7L2T3gHfANjcTEY
         zf/CpfY/WofHwlYAZUuK+FuinKu2wlJSiJSpRRhIf/p0ErGxsmOMOP3yUXSc8Qy6jGCm
         87l6/oP+B4etOGzk90QdQuW4DQZZynhoMaAPcRi4p3/0UJz4xb2rzKB/+EBdjF00Vj0d
         veUQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=zRxwbIgi/nx4F/08g2W9WJaMoLvFn8Iu27inV//7XF0=;
        b=kqySjfztgvGHtrzQiwmJ7piujUjbd29y+ZBbqmBEmWMankOfLOVxDniRIIDfXPMoRy
         O1kHxKCToIMAPXTqhhF4LEHll7PS2OfN4wBI54RfSufl6S5ChnH8ReUXtosS9ZQT2J1H
         t7oWJ/h47TtAc/2f7w0/hUgFSofNnV4pVANzPhl+woi2ePsoCPcygdbE84463VRDVhki
         oMaqoa6iTtCI7EJL9mFyyOGB6o2ce+K5NEG1T5nGZMFfm0MLhImIcqOK5WJbjQ4uKmQz
         sssZk6RxqWHl7aVGCpNbPkZcxVEdKFjzGFl54diI5eizDpaHy6nrPv1k1iUbp5bfkNmx
         s7bQ==
X-Gm-Message-State: AGRZ1gJALmUdlw4/YPa2ylzB19T7nUejMKliYu2ctvrFmLcQWqXWG0Ci
        yRivxBZjag/e5IKwIdkGkBo=
X-Google-Smtp-Source: AJdET5clmZ4KkA1z1jTzMW7SGVitgJuL0Mcvzbkvw8WUNnfMha7xN/I4DtmTDCZ3cyxDVDJRAK0Dtg==
X-Received: by 2002:a37:a5d1:: with SMTP id o200mr12943420qke.328.1540834866347;
        Mon, 29 Oct 2018 10:41:06 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.04
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:05 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v5 02/12] VFS: generic cross-device copy_file_range() support for all filesystems
Date:   Mon, 29 Oct 2018 13:40:49 -0400
Message-Id: <20181029174059.38326-4-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

If a filesystem does not support cross device or cross file system
type copy offload functionality, then this patch provides a fallback
to a page cache based physical data copy. This means the
copy_file_range() systemcall will never fail with EXDEV, and so in
future userspace will not need to detect or provide a fallback for
failed cross-device copies anymore.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 7a912e3..cff59bd 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1597,7 +1597,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	if (file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
-		if (ret != -EOPNOTSUPP)
+		if (ret != -EOPNOTSUPP && ret != -EXDEV)
 			goto done;
 	}
 
-- 
1.8.3.1

