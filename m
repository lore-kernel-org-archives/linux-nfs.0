Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:36724 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753263AbdBGNpq (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Feb 2017 08:45:46 -0500
Received: by mail-io0-f194.google.com with SMTP id q20so12816791ioi.3
        for <linux-nfs@vger.kernel.org>; Tue, 07 Feb 2017 05:45:46 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH 0/7] Some cleanups and updates for sunrpc
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <59432847-8e45-4423-c441-0c67ee645f38@gmail.com>
Date: Tue, 7 Feb 2017 21:44:31 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The first one is an bugfix of checking register_shrinker's result,
the following sixes are codes cleanup and updates.

Kinglong Mee (7):
  sunrpc: error out if register_shrinker fail
  sunrpc/nfs: cleanup procfs/pipefs entry in cache_detail
  sunrpc: rename NFS_NGROUPS to UNX_NGROUPS for auth unix
  sunrpc: remove dead codes of cr_magic in rpc_cred
  sunrpc: update the comments of sunrpc proc path
  sunrpc: record rpc client pointer in seq->private directly
  sunrpc: use simple_read_from_buffer for reading cache flush

 fs/nfs/cache_lib.c           |  3 +-
 include/linux/sunrpc/auth.h  |  6 +---
 include/linux/sunrpc/cache.h | 15 ++--------
 net/sunrpc/auth.c            |  9 +++---
 net/sunrpc/auth_null.c       |  3 --
 net/sunrpc/auth_unix.c       | 18 ++++++------
 net/sunrpc/cache.c           | 68 ++++++++++++++------------------------------
 net/sunrpc/debugfs.c         | 35 +++++++----------------
 net/sunrpc/svcauth_unix.c    |  4 +--
 9 files changed, 52 insertions(+), 109 deletions(-)

-- 
2.9.3


