Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3576EECAAA2
	for <linux-nfs@archiver.kernel.org>; Sun, 28 Aug 2022 18:50:21 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229819AbiH1SuT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 28 Aug 2022 14:50:19 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36170 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S229547AbiH1SuT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 28 Aug 2022 14:50:19 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id C5A5265E1
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 11:50:17 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 6263360DE7
        for <linux-nfs@vger.kernel.org>; Sun, 28 Aug 2022 18:50:17 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 987E7C433D6;
        Sun, 28 Aug 2022 18:50:16 +0000 (UTC)
Subject: [PATCH v2 0/7] Fixes for server-side xdr_stream overhaul
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 28 Aug 2022 14:50:15 -0400
Message-ID: <166171174172.21449.5036120183381273656.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've gotten push-back on the idea of rejecting RPC messages where
the RPC record size is larger than the RPC message itself. Therefore
that concept has been dropped from this series.

I've now been able to reproduce, exactly as it was described, a
recently-reported problem with READDIR handling. I've fixed that and
also determined that no other legacy NFS operations appear to be
vulnerable to this particular issue (within the Linux NFS server).


Changes since v1:
- Dropped the xdr_buf_length() helper
- Replaced 7/7 with patch that cleans up an unneeded use of xdr_buf::len
- Dropped the checks for oversized RPC records
- Fixed narrow problem with NFSv2 and NFSv3 READDIR processing

---

Chuck Lever (7):
      SUNRPC: Fix svcxdr_init_decode's end-of-buffer calculation
      SUNRPC: Fix svcxdr_init_encode's buflen calculation
      NFSD: Protect against READDIR send buffer overflow
      NFSD: Use xdr_inline_decode() to decode NFSv3 symlinks
      NFSD: Clean up WRITE arg decoders
      SUNRPC: Fix typo in xdr_buf_subsegment's kdoc comment
      NFSD: Clean up nfs4svc_encode_compoundres()


 fs/nfsd/nfs3proc.c         |  5 ++---
 fs/nfsd/nfs3xdr.c          | 18 ++++--------------
 fs/nfsd/nfs4xdr.c          |  4 ----
 fs/nfsd/nfsproc.c          |  5 ++---
 fs/nfsd/nfsxdr.c           |  4 +---
 include/linux/sunrpc/svc.h | 19 +++++++++++++++----
 net/sunrpc/xdr.c           |  2 +-
 7 files changed, 25 insertions(+), 32 deletions(-)

--
Chuck Lever

