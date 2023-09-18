Return-Path: <linux-nfs-owner@vger.kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D8858CD13D2
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Sep 2023 16:48:29 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229781AbjIRQsd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Sep 2023 12:48:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:42876 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230120AbjIRQsV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Sep 2023 12:48:21 -0400
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 92421172C
        for <linux-nfs@vger.kernel.org>; Mon, 18 Sep 2023 09:47:32 -0700 (PDT)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6E125C32777;
        Mon, 18 Sep 2023 14:18:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1695046711;
        bh=w6i1iNGJem8BsbeiQZQFAHcL5/hlMZkwc4S/pQzy7KY=;
        h=Subject:From:To:Cc:Date:From;
        b=DQsCrwjrtdNb9YUWfAutunUkY7HMyeSjxyF+l6fKeoIrMC85bGiKe3v9aHYxSKTxK
         q/iMhd4S1inG3q5KX7CAuOLPcvlaJvBdPXgWAwzzTnOZktgAvZDjBv8GUQG6wEnqS/
         wO8rzUbPfENdiIaMlPhfXor1sZORnhdFsaavccU5SQZGj0Q/8jViQN60/LfuBiXnzp
         av3GHEYfSBGMNXN+4TqAdFMxd04S9oGRMcp0yoxwQYtzo+yGjfi519cYLBdQr0eij4
         Iuotk6fBhLmuIB2a7XC6n7Zpd7kQL9/R4p62UOVLgVZTBFGd6Oh4nullN1cMZG0w5G
         8VchCDA+X7mfA==
Subject: [PATCH v1] SUNRPC: Remove BUG_ON call sites
From:   Chuck Lever <cel@kernel.org>
To:     neilb@suse.de, brauner@kernel.org
Cc:     Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Date:   Mon, 18 Sep 2023 10:18:30 -0400
Message-ID: <169504668787.134583.4338728458451666583.stgit@manet.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Chuck Lever <chuck.lever@oracle.com>

There is no need to take down the whole system for these assertions.

I'd rather not attempt a heroic save here, as some bug has occurred
that has left the transport data structures in an unknown state.
Just warn and then leak the left-over resources.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/svc.c |   11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

Let's start here. Comments?


diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index 587811a002c9..11a1d5e7f5c7 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -575,11 +575,14 @@ svc_destroy(struct kref *ref)
 	timer_shutdown_sync(&serv->sv_temptimer);
 
 	/*
-	 * The last user is gone and thus all sockets have to be destroyed to
-	 * the point. Check this.
+	 * Remaining transports at this point are not expected.
 	 */
-	BUG_ON(!list_empty(&serv->sv_permsocks));
-	BUG_ON(!list_empty(&serv->sv_tempsocks));
+	if (unlikely(!list_empty(&serv->sv_permsocks)))
+		pr_warn("SVC: permsocks remain for %s\n",
+			serv->sv_program->pg_name);
+	if (unlikely(!list_empty(&serv->sv_tempsocks)))
+		pr_warn("SVC: tempsocks remain for %s\n",
+			serv->sv_program->pg_name);
 
 	cache_clean_deferred(serv);
 


