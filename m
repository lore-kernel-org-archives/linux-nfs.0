Return-Path: <SRS0=tdDw=CX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-14.9 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6210C43461
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 14:27:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 88E7820829
	for <linux-nfs@archiver.kernel.org>; Mon, 14 Sep 2020 14:27:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1600093624;
	bh=f9uTyh33a2+faJ5onVvqk+6/QKRk0vmHVpNOFvAqT+0=;
	h=From:To:Cc:Subject:Date:List-ID:From;
	b=aPvoHAbkFJzalU1eQ7+wZN3q4RCqM0cWn104CptLPrEg7gkHxHUjFk5s31XNpmJwo
	 TwcFNsSJfOVxIOkbJTM8Nz6dv38jjvZUZlAUuVJR133nRKZ6MLBixH+GjVroGsopiP
	 CJ3swmWwlhUKwXsTj+OiOiYSpxZq5q/jDyIycyww=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726856AbgINOZc (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 14 Sep 2020 10:25:32 -0400
Received: from mail.kernel.org ([198.145.29.99]:32804 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726668AbgINNGE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 14 Sep 2020 09:06:04 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id D246321D41;
        Mon, 14 Sep 2020 13:05:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1600088728;
        bh=f9uTyh33a2+faJ5onVvqk+6/QKRk0vmHVpNOFvAqT+0=;
        h=From:To:Cc:Subject:Date:From;
        b=VCB6cgkR11HNpyJuxsl6qaKfgG1/Oi5qGRtVcQs5BbNPAYwG09mxMsEV6GHJFD+Ci
         hAqNoqRBU0rjOnZIh8zwaI3CtYKA2izbEIx/7YD/WykFev6GI4hyC1eqqcS60jTjrx
         lkhdSnp4gFhMFXec8wDn/4XxbBicOHNNwLITuzXM=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 01/15] NFSv4.1 handle ERR_DELAY error reclaiming locking state on delegation recall
Date:   Mon, 14 Sep 2020 09:05:12 -0400
Message-Id: <20200914130526.1804913-1-sashal@kernel.org>
X-Mailer: git-send-email 2.25.1
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

[ Upstream commit 3d7a9520f0c3e6a68b6de8c5812fc8b6d7a52626 ]

A client should be able to handle getting an ERR_DELAY error
while doing a LOCK call to reclaim state due to delegation being
recalled. This is a transient error that can happen due to server
moving its volumes and invalidating its file location cache and
upon reference to it during the LOCK call needing to do an
expensive lookup (leading to an ERR_DELAY error on a PUTFH).

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4proc.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 4cfb84119e017..997b731ee19ab 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -6687,7 +6687,12 @@ int nfs4_lock_delegation_recall(struct file_lock *fl, struct nfs4_state *state,
 	err = nfs4_set_lock_state(state, fl);
 	if (err != 0)
 		return err;
-	err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
+	do {
+		err = _nfs4_do_setlk(state, F_SETLK, fl, NFS_LOCK_NEW);
+		if (err != -NFS4ERR_DELAY)
+			break;
+		ssleep(1);
+	} while (err == -NFS4ERR_DELAY);
 	return nfs4_handle_delegation_recall_error(server, state, stateid, fl, err);
 }
 
-- 
2.25.1

