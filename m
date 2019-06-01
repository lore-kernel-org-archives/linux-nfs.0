Return-Path: <SRS0=Ox7S=UA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA7D5C28CC1
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Jun 2019 13:30:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 95DFC2745B
	for <linux-nfs@archiver.kernel.org>; Sat,  1 Jun 2019 13:30:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395818;
	bh=2u4dtYYCfBMkyXk9hND4YOWvxFui6Ydq4Lq2VEZEErk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=C5W8frf8IzsMnUFa8cgt2BmWtrNRcVxkqOmbrA9/ktkeHzs+ifkEbPJRP+4t1rq/0
	 b2AndSrkgxgYkNIwDs7BgNTfY+iSCZKWoqpHtmtQEtCMEtL3qBA3rx+dKW2AY8DYoo
	 4HDJ5iGPOLthig/XnZU3j+7Eaw88PQ7ZGt5njDJQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729706AbfFAN01 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Jun 2019 09:26:27 -0400
Received: from mail.kernel.org ([198.145.29.99]:56866 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1729702AbfFAN01 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 1 Jun 2019 09:26:27 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E1696273C0;
        Sat,  1 Jun 2019 13:26:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1559395586;
        bh=2u4dtYYCfBMkyXk9hND4YOWvxFui6Ydq4Lq2VEZEErk=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=U2d0omDgKlJnm8wyQVSwWclDKiAMimIrweaFkGxbhdmgeZoW6R8K7Di4xW202JrSd
         P+jU/WKeyM6d05gTK8DWkKwGpnnWIxEX2Umk4SNG4WL+0U2E3SehYR6EwiGqWxlYEn
         7IKzXwgjU80ZPzsMWb2JoKQwClkMLYPuV+0+TukA=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     ZhangXiaoxu <zhangxiaoxu5@huawei.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 12/56] NFS4: Fix v4.0 client state corruption when mount
Date:   Sat,  1 Jun 2019 09:25:16 -0400
Message-Id: <20190601132600.27427-12-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601132600.27427-1-sashal@kernel.org>
References: <20190601132600.27427-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: ZhangXiaoxu <zhangxiaoxu5@huawei.com>

[ Upstream commit f02f3755dbd14fb935d24b14650fff9ba92243b8 ]

stat command with soft mount never return after server is stopped.

When alloc a new client, the state of the client will be set to
NFS4CLNT_LEASE_EXPIRED.

When the server is stopped, the state manager will work, and accord
the state to recover. But the state is NFS4CLNT_LEASE_EXPIRED, it
will drain the slot table and lead other task to wait queue, until
the client recovered. Then the stat command is hung.

When discover server trunking, the client will renew the lease,
but check the client state, it lead the client state corruption.

So, we need to call state manager to recover it when detect server
ip trunking.

Signed-off-by: ZhangXiaoxu <zhangxiaoxu5@huawei.com>
Cc: stable@vger.kernel.org
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs4state.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 44f5cea496994..5be61affeefd8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -140,6 +140,10 @@ int nfs40_discover_server_trunking(struct nfs_client *clp,
 		/* Sustain the lease, even if it's empty.  If the clientid4
 		 * goes stale it's of no use for trunking discovery. */
 		nfs4_schedule_state_renewal(*result);
+
+		/* If the client state need to recover, do it. */
+		if (clp->cl_state)
+			nfs4_schedule_state_manager(clp);
 	}
 out:
 	return status;
-- 
2.20.1

