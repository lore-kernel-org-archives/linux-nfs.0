Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24250C433F5
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Feb 2022 22:23:14 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1386232AbiBHWXI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Feb 2022 17:23:08 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46016 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1387065AbiBHVwh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Feb 2022 16:52:37 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 621E0C0612BC;
        Tue,  8 Feb 2022 13:52:37 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id EB51A61626;
        Tue,  8 Feb 2022 21:52:36 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 17F54C004E1;
        Tue,  8 Feb 2022 21:52:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1644357156;
        bh=PNKEwm3u3qaphqcUfnN5Rn9BnqIaKAN9u5zK4UEZcG8=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=Nwm3nIHNGtSDa0xGGHTizO5yZQ9gz3c4msKmGTkm/lrFNR8QeDDBffdrJpSqzfFns
         llCxH7oV4j17JzMuSAJFra3uOJI7wRAQyIJEMRSthOnv6Xqe9FLhTle9S4Rxkznsk8
         Zo6oNAgD3Rd9Nib3tHdDCLoNZpXWa3a2jKndt/1FA8AlJ9NIFppHEsAnXTjvVVeeW9
         MOuaPlW3fNrX2mZcvTuX7do4ebaXpVwoIoaL2uZ96FDSN96h/WPnH1UpsOx7rpUaeY
         qkHDC92I4nWpGz1p5qGCqC2kvpdHVaFR4bWxBQrLuLiNnU+NmoE4WtWh/kQ3CNhvcO
         rCcH/B6Nk+8EA==
From:   Anna Schumaker <anna@kernel.org>
To:     fstests@vger.kernel.org
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/4] generic/531: Move test from 'quick' group to 'stress'
Date:   Tue,  8 Feb 2022 16:52:30 -0500
Message-Id: <20220208215232.491780-3-anna@kernel.org>
X-Mailer: git-send-email 2.35.1
In-Reply-To: <20220208215232.491780-1-anna@kernel.org>
References: <20220208215232.491780-1-anna@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Anna Schumaker <Anna.Schumaker@Netapp.com>

The comment up top says this is a stress test, so at the very least it
should be added to this group. As for removing it from the quick group,
making this test variable on the number of CPUs means this test could
take a very long time to finish (I'm unsure exactly how long on NFS v4.1
because I usually kill it after a half hour or so)

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
I have thought of two alternatives to this patch that would work for me:
  1) Could we add an _unsupported_fs function which is the opposite of
     _supported_fs to prevent tests from running on specific filesystems?
  2) Would it be okay to check if $FSTYP == "nfs" when setting nr_cpus,
     and set it to 1 instead? Perhaps through a function in common/rc
     that other tests can use if they scale work based on cpu-count?
---
 tests/generic/531 | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tests/generic/531 b/tests/generic/531
index 5e84ca977b44..62e3cac92423 100755
--- a/tests/generic/531
+++ b/tests/generic/531
@@ -12,7 +12,7 @@
 # Use every CPU possible to stress the filesystem.
 #
 . ./common/preamble
-_begin_fstest auto quick unlink
+_begin_fstest auto stress unlink
 testfile=$TEST_DIR/$seq.txt
 
 # Import common functions.
-- 
2.35.1

