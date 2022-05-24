Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F0B78C433EF
	for <linux-nfs@archiver.kernel.org>; Tue, 24 May 2022 18:57:36 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S233384AbiEXS5g (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 May 2022 14:57:36 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52224 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S240508AbiEXS5f (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2022 14:57:35 -0400
Received: from sin.source.kernel.org (sin.source.kernel.org [145.40.73.55])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 1E1E45B3C6
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2022 11:57:33 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by sin.source.kernel.org (Postfix) with ESMTPS id 6384BCE1A8A
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2022 18:57:32 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9811CC34100
        for <linux-nfs@vger.kernel.org>; Tue, 24 May 2022 18:57:30 +0000 (UTC)
Subject: [PATCH v2 6/6] NFSD: nfsd_file_put() can sleep
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Tue, 24 May 2022 14:57:29 -0400
Message-ID: <165341864964.3187.10891043744511023924.stgit@bazille.1015granger.net>
In-Reply-To: <165341832236.3187.8388683641228729897.stgit@bazille.1015granger.net>
References: <165341832236.3187.8388683641228729897.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Now that there are no more callers of nfsd_file_put() that might
hold a spin lock, ensure the lockdep infrastructure can catch
newly introduced calls to nfsd_file_put() made while a spinlock
is held.

Link: https://lore.kernel.org/linux-nfs/ece7fd1d-5fb3-5155-54ba-347cfc19bd9a@oracle.com/T/#mf1855552570cf9a9c80d1e49d91438cd9085aada
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/filecache.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index a7e3a443a2cb..d32fcd8ad457 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -302,6 +302,8 @@ nfsd_file_put_noref(struct nfsd_file *nf)
 void
 nfsd_file_put(struct nfsd_file *nf)
 {
+	might_sleep();
+
 	set_bit(NFSD_FILE_REFERENCED, &nf->nf_flags);
 	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags) == 0) {
 		nfsd_file_flush(nf);


