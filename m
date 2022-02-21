Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 073A5C4332F
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Feb 2022 16:16:08 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1379978AbiBUQPY (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 21 Feb 2022 11:15:24 -0500
Received: from mxb-00190b01.gslb.pphosted.com ([23.128.96.19]:40020 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1379977AbiBUQPY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Feb 2022 11:15:24 -0500
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 61E5F23BD4
        for <linux-nfs@vger.kernel.org>; Mon, 21 Feb 2022 08:15:00 -0800 (PST)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id DC6F861295
        for <linux-nfs@vger.kernel.org>; Mon, 21 Feb 2022 16:14:59 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BEDBC340E9
        for <linux-nfs@vger.kernel.org>; Mon, 21 Feb 2022 16:14:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1645460099;
        bh=LOLPvtUD+EhS7T1c0wX7yUcN9uOBW4TN6vov7vzKi7U=;
        h=From:To:Subject:Date:From;
        b=oeJKwQgRbHSZn4cQpKxXzq+ME+y1Oj2+PQvQdrioarcHLq0oL/M+bdpI7sSq7cPds
         g1cIzV0Zv37ueLljSMrk9L31qYAwEA2P7rONw8bywTODlSXduOcwuqVK9K9QeJZ6gL
         I+E0O5wwXKruMP7/qBLcj8TPmEc7e7IorHR2bXNnpVxiDIR/9OACbge/SdW2LKqSQJ
         5uAy0VYSCa+wUg2nJwRJ6BWPD7xsUbOHOFPBIXsx2BXNJLms29WNuxWKcrqaQmhLwG
         jGf2LWQxGOdFlVyLzivz30vM97D+qXMaKANavS7DsucCHSYx6Jk9CJTyCvOiVsEn1Y
         BRfcBbXZ3liHw==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v6 00/13] Readdir improvements
Date:   Mon, 21 Feb 2022 11:08:38 -0500
Message-Id: <20220221160851.15508-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.35.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The current NFS readdir code will always try to maximise the amount of
readahead it performs on the assumption that we can cache anything that
isn't immediately read by the process.
There are several cases where this assumption breaks down, including
when the 'ls -l' heuristic kicks in to try to force use of readdirplus
as a batch replacement for lookup/getattr.

--
v2: Remove reset of dtsize when NFS_INO_FORCE_READDIR is set
v3: Avoid excessive window shrinking in uncached_readdir case
v4: Track 'ls -l' cache hit/miss statistics
    Improved algorithm for falling back to uncached readdir
    Skip readdirplus when files are being written to
v5: bugfixes
    Skip readdirplus when the acdirmax/acregmax values are low
    Request a full XDR buffer when doing READDIRPLUS
v6: Add tracing
    Don't have lookup request readdirplus when it won't help

Trond Myklebust (13):
  NFS: constify nfs_server_capable() and nfs_have_writebacks()
  NFS: Trace lookup revalidation failure
  NFS: Adjust the amount of readahead performed by NFS readdir
  NFS: Simplify nfs_readdir_xdr_to_array()
  NFS: Improve algorithm for falling back to uncached readdir
  NFS: Improve heuristic for readdirplus
  NFS: Don't ask for readdirplus unless it can help nfs_getattr()
  NFSv4: Ask for a full XDR buffer of readdir goodness
  NFS: Readdirplus can't help lookup for case insensitive filesystems
  NFS: Don't request readdirplus when revaldation was forced
  NFS: Add basic readdir tracing
  NFS: Trace effects of readdirplus on the dcache
  NFS: Trace effects of the readdirplus heuristic

 fs/nfs/dir.c           | 275 +++++++++++++++++++++++++++--------------
 fs/nfs/inode.c         |  37 +++---
 fs/nfs/internal.h      |   4 +-
 fs/nfs/nfs3xdr.c       |   7 +-
 fs/nfs/nfs4xdr.c       |   6 +-
 fs/nfs/nfstrace.h      | 122 +++++++++++++++++-
 include/linux/nfs_fs.h |  14 ++-
 7 files changed, 339 insertions(+), 126 deletions(-)

-- 
2.35.1

