Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f66.google.com ([209.85.213.66]:38800 "EHLO
        mail-vk0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751546AbdLDTD4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Dec 2017 14:03:56 -0500
From: Thiago Rafael Becker <thiago.becker@gmail.com>
To: bfields@fieldses.org, neilb@suse.com
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Thiago Rafael Becker <thiago.becker@gmail.com>
Subject: [PATCH 0/3, v3] Move groups_sort outisde of set_groups
Date: Mon,  4 Dec 2017 17:03:21 -0200
Message-Id: <20171204190324.6629-1-thiago.becker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases where group_info is cached (e.g. sunrpc), multiplpe
threads may call set_groups with a freshly created group_info
cache (e.g. nfsd), and attempt to sort them simultaneously,
which configures a race condition that can overwrite some
groups in the cache and lead to errors. In the case of nfsd,
the client was receiving EPERM if the group used to provide
authorization was overwritten by this race condition.

In an email exchange with bfields, we agreed that it seems
unintuitive that the groups are sorted on set_groups, and that
it would be better to move the responsibility of sorting to
the caller of set_groups.

These patches:
 - Export groups_sort in include/linux/cred.h
 - Add a call to groups_sort after the groups are inserted in
   group_info
 - Remove the call to sort_groups from set_groups

Thiago Rafael Becker (3):
  kernel: make groups_sort globally visible
  kernel: Move groups_sort to the caller of set_groups.
  kernel: set_groups doesn't call groups_sort anymore.

 include/linux/cred.h      | 1 +
 kernel/groups.c           | 6 ++++--
 kernel/uid16.c            | 1 +
 net/sunrpc/svcauth_unix.c | 7 +++++++
 4 files changed, 13 insertions(+), 2 deletions(-)

-- 
2.9.5

