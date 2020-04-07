Return-Path: <SRS0=uC47=5X=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C059C2BB86
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Apr 2020 14:31:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 515502072A
	for <linux-nfs@archiver.kernel.org>; Tue,  7 Apr 2020 14:31:28 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729183AbgDGOb1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 7 Apr 2020 10:31:27 -0400
Received: from nibbler.cm4all.net ([82.165.145.151]:47597 "EHLO
        nibbler.cm4all.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729133AbgDGOb1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Apr 2020 10:31:27 -0400
Received: from localhost (localhost [127.0.0.1])
        by nibbler.cm4all.net (Postfix) with ESMTP id DD62EC0271
        for <linux-nfs@vger.kernel.org>; Tue,  7 Apr 2020 16:23:09 +0200 (CEST)
X-Virus-Scanned: Debian amavisd-new at nibbler.cm4all.net
Received: from nibbler.cm4all.net ([127.0.0.1])
        by localhost (nibbler.cm4all.net [127.0.0.1]) (amavisd-new, port 10024)
        with LMTP id H3_HMP2AIIPM for <linux-nfs@vger.kernel.org>;
        Tue,  7 Apr 2020 16:23:09 +0200 (CEST)
Received: from zero.intern.cm-ag (zero.intern.cm-ag [172.30.16.10])
        by nibbler.cm4all.net (Postfix) with SMTP id A7366C02C8
        for <linux-nfs@vger.kernel.org>; Tue,  7 Apr 2020 16:23:09 +0200 (CEST)
Received: (qmail 19706 invoked from network); 7 Apr 2020 17:35:22 +0200
Received: from unknown (HELO rabbit.intern.cm-ag) (172.30.3.1)
  by zero.intern.cm-ag with SMTP; 7 Apr 2020 17:35:22 +0200
Received: by rabbit.intern.cm-ag (Postfix, from userid 1023)
        id 7F4A246143D; Tue,  7 Apr 2020 16:23:09 +0200 (CEST)
From:   Max Kellermann <mk@cm4all.com>
To:     linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        trond.myklebust@hammerspace.com
Cc:     bfields@redhat.com, tytso@mit.edu, viro@zeniv.linux.org.uk,
        agruenba@redhat.com, linux-kernel@vger.kernel.org,
        Max Kellermann <mk@cm4all.com>, stable@vger.kernel.org
Subject: [PATCH v3 4/4] nfs/super: check NFS_CAP_ACLS instead of the NFS version
Date:   Tue,  7 Apr 2020 16:22:43 +0200
Message-Id: <20200407142243.2032-4-mk@cm4all.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200407142243.2032-1-mk@cm4all.com>
References: <20200407142243.2032-1-mk@cm4all.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This sets SB_POSIXACL only if ACL support is really enabled, instead
of always setting SB_POSIXACL if the NFS protocol version
theoretically supports ACL.

The code comment says "We will [apply the umask] ourselves", but that
happens in posix_acl_create() only if the kernel has POSIX ACL
support.  Without it, posix_acl_create() is an empty dummy function.

So let's not pretend we will apply the umask if we can already know
that we will never.

This fixes a problem where the umask is always ignored in the NFS
client when compiled without CONFIG_FS_POSIX_ACL.  This is a 4 year
old regression caused by commit 013cdf1088d723 which itself was not
completely wrong, but failed to consider all the side effects by
misdesigned VFS code.

Signed-off-by: Max Kellermann <mk@cm4all.com>
Reviewed-by: J. Bruce Fields <bfields@redhat.com>
Cc: stable@vger.kernel.org
---
 fs/nfs/super.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index dada09b391c6..dab79193f641 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -977,11 +977,14 @@ static void nfs_fill_super(struct super_block *sb, struct nfs_fs_context *ctx)
 	if (ctx && ctx->bsize)
 		sb->s_blocksize = nfs_block_size(ctx->bsize, &sb->s_blocksize_bits);
 
-	if (server->nfs_client->rpc_ops->version != 2) {
+	if (NFS_SB(sb)->caps & NFS_CAP_ACLS) {
 		/* The VFS shouldn't apply the umask to mode bits. We will do
 		 * so ourselves when necessary.
 		 */
 		sb->s_flags |= SB_POSIXACL;
+	}
+
+	if (server->nfs_client->rpc_ops->version != 2) {
 		sb->s_time_gran = 1;
 		sb->s_export_op = &nfs_export_ops;
 	} else
-- 
2.20.1

