Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D0A8C433E6
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 11:30:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 5282D61A38
	for <linux-nfs@archiver.kernel.org>; Thu, 25 Mar 2021 11:30:22 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S231476AbhCYL3t (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 25 Mar 2021 07:29:49 -0400
Received: from mail.kernel.org ([198.145.29.99]:35906 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S231516AbhCYL10 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 25 Mar 2021 07:27:26 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 649AC61A7F;
        Thu, 25 Mar 2021 11:27:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1616671630;
        bh=hswCQyZZ2Qmd89Jdq4tJKYt9JtQSZWQ6mdU4q/xSxXg=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=NC92YHvbxuy1qbT8YOn4s36UkkMcuxC/xR/EKsAiUeQH/081ezLcm3CaXpBTD3Pw8
         adyf9i9rjGvkJqf9RMYdJlRp4AmfQeUmUcU5pjtGI5QIqqsKV8QvNrSl+pXCz7JBXq
         65W+SdPe7EIJ7BS0QPUh1ei4KNgiLOcNoNXGXqaDzJj3Liro+8KwjZXT7KH01YsS4R
         RL9DCBLM3tdULaTFFWm2wU2pnbrOycjODBWbEJEJwNQ4/xPKn0LPE/bqvcSUqkflpn
         DNPz2SoesNTCHK0AazCGMNLSb9RZEOhuU6BQ+3WnAf9XvHuWDdBO5cYtfctCCibQNS
         3wffC1CRfYcDw==
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Bruce Fields <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        Benjamin Coddington <bcodding@redhat.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.4 14/24] NFSD: fix error handling in NFSv4.0 callbacks
Date:   Thu, 25 Mar 2021 07:26:40 -0400
Message-Id: <20210325112651.1927828-14-sashal@kernel.org>
X-Mailer: git-send-email 2.30.1
In-Reply-To: <20210325112651.1927828-1-sashal@kernel.org>
References: <20210325112651.1927828-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

[ Upstream commit b4250dd868d1b42c0a65de11ef3afbee67ba5d2f ]

When the server tries to do a callback and a client fails it due to
authentication problems, we need the server to set callback down
flag in RENEW so that client can recover.

Suggested-by: Bruce Fields <bfields@redhat.com>
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Benjamin Coddington <bcodding@redhat.com>
Link: https://lore.kernel.org/linux-nfs/FB84E90A-1A03-48B3-8BF7-D9D10AC2C9FE@oracle.com/T/#t
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfs4callback.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index efe55d101b0e..3c50d18fe8a9 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1121,6 +1121,7 @@ static void nfsd4_cb_done(struct rpc_task *task, void *calldata)
 		switch (task->tk_status) {
 		case -EIO:
 		case -ETIMEDOUT:
+		case -EACCES:
 			nfsd4_mark_cb_down(clp, task->tk_status);
 		}
 		break;
-- 
2.30.1

