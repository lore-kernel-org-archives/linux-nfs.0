Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8855CC433F5
	for <linux-nfs@archiver.kernel.org>; Mon, 11 Apr 2022 21:40:39 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1349764AbiDKVmw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 11 Apr 2022 17:42:52 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:36768 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234533AbiDKVmv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Apr 2022 17:42:51 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [145.40.68.75])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id B1C22338AB
        for <linux-nfs@vger.kernel.org>; Mon, 11 Apr 2022 14:40:36 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id 6CE3FB818C6
        for <linux-nfs@vger.kernel.org>; Mon, 11 Apr 2022 21:40:35 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CAD5EC385A4;
        Mon, 11 Apr 2022 21:40:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=k20201202; t=1649713234;
        bh=elS6dc6GUQBfhaA0pDKi1TFZWwfHuopySk7MhCnUjXI=;
        h=From:To:Cc:Subject:Date:From;
        b=XePthzAFCokZgqEqVz+GVq8jiPoNJbY7+yrHyOqOp3u3oV2cbIneXLN/GGZOQJn7V
         0cF8qjTad25fd+hBDjqJQo+/qd+CrIhz0w9UKtJL5wNtY9ZUC5CDsSQx7xJSULw6qN
         Ah0+jt5XQ3MLAfSvWwL0OBuCow0vcnznXoaOVNVp2zQFsRS7yxO+vmkrPD1ptmgxmg
         nzkT8eoBFojEUuuhwWj0gBLoi3okCp0xaGaYzuQSNs/T45nXngphlolqA8jgrRVHsd
         jWOhtu8qBoIWSVv7tb+m8tTsp4OZdKINVYw93pW+QyNAlNmwXQYav4uL0dzR2ML+9g
         JfDDUkNB677bQ==
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Cc:     ChenXiaoSong <chenxiaosong2@huawei.com>,
        Scott Mayhew <smayhew@redhat.com>
Subject: [PATCH v2 0/5] Ensure mapping errors are reported only once
Date:   Mon, 11 Apr 2022 17:33:41 -0400
Message-Id: <20220411213346.762302-1-trondmy@kernel.org>
X-Mailer: git-send-email 2.35.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

The expectation since Linux 4.13 has been that EIO errors are always
reported in fsync(), whether or not it was detected are reported
earlier.
On the other hand, ENOSPC errors are reported as soon as detected, and
should only be reported once.

Trond Myklebust (5):
  NFS: Do not report EINTR/ERESTARTSYS as mapping errors
  NFS: fsync() should report filesystem errors over EINTR/ERESTARTSYS
  NFS: Don't report ENOSPC write errors twice
  NFS: Do not report flush errors in nfs_write_end()
  NFS: Don't report errors from nfs_pageio_complete() more than once

 fs/nfs/file.c  | 49 ++++++++++++++++++++-----------------------------
 fs/nfs/write.c | 11 ++---------
 2 files changed, 22 insertions(+), 38 deletions(-)

-- 
2.35.1

