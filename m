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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 16A32C0044C
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D76722082B
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 17:41:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="JdM95rlG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D76722082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727991AbeJ3Cak (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 22:30:40 -0400
Received: from mail-qk1-f193.google.com ([209.85.222.193]:44747 "EHLO
        mail-qk1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727988AbeJ3Cak (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 22:30:40 -0400
Received: by mail-qk1-f193.google.com with SMTP id n12so5450454qkh.11;
        Mon, 29 Oct 2018 10:41:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=k6kHDi/G4VXAWe0Fwif0qGkn8F6UDS8N2NPKlrgg+Dk=;
        b=JdM95rlG/P3XhZyykf51LnONduhvJoZw4GLuVpNHoYwCPBK80b+e2CTwrPMNOps8lY
         DC1dtPgfFkZvjAi8LzoNFZwblxZUP8UaIicPzPUmTcOCbu8lPqWEIVCVLgobldCxwxbS
         8rHxkMcZH6sHkJuTUlIN9dHqSaWZDxQuV+SFFOzHCxCPGq3IbbeMIrJLJTXl+zYHGhAq
         828Q8PO/gu9Si1+gCO5qXz3ldEYD6C2fNOQz17tkRDPVBkQKPn5nqZmReVJXJ4B+z1Yn
         49W2Cxyh4T0U0lW9R8ubGYkBC1Ngg1vZXI49btIS01B3MgjYig2ZCNFmEiiE7OhnPZOA
         G13A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=k6kHDi/G4VXAWe0Fwif0qGkn8F6UDS8N2NPKlrgg+Dk=;
        b=kMNTfdTlDKSEuDdP8+KNaN5ogrV70w6rQsqJH/6pRgL/RiY1WXT+Mv6QTcAPeRP1fC
         3xCuOLMrWJb4PJJ7FAShTlSpHZ7olL3jcAoGT6jhtAl4YwCcbO1B8Vua2BvrUb42BAsl
         PaV6mJYGBkcV/CPmW4HochByFBM/hnSv8rHthiDaBoUQNVm/5ROcC/ly/j+IvRY2DSQN
         PmDTaIQA3150DqniGzrAw+JM+HzGbXnAlZykyr7Qt2EGeIeKjhpiokiHc0EvApippPBL
         QGNnu2wXmWgGf1hDMjb1z/tYlXOHaQzBfNSFI1p5sILEB3RQBzU9D5uXfZYYX4s2u006
         Rmmw==
X-Gm-Message-State: AGRZ1gKAdgLzfEAaIGMA8qqMkfm+EuCHUZFgWgbTEZDwmhIk0pIyvMpg
        omklOat957S0KHY9IcnNw3DShp0x
X-Google-Smtp-Source: AJdET5e0UAjtMwQ00OEWkSVgd0LDA+fnEfzTcoSZO51sdezu4gDC9vcD/6BjFcs/S2bcqP7c2RLoEw==
X-Received: by 2002:a37:91c2:: with SMTP id t185-v6mr7539438qkd.223.1540834863054;
        Mon, 29 Oct 2018 10:41:03 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id n190-v6sm13148929qkb.29.2018.10.29.10.41.01
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 10:41:02 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH 1/1] NFSv4: cleanup remove unused nfs4_xdev_fs_type
Date:   Mon, 29 Oct 2018 13:40:47 -0400
Message-Id: <20181029174059.38326-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
References: <20181029174059.38326-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

commit e8f25e6d6d19 "NFS: Remove the NFS v4 xdev mount function"
removed the last use of this.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/internal.h | 1 -
 1 file changed, 1 deletion(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 8357ff6..ecb6d43 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -395,7 +395,6 @@ int nfs_rename(struct inode *, struct dentry *,
 extern struct file_system_type nfs_fs_type;
 extern struct file_system_type nfs_xdev_fs_type;
 #if IS_ENABLED(CONFIG_NFS_V4)
-extern struct file_system_type nfs4_xdev_fs_type;
 extern struct file_system_type nfs4_referral_fs_type;
 #endif
 bool nfs_auth_info_match(const struct nfs_auth_info *, rpc_authflavor_t);
-- 
1.8.3.1

