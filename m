Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D65BC19F28
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Aug 2022 14:37:34 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S237518AbiHCOhd (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Aug 2022 10:37:33 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55490 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S235945AbiHCOhc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2022 10:37:32 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id D807019C27
        for <linux-nfs@vger.kernel.org>; Wed,  3 Aug 2022 07:37:30 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 81DA6B82264
        for <linux-nfs@vger.kernel.org>; Wed,  3 Aug 2022 14:37:29 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12442C433C1;
        Wed,  3 Aug 2022 14:37:27 +0000 (UTC)
Subject: [PATCH v2 0/3] Wait for DELEGRETURN before returning NFS4ERR_DELAY
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     imammedo@redhat.com
Date:   Wed, 03 Aug 2022 10:37:26 -0400
Message-ID: <165953688893.1658.15242150042289528147.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This RFC series adds logic to the Linux NFS server to make it wait a
few moments for clients to return a delegation before replying with
NFS4ERR_DELAY. There are two main benefits:

- This improves responsiveness when a delegated file is accessed
  from another client
- This removes an unnecessary latency if a client has neglected to
  return a delegation before attempting a RENAME or SETATTR

This series is incomplete:
- There are likely other operations that can benefit (eg. OPEN)
- The wait is a fixed 30ms delay; it would be better if the server
  could match an incoming CB_RECALL reply with waiters so they can
  proceed immediately, but I am still figuring out how that can be
  done

Changes since RFC:
- Eliminate spurious console messages on the server
- Wait for DELEGRETURN for RENAME operations
- Add CB done tracepoints
- Rework the retry loop

---

Chuck Lever (3):
      NFSD: Add tracepoints to report NFSv4 callback completions
      NFSD: Make nfsd4_setattr() wait before returning NFS4ERR_DELAY
      NFSD: Make nfsd4_rename() wait before returning NFS4ERR_DELAY


 fs/nfsd/nfs4layouts.c |  2 +-
 fs/nfsd/nfs4proc.c    | 52 ++++++++++++++++++++++++++++++--------
 fs/nfsd/nfs4state.c   | 21 ++++++++++++++++
 fs/nfsd/nfsd.h        |  1 +
 fs/nfsd/trace.h       | 58 +++++++++++++++++++++++++++++++++++++++++++
 fs/nfsd/xdr4.h        |  2 ++
 6 files changed, 124 insertions(+), 12 deletions(-)

--
Chuck Lever

