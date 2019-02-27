Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FAD7C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DAD3C20863
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:03 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730577AbfB0OwD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 09:52:03 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:41567 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730224AbfB0OwC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 09:52:02 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id 14DC4604E3BCF;
        Wed, 27 Feb 2019 15:52:01 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 2/4] nfs4: Rename nfs41_setup_state_renewal
Date:   Wed, 27 Feb 2019 15:51:28 +0100
Message-Id: <20190227145130.22323-3-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190227145130.22323-1-buczek@molgen.mpg.de>
References: <20190227145130.22323-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The function nfs41_setup_state_renewal is useful to the nfs 4.0 client
as well, so rename the function to nfs4_setup_state_renewal.

Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfs/nfs4state.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 02488b50534a..28863a9b705d 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -282,7 +282,7 @@ static int nfs4_begin_drain_session(struct nfs_client *clp)
 
 #if defined(CONFIG_NFS_V4_1)
 
-static int nfs41_setup_state_renewal(struct nfs_client *clp)
+static int nfs4_setup_state_renewal(struct nfs_client *clp)
 {
 	int status;
 	struct nfs_fsinfo fsinfo;
@@ -309,7 +309,7 @@ static void nfs41_finish_session_reset(struct nfs_client *clp)
 	clear_bit(NFS4CLNT_SESSION_RESET, &clp->cl_state);
 	/* create_session negotiated new slot table */
 	clear_bit(NFS4CLNT_BIND_CONN_TO_SESSION, &clp->cl_state);
-	nfs41_setup_state_renewal(clp);
+	nfs4_setup_state_renewal(clp);
 }
 
 int nfs41_init_clientid(struct nfs_client *clp, const struct cred *cred)
-- 
2.21.0

