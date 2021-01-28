Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.0 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_CR_TRAILER,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4BBE5C433E9
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Jan 2021 14:58:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id EEA2764DE5
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Jan 2021 14:58:06 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231924AbhA1O5l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Jan 2021 09:57:41 -0500
Received: from us-smtp-delivery-124.mimecast.com ([63.128.21.124]:46863 "EHLO
        us-smtp-delivery-124.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S231932AbhA1O4k (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Jan 2021 09:56:40 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1611845714;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:in-reply-to:in-reply-to:references:references;
        bh=y1kmH+B7NLmOeBWZSsj7F/0dKzsLTNAZN/u+CN4Js9M=;
        b=AYNYF12IFd2/9hX0Oo4Ej9hMj1sEVqC7LKZijo53hVDpp2aN1vRqoseNSjVq90WPYPKfGw
        Sj5Xrdp1JKZU53vZ/z0Qgubs6AbnKZqiAcm1LU2PQ/SRECTX3QVwWfXqcYGK63C2UN9Ynh
        IurjI4/NBVQ865W9pEFIgTfrAorzXYo=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-492-3n7Z3wnhPmmHNCeHUowMHQ-1; Thu, 28 Jan 2021 09:55:12 -0500
X-MC-Unique: 3n7Z3wnhPmmHNCeHUowMHQ-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 2DAA29CDAF;
        Thu, 28 Jan 2021 14:55:11 +0000 (UTC)
Received: from dwysocha.rdu.csb (ovpn-112-111.rdu2.redhat.com [10.10.112.111])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id BF591179B3;
        Thu, 28 Jan 2021 14:55:10 +0000 (UTC)
From:   Dave Wysochanski <dwysocha@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 02/10] NFS: In nfs_readpage() only increment NFSIOS_READPAGES when read succeeds
Date:   Thu, 28 Jan 2021 09:55:00 -0500
Message-Id: <1611845708-6752-3-git-send-email-dwysocha@redhat.com>
In-Reply-To: <1611845708-6752-1-git-send-email-dwysocha@redhat.com>
References: <1611845708-6752-1-git-send-email-dwysocha@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

There is a small inconsistency with nfs_readpage() vs nfs_readpages() with
regards to NFSIOS_READPAGES.  In readpage we unconditionally increment
NFSIOS_READPAGES at the top, which means even if the read fails.  In
readpages, we increment NFSIOS_READPAGES at the bottom based on how
many pages were successfully read.  Change readpage to be consistent with
readpages and so NFSIOS_READPAGES only reflects successful, non-fscache
reads.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 fs/nfs/read.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index dd92156e27c5..464077daf62f 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -319,7 +319,6 @@ int nfs_readpage(struct file *file, struct page *page)
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
 		page, PAGE_SIZE, page_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
-	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
 	/*
 	 * Try to flush any pending writes to the file..
@@ -359,6 +358,7 @@ int nfs_readpage(struct file *file, struct page *page)
 		if (!PageUptodate(page) && !ret)
 			ret = xchg(&ctx->error, 0);
 	}
+	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 out:
 	put_nfs_open_context(ctx);
 	return ret;
-- 
1.8.3.1

