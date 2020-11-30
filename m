Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-15.5 required=3.0 tests=BAYES_00,DKIMWL_WL_HIGH,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E5D31C64E8A
	for <linux-nfs@archiver.kernel.org>; Mon, 30 Nov 2020 21:25:56 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by mail.kernel.org (Postfix) with ESMTP id 69E4620857
	for <linux-nfs@archiver.kernel.org>; Mon, 30 Nov 2020 21:25:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="0xOpJiuO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388605AbgK3VZl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 30 Nov 2020 16:25:41 -0500
Received: from mail.kernel.org ([198.145.29.99]:42034 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2388485AbgK3VZl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 30 Nov 2020 16:25:41 -0500
Received: from leira.hammer.space (c-68-36-133-222.hsd1.mi.comcast.net [68.36.133.222])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 1D8752073C;
        Mon, 30 Nov 2020 21:25:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1606771500;
        bh=DASzqT4kAQ29qrK+viNs/MSa3um7C+aF4y4dk50+yb0=;
        h=From:To:Cc:Subject:Date:From;
        b=0xOpJiuOguOLcPnHEggju6cEyvF/sTTWJO4ojFXv+yPpqArmvFi1FzXYGX0R+V4hE
         QPI7mSVtVziDaCqvCeHUpvCb8VaUjpfSp4Nq8zrAB6XikQ50H0GIDWNv6/X9+GEBqM
         /YHL1llhrL/gpcVaY9s+jd12nRGydFVBnBXpf/7E=
From:   trondmy@kernel.org
To:     "J. Bruce Fields" <bfields@redhat.com>,
        Chuck Lever <chuck.lever@oracle.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] Patches to support NFS re-exporting
Date:   Mon, 30 Nov 2020 16:24:49 -0500
Message-Id: <20201130212455.254469-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.28.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

These patches fix a number of issues that Hammerspace has hit when doing
re-exporting of NFS.

Jeff Layton (3):
  nfsd: add a new EXPORT_OP_NOWCC flag to struct export_operations
  nfsd: allow filesystems to opt out of subtree checking
  nfsd: close cached files prior to a REMOVE or RENAME that would
    replace target

Trond Myklebust (3):
  exportfs: Add a function to return the raw output from fh_to_dentry()
  nfsd: Fix up nfsd to ensure that timeout errors don't result in ESTALE
  nfsd: Set PF_LOCAL_THROTTLE on local filesystems only

 Documentation/filesystems/nfs/exporting.rst | 52 +++++++++++++++++++++
 fs/exportfs/expfs.c                         | 32 +++++++++----
 fs/nfs/export.c                             |  2 +
 fs/nfsd/export.c                            |  6 +++
 fs/nfsd/nfs3xdr.c                           |  7 ++-
 fs/nfsd/nfsfh.c                             | 30 ++++++++++--
 fs/nfsd/nfsfh.h                             |  2 +-
 fs/nfsd/vfs.c                               | 29 ++++++++----
 include/linux/exportfs.h                    | 10 ++++
 9 files changed, 146 insertions(+), 24 deletions(-)

-- 
2.28.0

