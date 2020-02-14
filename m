Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF57EC2BA83
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:01:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id BC544206CC
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:01:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581696081;
	bh=ZhHiYeFc2NKNaZjgKVWO2UYT9NTin3LH5OMZVMG49es=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=c/8WVOC88Cs4nI01qTeKL/wQUed6F/yNN6TPcm73BdNfwlIQ3Of9qzTiZEYaVqpqg
	 EHE3qK3W7Xd/BAOOMoVZCKZpyc3zjCROrAFzHEDPXAqkI9GtN3QAqm3FxSPCfGXXbH
	 7YihRHc5P3qTZ0zNssbH88V1FQVJUx5RPZKFj0JQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389102AbgBNQAR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 11:00:17 -0500
Received: from mail.kernel.org ([198.145.29.99]:45588 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2389098AbgBNQAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 11:00:16 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 50785222C4;
        Fri, 14 Feb 2020 16:00:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581696016;
        bh=ZhHiYeFc2NKNaZjgKVWO2UYT9NTin3LH5OMZVMG49es=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=N21b/B0Dh3HWPejL5TLQODEear16h8CWPRNf786yHVbGEyHPwHQJvb/ETNYEwrHxO
         8haVNRaEpioWharfrT91TwvbRiW8dinCLtcbGPBT9W/kNcQwwm1x0aGpAH3oSbHkMN
         WER7zmB2/Dx8dGK+8Z0/mVfVFwfPRr4Zx+btoIB4=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Robert Milkowski <rmilkowski@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.5 532/542] NFSv4: try lease recovery on NFS4ERR_EXPIRED
Date:   Fri, 14 Feb 2020 10:48:44 -0500
Message-Id: <20200214154854.6746-532-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200214154854.6746-1-sashal@kernel.org>
References: <20200214154854.6746-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Robert Milkowski <rmilkowski@gmail.com>

[ Upstream commit 924491f2e476f7234d722b24171a4daff61bbe13 ]

Currently, if an nfs server returns NFS4ERR_EXPIRED to open(),
we return EIO to applications without even trying to recover.

Fixes: 272289a3df72 ("NFSv4: nfs4_do_handle_exception() handle revoke/expiry of a single stateid")
Signed-off-by: Robert Milkowski <rmilkowski@gmail.com>
Reviewed-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4proc.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f9bb4b43a5192..95ca7967f54cb 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3187,6 +3187,11 @@ static struct nfs4_state *nfs4_do_open(struct inode *dir,
 			exception.retry = 1;
 			continue;
 		}
+		if (status == -NFS4ERR_EXPIRED) {
+			nfs4_schedule_lease_recovery(server->nfs_client);
+			exception.retry = 1;
+			continue;
+		}
 		if (status == -EAGAIN) {
 			/* We must have found a delegation */
 			exception.retry = 1;
-- 
2.20.1

