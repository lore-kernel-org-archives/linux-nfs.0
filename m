Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E0DAC433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 11 May 2022 21:53:05 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S243183AbiEKVxE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 11 May 2022 17:53:04 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:43380 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230306AbiEKVxD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 11 May 2022 17:53:03 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9D82A118006
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2022 14:53:02 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 473F6B82630
        for <linux-nfs@vger.kernel.org>; Wed, 11 May 2022 21:53:01 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96096C34114;
        Wed, 11 May 2022 21:52:59 +0000 (UTC)
Subject: [PATCH RFC 2/2] NFSD: nfsd_file_put() can sleep
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     trondmy@hammerspace.com, bfields@fieldses.org, jlayton@redhat.com,
        dai.ngo@oracle.com
Date:   Wed, 11 May 2022 17:52:58 -0400
Message-ID: <165230597851.5906.18376771236120628748.stgit@klimt.1015granger.net>
In-Reply-To: <165230584037.5906.5496655737644872339.stgit@klimt.1015granger.net>
References: <165230584037.5906.5496655737644872339.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev1+g8516920
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Ensure the lockdep infrastructure can catch calls to nfsd_file_put()
when spinlocks are held.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/filecache.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index 8f7ed5dbb003..60a5d82e59b3 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -301,6 +301,8 @@ nfsd_file_put_noref(struct nfsd_file *nf)
 void
 nfsd_file_put(struct nfsd_file *nf)
 {
+	might_sleep();
+
 	set_bit(NFSD_FILE_REFERENCED, &nf->nf_flags);
 	if (test_bit(NFSD_FILE_HASHED, &nf->nf_flags) == 0) {
 		nfsd_file_flush(nf);


