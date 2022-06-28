Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D1610CCA47E
	for <linux-nfs@archiver.kernel.org>; Tue, 28 Jun 2022 18:06:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233942AbiF1SGm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 28 Jun 2022 14:06:42 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:51068 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233911AbiF1SGj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2022 14:06:39 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 596D71EC43;
        Tue, 28 Jun 2022 11:06:35 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 0B9DFB81F58;
        Tue, 28 Jun 2022 18:06:34 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4BA9EC341C6;
        Tue, 28 Jun 2022 18:06:32 +0000 (UTC)
Subject: [PATCH v2 07/31] NFSD: Refactor nfsd_file_gc()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Cc:     david@fromorbit.com, jlayton@redhat.com, tgraf@suug.ch
Date:   Tue, 28 Jun 2022 14:06:31 -0400
Message-ID: <165643959120.84360.16581537699987659564.stgit@manet.1015granger.net>
In-Reply-To: <165643915086.84360.2809940286726976517.stgit@manet.1015granger.net>
References: <165643915086.84360.2809940286726976517.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Refactor nfsd_file_gc() to use the new list_lru helper.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index b278030e0a12..4e1162f51a70 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -498,7 +498,11 @@ nfsd_file_lru_walk_list(struct shrink_control *sc)
 static void
 nfsd_file_gc(void)
 {
-	nfsd_file_lru_walk_list(NULL);
+	LIST_HEAD(dispose);
+
+	list_lru_walk(&nfsd_file_lru, nfsd_file_lru_cb,
+		      &dispose, LONG_MAX);
+	nfsd_file_gc_dispose_list(&dispose);
 }
 
 static void


