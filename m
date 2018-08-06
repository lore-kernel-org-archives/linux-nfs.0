Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.cn.fujitsu.com ([183.91.158.132]:24410 "EHLO
        heian.cn.fujitsu.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727730AbeHFLjU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 6 Aug 2018 07:39:20 -0400
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: xuhuan <xuhuan.fnst@cn.fujitsu.com>
Subject: xfstest generci/465 failed under all versions of NFS
Message-ID: <ff080c90-e2e9-686f-9bcd-b6a4af8ac1a0@cn.fujitsu.com>
Date: Mon, 6 Aug 2018 17:29:33 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

hi ,Bruce

I test NFS in xfstest generic/465 useing kernel v4.18-rc6.
I tested it with all version of nfs ,and all got failed.

This patch fixes a bug in the xfs filesystem.Prior to this patch,
generic/465 is failed under the xfs file system.

https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/commit/?id=ee70daaba82d70766d0723b743d9fdeb3b06102a

Now, under the xfs file system, generic/465 is passed, but when I use
it to test NFS, while the server using the xfs file system, the test will still fail.
I think it is a nfs's bug.I donnot know where is it.

Thanks.
Xu


