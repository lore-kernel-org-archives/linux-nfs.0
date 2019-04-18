Return-Path: <SRS0=DJTG=SU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6D9F1C10F0E
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 13:24:04 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3B501217D7
	for <linux-nfs@archiver.kernel.org>; Thu, 18 Apr 2019 13:24:04 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388263AbfDRNYD (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 18 Apr 2019 09:24:03 -0400
Received: from mx1.redhat.com ([209.132.183.28]:56110 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1733192AbfDRNYD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 Apr 2019 09:24:03 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 325843088296;
        Thu, 18 Apr 2019 13:24:03 +0000 (UTC)
Received: from coeurl.usersys.redhat.com (ovpn-121-236.rdu2.redhat.com [10.10.121.236])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 457F35D707;
        Thu, 18 Apr 2019 13:24:01 +0000 (UTC)
Received: by coeurl.usersys.redhat.com (Postfix, from userid 1000)
        id C495820F52; Thu, 18 Apr 2019 09:24:00 -0400 (EDT)
From:   Scott Mayhew <smayhew@redhat.com>
To:     bfields@fieldses.org, jlayton@kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: CB_RECALL can race with FREE_STATEID
Date:   Thu, 18 Apr 2019 09:24:00 -0400
Message-Id: <20190418132400.24161-1-smayhew@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Thu, 18 Apr 2019 13:24:03 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While trying to track down some issues involving large numbers of
delegations being recalled/revoked, I caught the server setting
SEQ4_STATUS_CB_PATH_DOWN while the client was actively responding to
CB_RECALLs.  It turns out that the client had already done a
TEST_STATEID and FREE_STATEID for a delegation being recalled by the
time it received the CB_RECALL.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 fs/nfsd/nfs4state.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a45fb00c5fc..e88e429133a8 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3958,6 +3958,14 @@ static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
 			rpc_delay(task, 2 * HZ);
 			return 0;
 		}
+		/*
+		 * Race: client may have done a FREE_STATEID before
+		 * receiving the CB_RECALL.
+		 */
+		if (dp->dl_stid.sc_type == NFS4_REVOKED_DELEG_STID &&
+				refcount_read(&dp->dl_stid.sc_count) == 1 &&
+				list_empty(&dp->dl_recall_lru))
+			return 1;
 		/*FALLTHRU*/
 	default:
 		return -1;
-- 
2.17.2

