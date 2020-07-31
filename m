Return-Path: <SRS0=5W3S=BK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6701DC433E0
	for <linux-nfs@archiver.kernel.org>; Fri, 31 Jul 2020 17:46:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 4C2272087C
	for <linux-nfs@archiver.kernel.org>; Fri, 31 Jul 2020 17:46:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="hQGw2lJk"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2387476AbgGaRqV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 31 Jul 2020 13:46:21 -0400
Received: from us-smtp-delivery-1.mimecast.com ([205.139.110.120]:37478 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1729018AbgGaRqV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2020 13:46:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1596217580;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding:
         in-reply-to:in-reply-to:references:references;
        bh=5rCgyPvN75bBTdUNtUGmsTPrHkuqaykQ50uu30gYKSk=;
        b=hQGw2lJkq9GumaGt4ozVgbS3W0iW8FYvJjT4VOoOwB74XqBFHa/fqCR9v9u1FtIxYY4mXI
        RqMJIi16khpU/y+8hc5mRtHdainaeXJ5xo3gSHPjGQWM8zbYat6WZ4FCWrFp8e0fATGpLL
        poH7N8shVhP94i6Wlu2JqJdzJh/AQIs=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-300-EAUx7jjSMiihieM2QmkB2g-1; Fri, 31 Jul 2020 13:46:16 -0400
X-MC-Unique: EAUx7jjSMiihieM2QmkB2g-1
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 5CD0D18839CB;
        Fri, 31 Jul 2020 17:46:15 +0000 (UTC)
Received: from aion.usersys.redhat.com (ovpn-115-198.rdu2.redhat.com [10.10.115.198])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id 43D946179C;
        Fri, 31 Jul 2020 17:46:15 +0000 (UTC)
Received: by aion.usersys.redhat.com (Postfix, from userid 1000)
        id 7BEA11A0008; Fri, 31 Jul 2020 13:46:14 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nfs: nfs_file_write() should check for writeback errors
Date:   Fri, 31 Jul 2020 13:46:14 -0400
Message-Id: <20200731174614.1299346-3-smayhew@redhat.com>
In-Reply-To: <20200731174614.1299346-1-smayhew@redhat.com>
References: <20200731174614.1299346-1-smayhew@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The NFS_CONTEXT_ERROR_WRITE flag (as well as the check of said flag) was
removed by commit 6fbda89b257f.  The absence of an error check allows
writes to be continually queued up for a server that may no longer be
able to handle them.  Fix it by adding an error check using the generic
error reporting functions.

Fixes: 6fbda89b257f ("NFS: Replace custom error reporting mechanism with
generic one")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfs/file.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index eeef6580052f..c6496f21d1e2 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -588,12 +588,14 @@ static const struct vm_operations_struct nfs_file_vm_ops = {
 	.page_mkwrite = nfs_vm_page_mkwrite,
 };
 
-static int nfs_need_check_write(struct file *filp, struct inode *inode)
+static int nfs_need_check_write(struct file *filp, struct inode *inode,
+				int error)
 {
 	struct nfs_open_context *ctx;
 
 	ctx = nfs_file_open_context(filp);
-	if (nfs_ctx_key_to_expire(ctx, inode))
+	if (nfs_error_is_fatal_on_server(error) ||
+	    nfs_ctx_key_to_expire(ctx, inode))
 		return 1;
 	return 0;
 }
@@ -604,6 +606,8 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	struct inode *inode = file_inode(file);
 	unsigned long written = 0;
 	ssize_t result;
+	errseq_t since;
+	int error;
 
 	result = nfs_key_timeout_notify(file, inode);
 	if (result)
@@ -628,6 +632,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 	if (iocb->ki_pos > i_size_read(inode))
 		nfs_revalidate_mapping(inode, file->f_mapping);
 
+	since = filemap_sample_wb_err(file->f_mapping);
 	nfs_start_io_write(inode);
 	result = generic_write_checks(iocb, from);
 	if (result > 0) {
@@ -646,7 +651,8 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 		goto out;
 
 	/* Return error values */
-	if (nfs_need_check_write(file, inode)) {
+	error = filemap_check_wb_err(file->f_mapping, since);
+	if (nfs_need_check_write(file, inode, error)) {
 		int err = nfs_wb_all(inode);
 		if (err < 0)
 			result = err;
-- 
2.25.4

