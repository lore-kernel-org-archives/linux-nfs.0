Return-Path: <SRS0=1UK0=RC=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CED45C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A7F4A20863
	for <linux-nfs@archiver.kernel.org>; Wed, 27 Feb 2019 14:52:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730594AbfB0OwF (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 27 Feb 2019 09:52:05 -0500
Received: from mx3.molgen.mpg.de ([141.14.17.11]:51731 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1730224AbfB0OwE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 27 Feb 2019 09:52:04 -0500
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id D25AC604E3BD1;
        Wed, 27 Feb 2019 15:52:02 +0100 (CET)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 4/4] nfs4.0: Refetch lease_time after clientid update
Date:   Wed, 27 Feb 2019 15:51:30 +0100
Message-Id: <20190227145130.22323-5-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190227145130.22323-1-buczek@molgen.mpg.de>
References: <20190227145130.22323-1-buczek@molgen.mpg.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

RFC 7530 requires us to refetch the lease time attribute once a new
clientID is established. This is already implemented for the
nfs4.1(+) clients by nfs41_init_clientid, which calls
nfs41_finish_session_reset, which calls nfs4_setup_state_renewal.

Let nfs4_init_clientid, which is used for 4.0 clients, call
nfs4_setup_state_renewal as well.

Signed-off-by: Donald Buczek <buczek@molgen.mpg.de>
---
 fs/nfs/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index ba6889dcf3d6..6059cb5408ff 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -135,7 +135,7 @@ int nfs4_init_clientid(struct nfs_client *clp, const struct cred *cred)
 	if (status != 0)
 		goto out;
 	clear_bit(NFS4CLNT_LEASE_CONFIRM, &clp->cl_state);
-	nfs4_schedule_state_renewal(clp);
+	nfs4_setup_state_renewal(clp);
 out:
 	return status;
 }
-- 
2.21.0

