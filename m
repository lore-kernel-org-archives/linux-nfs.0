Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-11.8 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3FBB7C433DB
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Jan 2021 19:41:52 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id F3D1B22AAA
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Jan 2021 19:41:51 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728892AbhASTbw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Jan 2021 14:31:52 -0500
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:60198 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729553AbhASTZk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Jan 2021 14:25:40 -0500
Received: from fieldses.org (fieldses.org [IPv6:2600:3c00:e000:2f7::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 993DBC061757;
        Tue, 19 Jan 2021 11:25:00 -0800 (PST)
Received: by fieldses.org (Postfix, from userid 2815)
        id 719F240CF; Tue, 19 Jan 2021 14:24:59 -0500 (EST)
DKIM-Filter: OpenDKIM Filter v2.11.0 fieldses.org 719F240CF
From:   "J. Bruce Fields" <bfields@redhat.com>
To:     linux-nfs@vger.kernel.org
Cc:     linux-fsdevel@vger.kernel.org,
        Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 0/3] NFS change attribute patches
Date:   Tue, 19 Jan 2021 14:24:54 -0500
Message-Id: <1611084297-27352-1-git-send-email-bfields@redhat.com>
X-Mailer: git-send-email 1.8.3.1
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

These patches move a little more of the change attribute logic into the
filesystems.  They should let us skip a few unnecessary stats, and use
the source filesystem's change attribute in the NFS reexport case.

Do this look reasonable to everyone else?

J. Bruce Fields (3):
  nfs: use change attribute for NFS re-exports
  nfsd: move change attribute generation to filesystem
  nfsd: skip some unnecessary stats in the v4 case

 fs/btrfs/export.c        |  2 ++
 fs/ext4/super.c          |  9 +++++++++
 fs/nfs/export.c          | 18 ++++++++++++++++++
 fs/nfsd/nfs3xdr.c        | 37 ++++++++++++++++++++-----------------
 fs/nfsd/nfsfh.h          | 28 ++++++----------------------
 fs/xfs/xfs_export.c      | 10 ++++++++++
 include/linux/exportfs.h |  1 +
 include/linux/iversion.h | 26 ++++++++++++++++++++++++++
 8 files changed, 92 insertions(+), 39 deletions(-)

-- 
2.29.2

