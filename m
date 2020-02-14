Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD752C2BA83
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 17:33:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 963472082F
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 17:33:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581701618;
	bh=yBlDfK0Mudw/4zVvE2Xj4NPpTKUWG5OSwDqj4f9zWs0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=JRfarpvSdYFIOU7ogalaQs1iigfpyBBtl0fSXaCdDGPFvvxNAt4cQAE1TWuFKi97f
	 Igg51c28SKiImLjrZVd9cpevaC5KMznFaOhZxFtHoIYOM4SndmX/VL33wvW4LQNFO9
	 W/Ac5yHjEeKkAhHTkJEzxuKFZ2/2s4VJE/7rNy4U=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2390203AbgBNQGU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 11:06:20 -0500
Received: from mail.kernel.org ([198.145.29.99]:56754 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2390386AbgBNQGU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 11:06:20 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id B64042187F;
        Fri, 14 Feb 2020 16:06:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581696379;
        bh=yBlDfK0Mudw/4zVvE2Xj4NPpTKUWG5OSwDqj4f9zWs0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=XVLofO0E5D9EVGi3knAChFC/mcSIHtDDMSg62n3WjO6gikX2m23BmuonRpYpZv8iG
         be5CG4fx+8X7RYZFmZ0PyHlMdTuugPT09AKuAC9sBNbfTqNqktJ52DideX399RY+YY
         BuUPgFR4Vc6mDtbRAHnnljy7NKn+NLA6oX5ck3YI=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Dave Chinner <david@fromorbit.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        "J . Bruce Fields" <bfields@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 207/459] nfsd: Clone should commit src file metadata too
Date:   Fri, 14 Feb 2020 10:57:37 -0500
Message-Id: <20200214160149.11681-207-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200214160149.11681-1-sashal@kernel.org>
References: <20200214160149.11681-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit 57f64034966fb945fc958f95f0c51e47af590344 ]

vfs_clone_file_range() can modify the metadata on the source file too,
so we need to commit that to stable storage as well.

Reported-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Acked-by: Dave Chinner <david@fromorbit.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/vfs.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index fc38b9fe45495..005d1802ab40e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -280,19 +280,25 @@ nfsd_lookup(struct svc_rqst *rqstp, struct svc_fh *fhp, const char *name,
  * Commit metadata changes to stable storage.
  */
 static int
-commit_metadata(struct svc_fh *fhp)
+commit_inode_metadata(struct inode *inode)
 {
-	struct inode *inode = d_inode(fhp->fh_dentry);
 	const struct export_operations *export_ops = inode->i_sb->s_export_op;
 
-	if (!EX_ISSYNC(fhp->fh_export))
-		return 0;
-
 	if (export_ops->commit_metadata)
 		return export_ops->commit_metadata(inode);
 	return sync_inode_metadata(inode, 1);
 }
 
+static int
+commit_metadata(struct svc_fh *fhp)
+{
+	struct inode *inode = d_inode(fhp->fh_dentry);
+
+	if (!EX_ISSYNC(fhp->fh_export))
+		return 0;
+	return commit_inode_metadata(inode);
+}
+
 /*
  * Go over the attributes and take care of the small differences between
  * NFS semantics and what Linux expects.
@@ -537,6 +543,9 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 	if (sync) {
 		loff_t dst_end = count ? dst_pos + count - 1 : LLONG_MAX;
 		int status = vfs_fsync_range(dst, dst_pos, dst_end, 0);
+
+		if (!status)
+			status = commit_inode_metadata(file_inode(src));
 		if (status < 0)
 			return nfserrno(status);
 	}
-- 
2.20.1

