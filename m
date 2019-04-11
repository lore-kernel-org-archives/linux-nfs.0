Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42489C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:27:57 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 0D3A52133D
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 16:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="b6YPHZEB"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726536AbfDKQ14 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 12:27:56 -0400
Received: from mail-yw1-f68.google.com ([209.85.161.68]:36404 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726264AbfDKQ14 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 12:27:56 -0400
Received: by mail-yw1-f68.google.com with SMTP id u197so2283646ywf.3
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 09:27:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=N4Jdg0FEpMUQlut5JKMsC7NOF920ZqV+sp4wA7FnW14=;
        b=b6YPHZEBRsfK44O0QwF8j2jXKlG9Unjqr+uUIQe9SHMOxCtRiXwrOcf2S7/mXtM2cf
         c1SdGY92Z74oOn5i8KQEcJXQmYSd/XF1N/l/cIxRjjihL5uqhl6gnZ8ibgl6h4qPL9mE
         iUHpVXm3Vm1iSe8v93hfWnWiFhhR1rHwD2odxS5CA8t9kS0sFwUYE4/ZEml19EuWcTp9
         LyRwawf8Sno7oNakeU15UchMzp5akmeIaORoYJnLeg6m92gHPSasNTDCdemGSVe8ih8B
         tPphySzYN+ncze4UJbj//QhR6kk9Cfkte5F4N1jXNnJyHCtMXy6FOuXfczBC3OozBpLL
         x77g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=N4Jdg0FEpMUQlut5JKMsC7NOF920ZqV+sp4wA7FnW14=;
        b=A3aSOIi3eTrW7HowNw+lkyJBit2s4Wpn1WQaFnHPYuipztWWo66O3jmIttxBG96Ra1
         qUsFUnmj8ak9dQLx5yGOwDGRjgw1UhJGqoSznkOA1EyRA+P+sFR0N9RUKfS9qJK74yEU
         AIpAwAu+Ojcd/rfl9nY2Xt/RfblxRiDYMWVhIsGGONDPrKEkM9RjzmhQDfhZsGdxs5h4
         kFreRfDoVmf2e2CT5RvB5JfPeavyXH9I8ZYnX1P8N+uTkhlC5kkOaCJbFcRc3AyQ6svs
         Yq/8A83vQbz6fhoRpE1P3ENRIeuI+UZC37glQkkUGyMLMZs7icR9ZIOhGti4aq+LkNiZ
         TnIw==
X-Gm-Message-State: APjAAAUxwXB/DdYACh8ZWSR/O51zPhwnbWuBCYGLV/Fr9+d1DTShbYiT
        Iz4uax/2dAkiytmDacstJe8=
X-Google-Smtp-Source: APXvYqxc6PPyOH12JxTHujR85JOcrLUmMZ70XE6EPTTIp5TyXV802QwEAUGHq4LDDfrcdBD+14qSNA==
X-Received: by 2002:a81:344b:: with SMTP id b72mr40393477ywa.38.1555000075283;
        Thu, 11 Apr 2019 09:27:55 -0700 (PDT)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id k189sm13331150ywa.48.2019.04.11.09.27.54
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Apr 2019 09:27:54 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.1 fix incorrect return value in copy_file_range
Date:   Thu, 11 Apr 2019 12:27:47 -0400
Message-Id: <20190411162747.4360-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

When VFS calls copy_file_range on a 4.0 mount (and when in and out
file is the same), we need to return ENOTSUPP instead of EINVAL.
Since no COPY operation is defined in 4.0, then like 3.0, it should
fallback to doing do_splice_direct().

Otherwise xfstest generic/075,091,112,263 fail.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 45b2322..9a222b0 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,6 +133,12 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
+	struct nfs_server *server = NFS_SERVER(file_inode(file_in);
+	struct nfs_client *client = server->nfs_client;
+
+	if (client->cl_minorversion < 1)
+		return -EOPNOTSUPP;
+
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
 	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
-- 
1.8.3.1

