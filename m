Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga02-in.huawei.com ([119.145.14.65]:64580 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932121Ab3JNM20 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Oct 2013 08:28:26 -0400
From: Kefeng Wang <wangkefeng.wang@huawei.com>
To: Alexander Viro <viro@zeniv.linux.org.uk>
CC: John McCutchan <john@johnmccutchan.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Eric Paris <eparis@redhat.com>, Robert Love <rlove@rlove.org>,
        <linux-kernel@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH 0/3] fs: use helper function path_foo() to simpily code
Date: Mon, 14 Oct 2013 20:25:59 +0800
Message-ID: <1381753562-47884-1-git-send-email-wangkefeng.wang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use helper function patch_equal() and path_put() to simpily code.

Kefeng Wang (3):
  fs: use path_equal() and path_put() to simplify code
  fs: nfsd: use path_equal() to simply code
  fs: notify: use path_equal() to simply code

 fs/namei.c                           | 20 ++++++--------------
 fs/nfsd/export.c                     |  3 +--
 fs/nfsd/nfs4xdr.c                    |  2 +-
 fs/notify/fanotify/fanotify.c        |  3 +--
 fs/notify/inotify/inotify_fsnotify.c |  3 +--
 5 files changed, 10 insertions(+), 21 deletions(-)

-- 
1.8.2.1


