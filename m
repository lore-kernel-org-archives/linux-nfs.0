Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 95946C2BB84
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 01:00:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6EB8864FAB
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 01:00:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231938AbhCQBAC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Mar 2021 21:00:02 -0400
Received: from mail.kernel.org ([198.145.29.99]:36102 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232235AbhCQA7B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Mar 2021 20:59:01 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 46AD764FFD;
        Wed, 17 Mar 2021 00:58:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1615942724;
        bh=+3BuXxYaXsFpdLnpNv938r7h4FCYprLWZIvWS455Uv8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Dm6xA++8uco461bCANGzfSScxweBwo0midiyd1rFri4AX/gaZUcc1gbV8eft6kqXj
         OdbsfsL6L0BCyoEmAw4+jpIXOWDeM0TD9z1D0LlEGSNR0IRFPwhlDOlEDL3v7GQ/R0
         B3hq+n37gZukojzPmfFONfoBTN8d35Q8HVLCV59nvqkpR5xlTWmiSJK/lDpg1fCQxu
         AozzfbqlpydQ5yooygpwqZo44QGRGWceLfgV+le3RGoZBWHv2t0TdxkaCjPtzhuzps
         uv21fVe2jM45vi7nxWE0V3g3HmCVJUeuVvVHbRbuiF6Uggu3sGMDUzOE3ttMrNUPfM
         4LyzE6rDjNjwQ==
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 34/37] nfs: we don't support removing system.nfs4_acl
Date:   Tue, 16 Mar 2021 20:57:59 -0400
Message-Id: <20210317005802.725825-34-sashal@kernel.org>
X-Mailer: git-send-email 2.30.1
In-Reply-To: <20210317005802.725825-1-sashal@kernel.org>
References: <20210317005802.725825-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit 4f8be1f53bf615102d103c0509ffa9596f65b718 ]

The NFSv4 protocol doesn't have any notion of reomoving an attribute, so
removexattr(path,"system.nfs4_acl") doesn't make sense.

There's no documented return value.  Arguably it could be EOPNOTSUPP but
I'm a little worried an application might take that to mean that we
don't support ACLs or xattrs.  How about EINVAL?

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 30e44b33040a..fa181c3ba5cd 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5754,6 +5754,9 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
 	unsigned int npages = DIV_ROUND_UP(buflen, PAGE_SIZE);
 	int ret, i;
 
+	/* You can't remove system.nfs4_acl: */
+	if (buflen == 0)
+		return -EINVAL;
 	if (!nfs4_server_supports_acls(server))
 		return -EOPNOTSUPP;
 	if (npages > ARRAY_SIZE(pages))
-- 
2.30.1

