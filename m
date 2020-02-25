Return-Path: <SRS0=o0xo=4N=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 94D95C35E01
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Feb 2020 16:05:30 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 60B0C2072D
	for <linux-nfs@archiver.kernel.org>; Tue, 25 Feb 2020 16:05:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="O2sGtDN0"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730109AbgBYQFa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 25 Feb 2020 11:05:30 -0500
Received: from us-smtp-1.mimecast.com ([205.139.110.61]:33068 "EHLO
        us-smtp-delivery-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1729817AbgBYQF3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Feb 2020 11:05:29 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1582646728;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=xEdDe2YU6HIeVPbCkZYGRxJ42NwXkF9k9DLr8ppHRtg=;
        b=O2sGtDN038hl55XOjnTWQJdbs2QnLu/wRt7iggqTTBz81HYyyIM6kZeSrOx4HOhbOQm4EL
        81vupDYjx1K8s6YTwCvt25I0g0jFFfdL0ZPmEWM0N0e0WyHI1ukuTe8mQ1ALIzWt2R9Rba
        sC/WnHzyQmm/tVaDfnd0Dp8lK3mdl08=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-206-8ROBD5zjNdyqaw0Oeudz9g-1; Tue, 25 Feb 2020 11:05:24 -0500
X-MC-Unique: 8ROBD5zjNdyqaw0Oeudz9g-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 448FD800D54;
        Tue, 25 Feb 2020 16:05:23 +0000 (UTC)
Received: from aion.usersys.redhat.com (ovpn-123-59.rdu2.redhat.com [10.10.123.59])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id EB1918AC30;
        Tue, 25 Feb 2020 16:05:22 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id 53A871A2C29; Tue, 25 Feb 2020 11:05:22 -0500 (EST)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     syzbot <syzbot+193c375dcddb4f345091@syzkaller.appspotmail.com>,
        syzkaller-bugs@googlegroups.com, linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix leak of ctx->nfs_server.hostname
Date:   Tue, 25 Feb 2020 11:05:22 -0500
Message-Id: <20200225160522.225406-1-smayhew@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If userspace passes an nfs_mount_data struct in the data argument of
mount(2), then nfs23_parse_monolithic() or nfs4_parse_monolithic()
will allocate memory for ctx->nfs_server.hostname.  This needs to be
freed in nfs_parse_source(), which also allocates memory for
ctx->nfs_server.hostname, otherwise a leak will occur.

Reported-by: syzbot+193c375dcddb4f345091@syzkaller.appspotmail.com
Fixes: f2aedb713c28 ("NFS: Add fs_context support.")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/fs_context.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index b616263b0eb6..e113fcb4bb4c 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -832,6 +832,8 @@ static int nfs_parse_source(struct fs_context *fc,
 	if (len > maxnamlen)
 		goto out_hostname;
=20
+	kfree(ctx->nfs_server.hostname);
+
 	/* N.B. caller will free nfs_server.hostname in all cases */
 	ctx->nfs_server.hostname =3D kmemdup_nul(dev_name, len, GFP_KERNEL);
 	if (!ctx->nfs_server.hostname)
--=20
2.24.1

