Return-Path: <SRS0=DjVz=QD=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 630D1C282CA
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Jan 2019 15:19:50 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28F602148D
	for <linux-nfs@archiver.kernel.org>; Sun, 27 Jan 2019 15:19:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726354AbfA0PTt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 27 Jan 2019 10:19:49 -0500
Received: from mx1.redhat.com ([209.132.183.28]:33534 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726344AbfA0PTt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sun, 27 Jan 2019 10:19:49 -0500
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 2F1DE2DD2B;
        Sun, 27 Jan 2019 15:19:49 +0000 (UTC)
Received: from bcodding.csb (ovpn-112-23.rdu2.redhat.com [10.10.112.23])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 92F425D736;
        Sun, 27 Jan 2019 15:19:48 +0000 (UTC)
Received: by bcodding.csb (Postfix, from userid 24008)
        id AFABD10C30F3; Sun, 27 Jan 2019 10:19:47 -0500 (EST)
From:   Benjamin Coddington <bcodding@redhat.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Always return the error that truncates a flushing page
Date:   Sun, 27 Jan 2019 10:19:47 -0500
Message-Id: <1cbf359e173a9f93e7c858faa43e623dda3858df.1548602308.git.bcodding@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Sun, 27 Jan 2019 15:19:49 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

We can't have nfs_wb_page() truncate the page from the mapping if there's
an error on the context without returning that error, because we may be in
nfs_updatepage() holding the page and trying to update the request.  Not
having any error returned means we'll proceed to create a new request and
dereference the truncated page->mapping.

If we're going to remove the page, always return the error that signaled us
to do so in nfs_page_async_flush().

Fixes: c373fff7bd25 ("NFSv4: Don't special case "launder"")
Cc: stable@vger.kernel.org # v4.11
Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfs/write.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5a0bbf917a32..c274339176cc 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -622,9 +622,11 @@ static int nfs_page_async_flush(struct nfs_pageio_descriptor *pgio,
 	WARN_ON_ONCE(test_bit(PG_CLEAN, &req->wb_flags));
 
 	ret = 0;
-	/* If there is a fatal error that covers this write, just exit */
-	if (nfs_error_is_fatal_on_server(req->wb_context->error))
+	/* If there is a fatal on server error on this context, just exit */
+	if (nfs_error_is_fatal_on_server(req->wb_context->error)) {
+		ret = req->wb_context->error;
 		goto out_launder;
+	}
 
 	if (!nfs_pageio_add_request(pgio, req)) {
 		ret = pgio->pg_error;
-- 
2.14.3

