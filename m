Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D729AC433F5
	for <linux-nfs@archiver.kernel.org>; Wed, 25 May 2022 15:47:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237707AbiEYPrd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 25 May 2022 11:47:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:58196 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S233702AbiEYPrd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 May 2022 11:47:33 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9F48034649
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 08:47:30 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 060D4B81C3B
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 15:47:29 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AA3ACC385B8
        for <linux-nfs@vger.kernel.org>; Wed, 25 May 2022 15:47:27 +0000 (UTC)
Subject: [PATCH v3 0/4] RELEASE_LOCKOWNER continued...
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 25 May 2022 11:47:26 -0400
Message-ID: <165349272692.4205.8499763565429173274.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I am still concerned that an approach that uses the lm_get/put_owner
methods is unworkable because that API is used in several unrelated
situations.

For example, a successful LOCK operation does a get_owner and
put_owner on the lockowner; the put_owner is called from
free_blocked_lock. A successful UNLOCK operation does two
put_owner calls; once from posix_lock_inode and once from
locks_free_lock.

Thus I believe it would be difficult to change fs/locks to count
locks accurately via the lm_get/put_owner API. Even if we could get
the lock counting right today, the API so far is confusing enough to
be vulnerable to breakage by subsequent changes in this area.

Therefore I'm leaning towards the so_count-based approach as shown
in this version of the patch series.

---

Chuck Lever (4):
      NFSD: Fix possible sleep during nfsd4_release_lockowner()
      NFSD: Modernize nfsd4_release_lockowner()
      NFSD: Add documenting comment for nfsd4_release_lockowner()
      NFSD: nfsd_file_put() can sleep


 fs/nfsd/filecache.c |  2 ++
 fs/nfsd/nfs4state.c | 63 ++++++++++++++++++++++-----------------------
 2 files changed, 33 insertions(+), 32 deletions(-)

--
Chuck Lever

