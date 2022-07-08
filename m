Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7C0D9C43334
	for <linux-nfs@archiver.kernel.org>; Fri,  8 Jul 2022 18:26:26 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S239548AbiGHS0Y (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 8 Jul 2022 14:26:24 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:47892 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S239604AbiGHS0J (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 8 Jul 2022 14:26:09 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 51B6188F2E;
        Fri,  8 Jul 2022 11:25:51 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id AC6DDB82924;
        Fri,  8 Jul 2022 18:25:46 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13193C341C0;
        Fri,  8 Jul 2022 18:25:45 +0000 (UTC)
Subject: [PATCH v3 19/32] NFSD: Remove lockdep assertion from
 unhash_and_release_locked()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, jlayton@redhat.com, tgraf@suug.ch
Date:   Fri, 08 Jul 2022 14:25:44 -0400
Message-ID: <165730474411.28142.18114782524479918905.stgit@klimt.1015granger.net>
In-Reply-To: <165730437087.28142.6731645688073512500.stgit@klimt.1015granger.net>
References: <165730437087.28142.6731645688073512500.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev3+g9561319
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

IIUC, holding the hash bucket lock is needed only in
nfsd_file_unhash, and there is already a lockdep assertion there.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 32ada8cce2e0..278a13d85e8f 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -306,8 +306,6 @@ nfsd_file_unhash(struct nfsd_file *nf)
 static bool
 nfsd_file_unhash_and_release_locked(struct nfsd_file *nf, struct list_head *dispose)
 {
-	lockdep_assert_held(&nfsd_file_hashtbl[nf->nf_hashval].nfb_lock);
-
 	trace_nfsd_file_unhash_and_release_locked(nf);
 	if (!nfsd_file_unhash(nf))
 		return false;


