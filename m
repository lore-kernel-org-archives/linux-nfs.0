Return-Path: <SRS0=MwxH=TQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 137F8C04E87
	for <linux-nfs@archiver.kernel.org>; Thu, 16 May 2019 01:48:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E619720873
	for <linux-nfs@archiver.kernel.org>; Thu, 16 May 2019 01:48:20 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726998AbfEPBqg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 May 2019 21:46:36 -0400
Received: from fieldses.org ([173.255.197.46]:33072 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726999AbfEPBUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 May 2019 21:20:23 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id 5E8171E3A; Wed, 15 May 2019 21:20:23 -0400 (EDT)
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd: fh_drop_write in nfsd_unlink
Date:   Wed, 15 May 2019 21:20:08 -0400
Message-Id: <1557969619-17157-4-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1557969619-17157-1-git-send-email-bfields@redhat.com>
References: <1557969619-17157-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

fh_want_write() can now be called twice, but I'm also fixing up the
callers not to do that.

Other cases include setattr and create.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/vfs.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 7dc98e14655d..fc24ee47eab5 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1786,12 +1786,12 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 	rdentry = lookup_one_len(fname, dentry, flen);
 	host_err = PTR_ERR(rdentry);
 	if (IS_ERR(rdentry))
-		goto out_nfserr;
+		goto out_drop_write;
 
 	if (d_really_is_negative(rdentry)) {
 		dput(rdentry);
-		err = nfserr_noent;
-		goto out;
+		host_err = -ENOENT;
+		goto out_drop_write;
 	}
 
 	if (!type)
@@ -1805,6 +1805,8 @@ nfsd_unlink(struct svc_rqst *rqstp, struct svc_fh *fhp, int type,
 		host_err = commit_metadata(fhp);
 	dput(rdentry);
 
+out_drop_write:
+	fh_drop_write(fhp);
 out_nfserr:
 	err = nfserrno(host_err);
 out:
-- 
2.21.0

