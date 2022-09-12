Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AF7C3C6FA83
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Sep 2022 21:22:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229718AbiILVWd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Sep 2022 17:22:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:52062 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229696AbiILVWc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2022 17:22:32 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8E7C14B0F4
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 14:22:30 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 353D5B80DF2
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:22:29 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA689C433D6
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2022 21:22:27 +0000 (UTC)
Subject: [PATCH v1 00/12] Short NFSD clean-ups
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Mon, 12 Sep 2022 17:22:27 -0400
Message-ID: <166301759113.89884.7985359396842428444.stgit@oracle-102.nfsv4.dev>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This is a set of clean-up patches and minor optimizations for NFSD.
I happened upon these unrelated changes while addressing recent
bugs.

---

Chuck Lever (12):
      SUNRPC: Optimize svc_process()
      SUNRPC: Parametrize how much of argsize should be zeroed
      NFSD: Reduce amount of struct nfsd4_compoundargs that needs clearing
      SUNRPC: Clarify comment that documents svc_max_payload()
      NFSD: Refactor common code out of dirlist helpers
      NFSD: Use xdr_inline_decode() to decode NFSv3 symlinks
      NFSD: Clean up WRITE arg decoders
      SUNRPC: Fix typo in xdr_buf_subsegment's kdoc comment
      NFSD: Clean up nfs4svc_encode_compoundres()
      NFSD: Remove "inline" directives on op_rsize_bop helpers
      NFSD: Remove unused nfsd4_compoundargs::cachetype field
      NFSD: Pack struct nfsd4_compoundres


 fs/lockd/svc4proc.c        |  24 ++++++++
 fs/lockd/svcproc.c         |  24 ++++++++
 fs/nfs/callback_xdr.c      |   1 +
 fs/nfsd/nfs2acl.c          |   5 ++
 fs/nfsd/nfs3acl.c          |   3 +
 fs/nfsd/nfs3proc.c         |  32 +++++++---
 fs/nfsd/nfs3xdr.c          |  18 ++----
 fs/nfsd/nfs4proc.c         | 123 +++++++++++++++++++++++--------------
 fs/nfsd/nfs4xdr.c          |  65 +++++++++++++++-----
 fs/nfsd/nfsproc.c          |  28 ++++++---
 fs/nfsd/nfsxdr.c           |   4 +-
 fs/nfsd/xdr4.h             |   6 +-
 include/linux/sunrpc/svc.h |   1 +
 include/linux/sunrpc/xdr.h |   2 +
 net/sunrpc/svc.c           |  34 +++++-----
 net/sunrpc/xdr.c           |  24 +++++++-
 16 files changed, 278 insertions(+), 116 deletions(-)

--
Chuck Lever

