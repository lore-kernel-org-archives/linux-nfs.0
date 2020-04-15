Return-Path: <SRS0=vByh=57=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E07DCC2BA19
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:47:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id B3FDB20737
	for <linux-nfs@archiver.kernel.org>; Wed, 15 Apr 2020 12:47:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1586954830;
	bh=L0c94b19MVAUqN2/oWXuSNcZrhQ1Dm0Nd6V1dgiWk8s=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=NU6HWXq0okyxgRMeL9C441XlFPB/0p10aNlBNIeES9dy4UnVZnUtMKU+LZXd4Wk4f
	 FVX8MdmOK6Gqzv2c4c+PUhiIeQgQ9xSC23EjOvwTZ81Zi1Zblz9PI6d0U2wkUe2Ng+
	 n9KlZVwI3N4Y5ndtYjqV3HY67Ye3lUkMa4VVY/2Y=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2408966AbgDOLnK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 15 Apr 2020 07:43:10 -0400
Received: from mail.kernel.org ([198.145.29.99]:34498 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2408961AbgDOLnI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 15 Apr 2020 07:43:08 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 7E94E2137B;
        Wed, 15 Apr 2020 11:43:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1586950988;
        bh=L0c94b19MVAUqN2/oWXuSNcZrhQ1Dm0Nd6V1dgiWk8s=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=jaros32FamXqjXmou8BEAegA1Skj7yU7uUkFkndQMkChXxn7AJi3+Jw++2OwsUZfU
         s7TJ2JMlL9e6dh9Rvo9QqKusoh+fUp7cV//s8LAYnIpI/n46p9BCSEwmb3DlIPS1LS
         qqhzg96KE1oDMXl2Xvxhqp4WgIbeZgFWLip5holQ=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Misono Tomohiro <misono.tomohiro@jp.fujitsu.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.5 035/106] NFS: direct.c: Fix memory leak of dreq when nfs_get_lock_context fails
Date:   Wed, 15 Apr 2020 07:41:15 -0400
Message-Id: <20200415114226.13103-35-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200415114226.13103-1-sashal@kernel.org>
References: <20200415114226.13103-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Misono Tomohiro <misono.tomohiro@jp.fujitsu.com>

[ Upstream commit 8605cf0e852af3b2c771c18417499dc4ceed03d5 ]

When dreq is allocated by nfs_direct_req_alloc(), dreq->kref is
initialized to 2. Therefore we need to call nfs_direct_req_release()
twice to release the allocated dreq. Usually it is called in
nfs_file_direct_{read, write}() and nfs_direct_complete().

However, current code only calls nfs_direct_req_relese() once if
nfs_get_lock_context() fails in nfs_file_direct_{read, write}().
So, that case would result in memory leak.

Fix this by adding the missing call.

Signed-off-by: Misono Tomohiro <misono.tomohiro@jp.fujitsu.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/direct.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 29f00da8a0b7f..6b0bf4ebd8124 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -571,6 +571,7 @@ ssize_t nfs_file_direct_read(struct kiocb *iocb, struct iov_iter *iter)
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
+		nfs_direct_req_release(dreq);
 		goto out_release;
 	}
 	dreq->l_ctx = l_ctx;
@@ -989,6 +990,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 	l_ctx = nfs_get_lock_context(dreq->ctx);
 	if (IS_ERR(l_ctx)) {
 		result = PTR_ERR(l_ctx);
+		nfs_direct_req_release(dreq);
 		goto out_release;
 	}
 	dreq->l_ctx = l_ctx;
-- 
2.20.1

