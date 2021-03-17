Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-19.2 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_CR_TRAILER,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F389C43333
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 01:03:02 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 6811164FBC
	for <linux-nfs@archiver.kernel.org>; Wed, 17 Mar 2021 01:03:02 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230137AbhCQBCg (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 16 Mar 2021 21:02:36 -0400
Received: from mail.kernel.org ([198.145.29.99]:41608 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S232457AbhCQBAS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 16 Mar 2021 21:00:18 -0400
Received: by mail.kernel.org (Postfix) with ESMTPSA id 1CE7B65007;
        Wed, 17 Mar 2021 01:00:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1615942817;
        bh=RMOjAYX1vm174Y9ksn1z6Hf+kiX9gRDRZjgDW5Hq9zA=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=DWPAhOGacG/ssDHEzOGnpNd92/2kJ5HOrZlgNbH2GxoUUkemIBLPZYDddnG6mmygm
         I1KQ7f4QGvDkW86Mi7uLorRcSuQjAdQ5cJVZe0XDrGzLp2D9s5LUGAZUyURFVWkR4C
         1/jqDxYcSKUCglg5row723xha1fjJaA7MCWOWfzK//QmWPvjGe76HFk9fs6lBwzy5N
         EW7qiFxTk1N/b1L3CJ3P1bhCuOmHArqtgN9CNNgzZT4da7cntFagbwS/1TrLn5dY9W
         /8sRVVtZJHG0S6e3W+2+yDbUyP+gtv/kd20lmG6h/V1KkxoyQkFO3LUVAZssPEQ9Qs
         I5CN+2M0refAw==
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Timo Rothenpieler <timo@rothenpieler.org>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.4 07/14] nfs: fix PNFS_FLEXFILE_LAYOUT Kconfig default
Date:   Tue, 16 Mar 2021 21:00:01 -0400
Message-Id: <20210317010008.727496-7-sashal@kernel.org>
X-Mailer: git-send-email 2.30.1
In-Reply-To: <20210317010008.727496-1-sashal@kernel.org>
References: <20210317010008.727496-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Timo Rothenpieler <timo@rothenpieler.org>

[ Upstream commit a0590473c5e6c4ef17c3132ad08fbad170f72d55 ]

This follows what was done in 8c2fabc6542d9d0f8b16bd1045c2eda59bdcde13.
With the default being m, it's impossible to build the module into the
kernel.

Signed-off-by: Timo Rothenpieler <timo@rothenpieler.org>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index c3428767332c..55ebf9f4a824 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -132,7 +132,7 @@ config PNFS_OBJLAYOUT
 config PNFS_FLEXFILE_LAYOUT
 	tristate
 	depends on NFS_V4_1 && NFS_V3
-	default m
+	default NFS_V4
 
 config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	string "NFSv4.1 Implementation ID Domain"
-- 
2.30.1

