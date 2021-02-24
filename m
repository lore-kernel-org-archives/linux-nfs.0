Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.2 required=3.0 tests=BAYES_00,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_CR_TRAILER,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6ABB7C433DB
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Feb 2021 18:40:33 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 1E23D64F07
	for <linux-nfs@archiver.kernel.org>; Wed, 24 Feb 2021 18:40:33 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S230371AbhBXSkb (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 24 Feb 2021 13:40:31 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:53042 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S230121AbhBXSkb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Feb 2021 13:40:31 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id E2AC8C061574
        for <linux-nfs@vger.kernel.org>; Wed, 24 Feb 2021 10:39:50 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 0F38A2824; Wed, 24 Feb 2021 13:39:50 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 0F38A2824
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fieldses.org;
        s=default; t=1614191990;
        bh=89JKKo21MYkxmYgK50+RPagik6pzK9B677Th2dQ/z8o=;
        h=Date:To:Cc:Subject:From:From;
        b=XyGoH7MibbwA9p7wip39g0Z4G2hrKauil5FiewTn3kYuWhMDfqF3txv7/f6Dq2lJM
         n3KePz4OCpzNeajVox8k7lLs1X0d2r1/A3N1oLrvV58H6KXA0sfnwuyoQo+ComtQ3u
         RLgiZNFTWvW+erxsWwwrtR0bDnQtx0Z4KoAZzQFw=
Date:   Wed, 24 Feb 2021 13:39:50 -0500
To:     Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org, Olga Kornievskaia <kolga@netapp.com>
Subject: [PATCH] nfsd: don't abort copies early
Message-ID: <20210224183950.GB11591@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

The typical result of the backwards comparison here is that the source
server in a server-to-server copy will return BAD_STATEID within a few
seconds of the copy starting, instead of giving the copy a full lease
period, so the copy_file_range() call will end up unnecessarily
returning a short read.

Fixes: 624322f1adc5 "NFSD add COPY_NOTIFY operation"
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 423fd6683f3a..61552e89bd89 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5389,7 +5389,7 @@ nfs4_laundromat(struct nfsd_net *nn)
 	idr_for_each_entry(&nn->s2s_cp_stateids, cps_t, i) {
 		cps = container_of(cps_t, struct nfs4_cpntf_state, cp_stateid);
 		if (cps->cp_stateid.sc_type == NFS4_COPYNOTIFY_STID &&
-				cps->cpntf_time > cutoff)
+				cps->cpntf_time < cutoff)
 			_free_cpntf_state_locked(nn, cps);
 	}
 	spin_unlock(&nn->s2s_cp_lock);
-- 
2.29.2

