Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 376CEC43334
	for <linux-nfs@archiver.kernel.org>; Sun,  5 Jun 2022 19:58:25 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1344175AbiFET6X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 5 Jun 2022 15:58:23 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:59870 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1343714AbiFET6W (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 5 Jun 2022 15:58:22 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [IPv6:2604:1380:4641:c500::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 7C14A49687
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 12:58:21 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 09A8F6118D
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 19:58:21 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 56706C385A5
        for <linux-nfs@vger.kernel.org>; Sun,  5 Jun 2022 19:58:20 +0000 (UTC)
Subject: [PATCH v1 0/5] Fix NFSv3 READDIRPLUS failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Sun, 05 Jun 2022 15:58:19 -0400
Message-ID: <165445865736.1664.4497130284832282034.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While looking into the filecache CPU soft lock-up issue, I ran
across this problem. I thought I could run it down in just an
afternoon (I was wrong) and that this problem probably affects more
users than the soft lock-up (jury's still out).

Anyway, NFSD's new READDIRPLUS dirent encoder blows past the end of
the directory payload xdr_stream when the client requests more than
a page worth of directory entries. I tracked this down to how
xdr_get_next_encode_buffer() computes xdr->end. First patch in this
series is the fix. The remaining patches are clean-ups and
optimizations.

I want to get this into 5.19-rc quickly. I would appreciate getting
at least two R-b's for this series.

---

Chuck Lever (5):
      SUNRPC: Fix the calculation of xdr->end in xdr_get_next_encode_buffer()
      SUNRPC: Optimize xdr_reserve_space()
      SUNRPC: Clean up xdr_commit_encode()
      SUNRPC: Clean up xdr_get_next_encode_buffer()
      SUNRPC: Remove pointer type casts from xdr_get_next_encode_buffer()


 net/sunrpc/xdr.c | 31 ++++++++++++++++++++++---------
 1 file changed, 22 insertions(+), 9 deletions(-)

--
Chuck Lever

