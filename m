Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EF11AC43334
	for <linux-nfs@archiver.kernel.org>; Tue, 21 Jun 2022 14:06:18 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S229626AbiFUOGR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 21 Jun 2022 10:06:17 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:54336 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1350518AbiFUOGR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2022 10:06:17 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 0EECE186E2
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2022 07:06:14 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id C14B9B8180B
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2022 14:06:12 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6DBBFC3411C
        for <linux-nfs@vger.kernel.org>; Tue, 21 Jun 2022 14:06:11 +0000 (UTC)
Subject: [PATCH 0/2] NFSD: Two tracepoint-related patches
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Tue, 21 Jun 2022 10:06:10 -0400
Message-ID: <165582017204.1716.2642742597692008742.stgit@klimt.1015granger.net>
User-Agent: StGit/1.5.dev3+g9561319
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Fodder for the next merge window. Comments welcome.

I plan to review Neil's directory parallelism patches very soon.
I'll post the filecache overhaul series once the rhashtable patches
are working well.

---

Chuck Lever (2):
      SUNRPC: Expand the svc_alloc_arg_err tracepoint
      NFSD: Instrument fh_verify()


 fs/nfsd/nfsfh.c               |  5 ++--
 fs/nfsd/trace.h               | 46 +++++++++++++++++++++++++++++++++++
 include/trace/events/sunrpc.h | 14 +++++++----
 net/sunrpc/svc_xprt.c         |  2 +-
 4 files changed, 59 insertions(+), 8 deletions(-)

--
Chuck Lever

