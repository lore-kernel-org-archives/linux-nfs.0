Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f46.google.com ([209.85.213.46]:36909 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752356Ab3FYBFs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Jun 2013 21:05:48 -0400
Received: by mail-yh0-f46.google.com with SMTP id i57so5340801yha.19
        for <linux-nfs@vger.kernel.org>; Mon, 24 Jun 2013 18:05:47 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 0/2] rpc_pipe: clean up how dentry operations get set in rpc_pipefs
Date: Mon, 24 Jun 2013 21:05:38 -0400
Message-Id: <1372122340-28982-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, I proposed a patch on the linux-nfs list to silence a WARNING:

    [PATCH] rpc_pipefs: only set rpc_dentry_ops if d_op isn't already set

When reviewing that, Bruce (properly) pointed out that that patch sucked
since it just hacked around the warning and did nothing to improve the
code. This patchset is an attempt to correct that by making rpc_pipefs
use a consistent set of dentry_operations, and ensuring that they're set
on every dentry at d_alloc time.

Since Trond has already merged the earlier patch I sent into his
nfs-for-next branch, this is based on top of that.

Jeff Layton (2):
  rpc_pipe: export simple_dentry_operations and have rpc_pipefs use it
  rpc_pipe: set dentry operations at d_alloc time

 fs/libfs.c            |  9 +++++----
 include/linux/fs.h    |  1 +
 net/sunrpc/rpc_pipe.c | 24 +++++++++++++++---------
 3 files changed, 21 insertions(+), 13 deletions(-)

-- 
1.8.1.4

