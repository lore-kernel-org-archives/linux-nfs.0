Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.4 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 14E38C07E98
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Jul 2021 02:05:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F0D5B613DC
	for <linux-nfs@archiver.kernel.org>; Sun,  4 Jul 2021 02:05:17 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229685AbhGDCHt (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 3 Jul 2021 22:07:49 -0400
Received: from mail.kernel.org ([198.145.29.99]:36590 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S229557AbhGDCHs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Sat, 3 Jul 2021 22:07:48 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id BA19A615A0
        for <linux-nfs@vger.kernel.org>; Sun,  4 Jul 2021 02:05:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1625364314;
        bh=Z7VDIDM8ceeNJgFzKU75zRut7RjKkI7HSrr3tcttMqw=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=plVRuwZPronG6M4b5M83z7lJscqpJtBH+Pe13oA3ll+uyi3UAkcIsCdMrc4GrnHER
         9eIT1peSN3yWxwgcbzSLYcR6I2d594zVJoFbOvcnDA5Nzr2eJZ68EM13Z3QAPEu54G
         R4u+L3vcViTSELMKQoxc89y7KxfRN1PjtUIEeG3lqE2PNcr0zQXZSrfoNjJoPht4+g
         MLX+SsR9HgQ5MbzqI1Rt+kAboeQvIIsMsWR0SPaUjxUeDxt2nwu/+0LQvxEDVtv1qb
         r9CcQYsqKYzf756sWsU2uFKpm2rJBaVIRN4M9yYtYSSivysVIfTzrXdpkiOwQmmzrP
         VGTZ3PfXkhiDA==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 5/5] NFSv4/pNFS: Return an error if _nfs4_pnfs_v3_ds_connect can't load NFSv3
Date:   Sat,  3 Jul 2021 22:05:10 -0400
Message-Id: <20210704020510.4898-5-trondmy@kernel.org>
X-Mailer: git-send-email 2.31.1
In-Reply-To: <20210704020510.4898-4-trondmy@kernel.org>
References: <20210704020510.4898-1-trondmy@kernel.org>
 <20210704020510.4898-2-trondmy@kernel.org>
 <20210704020510.4898-3-trondmy@kernel.org>
 <20210704020510.4898-4-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Currently we fail to return an error if the NFSv3 module failed to load
when we're trying to connect to a pNFS data server.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 1c2c0d08614e..cf19914fec81 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -855,7 +855,7 @@ static int _nfs4_pnfs_v3_ds_connect(struct nfs_server *mds_srv,
 	dprintk("--> %s DS %s\n", __func__, ds->ds_remotestr);
 
 	if (!load_v3_ds_connect())
-		goto out;
+		return -EPROTONOSUPPORT;
 
 	list_for_each_entry(da, &ds->ds_addrs, da_node) {
 		dprintk("%s: DS %s: trying address %s\n",
-- 
2.31.1

