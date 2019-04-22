Return-Path: <SRS0=DK+G=SY=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7B84C282E1
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 19:55:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8A0BC204EC
	for <linux-nfs@archiver.kernel.org>; Mon, 22 Apr 2019 19:55:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1555962933;
	bh=JDQdMdft2i9YickyGnKwmMhIlJw/ix9sMHbGZR/fblU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=Aku3H4MneKp9vdtRECImwZMqAG25rvgH9FOx0xjB/vGh5bPZ8L+lJjGLuFPJaq3yN
	 Cl1wvBpMXu3I8UgMR8sPN2NVC2CAmeaOUkoxPk7WFQ9vtU9M4T0K9JMqMCyGNRcLa1
	 JvWnosMTQ4kBFUTc8RJmjWssvexuQ7zSiruQMkrA=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730831AbfDVTt0 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 22 Apr 2019 15:49:26 -0400
Received: from mail.kernel.org ([198.145.29.99]:53150 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730825AbfDVTtZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Apr 2019 15:49:25 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id CAF3A2075A;
        Mon, 22 Apr 2019 19:49:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1555962564;
        bh=JDQdMdft2i9YickyGnKwmMhIlJw/ix9sMHbGZR/fblU=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=buiPjI0L6rFtOwiDdUpfn2FieUdKlgjG4UoQsLozIGahVmxj+MFCqw+kHh8qEjsKx
         DTSyp0lME64qDEDxY9JDrUdlZS9FmlJi4YkVEcxw3rQ+RgLeA7og5VbTGUwol878Z6
         KKecfxG+NTm1EEia6xgXHIGsnjHwKdyogQH6nBGI=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.9 17/29] NFS: Fix a typo in nfs_init_timeout_values()
Date:   Mon, 22 Apr 2019 15:48:36 -0400
Message-Id: <20190422194848.13049-17-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190422194848.13049-1-sashal@kernel.org>
References: <20190422194848.13049-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

[ Upstream commit 5a698243930c441afccec04e4d5dc8febfd2b775 ]

Specifying a retrans=0 mount parameter to a NFS/TCP mount, is
inadvertently causing the NFS client to rewrite any specified
timeout parameter to the default of 60 seconds.

Fixes: a956beda19a6 ("NFS: Allow the mount option retrans=0")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin (Microsoft) <sashal@kernel.org>
---
 fs/nfs/client.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ebecfb8fba06..28d8a57a9908 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -440,7 +440,7 @@ void nfs_init_timeout_values(struct rpc_timeout *to, int proto,
 	case XPRT_TRANSPORT_RDMA:
 		if (retrans == NFS_UNSPEC_RETRANS)
 			to->to_retries = NFS_DEF_TCP_RETRANS;
-		if (timeo == NFS_UNSPEC_TIMEO || to->to_retries == 0)
+		if (timeo == NFS_UNSPEC_TIMEO || to->to_initval == 0)
 			to->to_initval = NFS_DEF_TCP_TIMEO * HZ / 10;
 		if (to->to_initval > NFS_MAX_TCP_TIMEOUT)
 			to->to_initval = NFS_MAX_TCP_TIMEOUT;
-- 
2.19.1

