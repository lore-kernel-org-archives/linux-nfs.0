Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 00258C54EE9
	for <linux-nfs@archiver.kernel.org>; Thu,  8 Sep 2022 22:14:31 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229728AbiIHWOa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 8 Sep 2022 18:14:30 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54324 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229891AbiIHWO3 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Sep 2022 18:14:29 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B5FC0F0F
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 15:14:27 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 53E7B61D99
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 22:14:27 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A783BC433C1
        for <linux-nfs@vger.kernel.org>; Thu,  8 Sep 2022 22:14:26 +0000 (UTC)
Subject: [PATCH v4 8/8] NFSD: Make nfsd4_remove() wait before returning
 NFS4ERR_DELAY
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Thu, 08 Sep 2022 18:14:25 -0400
Message-ID: <166267526571.1842.11502743715868609327.stgit@manet.1015granger.net>
In-Reply-To: <166267495153.1842.14474564029477470642.stgit@manet.1015granger.net>
References: <166267495153.1842.14474564029477470642.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfsd_unlink() can kick off a CB_RECALL (via
vfs_unlink() -> leases_conflict()) if a delegation is present.
Before returning NFS4ERR_DELAY, give the client holding that
delegation a chance to return it and then retry the nfsd_unlink()
again, once.

Link: https://bugzilla.linux-nfs.org/show_bug.cgi?id=354
Tested-by: Igor Mammedov <imammedo@redhat.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/vfs.c |   11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index b597cb2af949..adb2624eca64 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1773,9 +1773,18 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 
 	fh_fill_pre_attrs(fhp);
 	if (type != S_IFDIR) {
+		int retries;
+
 		if (rdentry->d_sb->s_export_op->flags & EXPORT_OP_CLOSE_BEFORE_UNLINK)
 			nfsd_close_cached_files(rdentry);
-		host_err = vfs_unlink(&init_user_ns, dirp, rdentry, NULL);
+
+		for (retries = 1;;) {
+			host_err = vfs_unlink(&init_user_ns, dirp, rdentry, NULL);
+			if (host_err != -EAGAIN || !retries--)
+				break;
+			if (!nfsd_wait_for_delegreturn(rqstp, rinode))
+				break;
+		}
 	} else {
 		host_err = vfs_rmdir(&init_user_ns, dirp, rdentry);
 	}


