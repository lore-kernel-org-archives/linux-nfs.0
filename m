Return-Path: <SRS0=YdfS=U3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4D5DFC5B57A
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Jun 2019 12:37:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2CCDC2083B
	for <linux-nfs@archiver.kernel.org>; Fri, 28 Jun 2019 12:37:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726687AbfF1MhD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 28 Jun 2019 08:37:03 -0400
Received: from mx3.molgen.mpg.de ([141.14.17.11]:36345 "EHLO mx1.molgen.mpg.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1726696AbfF1MhD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 28 Jun 2019 08:37:03 -0400
Received: from theinternet.molgen.mpg.de (theinternet.molgen.mpg.de [141.14.31.7])
        by mx.molgen.mpg.de (Postfix) with ESMTP id DCA1020669590;
        Fri, 28 Jun 2019 14:37:01 +0200 (CEST)
From:   Donald Buczek <buczek@molgen.mpg.de>
To:     linux-nfs@vger.kernel.org, trond.myklebust@hammerspace.com,
        anna.schumaker@netapp.com
Cc:     Donald Buczek <buczek@molgen.mpg.de>
Subject: [PATCH 4/4 RESEND] nfs4.0: Refetch lease_time after clientid update
Date:   Fri, 28 Jun 2019 14:36:40 +0200
Message-Id: <20190628123640.8715-5-buczek@molgen.mpg.de>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190628123640.8715-1-buczek@molgen.mpg.de>
References: <20190628123640.8715-1-buczek@molgen.mpg.de>
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
index c2df257f426f..f32b02c2bc73 100644
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
2.22.0

