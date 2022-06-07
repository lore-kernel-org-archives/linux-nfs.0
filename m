Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31CCFCCA48A
	for <linux-nfs@archiver.kernel.org>; Wed,  8 Jun 2022 00:55:55 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1349992AbiFHAsu (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 7 Jun 2022 20:48:50 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:48748 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1449927AbiFGXKg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jun 2022 19:10:36 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 9C10138DD20
        for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2022 13:47:48 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id D295161648
        for <linux-nfs@vger.kernel.org>; Tue,  7 Jun 2022 20:47:47 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3C5FC385A2;
        Tue,  7 Jun 2022 20:47:46 +0000 (UTC)
Subject: [PATCH v2 0/5] Fix NFSv3 READDIRPLUS failures
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     trondmy@hammerspace.com, anna.schumaker@netapp.com
Date:   Tue, 07 Jun 2022 16:47:45 -0400
Message-ID: <165463444560.38298.18296069287423675496.stgit@bazille.1015granger.net>
User-Agent: StGit/1.5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

NFSD's new READDIRPLUS dirent encoder blows past the end of the
directory payload xdr_stream when the client requests more than a
page worth of directory entries. I tracked this down to how
xdr_get_next_encode_buffer() computes xdr->end. First patch in this
series is the fix. The remaining patches are clean-ups and
optimizations.

I want to get this series into 5.19-rc quickly. I would appreciate
getting one more R-b for this series, preferrably from one of the
NFS client maintainers.


Changes since v1:
- Adjusted patch 2/5 per Neil Brown's suggestion
- Series applied to my NFS client and tested there

---

Chuck Lever (5):
      SUNRPC: Fix the calculation of xdr->end in xdr_get_next_encode_buffer()
      SUNRPC: Optimize xdr_reserve_space()
      SUNRPC: Clean up xdr_commit_encode()
      SUNRPC: Clean up xdr_get_next_encode_buffer()
      SUNRPC: Remove pointer type casts from xdr_get_next_encode_buffer()


 include/linux/sunrpc/xdr.h | 16 +++++++++++++++-
 net/sunrpc/xdr.c           | 37 +++++++++++++++++++++++--------------
 2 files changed, 38 insertions(+), 15 deletions(-)

--
Chuck Lever

